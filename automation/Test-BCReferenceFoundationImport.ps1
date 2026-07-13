param([string]$ProductRoot,[string]$ManifestPath)
$ErrorActionPreference='Stop'
$root=if($ProductRoot){[IO.Path]::GetFullPath($ProductRoot)}else{[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))}
if(-not $ManifestPath){$ManifestPath=Join-Path $root 'contract\foundation-imports\bc-reference-library.json'}
$manifest=Get-Content -Raw $ManifestPath|ConvertFrom-Json
if($manifest.source_commit -ne 'dff88684d062e23794cbfb5423aecd331ac49790'){throw 'BC_FOUNDATION_SOURCE_COMMIT_MISMATCH'}
if($manifest.integration_state -ne 'foundation-import-not-ancestry'){throw 'BC_FOUNDATION_INTEGRATION_STATE_INVALID'}
foreach($entry in @($manifest.files)){
  $path=Join-Path $root $entry.path
  if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "BC_FOUNDATION_FILE_MISSING:$($entry.path)"}
  $actual=(git -C $root hash-object --path=$($entry.path) -- $path).Trim()
  if($LASTEXITCODE -ne 0 -or $actual -ne $entry.blob){throw "BC_FOUNDATION_BLOB_MISMATCH:$($entry.path)"}
  git -C $root cat-file -e "$($manifest.source_commit):$($entry.path)" 2>$null
  if($LASTEXITCODE -eq 0){$source=(git -C $root rev-parse "$($manifest.source_commit):$($entry.path)").Trim();if($source -ne $entry.blob){throw "BC_FOUNDATION_SOURCE_BLOB_MISMATCH:$($entry.path)"}}
}
Write-Output "PASS: $(@($manifest.files).Count) Foundation-Dateien bytegleich zu dff88684 gebunden."
