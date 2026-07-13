[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference='Stop'
function Fail([string]$Code){throw $Code}
$root=[IO.Path]::GetFullPath($Path)
$file=Join-Path $root 'projection.json'
if(-not(Test-Path -LiteralPath $file -PathType Leaf)){Fail 'DOCUMENT_PROJECTION_FILE_MISSING'}
try{$x=Get-Content -LiteralPath $file -Raw|ConvertFrom-Json}catch{Fail 'DOCUMENT_PROJECTION_JSON_INVALID'}
$schema=Get-Content -LiteralPath (Join-Path $PSScriptRoot '..\schemas\document-projection.schema.json') -Raw|ConvertFrom-Json
$script:RootSchema=$schema
$script:InvokeSchema={param([AllowNull()]$v,$s,$p).(Join-Path $PSScriptRoot 'Invoke-PortableSchemaValidation.ps1') -Value $v -Schema $s -RootSchema $script:RootSchema -Path $p}
try{. (Join-Path $PSScriptRoot 'Invoke-PortableSchemaValidation.ps1') -Value $x -Schema $schema -RootSchema $schema -Path 'root'}catch{Fail ("DOCUMENT_PROJECTION_SCHEMA_INVALID:"+$_.Exception.Message.Split(':')[0])}
$customer=[string]$x.customer_id
$spaces=@($x.documentation.spaces);$nodes=@($x.documentation.nodes);$documents=@($x.documentation.documents);$refs=@($x.documentation.references);$prov=@($x.documentation.provenance);$tickets=@($x.jira.tickets);$views=@($x.jira.views)
$all=@($spaces)+@($nodes)+@($documents)+@($refs)+@($prov)+@($tickets)+@($views)
if(@($all|Group-Object id|Where-Object Count -gt 1).Count -gt 0){Fail 'DOCUMENT_PROJECTION_DUPLICATE_ID'}
foreach($item in $all){if([string]$item.customer_id -ne $customer){Fail 'DOCUMENT_PROJECTION_CROSS_CUSTOMER'}}
$spaceById=@{};foreach($s in $spaces){$spaceById[[string]$s.id]=$s;if($null-ne$s.external-and([string]$s.external.origin-notmatch'^https://[A-Za-z0-9.-]+$')){Fail 'DOCUMENT_PROJECTION_ORIGIN_UNSAFE'}}
$documentById=@{};$paths=@{};foreach($d in $documents){$documentById[[string]$d.id]=$d;$p=[string]$d.source_path;if([IO.Path]::IsPathRooted($p)-or$p-match'(^|[\\/])\.\.([\\/]|$)'-or$p.Contains('\')){Fail 'DOCUMENT_PROJECTION_PATH_UNSAFE'};if($paths.ContainsKey($p)){Fail 'DOCUMENT_PROJECTION_SOURCE_PATH_DUPLICATE'};$paths[$p]=$true;if([string]$d.content_mode-eq'generated'){if([string]::IsNullOrWhiteSpace([string]$d.blueprint_id)){Fail 'DOCUMENT_PROJECTION_BLUEPRINT_MISSING'};if(@($d.provenance_ids).Count-eq0){Fail 'DOCUMENT_PROJECTION_PROVENANCE_MISSING'};if(@($d.authored_sections).Count-ne0){Fail 'DOCUMENT_PROJECTION_GENERATED_AUTHORED_CONFLICT'}}else{if(@($d.provenance_ids).Count-ne0){Fail 'DOCUMENT_PROJECTION_AUTHORED_PROVENANCE_CONFLICT'}}}
$provIds=@($prov.id);foreach($d in $documents){foreach($id in @($d.provenance_ids)){if($provIds-notcontains[string]$id){Fail 'DOCUMENT_PROJECTION_PROVENANCE_UNKNOWN'}}}
$nodeById=@{};foreach($n in $nodes){$nodeById[[string]$n.id]=$n;if(-not$spaceById.ContainsKey([string]$n.space_id)){Fail 'DOCUMENT_PROJECTION_SPACE_UNKNOWN'};if(-not$documentById.ContainsKey([string]$n.document_id)){Fail 'DOCUMENT_PROJECTION_DOCUMENT_UNKNOWN'}}
foreach($n in $nodes){if($null-ne$n.parent_id){if(-not$nodeById.ContainsKey([string]$n.parent_id)){Fail 'DOCUMENT_PROJECTION_PARENT_UNKNOWN'};if([string]$nodeById[[string]$n.parent_id].space_id-ne[string]$n.space_id){Fail 'DOCUMENT_PROJECTION_PARENT_CROSS_SPACE'}};$seen=@{};$cur=$n;while($null-ne$cur.parent_id){if($seen.ContainsKey([string]$cur.id)){Fail 'DOCUMENT_PROJECTION_NODE_CYCLE'};$seen[[string]$cur.id]=$true;$cur=$nodeById[[string]$cur.parent_id]}}
foreach($group in @($nodes|Group-Object {"$($_.space_id)|$($_.parent_id)|$($_.order)"})){if($group.Count-gt1){Fail 'DOCUMENT_PROJECTION_ORDER_DUPLICATE'}}
foreach($s in $spaces){if(-not$nodeById.ContainsKey([string]$s.home_node_id)-or-not$documentById.ContainsKey([string]$s.home_document_id)){Fail 'DOCUMENT_PROJECTION_HOME_UNKNOWN'};$homeNode=$nodeById[[string]$s.home_node_id];if([string]$homeNode.space_id-ne[string]$s.id-or[string]$homeNode.document_id-ne[string]$s.home_document_id){Fail 'DOCUMENT_PROJECTION_HOME_MISMATCH'}}
$domains=@{space=@($spaces.id);node=@($nodes.id);document=@($documents.id);ticket=@($tickets.id);view=@($views.id);provenance=@($prov.id)}
foreach($r in $refs){foreach($end in @($r.from,$r.to)){if(-not$domains.ContainsKey([string]$end.domain)-or$domains[[string]$end.domain]-notcontains[string]$end.id){Fail 'DOCUMENT_PROJECTION_REFERENCE_UNKNOWN'}}}
foreach($v in $views){foreach($id in @($v.ticket_ids)){if(@($tickets.id)-notcontains[string]$id){Fail 'DOCUMENT_PROJECTION_VIEW_TICKET_UNKNOWN'}}}
Write-Host 'PASS: Dokumentation und Jira sind unabhängig, hierarchisch und quellgebunden valide.'
