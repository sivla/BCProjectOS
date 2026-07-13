[CmdletBinding()]param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version 2.0
. (Join-Path $PSScriptRoot 'Spectra.JsonSchema.ps1')
. (Join-Path $PSScriptRoot 'Spectra.PowerShellHost.ps1')
. (Join-Path $PSScriptRoot 'Spectra.Bootstrap.ps1')

$passed=0
$stringSchema=[pscustomobject]@{type='string';pattern='^[0-9]{4}-[0-9]{2}-[0-9]{2}T'}
$constSchema=[pscustomobject]@{type='string';const='2031-01-01T00:00:00.0000000Z'}
$enumSchema=[pscustomobject]@{type='string';enum=@('2031-01-01T00:00:00.0000000Z')}
$date=[DateTime]::SpecifyKind([DateTime]::Parse('2031-01-01T00:00:00'),[DateTimeKind]::Utc)
$offset=[DateTimeOffset]::Parse('2031-01-01T01:00:00+01:00',[Globalization.CultureInfo]::InvariantCulture)
Test-SpectraJsonSchema -Value $date -Schema $stringSchema -RootSchema $stringSchema
Test-SpectraJsonSchema -Value $date -Schema $constSchema -RootSchema $constSchema
Test-SpectraJsonSchema -Value $offset -Schema $enumSchema -RootSchema $enumSchema
$passed++

$savedTemp=$env:TEMP
try {
  $env:TEMP=$null
  $tempPath=[IO.Path]::GetTempPath()
  if ([string]::IsNullOrWhiteSpace($tempPath) -or -not [IO.Path]::IsPathRooted($tempPath)) { throw 'PORTABILITY_TEMP_PATH_INVALID' }
} finally {
  $env:TEMP=$savedTemp
}
$tempTests=@('Test-SpectraPortableBootstrap.ps1','Test-SpectraPortableBootstrapNegative.ps1','Test-PortableSnapshotCatalog.ps1','Test-PortableSnapshotCatalogNegative.ps1')
foreach($test in $tempTests){
  $content=Get-Content -LiteralPath (Join-Path $PSScriptRoot $test) -Raw
  if($content -match '\$env:TEMP'){throw "PORTABILITY_TEMP_ENV_REMAINING:$test"}
  if($content -notmatch '\[IO\.Path\]::GetTempPath\(\)'){throw "PORTABILITY_TEMP_API_MISSING:$test"}
}
$passed++

$hostPath=Get-SpectraPowerShellHostPath
$probe=& $hostPath -NoProfile -Command '[Console]::Write([char]83)'
if([string]$probe -cne 'S'){throw 'PORTABILITY_CHILD_HOST_FAILED'}
foreach($script in @('Test-ExistingProjectAdoption.ps1','New-CustomerWorkspace.ps1')){
  $content=Get-Content -LiteralPath (Join-Path $PSScriptRoot $script) -Raw
  if($content -match '&\s+powershell(?:\.exe)?\b'){throw "PORTABILITY_FIXED_HOST_REMAINING:$script"}
}
$passed++

$negative=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Test-SpectraPortableBootstrapNegative.ps1') -Raw
if($negative -notmatch "'Junction'.*'SymbolicLink'"){throw 'PORTABILITY_LINK_PLATFORM_BRANCH_MISSING'}
$passed++

foreach($remote in @('https://github.com/sivla/BCProjectOS','https://github.com/sivla/BCProjectOS.git')){
  if(-not(Test-SpectraCanonicalRepositoryUrl $remote)){throw "PORTABILITY_CANONICAL_REMOTE_REJECTED:$remote"}
}
foreach($remote in @('https://github.com/sivla/Other.git','https://token@github.com/sivla/BCProjectOS.git','git@github.com:sivla/BCProjectOS.git','https://github.com/sivla/BCProjectOS-extra','https://github.com/sivla/BCProjectOS/')){
  if(Test-SpectraCanonicalRepositoryUrl $remote){throw "PORTABILITY_FOREIGN_REMOTE_ACCEPTED:$remote"}
}
$passed++

$relativeEvidence='spectra-relative-evidence-'+[guid]::NewGuid().ToString('N')+'.json'
try{
  Write-SpectraBootstrapJson $relativeEvidence ([ordered]@{status='PENDING'})
  if(-not(Test-Path $relativeEvidence -PathType Leaf)){throw 'PORTABILITY_RELATIVE_EVIDENCE_MISSING'}
}finally{if(Test-Path $relativeEvidence -PathType Leaf){Remove-Item -LiteralPath $relativeEvidence -Force}}
$passed++

$macAcceptance=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Test-SpectraMacOSOnboarding.ps1') -Raw
if($macAcceptance -notmatch 'remote set-url origin https://github\.com/sivla/BCProjectOS'){throw 'PORTABILITY_MACOS_CLONE_REMOTE_REBIND_MISSING'}
$passed++

$xdgRoot=Join-Path ([IO.Path]::GetTempPath()) ('spectra-xdg-first-run-'+[guid]::NewGuid().ToString('N'))
try{
  New-Item -ItemType Directory -Path $xdgRoot|Out-Null
  $roots=Get-SpectraDefaultRoots -HomePath (Join-Path $xdgRoot 'home') -XdgConfigHome (Join-Path $xdgRoot 'config parent') -XdgDataHome (Join-Path $xdgRoot 'data parent') -Platform macos
  $initialized=Initialize-SpectraBootstrapRoots -ConfigRoot $roots.config_root -RegistryRoot $roots.registry_root -ObservedAt '2031-01-01T00:00:00Z' -Apply
  if($initialized.status-cne'INITIALIZED'-or-not(Test-Path $roots.config_root -PathType Container)-or-not(Test-Path $roots.registry_root -PathType Container)){throw 'PORTABILITY_XDG_FIRST_RUN_FAILED'}
}finally{if(Test-Path $xdgRoot){Remove-Item -LiteralPath $xdgRoot -Recurse -Force}}
$passed++

if($passed -ne 8){throw "PORTABILITY_REGRESSION_COUNT_INVALID:$passed"}
Write-Host "PASS: $passed Portabilitaetsregressionen einschliesslich macOS-Clonebindung und XDG-First-Run."
