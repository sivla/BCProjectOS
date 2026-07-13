[CmdletBinding()]
param([Parameter(Mandatory)][string]$Path,[string]$Process,[string]$Role,[string]$Object,[string]$ProjectPhase,[string]$TaskType)
$ErrorActionPreference='Stop'
function Fail([string]$Code){throw $Code}
$file=Join-Path $Path 'bc-knowledge.json'
if(-not(Test-Path $file)){Fail 'BC_KNOWLEDGE_FILE_MISSING'}
$raw=Get-Content -Raw $file
try{$v=$raw|ConvertFrom-Json}catch{Fail 'BC_KNOWLEDGE_SCHEMA_INVALID'}
if($raw -match '(?i)password\s*=|api[_-]?token|client[_-]?secret'){Fail 'BC_KNOWLEDGE_SECRET_BLOCKED'}
if($raw -match '(?i)Universaarl|UABC|customer-evidence'){Fail 'BC_KNOWLEDGE_CUSTOMER_DATA'}
if($raw -match '[A-Za-z]:\\'){Fail 'BC_KNOWLEDGE_ABSOLUTE_PATH'}
if($v.product_id -ne 'spectra'){Fail 'BC_KNOWLEDGE_SCHEMA_INVALID'}
$allowed=@('https://github.com/MicrosoftDocs/dynamics365smb-docs.git','https://github.com/MicrosoftDocs/dynamics365smb-devitpro-pb.git','https://github.com/microsoft/BCApps.git')
$sourceIds=@{}
foreach($src in @($v.source_locks)){
  if([string]::IsNullOrWhiteSpace($src.source_id)-or[string]::IsNullOrWhiteSpace($src.title)-or[string]::IsNullOrWhiteSpace($src.publisher)){Fail 'BC_KNOWLEDGE_PROVENANCE_MISSING'}
  if($sourceIds.ContainsKey($src.source_id)){Fail 'BC_KNOWLEDGE_PROVENANCE_AMBIGUOUS'}
  if($src.canonical_url -notin $allowed -or $src.publisher -ne 'Microsoft'){Fail 'BC_KNOWLEDGE_SOURCE_UNAPPROVED'}
  if($src.commit -notmatch '^[a-f0-9]{40}$' -or $src.tree -notmatch '^[a-f0-9]{40}$' -or $src.content_digest -notmatch '^[a-f0-9]{64}$'){Fail 'BC_KNOWLEDGE_PROVENANCE_UNBOUND'}
  $sourceIds[$src.source_id]=$true
}
$ids=@{}
foreach($item in @($v.knowledge_items)){
  if($ids.ContainsKey($item.knowledge_id)){Fail 'BC_KNOWLEDGE_ID_DUPLICATE'};$ids[$item.knowledge_id]=$true
  if(-not $sourceIds.ContainsKey($item.source_id)){Fail 'BC_KNOWLEDGE_PROVENANCE_MISSING'}
  if([string]::IsNullOrWhiteSpace($item.locale)-or[string]::IsNullOrWhiteSpace($item.version)-or$item.locale-ne$v.locale-or$item.version-ne$v.bc_version){Fail 'BC_KNOWLEDGE_VERSION_LOCALE_MISMATCH'}
  if($item.knowledge_kind -notin @('official_documented','derived_standard_metadata','tested_generic_procedure','open_assumption')){Fail 'BC_KNOWLEDGE_KIND_UNKNOWN'}
  if(@($item.object_refs|Where-Object{$_ -match '^page:21$'}).Count -gt 0 -and @($item.object_refs|Where-Object{$_ -match '^page:22$'}).Count -gt 0){Fail 'BC_KNOWLEDGE_OBJECT_ID_CONTRADICTORY'}
  if($item.expected_effect -match '(?i)produktiv erfolgreich|customer accepted'){Fail 'BC_KNOWLEDGE_PRODUCTION_CLAIM'}
}
foreach($pt in @($v.playthroughs)){
  if($pt.mode-ne'plan-only'-or$pt.direct_mutation){Fail 'BC_KNOWLEDGE_DIRECT_MUTATION'}
  if($pt.customer_target-ne'unbound'){Fail 'BC_KNOWLEDGE_CUSTOMER_DATA'}
  if($pt.baseline-eq'microsoft_demo_baseline'-and($pt.title-match'(?i)fertig|produktiv')){Fail 'BC_KNOWLEDGE_CRONUS_NOT_CUSTOMER_READY'}
}
try{$s=Get-Content -Raw (Join-Path $PSScriptRoot '..\schemas\bc-consultant-knowledge.schema.json')|ConvertFrom-Json;$script:RootSchema=$s;$script:InvokeSchema={param([AllowNull()]$x,$y,$p).(Join-Path $PSScriptRoot 'Invoke-PortableSchemaValidation.ps1') -Value $x -Schema $y -RootSchema $script:RootSchema -Path $p};.(Join-Path $PSScriptRoot 'Invoke-PortableSchemaValidation.ps1') -Value $v -Schema $s -RootSchema $s -Path root}catch{Fail 'BC_KNOWLEDGE_SCHEMA_INVALID'}
$q=@($v.knowledge_items|Where-Object{(-not$Process-or$_.process-eq$Process)-and(-not$Role-or$_.role-eq$Role)-and(-not$Object-or$_.object_refs-contains$Object)-and(-not$ProjectPhase-or$_.project_phase-eq$ProjectPhase)-and(-not$TaskType-or$_.task_type-eq$TaskType)}|Sort-Object knowledge_id)
[pscustomobject]@{status='validated';count=$q.Count;items=$q}
