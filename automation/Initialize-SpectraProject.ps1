[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$ConfigPath,
  [Parameter(Mandatory=$true)][string]$Destination,
  [switch]$Apply
)
$ErrorActionPreference='Stop'
Set-StrictMode -Version 2.0

function Write-Utf8([string]$Path,[string]$Content) {
  $parent=Split-Path -Parent $Path
  if(-not(Test-Path -LiteralPath $parent)){New-Item -ItemType Directory -Path $parent -Force|Out-Null}
  [IO.File]::WriteAllText($Path,($Content -replace "`r`n","`n"),(New-Object Text.UTF8Encoding($false)))
}
function Assert-SafeRelative([string]$Value) {
  if([string]::IsNullOrWhiteSpace($Value)-or[IO.Path]::IsPathRooted($Value)-or$Value -match '(^|[\\/])\.\.([\\/]|$)|\\'){throw 'INIT_SOURCE_PATH_UNSAFE'}
}
function Get-Sha([string]$Path){return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}

$configFull=[IO.Path]::GetFullPath($ConfigPath)
if(-not(Test-Path -LiteralPath $configFull -PathType Leaf)){throw 'INIT_CONFIG_MISSING'}
$raw=Get-Content -LiteralPath $configFull -Raw
if($raw -match '(?i)(token|password|secret|credential|https?://|tenant[_-]?id)'){throw 'INIT_SECRET_OR_ENDPOINT_FORBIDDEN'}
$config=$raw|ConvertFrom-Json
. (Join-Path $PSScriptRoot 'Spectra.JsonSchema.ps1')
$schema=Get-Content -LiteralPath (Join-Path $PSScriptRoot '..\schemas\project-init.schema.json') -Raw|ConvertFrom-Json
try{Test-SpectraJsonSchema -Value $config -Schema $schema -RootSchema $schema -Path root}catch{throw 'INIT_SCHEMA_INVALID'}
. (Join-Path $PSScriptRoot 'Blueprint.Catalog.ps1')
$productRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$catalog=Test-SpectraBlueprintCatalog $productRoot
$selectedBlueprints=@($config.blueprints)
if(@($selectedBlueprints|Group-Object|Where-Object Count -gt 1).Count-gt0){throw 'INIT_BLUEPRINT_DUPLICATE'}
foreach($blueprintId in $selectedBlueprints){if(@($catalog.blueprints|Where-Object id -eq $blueprintId).Count-ne1){throw 'INIT_BLUEPRINT_UNKNOWN'}}
. (Join-Path $PSScriptRoot 'Project.Scenarios.ps1')
$projectTypeProperty=$config.PSObject.Properties['project_type']
$projectType=if($null-ne$projectTypeProperty-and-not[string]::IsNullOrWhiteSpace([string]$projectTypeProperty.Value)){[string]$projectTypeProperty.Value}elseif([string]$config.profile-eq'support-only'){'support'}else{'implementation'}
$predecessorProperty=$config.PSObject.Properties['predecessor'];$predecessor=if($null-ne$predecessorProperty){$predecessorProperty.Value}else{$null}
$scenario=Test-SpectraProjectScenarioSelection -Root $productRoot -ProjectType $projectType -Profile ([string]$config.profile) -Predecessor $predecessor -ProjectId ([string]$config.project_id)
$recommendedBlueprints=@($scenario.recommended_blueprints)
if($config.mode -eq 'onboard' -and $config.collaboration -ne 'existing-atlassian-readonly'){throw 'INIT_ONBOARDING_MODE_INVALID'}
if($config.mode -ne 'onboard' -and $null -ne $config.onboarding_source){throw 'INIT_ONBOARDING_SOURCE_UNEXPECTED'}
if(@($config.processes|Group-Object|Where-Object Count -gt 1).Count -gt 0){throw 'INIT_PROCESS_DUPLICATE'}
if(@($config.referenced_spaces|Where-Object id -eq $config.project_space.id).Count -gt 0){throw 'INIT_PROJECT_SPACE_DUPLICATED'}
if(@($config.referenced_spaces|Group-Object id|Where-Object Count -gt 1).Count -gt 0){throw 'INIT_REFERENCED_SPACE_DUPLICATE'}
$issueMappings=@($config.ticket_structure.issue_types)
$statusMappings=@($config.ticket_structure.status_mappings)
if(@($issueMappings|Group-Object source_type|Where-Object Count -gt 1).Count -gt 0){throw 'INIT_TICKET_TYPE_MAPPING_DUPLICATE'}
if(@($statusMappings|Group-Object source_status|Where-Object Count -gt 1).Count -gt 0){throw 'INIT_TICKET_STATUS_MAPPING_DUPLICATE'}
if($config.mode -eq 'onboard' -and $config.ticket_structure.strategy -ne 'imported-readonly'){throw 'INIT_TICKET_STRATEGY_INVALID'}

