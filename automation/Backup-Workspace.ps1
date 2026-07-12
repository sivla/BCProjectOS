[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Source,
  [Parameter(Mandatory=$true)][string]$Destination,
  [switch]$DryRun
)

$ErrorActionPreference='Stop'
$s=[IO.Path]::GetFullPath($Source)
$d=[IO.Path]::GetFullPath($Destination)
$excludedPattern='(?i)\\(\.env[^\\]*|.*secret.*|.*token.*|.*browser.*|.*auth.*|runtime-logs)(\\|$)'

if(-not (Test-Path $s -PathType Container)){throw 'BACKUP_SOURCE_MISSING'}
if((Test-Path $d) -and (Get-ChildItem $d -Force|Measure-Object).Count -gt 0){throw 'BACKUP_TARGET_NOT_EMPTY'}

$files=@(Get-ChildItem $s -File -Recurse|Where-Object{$_.FullName -notmatch $excludedPattern}|Sort-Object FullName)
$directories=@(
  Get-ChildItem $s -Directory -Recurse|
    Where-Object{$_.FullName -notmatch $excludedPattern}|
    ForEach-Object{$_.FullName.Substring($s.Length).TrimStart('\','/').Replace('\','/')}|
    Sort-Object -Unique
)
$entries=@()
foreach($f in $files){
  $rel=$f.FullName.Substring($s.Length).TrimStart('\','/').Replace('\','/')
  if($rel -match '(^|/)\.\.|^[A-Za-z]:|(^|/)(\.env|.*secret.*|.*token.*|.*browser.*|.*auth.*)'){throw "BACKUP_UNSAFE_PATH:$rel"}
  $entries+=([ordered]@{
    path=$rel
    size_bytes=$f.Length
    sha256=(Get-FileHash $f.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    mode='file'
  })
}

$digestPayload=[ordered]@{directories=$directories;files=$entries}
$manifest=[ordered]@{
  schema_version=1
  product_id='spectra'
  artifact_type='spectra_workspace_backup'
  source_identity=(Split-Path $s -Leaf)
  created_at='2026-07-12T00:00:00Z'
  directories=$directories
  files=$entries
  bundle_digest=([System.BitConverter]::ToString(
    [Security.Cryptography.SHA256]::Create().ComputeHash(
      [Text.Encoding]::UTF8.GetBytes(($digestPayload|ConvertTo-Json -Depth 10))
    )
  )).Replace('-','').ToLowerInvariant()
}

if($DryRun){$manifest|ConvertTo-Json -Depth 10;return}
New-Item -ItemType Directory -Force $d|Out-Null
foreach($directory in $directories){New-Item -ItemType Directory -Force (Join-Path $d ($directory -replace '/','\'))|Out-Null}
foreach($f in $files){
  $rel=$f.FullName.Substring($s.Length).TrimStart('\','/')
  $out=Join-Path $d $rel
  New-Item -ItemType Directory -Force (Split-Path $out)|Out-Null
  Copy-Item $f.FullName $out
}
$manifest|ConvertTo-Json -Depth 10|Set-Content (Join-Path $d 'backup-manifest.json') -Encoding utf8
Write-Host 'PASS: Workspace backup created.'
