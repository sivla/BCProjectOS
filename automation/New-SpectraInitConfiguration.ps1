[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$OutputPath,
  [string]$AnswersPath,
  [switch]$Interactive
)
$ErrorActionPreference='Stop';Set-StrictMode -Version 2.0
function Split-Values([string]$Value){return @($Value-split','|ForEach-Object{$_.Trim()}|Where-Object{$_})}
function Assert-Relative([string]$Value,[string]$Code){if([string]::IsNullOrWhiteSpace($Value)-or[IO.Path]::IsPathRooted($Value)-or$Value-match'(^|[\\/])\.\.([\\/]|$)|\\'){throw $Code}}
function Read-OptionalJson([string]$Base,[AllowNull()][string]$Relative,[string]$Code){if([string]::IsNullOrWhiteSpace($Relative)){return @()};Assert-Relative $Relative $Code;$path=Join-Path $Base $Relative;if(-not(Test-Path $path -PathType Leaf)){throw $Code};return Get-Content $path -Raw|ConvertFrom-Json}

if([bool]$AnswersPath-eq[bool]$Interactive){throw 'GUIDED_INIT_INPUT_MODE_INVALID'}
$output=[IO.Path]::GetFullPath($OutputPath);if(Test-Path $output){throw 'GUIDED_INIT_OUTPUT_EXISTS'};$outputParent=Split-Path -Parent $output;if(-not(Test-Path $outputParent -PathType Container)){throw 'GUIDED_INIT_OUTPUT_PARENT_MISSING'}
if($AnswersPath){$answersFull=[IO.Path]::GetFullPath($AnswersPath);if(-not(Test-Path $answersFull -PathType Leaf)){throw 'GUIDED_INIT_ANSWERS_MISSING'};$base=Split-Path -Parent $answersFull;$a=Get-Content $answersFull -Raw|ConvertFrom-Json}
else{
  $base=[IO.Path]::GetFullPath((Get-Location).Path)
  $mode=Read-Host 'Modus (new|local|onboard)'
  $profile=Read-Host 'Profil (implementation|support-only)'
  $projectType=Read-Host 'Projektart (implementation|support|fit-gap|migration)'
  $ticketStrategy=Read-Host 'Ticketstrategie (spectra-standard|project-mapping|imported-readonly)'
  $a=[pscustomobject]@{
    mode=$mode;project_id=(Read-Host 'Projekt-ID, z. B. PRJ-NEU-001');project_name=(Read-Host 'Projektname');profile=$profile;project_type=$projectType
    language=(Read-Host 'Sprache (de-DE|en-US)');processes=Split-Values (Read-Host 'BC-Prozesse, kommagetrennt')
    collaboration=(Read-Host 'Zusammenarbeit (local-only|portable-atlassian|existing-atlassian-readonly)')
    project_space_id=(Read-Host 'ID des zentralen Projekt-Space');project_space_title=(Read-Host 'Titel des zentralen Projekt-Space')
    referenced_spaces_path=(Read-Host 'Optionale relative JSON-Datei für weitere read-only Spaces')
    ticket_strategy=$ticketStrategy;ticket_provider=(Read-Host 'Ticketprovider (jira|generic-file|other)')
    ticket_mapping_version=(Read-Host 'Mappingversion');ticket_mapping_path=if($ticketStrategy-eq'spectra-standard'){$null}else{Read-Host 'Relative JSON-Datei mit Ticketmapping'}
    blueprints=Split-Values (Read-Host 'Blueprint-IDs, kommagetrennt')
    onboarding_source_path=if($mode-eq'onboard'){Read-Host 'Relativer Pfad zum portablen Export'}else{$null}
    predecessor_project_id=(Read-Host 'Optionale Vorgänger-Projekt-ID')
    predecessor_project_type=(Read-Host 'Optionale Vorgänger-Projektart')
    predecessor_relationship=(Read-Host 'Optionale Beziehung (continues-as|migrates-from|onboards-from)')
  }
}

