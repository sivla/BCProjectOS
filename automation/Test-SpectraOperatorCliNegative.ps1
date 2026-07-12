$ErrorActionPreference='Stop'
$temp=Join-Path ([IO.Path]::GetTempPath()) ('spectra-cli-neg-'+[guid]::NewGuid().ToString('N'))
try{
  New-Item -ItemType Directory -Force $temp|Out-Null
  $failed=$false
  try{& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command validate -Workspace $temp -Apply|Out-Null}catch{$failed=$_.Exception.Message -match 'SPECTRA_APPLY_NOT_SUPPORTED'}
  if(-not $failed){throw 'SPECTRA_NEGATIVE_APPLY_ACCEPTED'}
  $failed=$false
  try{& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace ([IO.Path]::GetPathRoot($temp))|Out-Null}catch{$failed=$_.Exception.Message -match 'SPECTRA_PATH_UNSAFE'}
  if(-not $failed){throw 'SPECTRA_NEGATIVE_PATH_ACCEPTED'}
  Write-Host 'PASS: Spectra operator CLI negative gates.'
}finally{if(Test-Path $temp){Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue}}
