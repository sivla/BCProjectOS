[CmdletBinding()]
param(
  [ValidateSet('install','doctor','init','adopt','register','validate','snapshot','uninstall')]
  [string]$Command = 'doctor',
  [string]$SourceRoot = $PSScriptRoot,
  [string]$InstallRoot,
  [string]$RegistryRoot,
  [string]$ConfigRoot,
  [Parameter(Mandatory)][string]$Version,
  [string]$Workspace,
  [string]$WorkspaceId,
  [string]$ProjectId,
  [ValidateSet('implementation','support-only')][string]$Profile = 'implementation',
  [ValidateSet('new','adopted')][string]$Mode = 'new',
  [string]$CustomerAlias,
  [string]$ConfigPath,
  [string]$DiscoveryPath,
  [string]$PlanPath,
  [string]$ExpectedPlanDigest,
  [string]$SnapshotPath,
  [switch]$Apply,
  [switch]$Approve
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$library = Join-Path $SourceRoot 'automation/Spectra.Bootstrap.ps1'
if (-not (Test-Path $library -PathType Leaf)) { throw 'INSTALL_SOURCE_INVALID' }
. $library

function Get-DefaultInstallRoot {
  if ((Get-SpectraPlatform) -eq 'macos') {
    $data = if ($env:XDG_DATA_HOME) { $env:XDG_DATA_HOME } else { "$HOME/.local/share" }
    return "$($data.TrimEnd('/'))/spectra/product"
  }
  $base = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { Join-Path $HOME 'AppData/Local' }
  Join-Path $base 'Spectra/product'
}
if (-not $InstallRoot) { $InstallRoot = Get-DefaultInstallRoot }
$InstallRoot = [IO.Path]::GetFullPath($InstallRoot)

function Assert-InstallDestination([string]$Path) {
  $parent = Split-Path -Parent $Path
  if (-not (Test-Path $parent -PathType Container)) { throw 'INSTALL_PARENT_MISSING' }
  Assert-SpectraNoLinkPath -Root $parent -Path $parent
  $savedPreference=$ErrorActionPreference
  $ErrorActionPreference='Continue'
  $gitOwner = @(& git -C $parent rev-parse --show-toplevel 2>$null)
  $gitExit=$LASTEXITCODE
  $ErrorActionPreference=$savedPreference
  if ($gitExit -eq 0) { throw 'INSTALL_DESTINATION_INSIDE_PROJECT_REPOSITORY' }
}
function Invoke-Install {
  $binding = Get-SpectraReleaseBinding -ProductRoot $SourceRoot -Version $Version
  $head = (& git -C $SourceRoot rev-parse HEAD 2>$null).Trim()
  if ($LASTEXITCODE -ne 0 -or $head -cne $binding.commit) { throw 'INSTALL_SOURCE_NOT_EXACT_RELEASE_TAG' }
  Assert-InstallDestination $InstallRoot
  $manifest = Read-SpectraBootstrapJson (Join-Path $SourceRoot "release/versions/$Version/release-manifest.json")
  . (Join-Path $SourceRoot 'automation/Release.Common.ps1')
  $planned = @($manifest.payload.files).Count
  if (-not $Apply) { return [ordered]@{status='PLANNED';writes_performed=$false;version=$Version;file_count=$planned} }
  if (-not $Approve) { throw 'INSTALL_APPROVAL_REQUIRED' }
  $existingMarkerPath = Join-Path $InstallRoot '.spectra-install.json'
  if (Test-Path $existingMarkerPath -PathType Leaf) {
    $existingMarker = Read-SpectraBootstrapJson $existingMarkerPath
    if ($existingMarker.version -ceq $Version -and $existingMarker.bundle_digest -ceq $binding.digest) {
      foreach ($file in @($manifest.payload.files)) {
        $existing = Join-Path $InstallRoot (([string]$file.path) -replace '/', [IO.Path]::DirectorySeparatorChar)
        if (-not (Test-Path $existing -PathType Leaf) -or (Get-SpectraBootstrapSha $existing) -cne [string]$file.sha256) { throw 'INSTALL_EXISTING_PAYLOAD_DRIFT' }
      }
      return [ordered]@{status='ALREADY_INSTALLED';writes_performed=$false;version=$Version;file_count=$planned}
    }
  }
  $parent=Split-Path -Parent $InstallRoot;$stage=Join-Path $parent ('.spectra-install-stage-'+[guid]::NewGuid().ToString('N'));$backup=$null
  try{
    New-Item -ItemType Directory -Path $stage|Out-Null
    foreach ($file in @($manifest.payload.files)) {
      $relative = [string]$file.path
      if ($relative -match '(^|/)[.][.](/|$)' -or [IO.Path]::IsPathRooted($relative) -or $relative.Contains('\')) { throw 'INSTALL_PAYLOAD_PATH_UNSAFE' }
      $destination = Join-Path $stage ($relative -replace '/', [IO.Path]::DirectorySeparatorChar)
      $directory = Split-Path -Parent $destination
      New-Item -ItemType Directory -Path $directory -Force | Out-Null
      Copy-BCProjectOSGitBlob -Root $SourceRoot -Revision ([string]$manifest.source_commit) -RelativePath $relative -Destination $destination
      if ((Get-SpectraBootstrapSha $destination) -cne [string]$file.sha256) { throw 'INSTALL_PAYLOAD_DIGEST_MISMATCH' }
      if ((Get-SpectraPlatform) -ne 'windows') {
        $permission = if ([string]$file.mode -ceq '100755') { '755' } else { '644' }
        & chmod $permission -- $destination
        if ($LASTEXITCODE -ne 0) { throw 'INSTALL_PAYLOAD_MODE_FAILED' }
      }
    }
    foreach ($metadataRelative in @("release/versions/$Version/release-manifest.json","release/versions/$Version/checksums.sha256")) {
      $metadataDestination=Join-Path $stage ($metadataRelative-replace'/',[IO.Path]::DirectorySeparatorChar)
      New-Item -ItemType Directory -Path (Split-Path -Parent $metadataDestination) -Force|Out-Null
      Copy-BCProjectOSGitBlob -Root $SourceRoot -Revision $binding.commit -RelativePath $metadataRelative -Destination $metadataDestination
    }
    $marker = [ordered]@{schema_version=1;product_id='spectra';version=$Version;release_commit=$binding.commit;release_tree=$binding.tree;bundle_digest=$binding.digest;file_count=$planned}
    Write-SpectraBootstrapJson -Path (Join-Path $stage '.spectra-install.json') -Value $marker
    if(Test-Path $InstallRoot){$backup=Join-Path $parent ('.spectra-install-backup-'+[guid]::NewGuid().ToString('N'));Move-Item -LiteralPath $InstallRoot -Destination $backup}
    Move-Item -LiteralPath $stage -Destination $InstallRoot
    if($backup){Remove-Item -LiteralPath $backup -Recurse -Force;$backup=$null}
  }catch{if($backup -and (Test-Path $backup) -and -not(Test-Path $InstallRoot)){Move-Item -LiteralPath $backup -Destination $InstallRoot;$backup=$null};throw}finally{if(Test-Path $stage){Remove-Item -LiteralPath $stage -Recurse -Force};if($backup -and (Test-Path $backup)){Remove-Item -LiteralPath $backup -Recurse -Force}}
  [ordered]@{status='INSTALLED';writes_performed=$true;version=$Version;file_count=$planned}
}
function Invoke-Uninstall {
  $markerPath = Join-Path $InstallRoot '.spectra-install.json'
  if (-not (Test-Path $markerPath -PathType Leaf)) { throw 'UNINSTALL_MARKER_MISSING' }
  Assert-SpectraNoLinkPath -Root $InstallRoot -Path $InstallRoot;$marker = Read-SpectraBootstrapJson $markerPath
  if([int]$marker.schema_version-ne1-or[string]$marker.product_id-cne'spectra'-or[string]$marker.release_commit-notmatch'^[a-f0-9]{40}$'-or[string]$marker.release_tree-notmatch'^[a-f0-9]{40}$'-or[string]$marker.bundle_digest-notmatch'^[a-f0-9]{64}$'){throw 'UNINSTALL_MARKER_INVALID'}
  $manifestPath = Join-Path $InstallRoot "release/versions/$($marker.version)/release-manifest.json"
  $checksumsPath = Join-Path $InstallRoot "release/versions/$($marker.version)/checksums.sha256"
  $manifest = Read-SpectraBootstrapJson $manifestPath
  if(-not(Test-Path $checksumsPath -PathType Leaf)){throw 'UNINSTALL_CHECKSUMS_MISSING'}
  if([string]$manifest.payload.bundle_digest-cne[string]$marker.bundle_digest-or[int]$manifest.payload.file_count-ne[int]$marker.file_count){throw 'UNINSTALL_MANIFEST_MISMATCH'}
  if (-not $Apply) { return [ordered]@{status='PLANNED';writes_performed=$false;preserves_registry=$true;preserves_config=$true} }
  if (-not $Approve) { throw 'UNINSTALL_APPROVAL_REQUIRED' }
  foreach($file in @($manifest.payload.files)){$relative=[string]$file.path;if([IO.Path]::IsPathRooted($relative)-or$relative.Contains('\')-or$relative-match'(^|/)\.\.(/|$)'){throw 'UNINSTALL_PAYLOAD_PATH_UNSAFE'};$path=Join-Path $InstallRoot ($relative-replace'/',[IO.Path]::DirectorySeparatorChar);Assert-SpectraNoLinkPath -Root $InstallRoot -Path $path;if(Test-Path $path -PathType Leaf){if((Get-SpectraBootstrapSha $path)-cne[string]$file.sha256){throw 'UNINSTALL_PAYLOAD_DRIFT'}}}
  foreach ($file in @($manifest.payload.files)) {
    $path = Join-Path $InstallRoot (([string]$file.path) -replace '/', [IO.Path]::DirectorySeparatorChar)
    if (Test-Path $path -PathType Leaf) { Remove-Item -LiteralPath $path -Force }
  }
  Remove-Item -LiteralPath $manifestPath,$checksumsPath -Force
  Remove-Item -LiteralPath $markerPath -Force
  [ordered]@{status='UNINSTALLED';writes_performed=$true;preserves_registry=$true;preserves_config=$true}
}

if ($Command -eq 'install') { Invoke-Install | ConvertTo-Json -Depth 10; exit 0 }
if ($Command -eq 'uninstall') { Invoke-Uninstall | ConvertTo-Json -Depth 10; exit 0 }
$installedCli = Join-Path $InstallRoot 'automation/Invoke-SpectraBootstrap.ps1'
if (-not (Test-Path $installedCli -PathType Leaf)) { throw 'INSTALL_NOT_FOUND' }
$mapped = if ($Command -eq 'snapshot') { 'handoff' } else { $Command }
& $installedCli -Command $mapped -RegistryRoot $RegistryRoot -ConfigRoot $ConfigRoot -ProductRoot $InstallRoot -Version $Version -Workspace $Workspace -WorkspaceId $WorkspaceId -ProjectId $ProjectId -Profile $Profile -Mode $Mode -CustomerAlias $CustomerAlias -ConfigPath $ConfigPath -DiscoveryPath $DiscoveryPath -PlanPath $PlanPath -ExpectedPlanDigest $ExpectedPlanDigest -SnapshotPath $SnapshotPath -Apply:$Apply -Approve:$Approve
