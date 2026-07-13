$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$tmp=Join-Path $env:TEMP ('spectra-project-init-'+[guid]::NewGuid().ToString('N'))
try{
  New-Item -ItemType Directory -Path $tmp|Out-Null
  foreach($mode in @('new','local','onboard')){
    $case=Join-Path $tmp $mode;New-Item -ItemType Directory -Path $case|Out-Null
    if($mode-eq'onboard'){
      $source=Join-Path $case 'export';New-Item -ItemType Directory -Path $source|Out-Null
      @([ordered]@{id='PAGE-SYN-001';title='Synthetischer Projektstart'})|ConvertTo-Json|Set-Content (Join-Path $source 'confluence-pages.json') -Encoding utf8
      @([ordered]@{id='ISSUE-SYN-001';type='Feature Request';status='In Delivery';title='Synthetische Aufgabe'})|ConvertTo-Json|Set-Content (Join-Path $source 'jira-issues.json') -Encoding utf8
    }
    $ticket=if($mode-eq'onboard'){
      [ordered]@{strategy='imported-readonly';provider='jira';mapping_version='2.1.0';read_only=$true;issue_types=@([ordered]@{source_type='Feature Request';spectra_category='work';hierarchy_level=1});status_mappings=@([ordered]@{source_status='In Delivery';spectra_status='in_progress'})}
    }elseif($mode-eq'local'){
      [ordered]@{strategy='project-mapping';provider='generic-file';mapping_version='1.2.0';read_only=$true;issue_types=@([ordered]@{source_type='Work Item';spectra_category='work';hierarchy_level=0},[ordered]@{source_type='Service Case';spectra_category='support';hierarchy_level=0});status_mappings=@([ordered]@{source_status='Queued';spectra_status='ready'},[ordered]@{source_status='Completed';spectra_status='done'})}
    }else{
      [ordered]@{strategy='spectra-standard';provider='jira';mapping_version='1.0.0';read_only=$true;issue_types=@([ordered]@{source_type='Epic';spectra_category='work';hierarchy_level=0},[ordered]@{source_type='Task';spectra_category='work';hierarchy_level=1},[ordered]@{source_type='Bug';spectra_category='defect';hierarchy_level=1});status_mappings=@([ordered]@{source_status='Open';spectra_status='planned'},[ordered]@{source_status='Done';spectra_status='done'})}
    }
    $blueprints=if($mode-eq'new'){@('BPC-CONFLUENCE-PROJECT','BPC-JIRA-PROJECT','BPC-BLANK-DOCUMENTS','BPC-METADATA')}elseif($mode-eq'local'){@('BPC-METADATA')}else{@('BPC-CONFLUENCE-PROJECT','BPC-JIRA-PROJECT')}
    $config=[ordered]@{schema_version=1;product_id='spectra';mode=$mode;project_id="PRJ-SYN-$($mode.ToUpperInvariant())";project_name="Synthetisches Projekt $mode";profile=if($mode-eq'local'){'support-only'}else{'implementation'};language='de-DE';bc_package='bc-basic-standard';processes=@('finance','p2p','o2c');collaboration=if($mode-eq'onboard'){'existing-atlassian-readonly'}elseif($mode-eq'local'){'local-only'}else{'portable-atlassian'};project_space=[ordered]@{id="SPACE-PROJECT-$($mode.ToUpperInvariant())";title='Zentraler Projektbereich'};referenced_spaces=@([ordered]@{id='SPACE-KNOWLEDGE';title='Referenziertes Wissen';read_only=$true});ticket_structure=$ticket;blueprints=@($blueprints);onboarding_source=if($mode-eq'onboard'){[ordered]@{path='export';format='spectra-portable-atlassian-v1'}}else{$null}}
    $configPath=Join-Path $case 'init.json';[IO.File]::WriteAllText($configPath,($config|ConvertTo-Json -Depth 10),(New-Object Text.UTF8Encoding($false)))
    $destination=Join-Path $case 'workspace'
    $before=if($mode-eq'onboard'){(Get-FileHash (Join-Path $case 'export\jira-issues.json')).Hash}else{$null}
    $dry=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace $destination -ConfigPath $configPath|ConvertFrom-Json
    if($dry.writes_performed-or(Test-Path $destination)){throw 'INIT_DRYRUN_MUTATED'}
    $apply=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace $destination -ConfigPath $configPath -Apply|ConvertFrom-Json
    if(-not$apply.writes_performed-or$apply.status-ne'APPLIED'){throw 'INIT_APPLY_FAILED'}
    $result=Get-Content (Join-Path $destination 'governance\project-init.json') -Raw|ConvertFrom-Json
    if($result.project_space.id-ne$config.project_space.id-or$result.live_write_enabled-ne$false){throw 'INIT_PROJECT_SPACE_INVALID'}
    $expectedCanonical=if($mode-eq'local'){'bp-customer-support'}else{'bp-bc-basic'}
    if([string]$result.blueprint_contract -cne 'blueprint-catalog-v2' -or [string]$result.canonical_blueprint_id -cne $expectedCanonical){throw 'INIT_CANONICAL_BLUEPRINT_INVALID'}
    if(-not(Test-Path (Join-Path $destination 'governance\blueprint-proposal\preview.json'))){throw 'INIT_CANONICAL_BLUEPRINT_PREVIEW_MISSING'}
    $ticketResult=Get-Content (Join-Path $destination 'collaboration\jira-structure.json') -Raw|ConvertFrom-Json
    if($ticketResult.strategy-ne$ticket.strategy-or$ticketResult.mapping_version-ne$ticket.mapping_version-or$ticketResult.source_values_preserved-ne$true){throw 'INIT_TICKET_MAPPING_INVALID'}
    if($mode-eq'local'){
      if(-not(Test-Path (Join-Path $destination 'templates\metadata\document.json'))-or(Test-Path (Join-Path $destination 'collaboration\pages\00 Support.md'))){throw 'INIT_BLUEPRINT_SELECTION_IGNORED'}
    }else{
      if(-not(Test-Path (Join-Path $destination 'collaboration\pages\00 Support.md'))-or-not(Test-Path (Join-Path $destination 'collaboration\jira-project-blueprint.json'))){throw 'INIT_BLUEPRINT_OUTPUT_MISSING'}
    }
    if($mode-eq'onboard' -and (Get-FileHash (Join-Path $case 'export\jira-issues.json')).Hash-ne$before){throw 'INIT_ONBOARDING_SOURCE_MUTATED'}
  }
  Write-Host 'PASS: Standardprofil und zwei abweichende Projekt-Ticketstrukturen sind deterministisch, portabel und isoliert.'
}finally{if(Test-Path $tmp){Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue}}
