[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Workspace)
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath($Workspace)
$recordPath=Join-Path $root 'reconciliation\project-reconciliation.json'
if(-not(Test-Path $recordPath -PathType Leaf)){throw 'RECONCILIATION_RECORD_MISSING'}
$record=Get-Content $recordPath -Raw|ConvertFrom-Json
$schema=Get-Content (Join-Path $PSScriptRoot '..\schemas\project-reconciliation.schema.json') -Raw|ConvertFrom-Json
. (Join-Path $PSScriptRoot 'Spectra.JsonSchema.ps1')
try{Test-SpectraJsonSchema -Value $record -Schema $schema -RootSchema $schema}catch{if($_.Exception.Message -like 'SPECTRA_SCHEMA_*'){throw 'RECONCILIATION_SCHEMA_INVALID'};throw}

function Test-Amount($State,[string]$Code){
  if([decimal]$State.amount -ne ([decimal]$State.hours * [decimal]$State.rate)){throw $Code}
}
Test-Amount $record.baseline 'RECONCILIATION_BASELINE_AMOUNT_MISMATCH'
Test-Amount $record.offer 'RECONCILIATION_OFFER_AMOUNT_MISMATCH'
Test-Amount $record.actual 'RECONCILIATION_ACTUAL_AMOUNT_MISMATCH'
if($record.baseline.currency -ne $record.offer.currency -or $record.offer.currency -ne $record.actual.currency){throw 'RECONCILIATION_CURRENCY_MISMATCH'}
if([decimal]$record.variance.hours -ne ([decimal]$record.actual.hours-[decimal]$record.offer.hours) -or
   [decimal]$record.variance.rate -ne ([decimal]$record.actual.rate-[decimal]$record.offer.rate) -or
   [decimal]$record.variance.amount -ne ([decimal]$record.actual.amount-[decimal]$record.offer.amount)){throw 'RECONCILIATION_VARIANCE_MISMATCH'}
$hasVariance=([decimal]$record.variance.hours -ne 0 -or [decimal]$record.variance.rate -ne 0 -or [decimal]$record.variance.amount -ne 0)
if($hasVariance -and ($record.variance.reason_code -eq 'none' -or [string]::IsNullOrWhiteSpace([string]$record.variance.reason))){throw 'RECONCILIATION_VARIANCE_REASON_REQUIRED'}
if(($record.classification -eq 'synthetic-fixture' -and ($record.synthetic -ne $true -or $record.truth_boundary.owner -ne 'synthetic-fixture' -or $record.truth_boundary.source_of_truth -ne 'synthetic-fixture' -or $record.truth_boundary.billing_status -ne 'not-applicable')) -or
   ($record.classification -eq 'customer-workspace' -and ($record.synthetic -ne $false -or $record.truth_boundary.owner -ne 'customer' -or $record.truth_boundary.source_of_truth -ne 'customer-workspace')) -or
   $record.truth_boundary.invoice_claim -ne $false -or $record.truth_boundary.productive_activity_claim -ne $false){throw 'RECONCILIATION_TRUTH_BOUNDARY_INVALID'}
Write-Host 'PASS: Versionierter Baseline-Angebot-Ist-Abgleich ist konsistent und nicht abrechnungsbehauptend.'
