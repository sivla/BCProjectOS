[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Destination,
  [Parameter(Mandatory=$true)][ValidateSet('implementation','support-only')][string]$Profile,
  [Parameter(Mandatory=$true)][string]$CustomerAlias,
  [Parameter(Mandatory=$true)][string]$Version,
  [Parameter(Mandatory=$true)][string]$ProductRoot,
  [Parameter(Mandatory=$true)][string]$ConfigPath
)
$ErrorActionPreference='Stop';Set-StrictMode -Version 2.0
$product=[IO.Path]::GetFullPath($ProductRoot);$destinationPath=[IO.Path]::GetFullPath($Destination);$configFull=[IO.Path]::GetFullPath($ConfigPath)
if($destinationPath-eq[IO.Path]::GetPathRoot($destinationPath)){throw 'BOUND_INIT_DESTINATION_UNSAFE'};$parent=Split-Path -Parent $destinationPath
if(-not(Test-Path $parent -PathType Container)){throw 'BOUND_INIT_DESTINATION_PARENT_MISSING'};if(Test-Path $destinationPath){throw 'BOUND_INIT_DESTINATION_EXISTS'}
if(-not(Test-Path $configFull -PathType Leaf)){throw 'BOUND_INIT_CONFIG_MISSING'};$config=Get-Content $configFull -Raw|ConvertFrom-Json
if([string]$config.profile-ne$Profile){throw 'BOUND_INIT_PROFILE_MISMATCH'}
$outer=Join-Path $parent ('.spectra-bound-init-'+[guid]::NewGuid().ToString('N'));$installed=Join-Path $outer 'installed';$layer=Join-Path $outer 'project-layer'
try{
  New-Item -ItemType Directory -Path $outer|Out-Null
  & (Join-Path $PSScriptRoot 'New-CustomerWorkspace.ps1') -Destination $installed -Profile $Profile -ExpectedBlueprintVersion $Version -CustomerAlias $CustomerAlias -ProductRoot $product|Out-Null
  & (Join-Path $PSScriptRoot 'Initialize-SpectraProject.ps1') -ConfigPath $configFull -Destination $layer -Apply|Out-Null
  foreach($file in @(Get-ChildItem $layer -File -Recurse)){
    $relative=$file.FullName.Substring($layer.Length).TrimStart([char[]]@('\','/'))-replace'\\','/'
    if($relative-eq'README.md'){$relative='PROJECT-INIT.md'}
    $target=Join-Path $installed ($relative-replace'/','\')
    if(Test-Path $target -PathType Leaf){
      if((Get-FileHash $file.FullName).Hash-eq(Get-FileHash $target).Hash){continue}
      throw "BOUND_INIT_PATH_CONFLICT:$relative"
    }
    $targetParent=Split-Path -Parent $target;if(-not(Test-Path $targetParent)){New-Item -ItemType Directory -Path $targetParent -Force|Out-Null}
    Copy-Item -LiteralPath $file.FullName -Destination $target
  }
  & (Join-Path $PSScriptRoot 'Test-CustomerWorkspace.ps1') -Path $installed -ProductRoot $product|Out-Null
  Move-Item -LiteralPath $installed -Destination $destinationPath
  Write-Host "PASS: Releasegebundener Spectra-Projektworkspace atomar erzeugt: $destinationPath"
}finally{if(Test-Path $outer){Remove-Item $outer -Recurse -Force -ErrorAction SilentlyContinue}}
