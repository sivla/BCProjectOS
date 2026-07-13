[CmdletBinding()]
param(
  [string]$ProductRoot,
  [string]$Version = '1.1.0-alpha.1',
  [Parameter(Mandatory)][string]$OutputPath
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
if (-not $ProductRoot) { $ProductRoot = Split-Path -Parent $PSScriptRoot }
. (Join-Path $PSScriptRoot 'Spectra.Bootstrap.ps1')

function Write-Evidence([string]$Status, [AllowNull()][string]$Reason, [System.Collections.IDictionary]$Gates) {
  $evidence = [ordered]@{
    schema_version = 1
    product_id = 'spectra'
    platform = Get-SpectraPlatform
    status = $Status
    reason = $Reason
    release_version = $Version
    gates = $Gates
  }
  Test-SpectraBootstrapSchema $evidence 'spectra-macos-onboarding-evidence.schema.json'
  Write-SpectraBootstrapJson -Path $OutputPath -Value $evidence
  $evidence
}

$pending = [ordered]@{}
foreach ($name in @('freshClone','install','doctor','init','adopt','validate','snapshot','noRemoteWrites','pathSemantics')) { $pending[$name] = 'PENDING' }
if ((Get-SpectraPlatform) -ne 'macos') {
  Write-Evidence -Status PENDING -Reason MACOS_RUNNER_EVIDENCE_MISSING -Gates $pending | ConvertTo-Json -Depth 10
  exit 0
}

Assert-SpectraToolAvailable pwsh 'BOOTSTRAP_PWSH_MISSING' | Out-Null
if ($PSVersionTable.PSEdition -ne 'Core' -or $PSVersionTable.PSVersion.Major -lt 7) { throw 'BOOTSTRAP_PWSH7_REQUIRED' }
$savedTmpDir=$env:TMPDIR
$physicalTemp='';$pwdExitCode=1
Push-Location -LiteralPath ([IO.Path]::GetTempPath())
try{$physicalTemp=(& /bin/pwd -P 2>$null|Select-Object -First 1).Trim();$pwdExitCode=$LASTEXITCODE}finally{Pop-Location}
if($pwdExitCode-ne0-or[string]::IsNullOrWhiteSpace($physicalTemp)-or-not(Test-Path $physicalTemp -PathType Container)){throw 'MACOS_PHYSICAL_TEMP_UNAVAILABLE'}
$env:TMPDIR=$physicalTemp
$temp = Join-Path $physicalTemp ('Spectra macOS acceptance ' + [guid]::NewGuid().ToString('N'))
$clone = Join-Path $temp 'fresh clone'
try {
  New-Item -ItemType Directory -Path $temp | Out-Null
  & git clone --no-hardlinks --quiet $ProductRoot $clone
  if ($LASTEXITCODE -ne 0) { throw 'MACOS_FRESH_CLONE_FAILED' }
  & git -C $clone remote set-url origin https://github.com/sivla/BCProjectOS
  if ($LASTEXITCODE -ne 0) { throw 'MACOS_FRESH_CLONE_REMOTE_FAILED' }
  $gates = [ordered]@{ freshClone='PASS'; install='PENDING'; doctor='PENDING'; init='PENDING'; adopt='PENDING'; validate='PENDING'; snapshot='PENDING'; noRemoteWrites='PENDING'; pathSemantics='PENDING' }

  & pwsh -NoProfile -File (Join-Path $clone 'automation/Test-ReleaseCandidate.ps1') -Version $Version -RequirePublished | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'MACOS_INSTALL_BINDING_FAILED' }
  $installed = Join-Path $temp 'installed product'
  & sh (Join-Path $clone 'install.sh') -Command install -SourceRoot $clone -InstallRoot $installed -Version $Version -Apply -Approve | Out-Null
  if ($LASTEXITCODE -ne 0 -or -not(Test-Path (Join-Path $installed '.spectra-install.json'))) { throw 'MACOS_INSTALL_FAILED' }
  $reinstall = & pwsh -NoProfile -File (Join-Path $clone 'install.ps1') -Command install -SourceRoot $clone -InstallRoot $installed -Version $Version -Apply -Approve | ConvertFrom-Json
  if ($reinstall.status -cne 'ALREADY_INSTALLED' -or $reinstall.writes_performed) { throw 'MACOS_REINSTALL_NOT_IDEMPOTENT' }; $gates.install = 'PASS'

  $roots = Get-SpectraDefaultRoots -HomePath (Join-Path $temp 'Home With Spaces') -XdgConfigHome (Join-Path $temp 'XDG Config') -XdgDataHome (Join-Path $temp 'XDG Data') -Platform macos
  & pwsh -NoProfile -File (Join-Path $installed 'automation/Invoke-SpectraBootstrap.ps1') -Command bootstrap -ProductRoot $installed -RegistryRoot $roots.registry_root -ConfigRoot $roots.config_root -Version $Version -Apply | Out-Null
  & pwsh -NoProfile -File (Join-Path $installed 'automation/Invoke-SpectraBootstrap.ps1') -Command doctor -ProductRoot $installed -RegistryRoot $roots.registry_root -ConfigRoot $roots.config_root -Version $Version | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'MACOS_DOCTOR_FAILED' }; $gates.doctor = 'PASS'

  & pwsh -NoProfile -File (Join-Path $installed 'automation/Test-SpectraPortableBootstrap.ps1') -Version $Version | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'MACOS_INIT_FAILED' }; $gates.init = 'PASS'; $gates.pathSemantics = 'PASS'
  & pwsh -NoProfile -File (Join-Path $installed 'automation/Test-ExistingProjectAdoption.ps1') -ReleaseVersion $Version | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'MACOS_ADOPT_FAILED' }; $gates.adopt = 'PASS'
  & pwsh -NoProfile -File (Join-Path $installed 'automation/Test-ProductContract.ps1') | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'MACOS_VALIDATE_FAILED' }; $gates.validate = 'PASS'
  $catalogRoot=Join-Path $roots.registry_root 'two-project-catalog';& pwsh -NoProfile -File (Join-Path $installed 'automation/New-SyntheticPortableSnapshotCatalog.ps1') -Destination $catalogRoot | Out-Null
  & pwsh -NoProfile -File (Join-Path $installed 'automation/Test-PortableSnapshotCatalog.ps1') | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'MACOS_SNAPSHOT_FAILED' }; $gates.snapshot = 'PASS'

  & pwsh -NoProfile -File (Join-Path $installed 'automation/Invoke-SpectraBootstrap.ps1') -Command doctor -ProductRoot $installed -RegistryRoot $roots.registry_root -ConfigRoot $roots.config_root -Version $Version -Remote 2>$null | Out-Null
  if ($LASTEXITCODE -eq 0) { throw 'MACOS_REMOTE_WRITE_NOT_BLOCKED' }; $gates.noRemoteWrites = 'PASS'
  & pwsh -NoProfile -File (Join-Path $clone 'install.ps1') -Command uninstall -SourceRoot $clone -InstallRoot $installed -Version $Version -Apply -Approve | Out-Null
  if ($LASTEXITCODE -ne 0 -or -not(Test-Path (Join-Path $catalogRoot 'catalog.json'))) { throw 'MACOS_UNINSTALL_PROJECT_DATA_LOSS' }
  Write-Evidence -Status PASS -Reason $null -Gates $gates | ConvertTo-Json -Depth 10
} finally {
  if (Test-Path $temp) { Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue }
  $env:TMPDIR=$savedTmpDir
}
