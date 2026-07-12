[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$temp = Join-Path $env:TEMP ('spectra-project-scenarios-' + [guid]::NewGuid().ToString('N'))
$utf8 = [Text.UTF8Encoding]::new($false)

function Write-Json([string]$Path, $Value) {
  [IO.File]::WriteAllText($Path, (($Value | ConvertTo-Json -Depth 20) + "`n"), $utf8)
}
function New-Answers([string]$ProjectType, [string]$Profile, [AllowNull()]$Predecessor) {
  $blueprints = if ($ProjectType -eq 'support') {
    @('BPC-CONFLUENCE-PROJECT','BPC-JIRA-PROJECT','BPC-METADATA')
  } else {
    @('BPC-CONFLUENCE-PROJECT','BPC-JIRA-PROJECT','BPC-BLANK-DOCUMENTS','BPC-METADATA')
  }
  $answer = [ordered]@{
    mode='new';project_id="PRJ-SCENARIO-$($ProjectType.ToUpperInvariant())";project_name="Synthetisches Projekt $ProjectType"
    profile=$Profile;project_type=$ProjectType;language='de-DE';processes=@('finance','p2p','o2c');collaboration='portable-atlassian'
    project_space_id="SPACE-SCENARIO-$($ProjectType.ToUpperInvariant())";project_space_title="Projektbereich $ProjectType";referenced_spaces_path=$null
    ticket_strategy='spectra-standard';ticket_provider='jira';ticket_mapping_version='1.0.0';ticket_mapping_path=$null;blueprints=$blueprints;onboarding_source_path=$null
    predecessor_project_id=$null;predecessor_project_type=$null;predecessor_relationship=$null
  }
  if ($null -ne $Predecessor) {
    $answer.predecessor_project_id=$Predecessor.project_id
    $answer.predecessor_project_type=$Predecessor.project_type
    $answer.predecessor_relationship=$Predecessor.relationship
  }
  return $answer
}

try {
  New-Item -ItemType Directory -Path $temp | Out-Null
  . (Join-Path $PSScriptRoot 'Project.Scenarios.ps1')
  $catalog = Test-SpectraProjectScenarioCatalog $root
  if (@($catalog.scenarios).Count -ne 4) { throw 'PROJECT_SCENARIO_CATALOG_COUNT_INVALID' }
  $cases = @(
    @{type='fit-gap';profile='implementation';predecessor=$null},
    @{type='implementation';profile='implementation';predecessor=[ordered]@{project_id='PRJ-SCENARIO-FIT-GAP';project_type='fit-gap';relationship='continues-as'}},
    @{type='migration';profile='implementation';predecessor=[ordered]@{project_id='PRJ-SCENARIO-IMPLEMENTATION';project_type='implementation';relationship='migrates-from'}},
    @{type='support';profile='support-only';predecessor=[ordered]@{project_id='PRJ-SCENARIO-IMPLEMENTATION';project_type='implementation';relationship='onboards-from'}}
  )
  foreach ($case in $cases) {
    $caseRoot = Join-Path $temp $case.type
    New-Item -ItemType Directory -Path $caseRoot | Out-Null
    $answersPath = Join-Path $caseRoot 'answers.json'
    $configPath = Join-Path $caseRoot 'config.json'
    Write-Json $answersPath (New-Answers $case.type $case.profile $case.predecessor)
    & (Join-Path $PSScriptRoot 'New-SpectraInitConfiguration.ps1') -OutputPath $configPath -AnswersPath $answersPath | Out-Null
    $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    if ([string]$config.project_type -cne $case.type) { throw "PROJECT_SCENARIO_CONFIG_TYPE_INVALID:$($case.type)" }
    $workspace = Join-Path $caseRoot 'workspace'
    $dry = & (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace $workspace -ConfigPath $configPath | ConvertFrom-Json
    if ($dry.writes_performed -or (Test-Path -LiteralPath $workspace)) { throw "PROJECT_SCENARIO_DRYRUN_MUTATED:$($case.type)" }
    & (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace $workspace -ConfigPath $configPath -Apply | Out-Null
    $contract = Get-Content -LiteralPath (Join-Path $workspace 'governance\project-init.json') -Raw | ConvertFrom-Json
    if ([string]$contract.project_type -cne $case.type -or [string]$contract.profile -cne $case.profile) { throw "PROJECT_SCENARIO_CONTRACT_INVALID:$($case.type)" }
    $scenario = Get-SpectraProjectScenario $root $case.type
    if (Compare-Object @($scenario.recommended_blueprints | Sort-Object) @($contract.recommended_blueprints | Sort-Object)) { throw "PROJECT_SCENARIO_RECOMMENDATION_INVALID:$($case.type)" }
    if ($null -eq $case.predecessor) {
      if ($null -ne $contract.predecessor) { throw "PROJECT_SCENARIO_PREDECESSOR_UNEXPECTED:$($case.type)" }
    } else {
      if ([string]$contract.predecessor.project_id -cne [string]$case.predecessor.project_id -or $contract.predecessor.read_only -ne $true) { throw "PROJECT_SCENARIO_PREDECESSOR_INVALID:$($case.type)" }
    }
    $blank = Join-Path $workspace 'templates\project-overview-scope.md'
    if ($case.type -eq 'support' -and (Test-Path -LiteralPath $blank)) { throw 'PROJECT_SCENARIO_SUPPORT_NOT_LEAN' }
    if ($case.type -ne 'support' -and -not (Test-Path -LiteralPath $blank -PathType Leaf)) { throw "PROJECT_SCENARIO_BLANKS_MISSING:$($case.type)" }
  }
  Write-Host 'PASS: Vier Projektarten, profilgerechte Blueprints und read-only Übergänge sind deterministisch belegt.'
} finally {
  if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
