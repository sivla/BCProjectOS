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
      @([ordered]@{id='ISSUE-SYN-001';type='task';title='Synthetische Aufgabe'})|ConvertTo-Json|Set-Content (Join-Path $source 'jira-issues.json') -Encoding utf8
    }
    $config=[ordered]@{schema_version=1;product_id='spectra';mode=$mode;project_id="PRJ-SYN-$($mode.ToUpperInvariant())";project_name="Synthetisches Projekt $mode";profile=if($mode-eq'local'){'support-only'}else{'implementation'};language='de-DE';bc_package='bc-basic-standard';processes=@('finance','p2p','o2c');collaboration=if($mode-eq'onboard'){'existing-atlassian-readonly'}elseif($mode-eq'local'){'local-only'}else{'portable-atlassian'};project_space=[ordered]@{id="SPACE-PROJECT-$($mode.ToUpperInvariant())";title='Zentraler Projektbereich'};referenced_spaces=@([ordered]@{id='SPACE-KNOWLEDGE';title='Referenziertes Wissen';read_only=$true});onboarding_source=if($mode-eq'onboard'){[ordered]@{path='export';format='spectra-portable-atlassian-v1'}}else{$null}}
    $configPath=Join-Path $case 'init.json';[IO.File]::WriteAllText($configPath,($config|ConvertTo-Json -Depth 10),(New-Object Text.UTF8Encoding($false)))
    $destination=Join-Path $case 'workspace'
    $before=if($mode-eq'onboard'){(Get-FileHash (Join-Path $case 'export\jira-issues.json')).Hash}else{$null}
    $dry=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace $destination -ConfigPath $configPath|ConvertFrom-Json
    if($dry.writes_performed-or(Test-Path $destination)){throw 'INIT_DRYRUN_MUTATED'}
    $apply=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command init -Workspace $destination -ConfigPath $configPath -Apply|ConvertFrom-Json
    if(-not$apply.writes_performed-or$apply.status-ne'APPLIED'){throw 'INIT_APPLY_FAILED'}
    $result=Get-Content (Join-Path $destination 'governance\project-init.json') -Raw|ConvertFrom-Json
    if($result.project_space.id-ne$config.project_space.id-or$result.live_write_enabled-ne$false){throw 'INIT_PROJECT_SPACE_INVALID'}
    if($mode-eq'onboard' -and (Get-FileHash (Join-Path $case 'export\jira-issues.json')).Hash-ne$before){throw 'INIT_ONBOARDING_SOURCE_MUTATED'}
  }
  Write-Host 'PASS: New, local and read-only onboarding initialization are deterministic and isolated.'
}finally{if(Test-Path $tmp){Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue}}
