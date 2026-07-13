$ErrorActionPreference='Stop'
$root=Join-Path $PSScriptRoot '..';$base=Join-Path $root 'catalogs/blueprint-catalog-v2.json'
$cases=@(
 @{n='unknown';c='BLUEPRINT_KIND_UNKNOWN';m={param($x)$x.blueprints[0].kind='customer'}},
 @{n='customer';c='BLUEPRINT_CUSTOMER_DATA_BLOCKED';m={param($x)$x.blueprints[0].purpose='UABC customer'}},
 @{n='billable';c='BLUEPRINT_BILLABLE_NON_TASK';m={param($x)$x.blueprints[2].modules[2].tickets[0].billable=$true}},
 @{n='empty-required';c='BLUEPRINT_REQUIRED_TEMPLATE_EMPTY';m={param($x)$x.blueprints[0].modules[0].templates=@()}},
 @{n='provenance';c='BLUEPRINT_PROVENANCE_REQUIRED';m={param($x)$x.blueprints[0].provenance.revision=''}},
 @{n='duplicate';c='BLUEPRINT_ID_DUPLICATE';m={param($x)$x.blueprints[1].blueprint_id=$x.blueprints[0].blueprint_id}},
 @{n='boundary';c='BLUEPRINT_CONTENT_BOUNDARY_INVALID';m={param($x)$x.blueprints[2].content_boundaries.product=$x.blueprints[2].content_boundaries.customer}},
 @{n='support-project';c='BLUEPRINT_SUPPORT_PROJECT_REQUIRED';m={param($x)$x.blueprints[1].required_fields=@('customer_id','project_id')}},
 @{n='paths';c='BLUEPRINT_TICKET_PATH_MISSING';m={param($x)$x.blueprints[2].modules[2].tickets=@($x.blueprints[2].modules[2].tickets | Where-Object type -notin @('story','bug'))}},
 @{n='candidate-status';c='BLUEPRINT_CANDIDATE_STATUS_INVALID';m={param($x)$x.blueprint_candidates[0].review_status='accepted'}},
 @{n='candidate-ref';c='BLUEPRINT_CANDIDATE_BLUEPRINT_UNKNOWN';m={param($x)$x.blueprint_candidates[0].blueprint_id='bp-unknown'}},
 @{n='space';c='BLUEPRINT_SPACE_MISSING';m={param($x)$x.blueprints[2].modules[1].space='customer'}}
 ,@{n='leading';c='BLUEPRINT_LEADING_INFORMATION_DUPLICATE';m={param($x)$x.blueprints[0].modules[1].templates[0].leading_location=$x.blueprints[0].modules[0].templates[0].leading_location}}
 ,@{n='node-missing';c='BLUEPRINT_PAGE_NODE_MISSING';m={param($x)$x.page_trees[0].nodes=@()}}
 ,@{n='order';c='BLUEPRINT_PAGE_ORDER_DUPLICATE';m={param($x)$x.page_trees[1].nodes[1].order=$x.page_trees[1].nodes[0].order}}
 ,@{n='parent';c='BLUEPRINT_PAGE_PARENT_UNKNOWN';m={param($x)$x.page_trees[1].nodes[1].parent_node_id='node-unknown'}}
 ,@{n='page-leading';c='BLUEPRINT_PAGE_LEADING_DUPLICATE';m={param($x)$x.page_trees[2].nodes[1].leading_location=$x.page_trees[2].nodes[0].leading_location}}
 ,@{n='page-empty';c='BLUEPRINT_PAGE_REQUIRED_EMPTY';m={param($x)$x.page_trees[0].nodes[0].title=''}}
 ,@{n='support-space';c='BLUEPRINT_SUPPORT_FOREIGN_SPACE';m={param($x)$x.blueprints[1].page_tree_refs=@('customer','product')}}
 ,@{n='cross-parent';c='BLUEPRINT_PAGE_PARENT_CROSS_SPACE';m={param($x)$x.page_trees[1].nodes[1].parent_node_id='node-customer-00'}}
 ,@{n='cycle';c='BLUEPRINT_PAGE_CYCLE';m={param($x)$x.page_trees[1].nodes[1].parent_node_id='node-product-02';$x.page_trees[1].nodes[2].parent_node_id='node-product-01'}}
 ,@{n='legacy-unknown';c='BLUEPRINT_LEGACY_REF_UNKNOWN';m={param($x)$x.blueprints[0].legacy_package_refs[0]='BPC-UNKNOWN'}}
 ,@{n='legacy-ambiguous';c='BLUEPRINT_LEGACY_MAPPING_AMBIGUOUS';m={param($x)$x.blueprints[0].legacy_package_refs=@($x.blueprints[0].legacy_package_refs[0],$x.blueprints[0].legacy_package_refs[0])}}
)
foreach($case in $cases){
  $tmp=Join-Path $env:TEMP ('blueprint-neg-'+[guid]::NewGuid().ToString('N'));New-Item -ItemType Directory -Force $tmp|Out-Null
  try{$x=Get-Content -Raw $base|ConvertFrom-Json;& $case.m $x;$p=Join-Path $tmp 'catalog.json';$x|ConvertTo-Json -Depth 30|Set-Content -LiteralPath $p -Encoding utf8
    $s=[Diagnostics.ProcessStartInfo]::new();$s.FileName='powershell.exe';$s.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Run-BlueprintCatalogV2Exact.ps1`" -CatalogPath `"$p`"";$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.RedirectStandardError=$true;$proc=[Diagnostics.Process]::Start($s);$o=$proc.StandardOutput.ReadToEnd().Trim();$e=$proc.StandardError.ReadToEnd().Trim();$proc.WaitForExit();if($proc.ExitCode -ne 1 -or $e -ne '' -or $o -cne $case.c){throw "BLUEPRINT_NEGATIVE_ORACLE:$($case.n):$o"};Write-Output "PASS $($case.n) ($($case.c))"}finally{if(Test-Path $tmp){Remove-Item -LiteralPath $tmp -Recurse -Force}}
}
Write-Output "PASS: $($cases.Count) isolierte Blueprint-Negativfaelle."
