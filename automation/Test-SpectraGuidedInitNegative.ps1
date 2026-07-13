$ErrorActionPreference='Stop';$tmp=Join-Path $env:TEMP ('spectra-guided-negative-'+[guid]::NewGuid().ToString('N'))
function Write-Json([string]$Path,$Value){[IO.File]::WriteAllText($Path,(($Value|ConvertTo-Json -Depth 20)+"`n"),(New-Object Text.UTF8Encoding($false)))}
function Base-Answers{[ordered]@{mode='new';project_id='PRJ-GUIDED-NEG';project_name='Synthetisches Projekt';profile='implementation';language='de-DE';processes=@('finance');collaboration='portable-atlassian';project_space_id='SPACE-GUIDED-NEG';project_space_title='Projektbereich';referenced_spaces_path=$null;ticket_strategy='spectra-standard';ticket_provider='jira';ticket_mapping_version='1.0.0';ticket_mapping_path=$null;blueprints=@('BPC-CONFLUENCE-PROJECT');onboarding_source_path=$null}}
function Expect([string]$Name,[string]$Code,[scriptblock]$Run){try{& $Run;throw "EXPECTED_GUIDED_FAILURE_NOT_RAISED:$Name"}catch{if($_.Exception.Message-ne$Code){throw "GUIDED_NEGATIVE_CODE_MISMATCH:${Name}:$($_.Exception.Message)"}}}
try{
  New-Item -ItemType Directory -Path $tmp|Out-Null
  Expect 'input-mode' 'GUIDED_INIT_INPUT_MODE_INVALID' {& (Join-Path $PSScriptRoot 'New-SpectraInitConfiguration.ps1') -OutputPath (Join-Path $tmp 'a.json')|Out-Null}
  $missing=Base-Answers;$missing.project_name=$null;$missingPath=Join-Path $tmp 'missing.json';Write-Json $missingPath $missing
  Expect 'missing-answer' 'GUIDED_INIT_ANSWER_MISSING:project_name' {& (Join-Path $PSScriptRoot 'New-SpectraInitConfiguration.ps1') -OutputPath (Join-Path $tmp 'b.json') -AnswersPath $missingPath|Out-Null}
  $custom=Base-Answers;$custom.ticket_strategy='project-mapping';$custom.ticket_mapping_path='../mapping.json';$customPath=Join-Path $tmp 'traversal.json';Write-Json $customPath $custom
  Expect 'mapping-traversal' 'GUIDED_INIT_TICKET_MAPPING_INVALID' {& (Join-Path $PSScriptRoot 'New-SpectraInitConfiguration.ps1') -OutputPath (Join-Path $tmp 'c.json') -AnswersPath $customPath|Out-Null}
  $valid=Base-Answers;$validPath=Join-Path $tmp 'valid.json';Write-Json $validPath $valid;$existing=Join-Path $tmp 'existing.json';Set-Content $existing '{}'
  Expect 'output-exists' 'GUIDED_INIT_OUTPUT_EXISTS' {& (Join-Path $PSScriptRoot 'New-SpectraInitConfiguration.ps1') -OutputPath $existing -AnswersPath $validPath|Out-Null}
  Expect 'cli-conflict' 'SPECTRA_DELEGATE_FAILED:init:SPECTRA_GUIDED_CONFIG_CONFLICT' {& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace (Join-Path $tmp 'workspace') -Guided -AnswersPath $validPath -ConfigPath $validPath|Out-Null}
  $invalid=Base-Answers;$invalid.blueprints=@('BPC-UNKNOWN');$invalidPath=Join-Path $tmp 'invalid-blueprint.json';Write-Json $invalidPath $invalid
  Expect 'unknown-blueprint' 'SPECTRA_DELEGATE_FAILED:init:INIT_BLUEPRINT_UNKNOWN' {& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace (Join-Path $tmp 'workspace2') -Guided -AnswersPath $invalidPath|Out-Null}
  Write-Host 'PASS: 6 geführte Init-Negativfälle sind fail-closed.'
}finally{if(Test-Path $tmp){Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue}}
