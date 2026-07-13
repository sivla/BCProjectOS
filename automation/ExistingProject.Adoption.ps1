Set-StrictMode -Version 2.0

function Get-AdoptionProductRoot { [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')) }

function Read-AdoptionJson([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw 'ADOPTION_FILE_MISSING' }
  try { Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json }
  catch { throw 'ADOPTION_JSON_INVALID' }
}

function Write-AdoptionJson([string]$Path, $Value) {
  $parent = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  [IO.File]::WriteAllText($Path, (($Value | ConvertTo-Json -Depth 40) + "`n"), [Text.UTF8Encoding]::new($false))
}

function Get-AdoptionFileDigest([string]$Path) {
  (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-AdoptionTextDigest([string]$Text) {
  $sha = [Security.Cryptography.SHA256]::Create()
  try { ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($Text)))).Replace('-', '').ToLowerInvariant() }
  finally { $sha.Dispose() }
}

function Assert-AdoptionSafeRelativePath([string]$Value) {
  if ([string]::IsNullOrWhiteSpace($Value)) { throw 'ADOPTION_PATH_UNSAFE' }
  if ([IO.Path]::IsPathRooted($Value) -or $Value.Contains('\') -or $Value -match '(^|/)\.\.(/|$)') { throw 'ADOPTION_PATH_UNSAFE' }
}

function Assert-AdoptionHttpsOrigin([string]$Value) {
  try { $uri = [Uri]$Value } catch { throw 'ADOPTION_SITE_INVALID' }
  if ($uri.Scheme -cne 'https' -or -not [string]::IsNullOrEmpty($uri.UserInfo) -or $uri.AbsolutePath -ne '/' -or $uri.Query -or $uri.Fragment) { throw 'ADOPTION_SITE_INVALID' }
}

function Assert-AdoptionSchema($Value, [string]$SchemaName) {
  $root = Get-AdoptionProductRoot
  . (Join-Path $root 'automation\Spectra.JsonSchema.ps1')
  $schema = Read-AdoptionJson (Join-Path $root "schemas\$SchemaName")
  try { Test-SpectraJsonSchema -Value $Value -Schema $schema -RootSchema $schema -Path 'root' }
  catch { throw ('ADOPTION_SCHEMA_INVALID:' + $_.Exception.Message.Split([Environment]::NewLine)[0]) }
}

function Assert-AdoptionNoForbiddenContent($Value) {
  $json = $Value | ConvertTo-Json -Depth 50 -Compress
  if ($json -match '(?i)UABC-|Universaarl|Bearer\s+|"(?:token|password|secret|auth_state)"\s*:') { throw 'ADOPTION_FORBIDDEN_CONTENT' }
  if ($json -match '(?i)[A-Za-z]:\\|file://|\\\\[^\\]') { throw 'ADOPTION_PATH_UNSAFE' }
}

function Assert-AdoptionUnique($Values, [string]$Code) {
  $seen = @{}
  foreach ($value in @($Values)) {
    $key = [string]$value
    if ($seen.ContainsKey($key)) { throw $Code }
    $seen[$key] = $true
  }
}

function Test-ExistingProjectDiscovery {
  param([Parameter(Mandatory=$true)]$Discovery)
  Assert-AdoptionNoForbiddenContent $Discovery
  Assert-AdoptionHttpsOrigin ([string]$Discovery.jira.base_url)
  Assert-AdoptionHttpsOrigin ([string]$Discovery.confluence.base_url)
  Assert-AdoptionSchema $Discovery 'existing-project-discovery.schema.json'
  if ($null -eq $Discovery.jira.project) {
    if ($null -ne $Discovery.jira.board.project_id) { throw 'ADOPTION_BOARD_PROJECT_MISMATCH' }
  } elseif ([string]$Discovery.jira.board.project_id -cne [string]$Discovery.jira.project.id) { throw 'ADOPTION_BOARD_PROJECT_MISMATCH' }
  Assert-AdoptionUnique @($Discovery.jira.issue_types | ForEach-Object id) 'ADOPTION_ISSUE_TYPE_DUPLICATE'
  Assert-AdoptionUnique @($Discovery.jira.statuses | ForEach-Object id) 'ADOPTION_STATUS_DUPLICATE'
  Assert-AdoptionUnique @($Discovery.jira.fields | ForEach-Object id) 'ADOPTION_FIELD_DUPLICATE'
  Assert-AdoptionUnique @($Discovery.confluence.spaces | ForEach-Object id) 'ADOPTION_SPACE_DUPLICATE'
  Assert-AdoptionUnique @($Discovery.confluence.pages | ForEach-Object id) 'ADOPTION_PAGE_DUPLICATE'
  $spaces = @{}; foreach ($space in @($Discovery.confluence.spaces)) { $spaces[[string]$space.id] = $true }
  $pages = @{}; foreach ($page in @($Discovery.confluence.pages)) { $pages[[string]$page.id] = $page }
  foreach ($page in @($Discovery.confluence.pages)) {
    if (-not $spaces.ContainsKey([string]$page.space_id)) { throw 'ADOPTION_PAGE_SPACE_UNKNOWN' }
    if ($page.parent_id -and -not $pages.ContainsKey([string]$page.parent_id)) { throw 'ADOPTION_PAGE_PARENT_UNKNOWN' }
    if ($page.parent_id -and [string]$pages[[string]$page.parent_id].space_id -cne [string]$page.space_id) { throw 'ADOPTION_PAGE_PARENT_CROSS_SPACE' }
  }
  $true
}

function Test-ExistingProjectAdoptionConfig {
  param([Parameter(Mandatory=$true)]$Config, [Parameter(Mandatory=$true)]$Discovery, [string]$DiscoveryPath)
  Assert-AdoptionNoForbiddenContent $Config
  Assert-AdoptionSafeRelativePath ([string]$Config.discovery_binding.relative_path)
  Assert-AdoptionHttpsOrigin ([string]$Config.jira_binding.base_url)
  foreach ($binding in @($Config.confluence_bindings)) { Assert-AdoptionHttpsOrigin ([string]$binding.base_url) }
  Assert-AdoptionSchema $Config 'existing-project-adoption-config.schema.json'
  Test-ExistingProjectDiscovery $Discovery | Out-Null
  if (-not $Config.product_binding.version -or -not $Config.product_binding.commit -or -not $Config.product_binding.tree -or -not $Config.product_binding.digest) { throw 'ADOPTION_PRODUCT_UNPINNED' }
  if ($Config.workspace.profile -eq 'support-only') {
    if ($null -ne $Config.workspace.project_id -or $null -ne $Config.workspace.project_name -or $null -ne $Discovery.jira.project -or $null -ne $Config.jira_binding.project_id -or $null -ne $Config.jira_binding.project_key) { throw 'ADOPTION_SUPPORT_PROJECT_FORBIDDEN' }
  } elseif ([string]::IsNullOrWhiteSpace([string]$Config.workspace.project_id) -or [string]::IsNullOrWhiteSpace([string]$Config.workspace.project_name) -or $null -eq $Discovery.jira.project) { throw 'ADOPTION_PROJECT_REQUIRED' }
  if ([string]$Config.discovery_binding.discovery_id -cne [string]$Discovery.discovery_id) { throw 'ADOPTION_DISCOVERY_ID_MISMATCH' }
  if ([string]$Config.discovery_binding.source_revision -cne [string]$Discovery.source_revision) { throw 'ADOPTION_DISCOVERY_DRIFT' }
  if ($DiscoveryPath -and [string]$Config.discovery_binding.sha256 -cne (Get-AdoptionFileDigest $DiscoveryPath)) { throw 'ADOPTION_DISCOVERY_DIGEST_MISMATCH' }
  if ([string]$Config.jira_binding.base_url -cne [string]$Discovery.jira.base_url -or [string]$Config.jira_binding.site_id -cne [string]$Discovery.jira.site_id) { throw 'ADOPTION_JIRA_SITE_MISMATCH' }
  if ($null -ne $Discovery.jira.project -and ([string]$Config.jira_binding.project_id -cne [string]$Discovery.jira.project.id -or [string]$Config.jira_binding.project_key -cne [string]$Discovery.jira.project.key)) { throw 'ADOPTION_JIRA_PROJECT_MISMATCH' }
  if ([string]$Config.jira_binding.board_id -cne [string]$Discovery.jira.board.id -or [string]$Config.jira_binding.board_name -cne [string]$Discovery.jira.board.name) { throw 'ADOPTION_JIRA_BOARD_MISMATCH' }
  $spaces = @{}; foreach ($space in @($Discovery.confluence.spaces)) { $spaces[[string]$space.id] = $space }
  $pages = @{}; foreach ($page in @($Discovery.confluence.pages)) { $pages[[string]$page.id] = $page }
  foreach ($binding in @($Config.confluence_bindings)) {
    if ([string]$binding.base_url -cne [string]$Discovery.confluence.base_url -or [string]$binding.site_id -cne [string]$Discovery.confluence.site_id) { throw 'ADOPTION_CONFLUENCE_SITE_MISMATCH' }
    if (-not $spaces.ContainsKey([string]$binding.space_id) -or [string]$spaces[[string]$binding.space_id].key -cne [string]$binding.space_key) { throw 'ADOPTION_SPACE_BINDING_MISMATCH' }
    if ($binding.root_page_id) {
      if (-not $pages.ContainsKey([string]$binding.root_page_id)) { throw 'ADOPTION_ROOT_PAGE_UNKNOWN' }
      if ([string]$pages[[string]$binding.root_page_id].space_id -cne [string]$binding.space_id) { throw 'ADOPTION_ROOT_PAGE_SPACE_MISMATCH' }
    }
  }
  $observed = @{
    issue_types = @{}; statuses = @{}; fields = @{}; spaces = @{}
  }
  foreach ($item in @($Discovery.jira.issue_types)) { $observed.issue_types[[string]$item.id] = $true }
  foreach ($item in @($Discovery.jira.statuses)) { $observed.statuses[[string]$item.id] = $true }
  foreach ($item in @($Discovery.jira.fields)) { $observed.fields[[string]$item.id] = $true }
  foreach ($item in @($Discovery.confluence.spaces)) { $observed.spaces[[string]$item.id] = $true }
  foreach ($kind in @('issue_types','statuses','fields','space_roles')) {
    $entries = @($Config.mapping.$kind)
    Assert-AdoptionUnique @($entries | ForEach-Object source_id) "ADOPTION_MAPPING_DUPLICATE_$($kind.ToUpperInvariant())"
    $targetKind = if ($kind -eq 'space_roles') { 'spaces' } else { $kind }
    foreach ($entry in $entries) { if (-not $observed[$targetKind].ContainsKey([string]$entry.source_id)) { throw "ADOPTION_MAPPING_SOURCE_UNKNOWN_$($kind.ToUpperInvariant())" } }
  }
  foreach ($kind in @('issue_types','statuses')) {
    $mapped = @{}; foreach ($entry in @($Config.mapping.$kind)) { $mapped[[string]$entry.source_id] = $true }
    foreach ($id in $observed[$kind].Keys) { if (-not $mapped.ContainsKey($id)) { throw "ADOPTION_MAPPING_INCOMPLETE_$($kind.ToUpperInvariant())" } }
  }
  Assert-AdoptionUnique @($Config.mapping.space_roles | ForEach-Object target) 'ADOPTION_LEADING_CONTENT_DUPLICATE'
  $true
}

function Get-ExistingProjectInspection {
  param([Parameter(Mandatory=$true)][string]$DiscoveryPath)
  $discovery = Read-AdoptionJson $DiscoveryPath
  Test-ExistingProjectDiscovery $discovery | Out-Null
  [ordered]@{
    product_id='spectra';discovery_id=$discovery.discovery_id;source_revision=$discovery.source_revision;sha256=Get-AdoptionFileDigest $DiscoveryPath
    jira=[ordered]@{project=$discovery.jira.project;board=$discovery.jira.board;issue_type_count=@($discovery.jira.issue_types).Count;status_count=@($discovery.jira.statuses).Count;field_count=@($discovery.jira.fields).Count}
    confluence=[ordered]@{space_count=@($discovery.confluence.spaces).Count;page_count=@($discovery.confluence.pages).Count;spaces=@($discovery.confluence.spaces)}
    writes_performed=$false
  }
}

function New-ExistingProjectAdoptionPlan {
  param([Parameter(Mandatory=$true)]$Config, [Parameter(Mandatory=$true)]$Discovery, [Parameter(Mandatory=$true)][string]$DiscoveryPath)
  Test-ExistingProjectAdoptionConfig -Config $Config -Discovery $Discovery -DiscoveryPath $DiscoveryPath | Out-Null
  $operations = @()
  $i = 0
  $operations += [ordered]@{id=('OP-{0:D3}' -f (++$i));class='adopt-as-is';domain='workspace';source_ref=$Config.discovery_binding.discovery_id;target=$Config.workspace.workspace_id;reason='Revisionsgebundenes Bestandsinventar lokal uebernehmen.';remote_action='none'}
  foreach ($kind in @('issue_types','statuses','fields','space_roles')) {
    $domain = @{issue_types='jira-issue-type';statuses='jira-status';fields='jira-field';space_roles='confluence-space'}[$kind]
    foreach ($entry in @($Config.mapping.$kind | Sort-Object source_id)) {
      $class = if ([string]$entry.source_name -ceq [string]$entry.target) { 'adopt-as-is' } else { 'explicit-map' }
      $operations += [ordered]@{id=('OP-{0:D3}' -f (++$i));class=$class;domain=$domain;source_ref=$entry.source_id;target=$entry.target;reason='Projektbezogene Zuordnung aus der geprueften Konfiguration.';remote_action='none'}
    }
  }
  $operations += [ordered]@{id=('OP-{0:D3}' -f (++$i));class='improvement-proposal';domain='improvement';source_ref=$Discovery.discovery_id;target='inbox/proposals';reason='Abweichungen bleiben pruefbare Vorschlaege und werden nicht automatisch umgesetzt.';remote_action='none'}
  $plan = [ordered]@{schema_version=1;product_id='spectra';plan_id=('ADP-' + $Config.config_id.Substring(4));config_id=$Config.config_id;discovery_id=$Discovery.discovery_id;source_revision=$Discovery.source_revision;discovery_sha256=Get-AdoptionFileDigest $DiscoveryPath;created_at=$Discovery.captured_at;operations=$operations;remote_mutation_allowed=$false;plan_digest=('0'*64)}
  $digestSource = [ordered]@{}; foreach ($property in $plan.Keys) { if ($property -ne 'plan_digest') { $digestSource[$property] = $plan[$property] } }
  $plan.plan_digest = Get-AdoptionTextDigest ($digestSource | ConvertTo-Json -Depth 40 -Compress)
  $plan = ($plan | ConvertTo-Json -Depth 40 -Compress) | ConvertFrom-Json
  Test-ExistingProjectAdoptionPlan -Plan $plan -Config $Config -Discovery $Discovery -DiscoveryPath $DiscoveryPath | Out-Null
  $plan
}

function Test-ExistingProjectAdoptionPlan {
  param([Parameter(Mandatory=$true)]$Plan, [Parameter(Mandatory=$true)]$Config, [Parameter(Mandatory=$true)]$Discovery, [Parameter(Mandatory=$true)][string]$DiscoveryPath)
  Assert-AdoptionSchema $Plan 'existing-project-adoption-plan.schema.json'
  Test-ExistingProjectAdoptionConfig -Config $Config -Discovery $Discovery -DiscoveryPath $DiscoveryPath | Out-Null
  if ([string]$Plan.config_id -cne [string]$Config.config_id -or [string]$Plan.discovery_id -cne [string]$Discovery.discovery_id) { throw 'ADOPTION_PLAN_BINDING_MISMATCH' }
  if ([string]$Plan.source_revision -cne [string]$Discovery.source_revision -or [string]$Plan.discovery_sha256 -cne (Get-AdoptionFileDigest $DiscoveryPath)) { throw 'ADOPTION_PLAN_DISCOVERY_DRIFT' }
  if ($Plan.remote_mutation_allowed) { throw 'ADOPTION_REMOTE_MUTATION_FORBIDDEN' }
  Assert-AdoptionUnique @($Plan.operations | ForEach-Object id) 'ADOPTION_PLAN_OPERATION_DUPLICATE'
  foreach ($operation in @($Plan.operations)) { if ([string]$operation.remote_action -cne 'none') { throw 'ADOPTION_DIRECT_MUTATION_FORBIDDEN' } }
  $digestSource = [ordered]@{}; foreach ($property in @($Plan.PSObject.Properties)) { if ($property.Name -ne 'plan_digest') { $digestSource[$property.Name] = $property.Value } }
  $actual = Get-AdoptionTextDigest ($digestSource | ConvertTo-Json -Depth 40 -Compress)
  if ([string]$Plan.plan_digest -cne $actual) { throw 'ADOPTION_PLAN_DIGEST_MISMATCH' }
  $true
}

function Invoke-ExistingProjectAdoptionApply {
  param([Parameter(Mandatory=$true)]$Config, [Parameter(Mandatory=$true)]$Discovery, [Parameter(Mandatory=$true)]$Plan, [Parameter(Mandatory=$true)][string]$DiscoveryPath, [Parameter(Mandatory=$true)][string]$Destination, [Parameter(Mandatory=$true)][string]$ExpectedPlanDigest, [switch]$Approve, [switch]$Remote)
  if (-not $Approve) { throw 'ADOPTION_APPROVAL_REQUIRED' }
  if ($Remote) { throw 'ADOPTION_REMOTE_ADAPTER_NOT_CONFIGURED' }
  Test-ExistingProjectAdoptionPlan -Plan $Plan -Config $Config -Discovery $Discovery -DiscoveryPath $DiscoveryPath | Out-Null
  if ([string]$ExpectedPlanDigest -cne [string]$Plan.plan_digest) { throw 'ADOPTION_PLAN_DIGEST_EXPECTED_MISMATCH' }
  $destinationPath = [IO.Path]::GetFullPath($Destination)
  if ($destinationPath -eq [IO.Path]::GetPathRoot($destinationPath)) { throw 'ADOPTION_DESTINATION_UNSAFE' }
  if (Test-Path -LiteralPath $destinationPath) {
    $receiptPath = Join-Path $destinationPath 'governance\adoption-receipt.json'
    if (Test-Path -LiteralPath $receiptPath) {
      $receipt = Read-AdoptionJson $receiptPath
      if ([string]$receipt.plan_digest -ceq [string]$Plan.plan_digest) { return [ordered]@{status='ALREADY_APPLIED';writes_performed=$false;plan_digest=$Plan.plan_digest;destination=$destinationPath} }
    }
    throw 'ADOPTION_DESTINATION_CONFLICT'
  }
  $parent = Split-Path -Parent $destinationPath
  if (-not (Test-Path -LiteralPath $parent -PathType Container)) { throw 'ADOPTION_DESTINATION_PARENT_MISSING' }
  $staging = Join-Path $parent ('.spectra-adoption-' + [guid]::NewGuid().ToString('N'))
  try {
    New-Item -ItemType Directory -Path $staging | Out-Null
    foreach ($folder in @('governance','imports','inbox','proposals','knowledge','support','projects','openspec')) { New-Item -ItemType Directory -Path (Join-Path $staging $folder) -Force | Out-Null }
    Write-AdoptionJson (Join-Path $staging 'governance\adoption-config.json') $Config
    Write-AdoptionJson (Join-Path $staging 'governance\adoption-plan.json') $Plan
    Write-AdoptionJson (Join-Path $staging 'imports\atlassian-discovery.json') $Discovery
    $workspace = [ordered]@{schema_version=1;product_id='spectra';workspace_id=$Config.workspace.workspace_id;customer_id=$Config.workspace.customer_id;customer_name=$Config.workspace.customer_name;profile=$Config.workspace.profile;project_id=$Config.workspace.project_id;project_name=$Config.workspace.project_name;product_binding=$Config.product_binding;adoption_plan_digest=$Plan.plan_digest;customer_truth_boundary='workspace-owned';remote_write_enabled=$false}
    Write-AdoptionJson (Join-Path $staging 'workspace.json') $workspace
    $inbox = [ordered]@{schema_version=1;product_id='spectra';workspace_id=$Config.workspace.workspace_id;intake_items=@();proposals=@();writes_performed=$false}
    Write-AdoptionJson (Join-Path $staging 'inbox\adoption-inbox.json') $inbox
    $receipt = [ordered]@{schema_version=1;product_id='spectra';config_id=$Config.config_id;discovery_id=$Discovery.discovery_id;source_revision=$Discovery.source_revision;plan_digest=$Plan.plan_digest;applied_at=$Discovery.captured_at;remote_writes=0;status='APPLIED'}
    Write-AdoptionJson (Join-Path $staging 'governance\adoption-receipt.json') $receipt
    [IO.File]::WriteAllText((Join-Path $staging 'openspec\config.yaml'), "schema: spec-driven`n", [Text.UTF8Encoding]::new($false))
    Move-Item -LiteralPath $staging -Destination $destinationPath
    [ordered]@{status='APPLIED';writes_performed=$true;plan_digest=$Plan.plan_digest;destination=$destinationPath}
  } finally { if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force -ErrorAction SilentlyContinue } }
}

function Test-ExistingProjectAdoptionWorkspace {
  param([Parameter(Mandatory=$true)][string]$Path)
  $root = [IO.Path]::GetFullPath($Path)
  foreach ($relative in @('workspace.json','governance/adoption-config.json','governance/adoption-plan.json','governance/adoption-receipt.json','imports/atlassian-discovery.json','inbox/adoption-inbox.json')) { if (-not (Test-Path -LiteralPath (Join-Path $root ($relative -replace '/', '\')) -PathType Leaf)) { throw 'ADOPTION_WORKSPACE_FILE_MISSING' } }
  $config = Read-AdoptionJson (Join-Path $root 'governance\adoption-config.json')
  $plan = Read-AdoptionJson (Join-Path $root 'governance\adoption-plan.json')
  $discoveryPath = Join-Path $root 'imports\atlassian-discovery.json'
  $discovery = Read-AdoptionJson $discoveryPath
  $config.discovery_binding.relative_path = 'imports/atlassian-discovery.json'
  $config.discovery_binding.sha256 = Get-AdoptionFileDigest $discoveryPath
  Test-ExistingProjectAdoptionPlan -Plan $plan -Config $config -Discovery $discovery -DiscoveryPath $discoveryPath | Out-Null
  $receipt = Read-AdoptionJson (Join-Path $root 'governance\adoption-receipt.json')
  if ([string]$receipt.plan_digest -cne [string]$plan.plan_digest -or $receipt.remote_writes -ne 0) { throw 'ADOPTION_RECEIPT_INVALID' }
  $true
}
