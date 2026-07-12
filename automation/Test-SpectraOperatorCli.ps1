$ErrorActionPreference='Stop'
$base=Join-Path ([IO.Path]::GetTempPath()) ('spectra-cli-'+[guid]::NewGuid().ToString('N'))
try{
  New-Item -ItemType Directory -Force $base|Out-Null
  foreach($profile in @('implementation','support-only')){
    $workspace=Join-Path $base $profile
    $backup=Join-Path $base "$profile-backup"
    $restore=Join-Path $base "$profile-restored"
    $initPlan=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace $workspace -Profile $profile -SyntheticPilot|ConvertFrom-Json
    if($initPlan.writes_performed -or (Test-Path $workspace)){throw 'SPECTRA_INIT_DRYRUN_MUTATED'}
    $init=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace $workspace -Profile $profile -SyntheticPilot -Apply|ConvertFrom-Json
    if($init.code -ne 'SPECTRA_OK' -or -not $init.writes_performed){throw 'SPECTRA_INIT_DELEGATION_INVALID'}
    $validated=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command validate -Workspace $workspace|ConvertFrom-Json
    if($validated.status -ne 'VALIDATED' -or $validated.writes_performed){throw 'SPECTRA_VALIDATE_DELEGATION_INVALID'}
    $profileRecord=Get-Content (Join-Path $workspace 'governance/policies/workspace-profile.yaml') -Raw|ConvertFrom-Json
    if($profileRecord.profile -ne $profile){throw 'SPECTRA_PROFILE_ISOLATION_FAILED'}
    $before=(Get-FileHash (Join-Path $workspace 'synthetic-fixture.yaml')).Hash
    $failed=$false;try{& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace $workspace -Profile $profile -SyntheticPilot -Apply|Out-Null}catch{$failed=$_.Exception.Message -match 'SPECTRA_DELEGATE_FAILED:init'}
    if(-not $failed -or (Get-FileHash (Join-Path $workspace 'synthetic-fixture.yaml')).Hash -ne $before){throw 'SPECTRA_RESUME_NOT_IDEMPOTENT'}
    $dry=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command backup -Workspace $workspace -Target $backup|ConvertFrom-Json
    if($dry.writes_performed -or (Test-Path $backup)){throw 'SPECTRA_BACKUP_DRYRUN_MUTATED'}
    & (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command backup -Workspace $workspace -Target $backup -Apply|Out-Null
    & (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command restore -Workspace $backup -Target $restore|Out-Null
    if(Test-Path $restore){throw 'SPECTRA_RESTORE_DRYRUN_MUTATED'}
    & (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command restore -Workspace $backup -Target $restore -Apply|Out-Null
    & (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command validate -Workspace $restore|Out-Null
  }
  Write-Host 'PASS: Spectra operator CLI delegated profile pilots, restart and backup/restore.'
}finally{if(Test-Path $base){Remove-Item $base -Recurse -Force -ErrorAction SilentlyContinue}}
