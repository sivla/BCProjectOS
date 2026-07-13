Set-StrictMode -Version 2.0
function Get-PortableSnapshotRoot{[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))}
function Write-PortableJson([string]$Path,$Value){$p=Split-Path -Parent $Path;if(-not(Test-Path $p)){New-Item -ItemType Directory -Path $p -Force|Out-Null};[IO.File]::WriteAllText($Path,(($Value|ConvertTo-Json -Depth 50)+"`n"),[Text.UTF8Encoding]::new($false))}
function Read-PortableJson([string]$Path){if(-not(Test-Path $Path -PathType Leaf)){throw 'SNAPSHOT_FILE_MISSING'};try{Get-Content $Path -Raw|ConvertFrom-Json}catch{throw 'SNAPSHOT_JSON_INVALID'}}
function Get-PortableSha([string]$Path){(Get-FileHash $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Get-PortableTextSha([string]$Text){$s=[Security.Cryptography.SHA256]::Create();try{([BitConverter]::ToString($s.ComputeHash([Text.Encoding]::UTF8.GetBytes($Text)))).Replace('-','').ToLowerInvariant()}finally{$s.Dispose()}}
function Assert-PortableRelative([string]$Path){if([string]::IsNullOrWhiteSpace($Path)-or[IO.Path]::IsPathRooted($Path)-or$Path.Contains('\')-or$Path-match'(^|/)\.\.(/|$)'-or$Path-match'^[A-Za-z]:'){throw 'SNAPSHOT_PATH_UNSAFE'}}
function Test-PortableSchema($Value,[string]$Name){$root=Get-PortableSnapshotRoot;. (Join-Path $root 'automation\Spectra.JsonSchema.ps1');$schema=Get-Content (Join-Path $root "schemas\$Name") -Raw|ConvertFrom-Json;$v=($Value|ConvertTo-Json -Depth 60 -Compress)|ConvertFrom-Json;try{Test-SpectraJsonSchema -Value $v -Schema $schema -RootSchema $schema -Path root}catch{throw "SNAPSHOT_SCHEMA_INVALID:$($_.Exception.Message.Split([Environment]::NewLine)[0])"}}
function Assert-PortableUnique($Values,[string]$Code){$s=@{};foreach($v in @($Values)){$k=[string]$v;if($s.ContainsKey($k)){throw $Code};$s[$k]=$true}}
function Test-PortableSnapshotObject($Snapshot){
  Test-PortableSchema $Snapshot 'portable-project-snapshot.schema.json';if(-not$Snapshot.immutable){throw 'SNAPSHOT_MUTABLE_RELEASE'}
  $inventoryJson=$Snapshot.source_inventory|ConvertTo-Json -Depth 30 -Compress;$inventoryDigest=Get-PortableTextSha $inventoryJson;if($inventoryDigest-cne[string]$Snapshot.provenance.source_inventory_digest){throw 'SNAPSHOT_SOURCE_INVENTORY_DIGEST_MISMATCH'}
  Assert-PortableUnique @($Snapshot.source_inventory|ForEach-Object source_id) 'SNAPSHOT_SOURCE_DUPLICATE';$sources=@{};foreach($source in @($Snapshot.source_inventory)){
    Assert-PortableRelative ([string]$source.relative_origin);$sources[[string]$source.source_id]=$source
    if ($source.source_type -eq 'confluence-page' -and ([string]::IsNullOrWhiteSpace([string]$source.space_id) -or [string]::IsNullOrWhiteSpace([string]$source.stable_object_id) -or [string]::IsNullOrWhiteSpace([string]$source.sync_checkpoint))) { throw 'SNAPSHOT_CONFLUENCE_BINDING_INVALID' }
    Assert-PortableUnique @($source.attachments|ForEach-Object attachment_id) 'SNAPSHOT_ATTACHMENT_DUPLICATE'
  }
  Assert-PortableUnique @($Snapshot.deltas|ForEach-Object delta_id) 'SNAPSHOT_DELTA_DUPLICATE';$deltas=@{};foreach($delta in @($Snapshot.deltas)){if(-not$sources.ContainsKey([string]$delta.source_id)){throw 'SNAPSHOT_DELTA_SOURCE_UNKNOWN'};$deltas[[string]$delta.delta_id]=$delta}
  Assert-PortableUnique @($Snapshot.tombstones | ForEach-Object tombstone_id) 'SNAPSHOT_TOMBSTONE_DUPLICATE'; $tombstoned = @{}; foreach ($t in @($Snapshot.tombstones)) { if (-not $deltas.ContainsKey([string]$t.delta_id)) { throw 'SNAPSHOT_TOMBSTONE_DELTA_UNKNOWN' }; $d = $deltas[[string]$t.delta_id]; if ($d.delta_type -notin @('deleted','inaccessible') -or [string]$d.source_id -cne [string]$t.source_id -or [string]$d.delta_type -cne [string]$t.reason) { throw 'SNAPSHOT_TOMBSTONE_RELATION_INVALID' }; $tombstoned[[string]$t.delta_id] = $true }
  foreach ($d in @($Snapshot.deltas | Where-Object delta_type -in @('deleted','inaccessible'))) { if (-not $tombstoned.ContainsKey([string]$d.delta_id)) { throw 'SNAPSHOT_TOMBSTONE_MISSING' } }
  foreach ($k in @($Snapshot.knowledge_change_sets)) { foreach ($id in @($k.source_ids)) { if (-not $sources.ContainsKey([string]$id)) { throw 'SNAPSHOT_KNOWLEDGE_SOURCE_UNKNOWN' } }; if ($k.projected_as_truth -and $k.review_status -ne 'accepted') { throw 'SNAPSHOT_UNREVIEWED_KNOWLEDGE_TRUTH' } }
  foreach ($c in @($Snapshot.coverage_matrix)) { if ([int]$c.covered -gt [int]$c.expected) { throw 'SNAPSHOT_COVERAGE_INVALID' }; if ($c.covered -lt $c.expected -and $c.status -eq 'complete') { throw 'SNAPSHOT_COVERAGE_STATUS_INVALID' } }
  foreach($c in @($Snapshot.contradictions)){foreach($id in @($c.source_ids)){if(-not$sources.ContainsKey([string]$id)){throw 'SNAPSHOT_CONTRADICTION_SOURCE_UNKNOWN'}}}
  foreach ($row in @($Snapshot.brownfield_reconciliation.import_matrix)) { if (-not $sources.ContainsKey([string]$row.source_id)) { throw 'SNAPSHOT_BROWNFIELD_SOURCE_UNKNOWN' }; if ($row.baseline_status -ne 'known' -and [string]::IsNullOrWhiteSpace([string]$row.open_gap)) { throw 'SNAPSHOT_BROWNFIELD_GAP_MISSING' } }
  $internal = @{}; foreach ($v in @($Snapshot.views | Where-Object audience -eq 'internal')) { foreach ($a in @($v.artifact_refs)) { $internal[[string]$a] = $true } }; foreach ($v in @($Snapshot.views | Where-Object audience -eq 'customer-specific')) { foreach ($a in @($v.artifact_refs)) { if ($internal.ContainsKey([string]$a) -and ([string]$a).StartsWith('INT-')) { throw 'SNAPSHOT_VIEW_BOUNDARY_LEAK' } } }
  $true
}
function Test-PortableSnapshotCatalog([string]$Path){
  $root=[IO.Path]::GetFullPath($Path);$catalogPath=Join-Path $root 'catalog.json';$catalog=Read-PortableJson $catalogPath;Test-PortableSchema $catalog 'spectra-multi-customer-catalog.schema.json';if(($catalog|ConvertTo-Json -Depth 30 -Compress)-match'"source_commit"'){throw 'SNAPSHOT_COMMIT_RUNTIME_INTERFACE_FORBIDDEN'}
  Assert-PortableUnique @($catalog.customers|ForEach-Object customer_id) 'SNAPSHOT_CUSTOMER_DUPLICATE';$projectIds=@{}
  foreach($customer in @($catalog.customers)){foreach($project in @($customer.projects)){
    $projectKey="$($customer.customer_id)/$($project.project_id)";if($projectIds.ContainsKey($projectKey)){throw 'SNAPSHOT_PROJECT_DUPLICATE'};$projectIds[$projectKey]=$true;Assert-PortableRelative ([string]$project.release_manifest_path)
    $releasePath=Join-Path $root ($project.release_manifest_path -replace '/', [IO.Path]::DirectorySeparatorChar);$release=Read-PortableJson $releasePath;Test-PortableSchema $release 'portable-snapshot-release.schema.json';if (-not $release.immutable -or $release.state -ne 'approved') { throw 'SNAPSHOT_RELEASE_NOT_APPROVED' }
    if([string]$release.customer_id-cne[string]$customer.customer_id-or[string]$release.project_id-cne[string]$project.project_id){throw 'SNAPSHOT_CROSS_CUSTOMER_LEAKAGE'}
    $releaseDir=Split-Path -Parent $releasePath;Assert-PortableRelative ([string]$release.snapshot_path);$snapshotPath=Join-Path $releaseDir ($release.snapshot_path-replace'/',[IO.Path]::DirectorySeparatorChar);$digest=Get-PortableSha $snapshotPath
    if($digest-cne[string]$release.snapshot_sha256-or$digest-cne[string]$project.snapshot_sha256){throw 'SNAPSHOT_RELEASE_DIGEST_MISMATCH'}
    if([string]$release.transports.filesystem.payload_sha256-cne$digest-or[string]$release.transports.http.payload_sha256-cne$digest){throw 'SNAPSHOT_TRANSPORT_DIVERGENCE'}
    try{$httpBytes=[Convert]::FromBase64String([string]$release.transports.http.content_base64)}catch{throw 'SNAPSHOT_HTTP_BYTES_INVALID'};$fileBytes=[IO.File]::ReadAllBytes($snapshotPath);if($httpBytes.Length-ne$fileBytes.Length){throw 'SNAPSHOT_TRANSPORT_BYTES_DIVERGENCE'};for($byteIndex=0;$byteIndex-lt$fileBytes.Length;$byteIndex++){if($httpBytes[$byteIndex]-ne$fileBytes[$byteIndex]){throw 'SNAPSHOT_TRANSPORT_BYTES_DIVERGENCE'}}
    if([string]$release.transports.filesystem.location-cne[string]$release.snapshot_path){throw 'SNAPSHOT_FILESYSTEM_TRANSPORT_INVALID'}
    $snapshot=Read-PortableJson $snapshotPath;Test-PortableSnapshotObject $snapshot|Out-Null;if([string]$snapshot.customer_id-cne[string]$customer.customer_id-or[string]$snapshot.project_id-cne[string]$project.project_id-or[string]$snapshot.snapshot_id-cne[string]$release.snapshot_id){throw 'SNAPSHOT_RELEASE_BINDING_MISMATCH'}
    $currentPath=Join-Path (Split-Path -Parent (Split-Path -Parent $releaseDir)) 'current.json';$current=Read-PortableJson $currentPath;if([string]$current.release_id-cne[string]$release.release_id-or[string]$current.snapshot_sha256-cne$digest-or[string]$current.release_manifest_path-cne[string]$project.release_manifest_path){throw 'SNAPSHOT_CURRENT_POINTER_INVALID'}
  }};$true
}
