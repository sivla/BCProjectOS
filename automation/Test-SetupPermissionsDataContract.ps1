[CmdletBinding()]param()
$ErrorActionPreference='Stop';$temp=Join-Path $env:TEMP ('spectra-setup-contract-'+[guid]::NewGuid().ToString('N'))
try{
  foreach($profile in @('implementation','support-only')){
    $a=Join-Path $temp "$profile-a";$b=Join-Path $temp "$profile-b"
    & (Join-Path $PSScriptRoot 'New-SyntheticSetupPermissionsData.ps1') -Destination $a -Profile $profile|Out-Null
    & (Join-Path $PSScriptRoot 'New-SyntheticSetupPermissionsData.ps1') -Destination $b -Profile $profile|Out-Null
    $ha=(Get-FileHash (Join-Path $a 'setup-permissions-data.json') -Algorithm SHA256).Hash;$hb=(Get-FileHash (Join-Path $b 'setup-permissions-data.json') -Algorithm SHA256).Hash;if($ha-ne$hb){throw 'SETUP_DATA_GENERATOR_NOT_DETERMINISTIC'}
    & (Join-Path $PSScriptRoot 'Test-SetupPermissionsData.ps1') -Path $a|Out-Null
    $cli=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command validate-setup-data -Workspace $a|ConvertFrom-Json;if($cli.status-ne'VALIDATED'-or$cli.writes_performed-ne$false){throw 'SETUP_DATA_CLI_INVALID'}
    $backup=Join-Path $temp "$profile-backup";$restore=Join-Path $temp "$profile-restore"
    & (Join-Path $PSScriptRoot 'Backup-Workspace.ps1') -Source $a -Destination $backup|Out-Null
    & (Join-Path $PSScriptRoot 'Restore-Workspace.ps1') -Backup $backup -Destination $restore|Out-Null
    if((Get-FileHash (Join-Path $restore 'setup-permissions-data.json') -Algorithm SHA256).Hash-ne$ha){throw 'SETUP_DATA_BACKUP_ROUNDTRIP_MISMATCH'}
    & (Join-Path $PSScriptRoot 'Test-SetupPermissionsData.ps1') -Path $restore|Out-Null
  }
  Write-Host 'PASS: Beide Profile sind deterministisch, read-only validierbar und per CLI nutzbar.'
}finally{if(Test-Path $temp){Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue}}