$destinationFull=[IO.Path]::GetFullPath($Destination)
if($destinationFull -eq [IO.Path]::GetPathRoot($destinationFull)){throw 'INIT_DESTINATION_UNSAFE'}
$parent=Split-Path -Parent $destinationFull
if(-not(Test-Path -LiteralPath $parent -PathType Container)){throw 'INIT_DESTINATION_PARENT_MISSING'}
if(Test-Path -LiteralPath $destinationFull){throw 'INIT_DESTINATION_EXISTS'}

$inventory=@()
$observedIssueTypes=@()
$observedStatuses=@()
if($config.mode -eq 'onboard'){
  Assert-SafeRelative ([string]$config.onboarding_source.path)
  $sourceRoot=[IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $configFull) ([string]$config.onboarding_source.path)))
  foreach($name in @('confluence-pages.json','jira-issues.json')){
    $file=Join-Path $sourceRoot $name
    if(-not(Test-Path -LiteralPath $file -PathType Leaf)){throw 'INIT_ONBOARDING_EXPORT_INCOMPLETE'}
    $before=Get-Sha $file
    $records=@(Get-Content -LiteralPath $file -Raw|ConvertFrom-Json)
    foreach($record in $records){
      if([string]::IsNullOrWhiteSpace([string]$record.id)){throw 'INIT_ONBOARDING_RECORD_INVALID'}
      if($name -eq 'jira-issues.json'){
        if([string]::IsNullOrWhiteSpace([string]$record.type)-or[string]::IsNullOrWhiteSpace([string]$record.status)){throw 'INIT_ONBOARDING_RECORD_INVALID'}
        $observedIssueTypes+=,[string]$record.type
        $observedStatuses+=,[string]$record.status
      }
    }
    $inventory+=,[ordered]@{file=$name;sha256=$before;record_count=$records.Count;read_only=$true}
    if((Get-Sha $file)-ne$before){throw 'INIT_ONBOARDING_SOURCE_MUTATED'}
  }
  foreach($type in @($observedIssueTypes|Sort-Object -Unique)){
    if(@($issueMappings|Where-Object{[string]$_.source_type -ceq $type}).Count -ne 1){throw 'INIT_TICKET_TYPE_UNMAPPED'}
  }
  foreach($status in @($observedStatuses|Sort-Object -Unique)){
    if(@($statusMappings|Where-Object{[string]$_.source_status -ceq $status}).Count -ne 1){throw 'INIT_TICKET_STATUS_UNMAPPED'}
  }
}

$plan=[ordered]@{
  schema_version=1;product_id='spectra';mode=$config.mode;project_id=$config.project_id;profile=$config.profile;project_type=$projectType
  destination=$destinationFull;project_space=$config.project_space.id;referenced_space_count=@($config.referenced_spaces).Count
  processes=@($config.processes);ticket_strategy=$config.ticket_structure.strategy;mapping_version=$config.ticket_structure.mapping_version
  selected_blueprints=$selectedBlueprints;recommended_blueprints=$recommendedBlueprints;predecessor=$predecessor
  writes_performed=$false;status='PLANNED';source_inventory=$inventory
}
if(-not$Apply){$plan|ConvertTo-Json -Depth 8 -Compress;return}

