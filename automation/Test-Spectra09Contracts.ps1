[CmdletBinding()]param()
$ErrorActionPreference='Stop'
$base=Join-Path ([IO.Path]::GetTempPath()) ('spectra-09-positive-'+[guid]::NewGuid().ToString('N'))
try{
  New-Item -ItemType Directory -Force $base|Out-Null
  foreach($profile in @('implementation','support-only')){
    $workspace=Join-Path $base $profile
    & (Join-Path $PSScriptRoot 'New-SyntheticSpectra09Profile.ps1') -Destination $workspace -Profile $profile|Out-Null
    & (Join-Path $PSScriptRoot 'Test-SyntheticSpectra09Profile.ps1') -Path $workspace|Out-Null
    foreach($command in @('validate-reconciliation','validate-provenance')){
      $result=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command $command -Workspace $workspace|ConvertFrom-Json
      if($result.status -ne 'VALIDATED' -or $result.writes_performed -ne $false){throw "SPECTRA09_CLI_RESULT_INVALID:$command"}
      $applyAccepted=$true;try{& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command $command -Workspace $workspace -Apply|Out-Null}catch{$applyAccepted=$false}
      if($applyAccepted){throw "SPECTRA09_READONLY_APPLY_ACCEPTED:$command"}
    }
  }
  Write-Host 'PASS: Beide isolierten Spectra-0.9-Profile und read-only CLI-Routen sind gültig.'
}finally{if(Test-Path $base){Remove-Item $base -Recurse -Force -ErrorAction SilentlyContinue}}
