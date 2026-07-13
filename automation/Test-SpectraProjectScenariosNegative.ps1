[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$temp = Join-Path $env:TEMP ('spectra-project-scenarios-negative-' + [guid]::NewGuid().ToString('N'))
$utf8 = [Text.UTF8Encoding]::new($false)

function Base-Config {
  [ordered]@{
    schema_version=1;product_id='spectra';mode='new';project_id='PRJ-SCENARIO-NEG';project_name='Synthetisches Projekt'
    profile='implementation';project_type='implementation';language='de-DE';bc_package='bc-basic-standard';processes=@('finance')
    collaboration='portable-atlassian';project_space=[ordered]@{id='SPACE-SCENARIO-NEG';title='Projektbereich'};referenced_spaces=@()
    ticket_structure=[ordered]@{strategy='spectra-standard';provider='jira';mapping_version='1.0.0';read_only=$true;issue_types=@([ordered]@{source_type='Task';spectra_category='work';hierarchy_level=1});status_mappings=@([ordered]@{source_status='Open';spectra_status='planned'})}
    blueprints=@('BPC-CONFLUENCE-PROJECT');onboarding_source=$null;predecessor=$null
  }
}
function Invoke-Case([string]$Name, [string]$Code, [scriptblock]$Mutate) {
  $root = Join-Path $temp $Name
  New-Item -ItemType Directory -Path $root | Out-Null
  $value = Base-Config
  & $Mutate $value
  $config = Join-Path $root 'config.json'
  [IO.File]::WriteAllText($config, (($value | ConvertTo-Json -Depth 20) + "`n"), $utf8)
  try {
    & (Join-Path $PSScriptRoot 'Initialize-SpectraProject.ps1') -ConfigPath $config -Destination (Join-Path $root 'workspace') | Out-Null
    throw "EXPECTED_PROJECT_SCENARIO_FAILURE_NOT_RAISED:$Name"
  } catch {
    if ($_.Exception.Message -cne $Code) { throw "PROJECT_SCENARIO_NEGATIVE_MISMATCH:${Name}:$($_.Exception.Message)" }
  }
}

try {
  New-Item -ItemType Directory -Path $temp | Out-Null
  $cases = @(
    @{name='unknown-type';code='INIT_SCHEMA_INVALID';mutate={param($x)$x.project_type='unknown'}},
    @{name='support-profile';code='PROJECT_SCENARIO_PROFILE_MISMATCH';mutate={param($x)$x.project_type='support'}},
    @{name='implementation-profile';code='PROJECT_SCENARIO_PROFILE_MISMATCH';mutate={param($x)$x.profile='support-only'}},
    @{name='self-reference';code='PROJECT_SCENARIO_SELF_REFERENCE';mutate={param($x)$x.predecessor=[ordered]@{project_id=$x.project_id;project_type='fit-gap';relationship='continues-as';read_only=$true}}},
    @{name='predecessor-type';code='PROJECT_SCENARIO_PREDECESSOR_TYPE_INVALID';mutate={param($x)$x.predecessor=[ordered]@{project_id='PRJ-OTHER-001';project_type='migration';relationship='continues-as';read_only=$true}}},
    @{name='relationship';code='PROJECT_SCENARIO_RELATIONSHIP_INVALID';mutate={param($x)$x.predecessor=[ordered]@{project_id='PRJ-OTHER-002';project_type='fit-gap';relationship='migrates-from';read_only=$true}}},
    @{name='write-predecessor';code='INIT_SCHEMA_INVALID';mutate={param($x)$x.predecessor=[ordered]@{project_id='PRJ-OTHER-003';project_type='fit-gap';relationship='continues-as';read_only=$false}}},
    @{name='fit-gap-predecessor';code='PROJECT_SCENARIO_PREDECESSOR_TYPE_INVALID';mutate={param($x)$x.project_type='fit-gap';$x.predecessor=[ordered]@{project_id='PRJ-OTHER-004';project_type='implementation';relationship='continues-as';read_only=$true}}}
  )
  foreach ($case in $cases) { Invoke-Case $case.name $case.code $case.mutate }

  $answers = [ordered]@{mode='new';project_id='PRJ-GUIDED-INCOMPLETE';project_name='Synthetisches Projekt';profile='implementation';project_type='implementation';language='de-DE';processes=@('finance');collaboration='portable-atlassian';project_space_id='SPACE-GUIDED-INCOMPLETE';project_space_title='Projektbereich';referenced_spaces_path=$null;ticket_strategy='spectra-standard';ticket_provider='jira';ticket_mapping_version='1.0.0';ticket_mapping_path=$null;blueprints=@('BPC-CONFLUENCE-PROJECT');onboarding_source_path=$null;predecessor_project_id='PRJ-OTHER-005';predecessor_project_type=$null;predecessor_relationship=$null}
  $answersPath = Join-Path $temp 'incomplete-answers.json'
  [IO.File]::WriteAllText($answersPath, (($answers | ConvertTo-Json -Depth 20) + "`n"), $utf8)
  try {
    & (Join-Path $PSScriptRoot 'New-SpectraInitConfiguration.ps1') -OutputPath (Join-Path $temp 'incomplete-config.json') -AnswersPath $answersPath | Out-Null
    throw 'EXPECTED_PROJECT_SCENARIO_FAILURE_NOT_RAISED:incomplete-predecessor'
  } catch {
    if ($_.Exception.Message -cne 'GUIDED_INIT_PREDECESSOR_INCOMPLETE') { throw "PROJECT_SCENARIO_NEGATIVE_MISMATCH:incomplete-predecessor:$($_.Exception.Message)" }
  }
  Write-Host 'PASS: 9 Projektart-/Übergangsfehler werden isoliert und fail-closed abgelehnt.'
} finally {
  if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