$required=@('mode','project_id','project_name','profile','language','processes','collaboration','project_space_id','project_space_title','ticket_strategy','ticket_provider','ticket_mapping_version','blueprints')
foreach($name in $required){$p=$a.PSObject.Properties[$name];if($null-eq$p-or$null-eq$p.Value-or($p.Value-is[string]-and[string]::IsNullOrWhiteSpace($p.Value))){throw "GUIDED_INIT_ANSWER_MISSING:$name"}}
$referencedSpaces=@(Read-OptionalJson $base ([string]$a.referenced_spaces_path) 'GUIDED_INIT_REFERENCED_SPACES_INVALID')
$projectTypeProperty=$a.PSObject.Properties['project_type']
$projectType=if($null-ne$projectTypeProperty-and-not[string]::IsNullOrWhiteSpace([string]$projectTypeProperty.Value)){[string]$projectTypeProperty.Value}elseif([string]$a.profile-eq'support-only'){'support'}else{'implementation'}
$predecessorNames=@('predecessor_project_id','predecessor_project_type','predecessor_relationship')
$predecessorValues=@();foreach($name in $predecessorNames){$property=$a.PSObject.Properties[$name];$predecessorValues+=,$(if($null-ne$property){[string]$property.Value}else{$null})}
$presentPredecessorValues=@($predecessorValues|Where-Object{-not[string]::IsNullOrWhiteSpace($_)})
if($presentPredecessorValues.Count-ne0-and$presentPredecessorValues.Count-ne3){throw 'GUIDED_INIT_PREDECESSOR_INCOMPLETE'}
$predecessor=if($presentPredecessorValues.Count-eq3){[ordered]@{project_id=$predecessorValues[0];project_type=$predecessorValues[1];relationship=$predecessorValues[2];read_only=$true}}else{$null}
if([string]$a.ticket_strategy-eq'spectra-standard'){
  $ticket=[ordered]@{strategy='spectra-standard';provider=[string]$a.ticket_provider;mapping_version=[string]$a.ticket_mapping_version;read_only=$true;issue_types=@([ordered]@{source_type='Epic';spectra_category='work';hierarchy_level=0},[ordered]@{source_type='Story';spectra_category='work';hierarchy_level=1},[ordered]@{source_type='Task';spectra_category='work';hierarchy_level=2},[ordered]@{source_type='Bug';spectra_category='defect';hierarchy_level=2});status_mappings=@([ordered]@{source_status='Open';spectra_status='planned'},[ordered]@{source_status='In Progress';spectra_status='in_progress'},[ordered]@{source_status='Done';spectra_status='done'})}
}else{
  $mappingPath=[string]$a.ticket_mapping_path;Assert-Relative $mappingPath 'GUIDED_INIT_TICKET_MAPPING_INVALID';$full=Join-Path $base $mappingPath;if(-not(Test-Path $full -PathType Leaf)){throw 'GUIDED_INIT_TICKET_MAPPING_INVALID'};$ticket=Get-Content $full -Raw|ConvertFrom-Json
  $ticket.strategy=[string]$a.ticket_strategy;$ticket.provider=[string]$a.ticket_provider;$ticket.mapping_version=[string]$a.ticket_mapping_version
}
$config=[ordered]@{schema_version=1;product_id='spectra';mode=[string]$a.mode;project_id=[string]$a.project_id;project_name=[string]$a.project_name;profile=[string]$a.profile;project_type=$projectType;language=[string]$a.language;bc_package='bc-basic-standard';processes=@($a.processes);collaboration=[string]$a.collaboration;project_space=[ordered]@{id=[string]$a.project_space_id;title=[string]$a.project_space_title};referenced_spaces=$referencedSpaces;ticket_structure=$ticket;blueprints=@($a.blueprints);onboarding_source=if([string]$a.mode-eq'onboard'){[ordered]@{path=[string]$a.onboarding_source_path;format='spectra-portable-atlassian-v1'}}else{$null};predecessor=$predecessor}
. (Join-Path $PSScriptRoot 'Spectra.JsonSchema.ps1');$schema=Get-Content (Join-Path $PSScriptRoot '..\schemas\project-init.schema.json') -Raw|ConvertFrom-Json
try{Test-SpectraJsonSchema -Value ($config|ConvertTo-Json -Depth 20|ConvertFrom-Json) -Schema $schema -RootSchema $schema -Path root}catch{throw 'GUIDED_INIT_CONFIG_INVALID'}
[IO.File]::WriteAllText($output,(($config|ConvertTo-Json -Depth 20)+"`n"),(New-Object Text.UTF8Encoding($false)))
Write-Host "PASS: Geführte Init-Konfiguration erzeugt: $output"
