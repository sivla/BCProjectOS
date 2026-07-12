[CmdletBinding()]param()
$ErrorActionPreference='Stop'
$base=Join-Path ([IO.Path]::GetTempPath()) ('spectra-09-compat-'+[guid]::NewGuid().ToString('N'))
try{
  New-Item -ItemType Directory -Force $base|Out-Null
  $legacy=Join-Path $base 'legacy-08'
  & (Join-Path $PSScriptRoot 'New-CustomerWorkspace.ps1') -Destination $legacy -Profile implementation -SyntheticFixture|Out-Null
  & (Join-Path $PSScriptRoot 'Test-SyntheticWorkspaceFixture.ps1') -Path $legacy|Out-Null
  if((Test-Path (Join-Path $legacy 'reconciliation')) -or (Test-Path (Join-Path $legacy 'adapter\adapter-provenance.json'))){throw 'SPECTRA09_LEGACY_WORKSPACE_MUTATED'}
  foreach($profile in @('implementation','support-only')){
    $source=Join-Path $base "$profile-source";$backup=Join-Path $base "$profile-backup";$restored=Join-Path $base "$profile-restored"
    & (Join-Path $PSScriptRoot 'New-SyntheticSpectra09Profile.ps1') -Destination $source -Profile $profile|Out-Null
    $sourceHashes=@{};Get-ChildItem $source -Recurse -File|ForEach-Object{$relative=$_.FullName.Substring($source.Length).TrimStart('\','/');$sourceHashes[$relative]=(Get-FileHash $_.FullName -Algorithm SHA256).Hash}
    & (Join-Path $PSScriptRoot 'Backup-Workspace.ps1') -Source $source -Destination $backup|Out-Null
    & (Join-Path $PSScriptRoot 'Restore-Workspace.ps1') -Backup $backup -Destination $restored|Out-Null
    & (Join-Path $PSScriptRoot 'Test-SyntheticSpectra09Profile.ps1') -Path $restored|Out-Null
    foreach($relative in $sourceHashes.Keys){$target=Join-Path $restored $relative;if(-not(Test-Path $target)-or(Get-FileHash $target -Algorithm SHA256).Hash -ne $sourceHashes[$relative]){throw "SPECTRA09_ROUNDTRIP_MISMATCH:$relative"}}
  }
  Write-Host 'PASS: 0.8-Kompatibilität und Spectra-0.9-Backup/Restore-Roundtrip sind belegt.'
}finally{if(Test-Path $base){Remove-Item $base -Recurse -Force -ErrorAction SilentlyContinue}}
