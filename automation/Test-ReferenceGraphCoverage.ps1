[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath($Path)
$recordPath=Join-Path $root 'graph\reference-graph-coverage.json'
if(-not(Test-Path -LiteralPath $recordPath -PathType Leaf)){throw 'GRAPH_COVERAGE_RECORD_MISSING'}
$record=Get-Content -LiteralPath $recordPath -Raw|ConvertFrom-Json

$allowedReasons=@('direct','merged-duplicates','transformed-domain','excluded-nonportable','excluded-policy')
foreach($mapping in @($record.mappings)){if([string]$mapping.reason_code -notin $allowedReasons){throw 'GRAPH_COVERAGE_REASON_UNKNOWN'}}
if($record.claims.one_to_one_claim -ne $false -or $record.claims.complete_projection_claim -ne $false){throw 'GRAPH_COVERAGE_COMPLETENESS_CLAIM_INVALID'}
function Resolve-SafePath([string]$RelativePath){
  if([string]::IsNullOrWhiteSpace($RelativePath)-or $RelativePath -match '^[A-Za-z]:|^/|\\|(^|/)\.\.(/|$)'){throw 'GRAPH_COVERAGE_PATH_UNSAFE'}
  $resolved=[IO.Path]::GetFullPath((Join-Path $root $RelativePath))
  if(-not $resolved.StartsWith($root.TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'GRAPH_COVERAGE_PATH_UNSAFE'}
  if(-not(Test-Path -LiteralPath $resolved -PathType Leaf)){throw 'GRAPH_COVERAGE_FILE_MISSING'}
  return $resolved
}
foreach($binding in @($record.provenance.source,$record.provenance.mapping,$record.provenance.projection)){[void](Resolve-SafePath ([string]$binding.path))}

. (Join-Path $PSScriptRoot 'Spectra.JsonSchema.ps1')
$schema=Get-Content (Join-Path $PSScriptRoot '..\schemas\reference-graph-coverage.schema.json') -Raw|ConvertFrom-Json
try{Test-SpectraJsonSchema -Value $record -Schema $schema -RootSchema $schema}catch{throw 'GRAPH_COVERAGE_SCHEMA_INVALID'}
if($record.provenance.source_mode -ne 'read-only' -or $record.provenance.source_unchanged -ne $true -or $record.provenance.writes_performed -ne $false -or $record.provenance.projection_only -ne $true){throw 'GRAPH_COVERAGE_READ_ONLY_BOUNDARY_INVALID'}

$sourcePath=Resolve-SafePath ([string]$record.provenance.source.path)
$mappingPath=Resolve-SafePath ([string]$record.provenance.mapping.path)
$projectionPath=Resolve-SafePath ([string]$record.provenance.projection.path)
foreach($pair in @(@($sourcePath,[string]$record.provenance.source.sha256),@($mappingPath,[string]$record.provenance.mapping.sha256),@($projectionPath,[string]$record.provenance.projection.sha256))){if((Get-FileHash -LiteralPath $pair[0] -Algorithm SHA256).Hash.ToLowerInvariant() -cne $pair[1]){throw 'GRAPH_COVERAGE_DIGEST_MISMATCH'}}

$native=@((Get-Content $sourcePath -Raw|ConvertFrom-Json).relations)
$portable=@((Get-Content $projectionPath -Raw|ConvertFrom-Json).edges)
$ruleFile=@((Get-Content $mappingPath -Raw|ConvertFrom-Json).mappings)
$nativeClasses=@($record.native_relation_classes);$portableClasses=@($record.portable_relation_classes);$mappings=@($record.mappings)
function Assert-Unique([array]$Values,[string]$Code){if(@($Values|Sort-Object -Unique).Count -ne $Values.Count){throw $Code}}
Assert-Unique @($native|ForEach-Object id) 'GRAPH_COVERAGE_NATIVE_ID_DUPLICATE'
Assert-Unique @($portable|ForEach-Object id) 'GRAPH_COVERAGE_PORTABLE_ID_DUPLICATE'
Assert-Unique @($nativeClasses|ForEach-Object class_id) 'GRAPH_COVERAGE_CLASS_DUPLICATE'
Assert-Unique @($portableClasses|ForEach-Object class_id) 'GRAPH_COVERAGE_CLASS_DUPLICATE'
Assert-Unique @($mappings|ForEach-Object mapping_id) 'GRAPH_COVERAGE_MAPPING_ID_DUPLICATE'
Assert-Unique @($mappings|ForEach-Object native_class) 'GRAPH_COVERAGE_DUPLICATE_MAPPING'

foreach($class in $nativeClasses){
  $actual=@($native|Where-Object class -ceq $class.class_id).Count
  if($actual -ne [int]$class.count){throw 'GRAPH_COVERAGE_CLASS_COUNT_MISMATCH'}
  $mapped=@($mappings|Where-Object native_class -ceq $class.class_id)
  if($mapped.Count -eq 0){throw 'GRAPH_COVERAGE_CLASS_MISSING'}
}
foreach($mapping in $mappings){
  $nativeClass=@($nativeClasses|Where-Object class_id -ceq $mapping.native_class)
  if($nativeClass.Count -ne 1){throw 'GRAPH_COVERAGE_CLASS_UNKNOWN'}
  if([int]$mapping.native_count -ne [int]$nativeClass[0].count){throw 'GRAPH_COVERAGE_MAPPING_COUNT_MISMATCH'}
  switch([string]$mapping.outcome){
    'projected' {if($mapping.reason_code -ne 'direct' -or [int]$mapping.native_count -ne [int]$mapping.portable_edge_count -or $null -eq $mapping.portable_class){throw 'GRAPH_COVERAGE_OUTCOME_INVALID'}}
    'merged' {if($mapping.reason_code -ne 'merged-duplicates' -or [int]$mapping.portable_edge_count -ge [int]$mapping.native_count -or [int]$mapping.portable_edge_count -le 0){throw 'GRAPH_COVERAGE_OUTCOME_INVALID'}}
    'transformed' {if($mapping.reason_code -ne 'transformed-domain' -or [int]$mapping.portable_edge_count -le 0 -or $null -eq $mapping.portable_class){throw 'GRAPH_COVERAGE_OUTCOME_INVALID'}}
    'excluded' {if($mapping.reason_code -notin @('excluded-nonportable','excluded-policy') -or [int]$mapping.portable_edge_count -ne 0 -or $null -ne $mapping.portable_class){throw 'GRAPH_COVERAGE_EXCLUSION_UNEXPLAINED'}}
  }
  if($mapping.outcome -ne 'excluded'){
    $portableClass=@($portableClasses|Where-Object class_id -ceq $mapping.portable_class)
    if($portableClass.Count -ne 1 -or [int]$portableClass[0].count -ne [int]$mapping.portable_edge_count){throw 'GRAPH_COVERAGE_PORTABLE_CLASS_MISMATCH'}
  }
}
foreach($class in $portableClasses){if(@($portable|Where-Object class -ceq $class.class_id).Count -ne [int]$class.count){throw 'GRAPH_COVERAGE_CLASS_COUNT_MISMATCH'}}

if($ruleFile.Count -ne $mappings.Count){throw 'GRAPH_COVERAGE_MAPPING_RULE_MISMATCH'}
foreach($mapping in $mappings){$rule=@($ruleFile|Where-Object mapping_id -ceq $mapping.mapping_id);if($rule.Count -ne 1 -or $rule[0].native_class -cne $mapping.native_class -or $rule[0].portable_class -cne $mapping.portable_class -or $rule[0].outcome -cne $mapping.outcome -or $rule[0].reason_code -cne $mapping.reason_code){throw 'GRAPH_COVERAGE_MAPPING_RULE_MISMATCH'}}

$nativeTotal=$native.Count;$portableTotal=$portable.Count;$accounted=(@($mappings|Measure-Object native_count -Sum).Sum);$excluded=(@($mappings|Where-Object outcome -eq excluded|Measure-Object native_count -Sum).Sum);$projected=$accounted-$excluded
$summary=$record.summary
if([int]$summary.native_total -ne $nativeTotal -or [int]$summary.portable_edge_total -ne $portableTotal -or [int]$summary.accounted_native_total -ne $accounted -or [int]$summary.projected_native_total -ne $projected -or [int]$summary.excluded_native_total -ne $excluded -or [int]$summary.coverage_numerator -ne $accounted -or [int]$summary.coverage_denominator -ne $nativeTotal){throw 'GRAPH_COVERAGE_SUMMARY_MISMATCH'}
$expectedRatio=[decimal]$accounted/[decimal]$nativeTotal
if([decimal]$summary.coverage_ratio -ne $expectedRatio -or [bool]$record.claims.explanation_complete -ne ($accounted -eq $nativeTotal)){throw 'GRAPH_COVERAGE_SUMMARY_MISMATCH'}
Write-Host 'PASS: Referenzgraph-Projektion, Coverage-Semantik, Digests und read-only Provenienz sind konsistent.'
