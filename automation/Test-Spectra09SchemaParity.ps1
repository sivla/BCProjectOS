[CmdletBinding()]param()
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$contracts=@(
  @{schema='schemas/project-reconciliation.schema.json';validator='automation/Test-ProjectReconciliation.ps1';required=@('schema_version','contract_version','record_type','reconciliation_id','product_id','profile','classification','synthetic','baseline','offer','actual','variance','truth_boundary');defs=@{financial_state=@('version','hours','rate','amount','currency');variance=@('hours','rate','amount','reason_code','reason');truth_boundary=@('owner','source_of_truth','invoice_claim','productive_activity_claim','billing_status')}},
  @{schema='schemas/adapter-provenance.schema.json';validator='automation/Test-AdapterProvenance.ps1';required=@('schema_version','contract_version','record_type','provenance_id','product_id','profile','classification','synthetic','source','mapping','projection','source_of_truth','write_protection');defs=@{source=@('blob_path','source_hash','source_hash_after','media_type');mapping=@('mapping_id','mapping_version','deterministic');projection=@('projection_path','digest_algorithm','projection_digest');source_of_truth=@('owner','unchanged');write_protection=@('source_mode','writes_performed','projection_only','overwrite_allowed')}}
)
foreach($contract in $contracts){
  $schemaPath=Join-Path $root $contract.schema;$validatorPath=Join-Path $root $contract.validator
  $schema=Get-Content $schemaPath -Raw|ConvertFrom-Json
  if(@(Compare-Object @($schema.required|Sort-Object) @($contract.required|Sort-Object)).Count -gt 0 -or $schema.additionalProperties -ne $false){throw "SPECTRA09_SCHEMA_ROOT_PARITY_INVALID:$($contract.schema)"}
  foreach($definition in $contract.defs.Keys){$actual=@($schema.'$defs'.$definition.required|Sort-Object);$expected=@($contract.defs[$definition]|Sort-Object);if(@(Compare-Object $actual $expected).Count -gt 0 -or $schema.'$defs'.$definition.additionalProperties -ne $false){throw "SPECTRA09_SCHEMA_DEF_PARITY_INVALID:$definition"}}
  $validatorText=Get-Content $validatorPath -Raw
  if($validatorText -notmatch [regex]::Escape((Split-Path $contract.schema -Leaf)) -or $validatorText -notmatch 'Test-SpectraJsonSchema'){throw "SPECTRA09_VALIDATOR_ROUTE_MISSING:$($contract.validator)"}
}
$cli=Get-Content (Join-Path $root 'automation\Invoke-Spectra.ps1') -Raw
foreach($command in @('validate-reconciliation','validate-provenance')){if($cli -notmatch [regex]::Escape($command)){throw "SPECTRA09_CLI_ROUTE_MISSING:$command"}}
Write-Host 'PASS: Spectra-0.9-Schemas, geschlossene Felder und Validator-/CLI-Routen sind paritätisch.'
