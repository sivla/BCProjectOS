[CmdletBinding()]
param([Parameter(Mandatory)][string]$BlueprintId,[Parameter(Mandatory)][string]$OutputPath,[string]$TargetPath)
$ErrorActionPreference='Stop'
$catalogPath=Join-Path $PSScriptRoot '..\catalogs\blueprint-catalog-v2.json'
$catalog=Get-Content -Raw $catalogPath | ConvertFrom-Json
$bp=@($catalog.blueprints | Where-Object blueprint_id -ceq $BlueprintId)
if($bp.Count -ne 1){throw 'BLUEPRINT_UNKNOWN'}
New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null
$targetRevision='none';$targetDigest='none';$targetState='absent'
if($TargetPath){
  if(-not (Test-Path -LiteralPath $TargetPath -PathType Leaf)){throw 'BLUEPRINT_TARGET_UNSAFE'}
  $targetRevision=(Get-FileHash -LiteralPath $TargetPath -Algorithm SHA256).Hash.ToLowerInvariant();$targetDigest=$targetRevision;$targetState='observed'
}
$trees=@($catalog.page_trees | Where-Object {$_.space_id -in @($bp[0].page_tree_refs)})
if($trees.Count -ne @($bp[0].page_tree_refs).Count){throw 'BLUEPRINT_PAGE_TREE_REF_UNKNOWN'}
$preview=[ordered]@{preview_schema='1.0';proposal_id=('proposal-'+$BlueprintId);blueprint_id=$bp[0].blueprint_id;blueprint_version=$bp[0].version;provenance=$bp[0].provenance;target_revision=$targetRevision;target_digest=$targetDigest;target_state=$targetState;action='proposal-only';mutations=@();conflicts=@();modules=@($bp[0].modules | ForEach-Object {[ordered]@{module_id=$_.module_id;title=$_.title;space=$_.space;content_boundary=$_.content_boundary;required=$_.required;optional=$_.optional;leading_locations=@($_.templates | ForEach-Object leading_location);templates=@($_.templates | ForEach-Object {[ordered]@{template_id=$_.template_id;purpose=$_.purpose;leading_location=$_.leading_location}});tickets=@($_.tickets | ForEach-Object {[ordered]@{ticket_id=$_.ticket_id;type=$_.type;parent_id=$_.parent_id;billable=$_.billable}})}});page_trees=@($trees | ForEach-Object {[ordered]@{space_id=$_.space_id;home_node_id=$_.home_node_id;nodes=@($_.nodes | ForEach-Object {[ordered]@{node_id=$_.node_id;title=$_.title;order=$_.order;parent_node_id=$_.parent_node_id;leading_location=$_.leading_location;required_when=$_.required_when;create_when_content_available=$_.create_when_content_available}})}})}
$json=$preview | ConvertTo-Json -Depth 20
[IO.File]::WriteAllText((Join-Path $OutputPath 'preview.json'),$json,(New-Object Text.UTF8Encoding($false)))
[IO.File]::WriteAllText((Join-Path $OutputPath 'proposal.json'),($preview | ConvertTo-Json -Depth 20),(New-Object Text.UTF8Encoding($false)))
Write-Output ('PREVIEW='+$BlueprintId)
