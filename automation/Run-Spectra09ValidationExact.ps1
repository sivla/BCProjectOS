[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][ValidateSet('reconciliation','provenance','profile')][string]$Validator,
  [Parameter(Mandatory=$true)][string]$Path
)
$ErrorActionPreference='Stop'
try{
  switch($Validator){
    'reconciliation'{& (Join-Path $PSScriptRoot 'Test-ProjectReconciliation.ps1') -Workspace $Path|Out-Null}
    'provenance'{& (Join-Path $PSScriptRoot 'Test-AdapterProvenance.ps1') -Workspace $Path|Out-Null}
    'profile'{& (Join-Path $PSScriptRoot 'Test-SyntheticSpectra09Profile.ps1') -Path $Path|Out-Null}
  }
  Write-Output 'PASS'
  exit 0
}catch{
  Write-Output $_.Exception.Message
  exit 1
}
