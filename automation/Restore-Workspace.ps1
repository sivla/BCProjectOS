[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Backup,
  [Parameter(Mandatory=$true)][string]$Destination,
  [switch]$DryRun
)

$ErrorActionPreference='Stop'
$b=[IO.Path]::GetFullPath($Backup)
$d=[IO.Path]::GetFullPath($Destination)
$m=Get-Content (Join-Path $b 'backup-manifest.json') -Raw|ConvertFrom-Json
if((Test-Path $d -PathType Container) -and (Get-ChildItem $d -Force|Measure-Object).Count -gt 0){throw 'RESTORE_TARGET_NOT_EMPTY'}
$stage="$d.spectra-restore-$([guid]::NewGuid().ToString('N'))"
if($DryRun){Write-Output ([ordered]@{status='DRY_RUN';files=@($m.files).Count}|ConvertTo-Json);return}

try{
  New-Item -ItemType Directory -Force $stage|Out-Null
  foreach($directory in @($m.directories)){
    if([string]$directory -match '(^|/)\.\.|^[A-Za-z]:|\\'){throw "RESTORE_UNSAFE_DIRECTORY:$directory"}
    New-Item -ItemType Directory -Force (Join-Path $stage ([string]$directory -replace '/','\'))|Out-Null
  }
  foreach($e in @($m.files)){
    $src=Join-Path $b ([string]$e.path -replace '/','\')
    if(-not (Test-Path $src)){throw "RESTORE_FILE_MISSING:$($e.path)"}
    if((Get-FileHash $src -Algorithm SHA256).Hash.ToLowerInvariant() -ne [string]$e.sha256){throw "RESTORE_HASH_MISMATCH:$($e.path)"}
    $out=Join-Path $stage ([string]$e.path -replace '/','\')
    New-Item -ItemType Directory -Force (Split-Path $out)|Out-Null
    Copy-Item $src $out
  }
  if(Test-Path $d){Remove-Item $d -Force -Recurse}
  Move-Item $stage $d
  Write-Host 'PASS: Workspace restore completed atomically.'
}finally{
  if(Test-Path $stage){Remove-Item $stage -Force -Recurse -ErrorAction SilentlyContinue}
}
