[CmdletBinding()]
param([Parameter(Mandatory)][string]$CatalogPath)
$ErrorActionPreference='Stop'
function Fail([string]$c){throw $c}
if(-not (Test-Path -LiteralPath $CatalogPath -PathType Leaf)){Fail 'BLUEPRINT_CATALOG_MISSING'}
try{$catalog=Get-Content -Raw $CatalogPath | ConvertFrom-Json}catch{Fail 'BLUEPRINT_SCHEMA_INVALID'}
$schemaPath=Join-Path $PSScriptRoot '..\schemas\blueprint-catalog-v2.schema.json';$schema=Get-Content -Raw $schemaPath | ConvertFrom-Json
$script:RootSchema=$schema
$script:InvokeSchema={param([AllowNull()]$v,$s,$p) . (Join-Path $PSScriptRoot 'Invoke-PortableSchemaValidation.ps1') -Value $v -Schema $s -RootSchema $script:RootSchema -Path $p}
try { . (Join-Path $PSScriptRoot 'Invoke-PortableSchemaValidation.ps1') -Value $catalog -Schema $schema -RootSchema $schema -Path root } catch { Fail 'BLUEPRINT_SCHEMA_INVALID' }
if($catalog.product_id -cne 'spectra' -or $catalog.schema_version -ne 1 -or $catalog.catalog_version -cne '2.0'){Fail 'BLUEPRINT_SCHEMA_INVALID'}
$seen=@{}
foreach($bp in @($catalog.blueprints)){
  $ticketSeen=@{};$leading=@{}
  if($seen.ContainsKey($bp.blueprint_id)){Fail 'BLUEPRINT_ID_DUPLICATE'};$seen[$bp.blueprint_id]=$true
  if($bp.lifecycle -ne 'template'){Fail 'BLUEPRINT_LIFECYCLE_INVALID'}
  if($bp.provenance.source -cne 'spectra-catalog' -or [string]::IsNullOrWhiteSpace($bp.provenance.revision)){Fail 'BLUEPRINT_PROVENANCE_REQUIRED'}
  if($bp.kind -notin @('implementation','support-only','bc-basic')){Fail 'BLUEPRINT_KIND_UNKNOWN'}
  if($bp.content_boundaries.customer -eq $bp.content_boundaries.product -or $bp.content_boundaries.product -eq $bp.content_boundaries.consulting){Fail 'BLUEPRINT_CONTENT_BOUNDARY_INVALID'}
  if($bp.kind -eq 'support-only' -and @($bp.required_fields) -contains 'project_id'){Fail 'BLUEPRINT_SUPPORT_PROJECT_REQUIRED'}
  if($bp.kind -eq 'support-only' -and @($bp.page_tree_refs) -contains 'product'){Fail 'BLUEPRINT_SUPPORT_FOREIGN_SPACE'}
  if($bp.kind -eq 'bc-basic'){
    $spaces=@($bp.modules | ForEach-Object space)
    foreach($requiredSpace in @('customer','product','consulting')){if($spaces -notcontains $requiredSpace){Fail 'BLUEPRINT_SPACE_MISSING'}}
    $types=@($bp.modules | ForEach-Object { @($_.tickets | ForEach-Object type) })
    if($types -notcontains 'story' -or $types -notcontains 'bug'){Fail 'BLUEPRINT_TICKET_PATH_MISSING'}
  }
  foreach($ref in @($bp.page_tree_refs)){if(@($catalog.page_trees | ForEach-Object space_id) -notcontains $ref){Fail 'BLUEPRINT_PAGE_TREE_REF_UNKNOWN'}}
  foreach($m in @($bp.modules)){
    if($m.required -and @($m.templates).Count -eq 0){Fail 'BLUEPRINT_REQUIRED_TEMPLATE_EMPTY'}
    foreach($t in @($m.templates)){if([string]::IsNullOrWhiteSpace($t.leading_location)){Fail 'BLUEPRINT_TEMPLATE_REQUIRED_FIELD'};if($leading.ContainsKey($t.leading_location)){Fail 'BLUEPRINT_LEADING_INFORMATION_DUPLICATE'};$leading[$t.leading_location]=$true }
    foreach($ticket in @($m.tickets)){
      if($ticketSeen.ContainsKey($ticket.ticket_id)){Fail 'BLUEPRINT_ID_DUPLICATE'};$ticketSeen[$ticket.ticket_id]=$true
      if($ticket.billable -and $ticket.type -ne 'task'){Fail 'BLUEPRINT_BILLABLE_NON_TASK'}
      if($ticket.type -notin @('phase','epic','story','bug','task')){Fail 'BLUEPRINT_TICKET_TYPE_INVALID'}
    }
  }
}
$candidateIds=@{};foreach($candidate in @($catalog.blueprint_candidates)){if($candidate.review_status -ne 'pending'){Fail 'BLUEPRINT_CANDIDATE_STATUS_INVALID'};if($candidateIds.ContainsKey($candidate.candidate_id)){Fail 'BLUEPRINT_ID_DUPLICATE'};$candidateIds[$candidate.candidate_id]=$true;if(@($catalog.blueprints | ForEach-Object blueprint_id) -notcontains $candidate.blueprint_id){Fail 'BLUEPRINT_CANDIDATE_BLUEPRINT_UNKNOWN'}}
$text=Get-Content -Raw $CatalogPath
if($text -match '(?i)Universaarl|UABC|password\s*=|api[_-]?token|tenant\s*[:=]'){Fail 'BLUEPRINT_CUSTOMER_DATA_BLOCKED'}
$treeIds=@{};$globalNodes=@{}
foreach($tree in @($catalog.page_trees)){foreach($node in @($tree.nodes)){if($globalNodes.ContainsKey($node.node_id)){Fail 'BLUEPRINT_PAGE_NODE_DUPLICATE'};$globalNodes[$node.node_id]=[pscustomobject]@{Node=$node;Space=$tree.space_id}}}
foreach($tree in @($catalog.page_trees)){
  $nodes=@($tree.nodes);$byId=@{};$orders=@{};$locations=@{}
  if($nodes.Count -eq 0 -or $tree.home_node_id -notin @($nodes | ForEach-Object node_id)){Fail 'BLUEPRINT_PAGE_NODE_MISSING'}
  foreach($node in $nodes){
    if($byId.ContainsKey($node.node_id)){Fail 'BLUEPRINT_PAGE_NODE_DUPLICATE'};$byId[$node.node_id]=$node
    if($orders.ContainsKey([string]$node.order)){Fail 'BLUEPRINT_PAGE_ORDER_DUPLICATE'};$orders[[string]$node.order]=$true
    if($locations.ContainsKey($node.leading_location)){Fail 'BLUEPRINT_PAGE_LEADING_DUPLICATE'};$locations[$node.leading_location]=$true
    if([string]::IsNullOrWhiteSpace($node.title)){Fail 'BLUEPRINT_PAGE_REQUIRED_EMPTY'}
  }
  foreach($node in $nodes){if($null -ne $node.parent_node_id -and -not $globalNodes.ContainsKey($node.parent_node_id)){Fail 'BLUEPRINT_PAGE_PARENT_UNKNOWN'};if($null -ne $node.parent_node_id -and $globalNodes[$node.parent_node_id].Space -ne $tree.space_id){Fail 'BLUEPRINT_PAGE_PARENT_CROSS_SPACE'}}
  foreach($node in $nodes){$seenCycle=@{};$cur=$node;while($null -ne $cur.parent_node_id){if($seenCycle.ContainsKey($cur.node_id)){Fail 'BLUEPRINT_PAGE_CYCLE'};$seenCycle[$cur.node_id]=$true;if(-not $globalNodes.ContainsKey($cur.parent_node_id)){break};$cur=$globalNodes[$cur.parent_node_id].Node}}
  if($treeIds.ContainsKey($tree.space_id)){Fail 'BLUEPRINT_SPACE_DUPLICATE'};$treeIds[$tree.space_id]=$true
}
Write-Output 'BLUEPRINT_VALID'
