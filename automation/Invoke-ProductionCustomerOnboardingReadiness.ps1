[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][ValidateSet('preflight','plan','validate')][string]$Command,
  [Parameter(Mandatory=$true)][string]$InputPath,
  [string]$OutputPath,
  [string]$ProductRoot
)
$ErrorActionPreference='Stop'
$root=if($ProductRoot){[IO.Path]::GetFullPath($ProductRoot)}else{[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))}
$inputFull=[IO.Path]::GetFullPath($InputPath)
if(-not(Test-Path -LiteralPath $inputFull -PathType Leaf)){throw 'READINESS_INPUT_MISSING'}
. (Join-Path $PSScriptRoot 'Spectra.JsonSchema.ps1')
$schema=Get-Content -LiteralPath (Join-Path $root 'schemas/production-customer-onboarding-readiness.schema.json') -Raw|ConvertFrom-Json
try{$record=Get-Content -LiteralPath $inputFull -Raw|ConvertFrom-Json}catch{throw 'READINESS_SCHEMA_INVALID'}
if($record.project_type -notin @('implementation','support-only','fit-gap','migration')){throw 'READINESS_PROFILE_UNKNOWN'}
$ids=@([string]$record.customer_id,[string]$record.workspace_id,[string]$record.project_id)
if(@($ids|Select-Object -Unique).Count-ne3){throw 'READINESS_DUPLICATE_ID'}
if($record.predecessor -and [string]$record.predecessor.customer_id -cne [string]$record.customer_id){throw 'READINESS_CROSS_CUSTOMER_REFERENCE'}
if([string]$record.atlassian.mode -notin @('simulated','manual-materialization') -or [bool]$record.atlassian.live_apply){throw 'READINESS_LIVE_APPLY_FORBIDDEN'}
foreach($secretRef in @($record.data_boundary.secret_references)){if([string]$secretRef -cnotmatch '^[A-Z][A-Z0-9_]{2,80}$'){throw 'READINESS_SECRET_VALUE_FORBIDDEN'}}
foreach($property in @($record.PSObject.Properties)){
  foreach($value in @($property.Value)){if($value -is [string] -and ([IO.Path]::IsPathRooted($value) -or $value -match '(^|[\\/])\.\.([\\/]|$)')){throw 'READINESS_ABSOLUTE_PATH_FORBIDDEN'}}
}
$manifestRelative=[string]$record.product_binding.manifest_path
if([IO.Path]::IsPathRooted($manifestRelative) -or $manifestRelative -match '(^|[\\/])\.\.([\\/]|$)'){throw 'READINESS_ABSOLUTE_PATH_FORBIDDEN'}
try{Test-SpectraJsonSchema -Value $record -Schema $schema -RootSchema $schema -Path root}catch{throw 'READINESS_SCHEMA_INVALID'}
$manifestPath=Join-Path $root ($manifestRelative -replace '/', [IO.Path]::DirectorySeparatorChar)
if(-not(Test-Path -LiteralPath $manifestPath -PathType Leaf)){throw 'READINESS_RELEASE_EVIDENCE_MISSING'}
$manifest=Get-Content -LiteralPath $manifestPath -Raw|ConvertFrom-Json
if($manifest.manifest_state -ne 'final' -or -not [bool]$manifest.installable_blueprint -or $manifest.release_version -cne $record.product_binding.version -or $manifest.expected_tag -cne $record.product_binding.release_tag){throw 'READINESS_RELEASE_EVIDENCE_INVALID'}

$steps=@(
  [ordered]@{order=1;operation='release-preflight';mode='read-only'},
  [ordered]@{order=2;operation=if($record.predecessor){'brownfield-adopt'}else{'workspace-init'};mode='plan-only'},
  [ordered]@{order=3;operation='project-register';mode='explicit-apply'},
  [ordered]@{order=4;operation='workspace-validate';mode='read-only'},
  [ordered]@{order=5;operation='source-intake';mode='proposal-only'},
  [ordered]@{order=6;operation='upgrade-plan';mode='plan-only'},
  [ordered]@{order=7;operation='backup-restore-proof';mode='explicit-apply'},
  [ordered]@{order=8;operation='snapshot-handoff';mode='explicit-apply'},
  [ordered]@{order=9;operation='support-readiness';mode='read-only'},
  [ordered]@{order=10;operation='safe-uninstall';mode='explicit-apply'}
)
$plan=[ordered]@{schema_version=1;product_id='spectra';customer_id=$record.customer_id;workspace_id=$record.workspace_id;project_id=$record.project_id;project_type=$record.project_type;release_tag=$record.product_binding.release_tag;atlassian_mode=$record.atlassian.mode;customer_go_live_ready='not-applicable';steps=$steps;writes_performed=$false}
if($Command-eq'plan'){
  if(-not$OutputPath){throw 'READINESS_PLAN_OUTPUT_REQUIRED'}
  $outputFull=[IO.Path]::GetFullPath($OutputPath)
  $parent=Split-Path -Parent $outputFull;if(-not(Test-Path $parent -PathType Container)){throw 'READINESS_PLAN_PARENT_MISSING'}
  $temp=Join-Path $parent ('.'+[IO.Path]::GetFileName($outputFull)+'.'+[guid]::NewGuid().ToString('N')+'.tmp')
  $content=($plan|ConvertTo-Json -Depth 10)+[Environment]::NewLine
  $writeRequired=-not(Test-Path $outputFull -PathType Leaf) -or [IO.File]::ReadAllText($outputFull) -cne $content
  if($writeRequired){try{[IO.File]::WriteAllText($temp,$content,[Text.UTF8Encoding]::new($false));Move-Item -LiteralPath $temp -Destination $outputFull -Force}finally{if(Test-Path $temp){Remove-Item $temp -Force}}}
}
[ordered]@{product_id='spectra';command=$Command;status=if($Command-eq'plan'){'PLANNED'}else{'PASS'};profile=$record.project_type;writes_performed=if($Command-eq'plan'){$writeRequired}else{$false};remote_writes=$false;plan=$plan}|ConvertTo-Json -Depth 12
