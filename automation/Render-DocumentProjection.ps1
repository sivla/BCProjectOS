[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Path,[Parameter(Mandatory=$true)][string]$Destination)
$ErrorActionPreference='Stop'
$source=[IO.Path]::GetFullPath($Path);$target=[IO.Path]::GetFullPath($Destination)
if(Test-Path -LiteralPath $target){throw 'DOCUMENT_RENDER_TARGET_EXISTS'}
& (Join-Path $PSScriptRoot 'Test-DocumentProjection.ps1') -Path $source|Out-Null
$x=Get-Content (Join-Path $source 'projection.json') -Raw|ConvertFrom-Json
New-Item -ItemType Directory -Path $target|Out-Null
$rendered=@()
foreach($d in @($x.documentation.documents|Where-Object content_mode -eq 'generated'|Sort-Object id)){
  $relative=[string]$d.source_path;$out=Join-Path $target ($relative-replace'/','\');New-Item -ItemType Directory -Force -Path (Split-Path $out -Parent)|Out-Null
  $body=@("---","documentId: $($d.id)","contentMode: generated","blueprintId: $($d.blueprint_id)","snapshotId: $($x.snapshot.id)","sourceRevision: $($x.snapshot.source_revision)","sourceDigest: $($x.snapshot.source_digest)","generatedAt: $($x.snapshot.generated_at)","provenance: $(@($d.provenance_ids)-join ',')","---","","# $($d.title)","","Diese Ansicht wurde deterministisch aus dem validierten synthetischen Snapshot erzeugt.","")-join"`n"
  [IO.File]::WriteAllText($out,$body,[Text.UTF8Encoding]::new($false));$rendered+=$relative
}
$index=[ordered]@{schema_version=1;product_id='spectra';snapshot_id=$x.snapshot.id;generated_documents=@($rendered);authored_documents=@($x.documentation.documents|Where-Object content_mode -eq 'authored'|ForEach-Object source_path|Sort-Object)}
[IO.File]::WriteAllText((Join-Path $target 'projection-index.json'),(($index|ConvertTo-Json -Depth 5)+"`n"),[Text.UTF8Encoding]::new($false))
Write-Host 'PASS: Generierte Ansichten wurden deterministisch gerendert; authored Inhalte blieben unangetastet.'
