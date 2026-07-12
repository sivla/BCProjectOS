[CmdletBinding()]param()
$ErrorActionPreference='Stop'
$base=Join-Path ([IO.Path]::GetTempPath()) ('spectra-graph-coverage-positive-'+[guid]::NewGuid().ToString('N'))
$story=Join-Path ([IO.Path]::GetTempPath()) ('spectra-graph-coverage-story-'+[guid]::NewGuid().ToString('N'))
try{
  & (Join-Path $PSScriptRoot 'New-SyntheticReferenceGraphCoverage.ps1') -Destination $base|Out-Null
  & (Join-Path $PSScriptRoot 'Test-ReferenceGraphCoverage.ps1') -Path $base|Out-Null
  $cli=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command validate-graph-coverage -Workspace $base|ConvertFrom-Json
  if($cli.status -ne 'VALIDATED' -or $cli.writes_performed -ne $false -or $cli.delegate -ne 'Test-ReferenceGraphCoverage.ps1'){throw 'GRAPH_COVERAGE_CLI_INTEGRATION_FAILED'}
  & (Join-Path $PSScriptRoot 'New-PortableProjectStoryFixture.ps1') -Destination $story|Out-Null
  & (Join-Path $PSScriptRoot 'Invoke-PortableFullConformance.ps1') -Path $story -CoveragePath $base
  Write-Host 'PASS: Positives Coverage-Fixture, read-only Validator und CLI-Route.'
}finally{foreach($path in @($base,$story)){if(Test-Path $path){Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue}}}
