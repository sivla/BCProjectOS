[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Destination)
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath($Destination)
if(Test-Path $root){throw 'GRAPH_COVERAGE_TARGET_EXISTS'}
$utf8=New-Object Text.UTF8Encoding($false)
function Write-Json([string]$Path,$Value){$directory=Split-Path -Parent $Path;if(-not(Test-Path $directory)){New-Item -ItemType Directory -Force $directory|Out-Null};[IO.File]::WriteAllText($Path,(($Value|ConvertTo-Json -Depth 30)+"`n"),$utf8)}

$native=@()
$native+=@(1..4|ForEach-Object{[ordered]@{id="NREL-PAGE-TICKET-$_";class='page-ticket-link';from="PAGE-$_";to="TICKET-$_"}})
$native+=@(1..4|ForEach-Object{[ordered]@{id="NREL-TICKET-EVIDENCE-$_";class='ticket-evidence-detail';from="TICKET-$_";to="EVIDENCE-$([math]::Ceiling($_/2))"}})
$native+=@(1..2|ForEach-Object{[ordered]@{id="NREL-DECISION-DELIVERABLE-$_";class='decision-deliverable-link';from="DECISION-$_";to="DELIVERABLE-$_"}})
$native+=@(1..2|ForEach-Object{[ordered]@{id="NREL-INTERNAL-ORDER-$_";class='internal-display-order';from="ITEM-$_";to="ITEM-$($_+1)"}})
$portable=@()
$portable+=@(1..4|ForEach-Object{[ordered]@{id="EDGE-PAGE-TICKET-$_";class='page-ticket';from="PAGE-$_";to="TICKET-$_"}})
$portable+=@(1..2|ForEach-Object{[ordered]@{id="EDGE-TICKET-EVIDENCE-$_";class='ticket-evidence';from="TICKET-$($_*2-1)";to="EVIDENCE-$_"}})
$portable+=@(1..2|ForEach-Object{[ordered]@{id="EDGE-DECISION-DELIVERABLE-$_";class='decision-deliverable';from="DECISION-$_";to="DELIVERABLE-$_"}})
$mappings=@(
  [ordered]@{mapping_id='MAP-PAGE-TICKET';native_class='page-ticket-link';portable_class='page-ticket';outcome='projected';native_count=4;portable_edge_count=4;reason_code='direct'},
  [ordered]@{mapping_id='MAP-TICKET-EVIDENCE';native_class='ticket-evidence-detail';portable_class='ticket-evidence';outcome='merged';native_count=4;portable_edge_count=2;reason_code='merged-duplicates'},
  [ordered]@{mapping_id='MAP-DECISION-DELIVERABLE';native_class='decision-deliverable-link';portable_class='decision-deliverable';outcome='transformed';native_count=2;portable_edge_count=2;reason_code='transformed-domain'},
  [ordered]@{mapping_id='MAP-INTERNAL-ORDER';native_class='internal-display-order';portable_class=$null;outcome='excluded';native_count=2;portable_edge_count=0;reason_code='excluded-nonportable'}
)
$nativePath=Join-Path $root 'graph\native-relations.json';$portablePath=Join-Path $root 'graph\portable-graph.json';$mappingPath=Join-Path $root 'graph\mapping-rules.json'
Write-Json $nativePath ([ordered]@{relations=$native});Write-Json $portablePath ([ordered]@{edges=$portable});Write-Json $mappingPath ([ordered]@{mappings=$mappings})
function Hash([string]$Path){(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
$coverage=[ordered]@{
  schema_version=1;contract_version='1.0.0';record_type='reference-graph-projection-coverage';coverage_id='RGC-SYNTHETIC-GENERIC';product_id='spectra';classification='synthetic-fixture';coverage_semantics='explained-native-relations'
  native_relation_classes=@([ordered]@{class_id='page-ticket-link';count=4},[ordered]@{class_id='ticket-evidence-detail';count=4},[ordered]@{class_id='decision-deliverable-link';count=2},[ordered]@{class_id='internal-display-order';count=2})
  portable_relation_classes=@([ordered]@{class_id='page-ticket';count=4},[ordered]@{class_id='ticket-evidence';count=2},[ordered]@{class_id='decision-deliverable';count=2})
  mappings=$mappings
  summary=[ordered]@{native_total=12;portable_edge_total=8;accounted_native_total=12;projected_native_total=10;excluded_native_total=2;coverage_numerator=12;coverage_denominator=12;coverage_ratio=1.0}
  provenance=[ordered]@{source=[ordered]@{path='graph/native-relations.json';sha256=(Hash $nativePath)};mapping=[ordered]@{path='graph/mapping-rules.json';sha256=(Hash $mappingPath)};projection=[ordered]@{path='graph/portable-graph.json';sha256=(Hash $portablePath)};digest_algorithm='SHA-256';source_mode='read-only';source_unchanged=$true;writes_performed=$false;projection_only=$true}
  claims=[ordered]@{one_to_one_claim=$false;complete_projection_claim=$false;explanation_complete=$true}
}
Write-Json (Join-Path $root 'graph\reference-graph-coverage.json') $coverage
Write-Host 'PASS: Synthetisches Referenzgraph-Coverage-Fixture wurde deterministisch erzeugt.'
