[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$temp=Join-Path ([IO.Path]::GetTempPath()) ('spectra-engagement-contract-'+[guid]::NewGuid().ToString('N'))
try{
  $a=Join-Path $temp 'a';$b=Join-Path $temp 'b'
  & (Join-Path $PSScriptRoot 'New-SyntheticEngagementFitStandard.ps1') -Destination $a|Out-Null
  & (Join-Path $PSScriptRoot 'New-SyntheticEngagementFitStandard.ps1') -Destination $b|Out-Null
  $aHash=(Get-FileHash (Join-Path $a 'engagement-fit-standard.json') -Algorithm SHA256).Hash
  $bHash=(Get-FileHash (Join-Path $b 'engagement-fit-standard.json') -Algorithm SHA256).Hash
  if($aHash-ne$bHash){throw 'ENGAGEMENT_GENERATOR_NOT_DETERMINISTIC'}
  $before=$aHash
  & (Join-Path $PSScriptRoot 'Test-EngagementFitStandard.ps1') -Path $a|Out-Null
  if((Get-FileHash (Join-Path $a 'engagement-fit-standard.json') -Algorithm SHA256).Hash-ne$before){throw 'ENGAGEMENT_VALIDATOR_MUTATED_SOURCE'}
  $cli=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command validate-engagement-fit-standard -Workspace $a|ConvertFrom-Json
  if($cli.status-ne'VALIDATED'-or$cli.writes_performed-ne$false-or$cli.delegate-ne'Test-EngagementFitStandard.ps1'){throw 'ENGAGEMENT_CLI_DELEGATION_INVALID'}
  if(-not(Test-Path (Join-Path $root 'schemas\engagement-fit-standard.schema.json') -PathType Leaf)){throw 'ENGAGEMENT_SCHEMA_MISSING'}
  Write-Host 'PASS: Deterministischer Engagement-Vertrag, read-only Validator und CLI-Route.'
}finally{if(Test-Path $temp){Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue}}
