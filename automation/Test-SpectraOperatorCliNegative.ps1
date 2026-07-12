$ErrorActionPreference='Stop'
$base=Join-Path ([IO.Path]::GetTempPath()) ('spectra-cli-neg-'+[guid]::NewGuid().ToString('N'))
try{
  New-Item -ItemType Directory -Force $base|Out-Null
  $failed=$false;try{& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command unknown -Workspace $base|Out-Null}catch{$failed=$_.Exception.Message -match '^SPECTRA_COMMAND_UNKNOWN$'};if(-not $failed){throw 'SPECTRA_UNKNOWN_COMMAND_ACCEPTED'}
  $failed=$false;try{& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command validate -Workspace $base -Apply|Out-Null}catch{$failed=$_.Exception.Message -match 'SPECTRA_APPLY_NOT_SUPPORTED'};if(-not $failed){throw 'SPECTRA_NEGATIVE_APPLY_ACCEPTED'}
  $failed=$false;try{& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace ([IO.Path]::GetPathRoot($base))|Out-Null}catch{$failed=$_.Exception.Message -match 'SPECTRA_PATH_UNSAFE'};if(-not $failed){throw 'SPECTRA_NEGATIVE_PATH_ACCEPTED'}
  $source=Join-Path $base 'source';$backup=Join-Path $base 'backup';$target=Join-Path $base 'target';New-Item -ItemType Directory -Force $source,$target|Out-Null;Set-Content (Join-Path $source 'safe.txt') 'safe';Set-Content (Join-Path $target 'existing.txt') 'preserve'
  & (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command backup -Workspace $source -Target $backup -Apply|Out-Null
  $before=(Get-FileHash (Join-Path $target 'existing.txt')).Hash;$failed=$false;try{& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command restore -Workspace $backup -Target $target -Apply|Out-Null}catch{$failed=$_.Exception.Message -match 'SPECTRA_DELEGATE_FAILED:restore'}
  if(-not $failed -or (Get-FileHash (Join-Path $target 'existing.txt')).Hash -ne $before){throw 'SPECTRA_RESTORE_ROLLBACK_FAILED'}
  $failed=$false;try{& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command validate -Workspace (Join-Path $base 'missing')|Out-Null}catch{$failed=$_.Exception.Message -match 'SPECTRA_DELEGATE_FAILED:validate:SPECTRA_DELEGATE_EXIT_1'};if(-not $failed){throw 'SPECTRA_DELEGATE_EXIT_IGNORED'}
  foreach($route in @('plan-upgrade','upgrade')){
    $plan=Join-Path $base "$route.json"
    $failed=$false;try{& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command $route -Workspace $source -Target $plan -Version '0.8.0-alpha.1'|Out-Null}catch{$failed=$_.Exception.Message -match "SPECTRA_DELEGATE_FAILED:$route`:WORKSPACE_METADATA_MISSING"}
    if(-not $failed -or (Test-Path $plan)){throw "SPECTRA_$($route.ToUpperInvariant().Replace('-','_'))_FAIL_CLOSED_INVALID"}
  }
  $failed=$false;try{& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command candidate-check -Workspace $source -Version '9.9.9-alpha.1'|Out-Null}catch{$failed=$_.Exception.Message -match 'SPECTRA_DELEGATE_FAILED:candidate-check:SPECTRA_DELEGATE_EXIT_1'};if(-not $failed){throw 'SPECTRA_CANDIDATE_CHECK_FAIL_CLOSED_INVALID'}
  Write-Host 'PASS: Spectra operator CLI fail-closed and rollback gates.'
}finally{if(Test-Path $base){Remove-Item $base -Recurse -Force -ErrorAction SilentlyContinue}}
