[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Destination,
  [Parameter(Mandatory=$true)][ValidateSet('implementation','support-only')][string]$Profile,
  [Parameter(Mandatory=$true)][string]$ProductCommit,
  [Parameter(Mandatory=$true)][string]$ProductTree,
  [Parameter(Mandatory=$true)][string]$ProductDigest
)
$ErrorActionPreference='Stop';Set-StrictMode -Version 2.0
. (Join-Path $PSScriptRoot 'ExistingProject.Adoption.ps1')
$d=[IO.Path]::GetFullPath($Destination);if(Test-Path $d){throw 'ADOPTION_FIXTURE_EXISTS'};$parent=Split-Path -Parent $d;if(-not(Test-Path $parent)){throw 'ADOPTION_FIXTURE_PARENT_MISSING'}
$suffix=if($Profile-eq'implementation'){'IMPL'}else{'SUPPORT'}
if($Profile-eq'implementation'){
  $issueTypes=@(
    [ordered]@{id='10001';name='Phase';hierarchy_level=0},[ordered]@{id='10002';name='Epic';hierarchy_level=1},[ordered]@{id='10003';name='Story';hierarchy_level=2},[ordered]@{id='10004';name='Bug';hierarchy_level=2},[ordered]@{id='10005';name='Task';hierarchy_level=3})
  $statuses=@([ordered]@{id='1';name='Open'},[ordered]@{id='2';name='In Progress'},[ordered]@{id='3';name='Done'})
  $fields=@([ordered]@{id='summary';name='Summary'},[ordered]@{id='acceptance';name='Acceptance Criteria'},[ordered]@{id='worklog';name='Worklog'})
  $spaces=@([ordered]@{id='S1';key='CUSTOMER';name='Customer Project'},[ordered]@{id='S2';key='PRODUCT';name='Product Reference'},[ordered]@{id='S3';key='METHOD';name='Consulting Method'})
  $pages=@([ordered]@{id='P1';space_id='S1';title='Project Home';parent_id=$null;version=7},[ordered]@{id='P2';space_id='S1';title='Scope';parent_id='P1';version=3},[ordered]@{id='P3';space_id='S2';title='Product Home';parent_id=$null;version=2},[ordered]@{id='P4';space_id='S3';title='Method Home';parent_id=$null;version=4})
  $spaceBindings=@([ordered]@{base_url='https://docs.example.test';site_id='CONF-IMPL';space_id='S1';space_key='CUSTOMER';role='project';root_page_id='P1'},[ordered]@{base_url='https://docs.example.test';site_id='CONF-IMPL';space_id='S2';space_key='PRODUCT';role='product';root_page_id='P3'},[ordered]@{base_url='https://docs.example.test';site_id='CONF-IMPL';space_id='S3';space_key='METHOD';role='consulting';root_page_id='P4'})
  $spaceMappings=@([ordered]@{source_id='S1';source_name='Customer Project';target='project'},[ordered]@{source_id='S2';source_name='Product Reference';target='product'},[ordered]@{source_id='S3';source_name='Consulting Method';target='consulting'})
  $projectId='PRJ-SYN-IMPL';$projectName='Synthetisches Bestandsprojekt';$jiraProject=[ordered]@{id='J100';key='SYN';name='Synthetic Delivery'};$board=[ordered]@{id='B100';name='Delivery Board';project_id='J100';filter_id='F100'}
}else{
  $issueTypes=@([ordered]@{id='20001';name='Request';hierarchy_level=0},[ordered]@{id='20002';name='Incident';hierarchy_level=0},[ordered]@{id='20003';name='Subtask';hierarchy_level=1})
  $statuses=@([ordered]@{id='11';name='Incoming'},[ordered]@{id='12';name='Working'},[ordered]@{id='13';name='Resolved'})
  $fields=@([ordered]@{id='summary';name='Summary'},[ordered]@{id='service';name='Service Area'})
  $spaces=@([ordered]@{id='S10';key='HELP';name='Service Desk'},[ordered]@{id='S11';key='KB';name='Knowledge Base'})
  $pages=@([ordered]@{id='P10';space_id='S10';title='Support Home';parent_id=$null;version=9},[ordered]@{id='P11';space_id='S11';title='Knowledge Home';parent_id=$null;version=5})
  $spaceBindings=@([ordered]@{base_url='https://support-docs.example.test';site_id='CONF-SUPPORT';space_id='S10';space_key='HELP';role='support';root_page_id='P10'},[ordered]@{base_url='https://support-docs.example.test';site_id='CONF-SUPPORT';space_id='S11';space_key='KB';role='knowledge';root_page_id='P11'})
  $spaceMappings=@([ordered]@{source_id='S10';source_name='Service Desk';target='support'},[ordered]@{source_id='S11';source_name='Knowledge Base';target='knowledge'})
  $projectId=$null;$projectName=$null;$jiraProject=$null;$board=[ordered]@{id='B200';name='Support Queue';project_id=$null;filter_id=$null}
}
$sourceRevision=if($Profile-eq'implementation'){('a'*64)}else{('b'*64)}
$discovery=[ordered]@{schema_version=1;product_id='spectra';discovery_id="DSC-SYN-$suffix";captured_at=if($Profile-eq'implementation'){'2031-01-10T08:00:00Z'}else{'2031-01-11T08:00:00Z'};source_revision=$sourceRevision;jira=[ordered]@{base_url=if($Profile-eq'implementation'){'https://jira.example.test'}else{'https://support-jira.example.test'};site_id="JIRA-$suffix";project=$jiraProject;board=$board;issue_types=$issueTypes;statuses=$statuses;fields=$fields;components=@([ordered]@{id='C1';name='Business Central'});labels=@('spectra-synthetic')};confluence=[ordered]@{base_url=$spaceBindings[0].base_url;site_id=$spaceBindings[0].site_id;spaces=$spaces;pages=$pages}}
$staging=Join-Path $parent ('.adoption-fixture-'+[guid]::NewGuid().ToString('N'))
try{
  New-Item -ItemType Directory -Path $staging|Out-Null
  $discoveryPath=Join-Path $staging 'discovery.json';Write-AdoptionJson $discoveryPath $discovery
  $issueMappings=@();foreach($it in $issueTypes){$target=switch($it.name){'Phase'{'phase'}'Epic'{'epic'}'Story'{'story'}'Bug'{'defect'}'Task'{'task'}'Request'{'support-request'}'Incident'{'defect'}default{'subtask'}};$issueMappings+=[ordered]@{source_id=$it.id;source_name=$it.name;target=$target}}
  $statusMappings=@();foreach($s in $statuses){$target=switch($s.name){'Open'{'planned'}'Incoming'{'ready'}'In Progress'{'in_progress'}'Working'{'in_progress'}default{'done'}};$statusMappings+=[ordered]@{source_id=$s.id;source_name=$s.name;target=$target}}
  $fieldMappings=@();foreach($f in $fields){$fieldMappings+=[ordered]@{source_id=$f.id;source_name=$f.name;target=($f.name.ToLowerInvariant() -replace ' ','_')}}
  $jiraProjectId=if($null -eq $jiraProject){$null}else{$jiraProject.id};$jiraProjectKey=if($null -eq $jiraProject){$null}else{$jiraProject.key}
  $config=[ordered]@{schema_version=1;product_id='spectra';config_id="ADC-SYN-$suffix";workspace=[ordered]@{customer_id="CUS-SYN-$suffix";customer_name="Synthetischer Kunde $suffix";workspace_id="WS-SYN-$suffix";profile=$Profile;project_id=$projectId;project_name=$projectName};product_binding=[ordered]@{version='1.0.0';commit=$ProductCommit;tree=$ProductTree;digest=$ProductDigest};discovery_binding=[ordered]@{discovery_id=$discovery.discovery_id;source_revision=$discovery.source_revision;sha256=Get-AdoptionFileDigest $discoveryPath;relative_path='discovery.json'};jira_binding=[ordered]@{base_url=$discovery.jira.base_url;site_id=$discovery.jira.site_id;project_id=$jiraProjectId;project_key=$jiraProjectKey;board_id=$board.id;board_name=$board.name;filter_id=$board.filter_id};confluence_bindings=$spaceBindings;mapping=[ordered]@{version='1.0.0';issue_types=$issueMappings;statuses=$statusMappings;fields=$fieldMappings;space_roles=$spaceMappings};runtime_secret_keys=@('SPECTRA_ATLASSIAN_ACCOUNT','SPECTRA_ATLASSIAN_TOKEN')}
  Write-AdoptionJson (Join-Path $staging 'config.json') $config
  Move-Item -LiteralPath $staging -Destination $d
  Write-Host "PASS: Synthetische Existing-Project-Fixture $Profile erzeugt."
}finally{if(Test-Path $staging){Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue}}
