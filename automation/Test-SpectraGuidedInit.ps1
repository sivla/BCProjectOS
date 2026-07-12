$ErrorActionPreference='Stop';$tmp=Join-Path $env:TEMP ('spectra-guided-test-'+[guid]::NewGuid().ToString('N'))
function Write-Json([string]$Path,$Value){[IO.File]::WriteAllText($Path,(($Value|ConvertTo-Json -Depth 20)+"`n"),(New-Object Text.UTF8Encoding($false)))}
function Base-Answers([string]$Name){[ordered]@{mode='new';project_id="PRJ-GUIDED-$Name";project_name="Geführtes synthetisches Projekt $Name";profile='implementation';language='de-DE';processes=@('finance','p2p','o2c');collaboration='portable-atlassian';project_space_id="SPACE-GUIDED-$Name";project_space_title='Geführter Projektbereich';referenced_spaces_path=$null;ticket_strategy='spectra-standard';ticket_provider='jira';ticket_mapping_version='1.0.0';ticket_mapping_path=$null;blueprints=@('BPC-CONFLUENCE-PROJECT','BPC-JIRA-PROJECT');onboarding_source_path=$null}}
try{
  New-Item -ItemType Directory -Path $tmp|Out-Null
  $standard=Base-Answers 'STANDARD';$standardPath=Join-Path $tmp 'standard-answers.json';Write-Json $standardPath $standard
  $configOut=Join-Path $tmp 'reviewed-config.json';$workspace=Join-Path $tmp 'standard-workspace'
  $dry=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace $workspace -Guided -AnswersPath $standardPath -ConfigOutput $configOut|ConvertFrom-Json
  if($dry.writes_performed-or(Test-Path $workspace)-or-not(Test-Path $configOut)){throw 'GUIDED_INIT_DRYRUN_INVALID'}
  $saved=Get-Content $configOut -Raw|ConvertFrom-Json;if($saved.ticket_structure.strategy-ne'spectra-standard'-or@($saved.blueprints).Count-ne2){throw 'GUIDED_INIT_CONFIG_OUTPUT_INVALID'}
  $applied=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace $workspace -Guided -AnswersPath $standardPath -SyntheticPilot -Apply|ConvertFrom-Json
  if(-not$applied.writes_performed-or-not(Test-Path (Join-Path $workspace 'collaboration\pages\00 Support.md'))){throw 'GUIDED_INIT_STANDARD_APPLY_INVALID'}

  $mapping=[ordered]@{strategy='project-mapping';provider='other';mapping_version='2.0.0';read_only=$true;issue_types=@([ordered]@{source_type='Service Request';spectra_category='support';hierarchy_level=0});status_mappings=@([ordered]@{source_status='Resolved';spectra_status='done'})};Write-Json (Join-Path $tmp 'mapping.json') $mapping
  $custom=Base-Answers 'CUSTOM';$custom.profile='support-only';$custom.collaboration='local-only';$custom.ticket_strategy='project-mapping';$custom.ticket_provider='other';$custom.ticket_mapping_version='2.0.0';$custom.ticket_mapping_path='mapping.json';$custom.blueprints=@('BPC-METADATA');$customPath=Join-Path $tmp 'custom-answers.json';Write-Json $customPath $custom
  $customWorkspace=Join-Path $tmp 'custom-workspace';& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace $customWorkspace -Guided -AnswersPath $customPath -SyntheticPilot -Apply|Out-Null
  $ticket=Get-Content (Join-Path $customWorkspace 'collaboration\jira-structure.json') -Raw|ConvertFrom-Json
  if($ticket.issue_type_mappings[0].source_type-ne'Service Request'-or-not(Test-Path (Join-Path $customWorkspace 'templates\metadata\snapshot.json'))){throw 'GUIDED_INIT_CUSTOM_MAPPING_INVALID'}
  Write-Host 'PASS: Geführter Standard- und Projektmapping-Init sind deterministisch, prüfbar und anwendbar.'
}finally{if(Test-Path $tmp){Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue}}
