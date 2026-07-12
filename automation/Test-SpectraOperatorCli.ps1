$ErrorActionPreference='Stop'
$base=Join-Path ([IO.Path]::GetTempPath()) ('spectra-cli-'+[guid]::NewGuid().ToString('N'))
try{
  $implementation=Join-Path $base 'implementation'
  $support=Join-Path $base 'support-only'
  New-Item -ItemType Directory -Force $implementation,$support|Out-Null
  foreach($profile in @(@{name='implementation';path=$implementation},@{name='support-only';path=$support})){
    $before=@(Get-ChildItem $profile.path -Force).Count
    $json=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace $profile.path|ConvertFrom-Json
    if($json.product_id -ne 'spectra' -or $json.mode -ne 'dry-run' -or $json.writes_performed -ne $false){throw 'SPECTRA_DRY_RUN_INVALID'}
    if(@(Get-ChildItem $profile.path -Force).Count -ne $before){throw 'SPECTRA_DRY_RUN_MUTATED'}
  }
  $blocked=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command backup -Workspace $implementation -Apply|ConvertFrom-Json
  if($blocked.code -ne 'SPECTRA_APPLY_GATE_PENDING' -or $blocked.writes_performed -ne $false){throw 'SPECTRA_ROLLBACK_GATE_INVALID'}
  if($implementation -eq $support){throw 'SPECTRA_PROFILE_ISOLATION_FAILED'}
  Write-Host 'PASS: Spectra operator CLI dry-run, isolation and rollback gates.'
}finally{if(Test-Path $base){Remove-Item $base -Recurse -Force -ErrorAction SilentlyContinue}}
