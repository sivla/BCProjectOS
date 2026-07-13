[CmdletBinding()]param()
$ErrorActionPreference='Stop';Set-StrictMode -Version 2.0;. (Join-Path $PSScriptRoot 'PortableSnapshot.Catalog.ps1')
$temp=Join-Path ([IO.Path]::GetTempPath()) ('snapshot-negative-'+[guid]::NewGuid().ToString('N'));$passed=0
function Context([string]$Root){$catalogPath=Join-Path $Root 'catalog.json';$catalog=Read-PortableJson $catalogPath;$project=$catalog.customers[0].projects[0];$releasePath=Join-Path $Root ($project.release_manifest_path-replace'/',[IO.Path]::DirectorySeparatorChar);$release=Read-PortableJson $releasePath;$snapshotPath=Join-Path (Split-Path -Parent $releasePath) $release.snapshot_path;$snapshot=Read-PortableJson $snapshotPath;[ordered]@{catalogPath=$catalogPath;catalog=$catalog;project=$project;releasePath=$releasePath;release=$release;snapshotPath=$snapshotPath;snapshot=$snapshot;currentPath=Join-Path $Root "customers\$($catalog.customers[0].customer_id)\projects\$($project.project_id)\snapshots\current.json"}}
function Rebind($c){Write-PortableJson $c.snapshotPath $c.snapshot;$digest=Get-PortableSha $c.snapshotPath;$c.release.snapshot_sha256=$digest;$c.release.transports.filesystem.payload_sha256=$digest;$c.release.transports.http.payload_sha256=$digest;$c.release.transports.http.content_base64=[Convert]::ToBase64String([IO.File]::ReadAllBytes($c.snapshotPath));Write-PortableJson $c.releasePath $c.release;$c.catalog.customers[0].projects[0].snapshot_sha256=$digest;Write-PortableJson $c.catalogPath $c.catalog;$current=Read-PortableJson $c.currentPath;$current.snapshot_sha256=$digest;Write-PortableJson $c.currentPath $current}
function Case([string]$Name,[string]$Expected,[scriptblock]$Mutation,[switch]$RebindSnapshot){$d=Join-Path $temp $Name;& (Join-Path $PSScriptRoot 'New-SyntheticPortableSnapshotCatalog.ps1') -Destination $d|Out-Null;$c=Context $d;&$Mutation $c;if($RebindSnapshot){Rebind $c};try{Test-PortableSnapshotCatalog $d|Out-Null;throw "NEGATIVE_ACCEPTED:$Name"}catch{if(-not$_.Exception.Message.StartsWith($Expected,[StringComparison]::Ordinal)){throw "NEGATIVE_WRONG:${Name}:$($_.Exception.Message)"}};$script:passed++}
try{New-Item -ItemType Directory -Path $temp|Out-Null
  Case unknown-source 'SNAPSHOT_SCHEMA_INVALID' {param($c)$c.snapshot.source_inventory[0].source_type='unknown'} -RebindSnapshot
  Case unstable-id 'SNAPSHOT_SCHEMA_INVALID' {param($c)$c.snapshot.source_inventory[0].stable_object_id=''} -RebindSnapshot
  Case bad-hash 'SNAPSHOT_SCHEMA_INVALID' {param($c)$c.snapshot.source_inventory[0].content_sha256='bad'} -RebindSnapshot
  Case absolute-path 'SNAPSHOT_SCHEMA_INVALID' {param($c)$c.snapshot.source_inventory[0].relative_origin='C:/private/source.json'} -RebindSnapshot
  Case missing-checkpoint 'SNAPSHOT_SCHEMA_INVALID' {param($c)$c.snapshot.source_inventory[0].PSObject.Properties.Remove('sync_checkpoint')} -RebindSnapshot
  Case inventory-digest 'SNAPSHOT_SOURCE_INVENTORY_DIGEST_MISMATCH' {param($c)$c.snapshot.provenance.source_inventory_digest=('9'*64)} -RebindSnapshot
  Case tombstone-missing 'SNAPSHOT_TOMBSTONE_MISSING' {param($c)$c.snapshot.tombstones=@($c.snapshot.tombstones | Where-Object reason -ne 'deleted')} -RebindSnapshot
  Case tombstone-relation 'SNAPSHOT_TOMBSTONE_RELATION_INVALID' {param($c)$c.snapshot.tombstones[0].reason='inaccessible'} -RebindSnapshot
  Case unreviewed-truth 'SNAPSHOT_UNREVIEWED_KNOWLEDGE_TRUTH' {param($c)$c.snapshot.knowledge_change_sets[1].projected_as_truth=$true} -RebindSnapshot
  Case no-approved-release 'SNAPSHOT_SCHEMA_INVALID' {param($c)$c.release.state='draft';Write-PortableJson $c.releasePath $c.release}
  Case cross-customer 'SNAPSHOT_CROSS_CUSTOMER_LEAKAGE' {param($c)$c.release.customer_id='CUS-SYN-B';Write-PortableJson $c.releasePath $c.release}
  Case mutable-release 'SNAPSHOT_SCHEMA_INVALID' {param($c)$c.release.immutable=$false;Write-PortableJson $c.releasePath $c.release}
  Case transport-divergence 'SNAPSHOT_TRANSPORT_DIVERGENCE' {param($c)$c.release.transports.http.payload_sha256=('8'*64);Write-PortableJson $c.releasePath $c.release}
  Case transport-bytes-divergence 'SNAPSHOT_TRANSPORT_BYTES_DIVERGENCE' {param($c)$c.release.transports.http.content_base64=[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('different'));Write-PortableJson $c.releasePath $c.release}
  Case current-drift 'SNAPSHOT_CURRENT_POINTER_INVALID' {param($c)$current=Read-PortableJson $c.currentPath;$current.release_id='SRL-OTHER';Write-PortableJson $c.currentPath $current}
  Case coverage-invalid 'SNAPSHOT_COVERAGE_INVALID' {param($c)$c.snapshot.coverage_matrix[0].covered=4} -RebindSnapshot
  Case view-leak 'SNAPSHOT_VIEW_BOUNDARY_LEAK' {param($c)$c.snapshot.views[1].artifact_refs=@($c.snapshot.views[0].artifact_refs[0])} -RebindSnapshot
  if($passed-ne17){throw "SNAPSHOT_NEGATIVE_COUNT_INVALID:$passed"};Write-Host "PASS: $passed isolierte Snapshot-/Katalog-Negativfaelle."
}finally{if(Test-Path $temp){Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue}}