$staging=Join-Path $parent ('.spectra-init-'+[guid]::NewGuid().ToString('N'))
try{
  New-Item -ItemType Directory -Path $staging|Out-Null
  foreach($dir in @('governance','collaboration','collaboration/pages','collaboration/issues','imports','openspec')){New-Item -ItemType Directory -Path (Join-Path $staging $dir)-Force|Out-Null}
  $contract=[ordered]@{
    schema_version=1;product_id='spectra';mode=$config.mode;project_id=$config.project_id;project_name=$config.project_name
    profile=$config.profile;project_type=$projectType;language=$config.language;bc_package=$config.bc_package;processes=@($config.processes);collaboration=$config.collaboration
    project_space=$config.project_space;referenced_spaces=@($config.referenced_spaces);ticket_structure=$config.ticket_structure;source_inventory=$inventory
    blueprints=@($selectedBlueprints);recommended_blueprints=@($recommendedBlueprints);predecessor=$predecessor
    customer_truth_boundary='workspace-owned';live_write_enabled=$false
  }
  Write-Utf8 (Join-Path $staging 'governance\project-init.json') (($contract|ConvertTo-Json -Depth 12)+"`n")
  $space=[ordered]@{schema_version=1;project_space=$config.project_space;referenced_spaces=@($config.referenced_spaces);page_roots=@('Projektstart','Scope und Entscheidungen','Prozesse','Tests und Freigaben','Betrieb und Handover')}
  Write-Utf8 (Join-Path $staging 'collaboration\project-space.json') (($space|ConvertTo-Json -Depth 8)+"`n")
  $jira=[ordered]@{
    schema_version=1
    canonical_categories=@('work','defect','change','decision','risk','evidence','support')
    canonical_statuses=@('planned','ready','in_progress','blocked','done','closed','rejected')
    strategy=$config.ticket_structure.strategy
    provider=$config.ticket_structure.provider
    mapping_version=$config.ticket_structure.mapping_version
    issue_type_mappings=@($issueMappings)
    status_mappings=@($statusMappings)
    components=@($config.processes)
    source_values_preserved=$true
    live_write_enabled=$false
  }
  Write-Utf8 (Join-Path $staging 'collaboration\jira-structure.json') (($jira|ConvertTo-Json -Depth 8)+"`n")
  foreach($blueprintId in $selectedBlueprints){
    $blueprint=@($catalog.blueprints|Where-Object id -eq $blueprintId)[0]
    foreach($artifact in @($blueprint.artifacts)){
      $source=Join-Path $productRoot ([string]$artifact.source_path -replace'/','\')
      $target=Join-Path $staging ([string]$artifact.target_path -replace'/','\')
      $targetParent=Split-Path -Parent $target
      if(-not(Test-Path -LiteralPath $targetParent)){New-Item -ItemType Directory -Path $targetParent -Force|Out-Null}
      Copy-Item -LiteralPath $source -Destination $target
    }
  }
  Write-Utf8 (Join-Path $staging 'openspec\config.yaml') "schema: spec-driven`n"
  Write-Utf8 (Join-Path $staging 'README.md') "# Spectra Projektworkspace`n`nProjekt: $($config.project_name)`n`nModus: $($config.mode)`n`nKeine Live-Atlassian-Schreibverbindung aktiviert.`n"
  Move-Item -LiteralPath $staging -Destination $destinationFull
  $plan.status='APPLIED';$plan.writes_performed=$true
  $plan|ConvertTo-Json -Depth 8 -Compress
}finally{if(Test-Path -LiteralPath $staging){Remove-Item -LiteralPath $staging -Recurse -Force -ErrorAction SilentlyContinue}}
