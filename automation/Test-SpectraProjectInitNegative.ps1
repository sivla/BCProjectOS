$ErrorActionPreference='Stop'
$tmp=Join-Path $env:TEMP ('spectra-project-init-negative-'+[guid]::NewGuid().ToString('N'))
function Expect-Failure([string]$Name,[scriptblock]$Mutate,[string]$Code){
  $case=Join-Path $tmp $Name;New-Item -ItemType Directory -Path $case -Force|Out-Null
  $x=[ordered]@{schema_version=1;product_id='spectra';mode='new';project_id='PRJ-SYN-NEG';project_name='Synthetisches Projekt';profile='implementation';language='de-DE';bc_package='bc-basic-standard';processes=@('finance');collaboration='portable-atlassian';project_space=[ordered]@{id='SPACE-PROJECT';title='Projektbereich'};referenced_spaces=@();ticket_structure=[ordered]@{strategy='spectra-standard';provider='jira';mapping_version='1.0.0';read_only=$true;issue_types=@([ordered]@{source_type='Task';spectra_category='work';hierarchy_level=1});status_mappings=@([ordered]@{source_status='Open';spectra_status='planned'})};onboarding_source=$null}
  & $Mutate $x $case
  $config=Join-Path $case 'init.json';[IO.File]::WriteAllText($config,($x|ConvertTo-Json -Depth 10),(New-Object Text.UTF8Encoding($false)))
  try{& (Join-Path $PSScriptRoot 'Initialize-SpectraProject.ps1') -ConfigPath $config -Destination (Join-Path $case 'workspace')|Out-Null;throw "EXPECTED_FAILURE_NOT_RAISED:$Name"}catch{if($_.Exception.Message-ne$Code){throw "NEGATIVE_CODE_MISMATCH:${Name}:$($_.Exception.Message)"}}
}
try{
  New-Item -ItemType Directory -Path $tmp|Out-Null
  $cases=@(
    @('unknown-process',{param($x,$d)$x.processes=@('unknown')},'INIT_SCHEMA_INVALID'),
    @('duplicate-process',{param($x,$d)$x.processes=@('finance','finance')},'INIT_PROCESS_DUPLICATE'),
    @('duplicate-ticket-type',{param($x,$d)$x.ticket_structure.issue_types+=,[ordered]@{source_type='Task';spectra_category='defect';hierarchy_level=1}},'INIT_TICKET_TYPE_MAPPING_DUPLICATE'),
    @('duplicate-ticket-status',{param($x,$d)$x.ticket_structure.status_mappings+=,[ordered]@{source_status='Open';spectra_status='ready'}},'INIT_TICKET_STATUS_MAPPING_DUPLICATE'),
    @('unknown-ticket-category',{param($x,$d)$x.ticket_structure.issue_types[0].spectra_category='unknown'},'INIT_SCHEMA_INVALID'),
    @('duplicate-project-space',{param($x,$d)$x.referenced_spaces=@([ordered]@{id='SPACE-PROJECT';title='Duplicate';read_only=$true})},'INIT_PROJECT_SPACE_DUPLICATED'),
    @('write-reference',{param($x,$d)$x.referenced_spaces=@([ordered]@{id='SPACE-OTHER';title='Other';read_only=$false})},'INIT_SCHEMA_INVALID'),
    @('secret',{param($x,$d)$x.project_name='token secret'},'INIT_SECRET_OR_ENDPOINT_FORBIDDEN'),
    @('endpoint',{param($x,$d)$x.project_name='https://example.invalid'},'INIT_SECRET_OR_ENDPOINT_FORBIDDEN'),
    @('onboard-mode',{param($x,$d)$x.mode='onboard';$x.onboarding_source=[ordered]@{path='export';format='spectra-portable-atlassian-v1'}},'INIT_ONBOARDING_MODE_INVALID'),
    @('unexpected-source',{param($x,$d)$x.onboarding_source=[ordered]@{path='export';format='spectra-portable-atlassian-v1'}},'INIT_ONBOARDING_SOURCE_UNEXPECTED'),
    @('unsafe-source',{param($x,$d)$x.mode='onboard';$x.collaboration='existing-atlassian-readonly';$x.ticket_structure.strategy='imported-readonly';$x.onboarding_source=[ordered]@{path='../export';format='spectra-portable-atlassian-v1'}},'INIT_SOURCE_PATH_UNSAFE'),
    @('missing-export',{param($x,$d)$x.mode='onboard';$x.collaboration='existing-atlassian-readonly';$x.ticket_structure.strategy='imported-readonly';$x.onboarding_source=[ordered]@{path='export';format='spectra-portable-atlassian-v1'};New-Item -ItemType Directory (Join-Path $d 'export')|Out-Null},'INIT_ONBOARDING_EXPORT_INCOMPLETE'),
    @('unmapped-ticket-type',{param($x,$d)$x.mode='onboard';$x.collaboration='existing-atlassian-readonly';$x.ticket_structure.strategy='imported-readonly';$x.onboarding_source=[ordered]@{path='export';format='spectra-portable-atlassian-v1'};$e=Join-Path $d 'export';New-Item -ItemType Directory $e|Out-Null;@([ordered]@{id='PAGE-1'})|ConvertTo-Json|Set-Content (Join-Path $e 'confluence-pages.json');@([ordered]@{id='ISSUE-1';type='Custom';status='Open'})|ConvertTo-Json|Set-Content (Join-Path $e 'jira-issues.json')},'INIT_TICKET_TYPE_UNMAPPED'),
    @('unmapped-ticket-status',{param($x,$d)$x.mode='onboard';$x.collaboration='existing-atlassian-readonly';$x.ticket_structure.strategy='imported-readonly';$x.ticket_structure.issue_types[0].source_type='Custom';$x.onboarding_source=[ordered]@{path='export';format='spectra-portable-atlassian-v1'};$e=Join-Path $d 'export';New-Item -ItemType Directory $e|Out-Null;@([ordered]@{id='PAGE-1'})|ConvertTo-Json|Set-Content (Join-Path $e 'confluence-pages.json');@([ordered]@{id='ISSUE-1';type='Custom';status='Unexpected'})|ConvertTo-Json|Set-Content (Join-Path $e 'jira-issues.json')},'INIT_TICKET_STATUS_UNMAPPED')
  )
  foreach($c in $cases){Expect-Failure $c[0] $c[1] $c[2]}
  Write-Host "PASS: $($cases.Count) project-init negative cases fail closed."
}finally{if(Test-Path $tmp){Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue}}
