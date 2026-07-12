[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Workspace)
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath($Workspace)
$recordPath=Join-Path $root 'adapter\adapter-provenance.json'
if(-not(Test-Path $recordPath -PathType Leaf)){throw 'PROVENANCE_RECORD_MISSING'}
$record=Get-Content $recordPath -Raw|ConvertFrom-Json
$schema=Get-Content (Join-Path $PSScriptRoot '..\schemas\adapter-provenance.schema.json') -Raw|ConvertFrom-Json
. (Join-Path $PSScriptRoot 'Spectra.JsonSchema.ps1')
try{Test-SpectraJsonSchema -Value $record -Schema $schema -RootSchema $schema}catch{if($_.Exception.Message -like 'SPECTRA_SCHEMA_*'){throw 'PROVENANCE_SCHEMA_INVALID'};throw}

function Resolve-SafeContractPath([string]$RelativePath){
  if([string]::IsNullOrWhiteSpace($RelativePath) -or [IO.Path]::IsPathRooted($RelativePath) -or $RelativePath -match '\\' -or $RelativePath -match '(^|/)\.\.(/|$)'){throw 'PROVENANCE_PATH_UNSAFE'}
  $resolved=[IO.Path]::GetFullPath((Join-Path $root ($RelativePath -replace '/','\')))
  $prefix=$root.TrimEnd('\','/')+[IO.Path]::DirectorySeparatorChar
  if(-not $resolved.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'PROVENANCE_PATH_UNSAFE'}
  return $resolved
}
$sourcePath=Resolve-SafeContractPath ([string]$record.source.blob_path)
$projectionPath=Resolve-SafeContractPath ([string]$record.projection.projection_path)
if($sourcePath -eq $projectionPath){throw 'PROVENANCE_PATH_COLLISION'}
if(-not(Test-Path $sourcePath -PathType Leaf) -or -not(Test-Path $projectionPath -PathType Leaf)){throw 'PROVENANCE_FILE_MISSING'}
$sourceHash=(Get-FileHash $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant()
$projectionHash=(Get-FileHash $projectionPath -Algorithm SHA256).Hash.ToLowerInvariant()
if($sourceHash -ne [string]$record.source.source_hash){throw 'PROVENANCE_SOURCE_HASH_MISMATCH'}
if([string]$record.source.source_hash_after -ne [string]$record.source.source_hash){throw 'PROVENANCE_SOURCE_CHANGED'}
if($projectionHash -ne [string]$record.projection.projection_digest){throw 'PROVENANCE_PROJECTION_DIGEST_MISMATCH'}
if($record.mapping.deterministic -ne $true){throw 'PROVENANCE_MAPPING_NOT_DETERMINISTIC'}
if(($record.classification -eq 'synthetic-fixture' -and ($record.synthetic -ne $true -or $record.source_of_truth.owner -ne 'synthetic-fixture')) -or
   ($record.classification -eq 'customer-workspace' -and ($record.synthetic -ne $false -or $record.source_of_truth.owner -ne 'customer-workspace')) -or
   $record.source_of_truth.unchanged -ne $true){throw 'PROVENANCE_TRUTH_BOUNDARY_INVALID'}
if($record.write_protection.source_mode -ne 'read-only' -or $record.write_protection.writes_performed -ne $false -or $record.write_protection.projection_only -ne $true -or $record.write_protection.overwrite_allowed -ne $false){throw 'PROVENANCE_WRITE_PROTECTION_INVALID'}
Write-Host 'PASS: Adapter-Provenienz bindet Source- und Projektionsbytes bei unveränderter Source-of-Truth.'
