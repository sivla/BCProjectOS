[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference='Stop'
Set-StrictMode -Version 2.0
$root=[IO.Path]::GetFullPath($Path)
$recordPath=Join-Path $root 'engagement-fit-standard.json'
if(-not(Test-Path -LiteralPath $recordPath -PathType Leaf)){throw 'ENGAGEMENT_RECORD_MISSING'}
$record=Get-Content -LiteralPath $recordPath -Raw|ConvertFrom-Json
. (Join-Path $PSScriptRoot 'Spectra.JsonSchema.ps1')
$schema=Get-Content (Join-Path $PSScriptRoot '..\schemas\engagement-fit-standard.schema.json') -Raw|ConvertFrom-Json
try{Test-SpectraJsonSchema -Value $record -Schema $schema -RootSchema $schema}catch{throw 'ENGAGEMENT_SCHEMA_INVALID'}

function Assert-Unique([array]$Values,[string]$Code){if(@($Values|Sort-Object -Unique).Count-ne$Values.Count){throw $Code}}
function Assert-References([array]$Values,[array]$Allowed,[string]$Code){foreach($value in $Values){if($Allowed -notcontains [string]$value){throw $Code}}}

$roleIds=@($record.roles|ForEach-Object role_id)
$scopeIds=@($record.scope_items|ForEach-Object scope_id)
$phaseIds=@($record.phases|ForEach-Object phase_id)
$deliverableIds=@($record.deliverables|ForEach-Object deliverable_id)
$assumptionIds=@($record.assumptions|ForEach-Object assumption_id)
$processIds=@($record.processes|ForEach-Object process_id)
$useCaseIds=@($record.use_cases|ForEach-Object use_case_id)
$decisionIds=@($record.decisions|ForEach-Object decision_id)
$optionIds=@($record.assessments|ForEach-Object{@($_.options|ForEach-Object option_id)})
$allIds=@($record.engagement_id,$record.project_id,$record.customer_id,$record.offer.offer_id)+@($record.scope_items|ForEach-Object scope_id)+@($record.exclusions|ForEach-Object exclusion_id)+$assumptionIds+$phaseIds+$deliverableIds+$roleIds+@($record.gates|ForEach-Object gate_id)+$processIds+@($record.processes|ForEach-Object{@($_.steps|ForEach-Object step_id)})+$useCaseIds+@($record.assessments|ForEach-Object assessment_id)+$optionIds+$decisionIds+@($record.open_questions|ForEach-Object question_id)
Assert-Unique $allIds 'ENGAGEMENT_DUPLICATE_ID'
if([datetime]$record.offer.valid_from -gt [datetime]$record.offer.valid_to){throw 'ENGAGEMENT_OFFER_PERIOD_INVALID'}
$history=@($record.offer.change_history|Sort-Object version)
for($i=0;$i-lt$history.Count;$i++){
  if([int]$history[$i].version-ne($i+1)-or[datetime]$history[$i].valid_from-gt[datetime]$history[$i].valid_to){throw 'ENGAGEMENT_OFFER_HISTORY_INVALID'}
  Assert-References @($history[$i].scope_ids) $scopeIds 'ENGAGEMENT_SCOPE_REFERENCE_INVALID'
}
$current=$history[-1]
if([int]$current.version-ne[int]$record.offer.version-or$current.status-ne$record.offer.status-or[decimal]$current.planned_hours-ne[decimal]$record.offer.planned_hours-or[decimal]$current.planned_cost-ne[decimal]$record.offer.planned_cost-or$current.valid_from-ne$record.offer.valid_from-or$current.valid_to-ne$record.offer.valid_to){throw 'ENGAGEMENT_OFFER_HISTORY_INVALID'}
$inScope=@($record.scope_items|Where-Object outcome -eq 'in-scope')
if([decimal](@($inScope|Measure-Object planned_hours -Sum).Sum)-ne[decimal]$record.offer.planned_hours-or[decimal](@($inScope|Measure-Object planned_cost -Sum).Sum)-ne[decimal]$record.offer.planned_cost){throw 'ENGAGEMENT_SCOPE_TOTAL_INVALID'}

foreach($assumption in $record.assumptions){Assert-References @($assumption.owner_role) $roleIds 'ENGAGEMENT_ROLE_REFERENCE_INVALID'}
foreach($scope in $record.scope_items){Assert-References @($scope.assumption_ids) $assumptionIds 'ENGAGEMENT_ASSUMPTION_REFERENCE_INVALID';Assert-References @($scope.deliverable_ids) $deliverableIds 'ENGAGEMENT_DELIVERABLE_REFERENCE_INVALID'}

$orderedPhases=@($record.phases|Sort-Object sequence)
for($i=0;$i-lt$orderedPhases.Count;$i++){
  if([int]$orderedPhases[$i].sequence-ne($i+1)-or[datetime]$orderedPhases[$i].start_date-gt[datetime]$orderedPhases[$i].end_date){throw 'ENGAGEMENT_PHASE_SEQUENCE_INVALID'}
  if($i-gt0-and[datetime]$orderedPhases[$i].start_date-lt[datetime]$orderedPhases[$i-1].start_date){throw 'ENGAGEMENT_PHASE_SEQUENCE_INVALID'}
}
foreach($deliverable in $record.deliverables){Assert-References @($deliverable.phase_id) $phaseIds 'ENGAGEMENT_PHASE_REFERENCE_INVALID';$phase=@($record.phases|Where-Object phase_id -eq $deliverable.phase_id)[0];if([datetime]$deliverable.due_date-lt[datetime]$phase.start_date-or[datetime]$deliverable.due_date-gt[datetime]$phase.end_date){throw 'ENGAGEMENT_DELIVERABLE_DUE_DATE_INVALID'}}

$raciKeys=@()
foreach($assignment in $record.raci){Assert-References @($assignment.deliverable_id) $deliverableIds 'ENGAGEMENT_DELIVERABLE_REFERENCE_INVALID';Assert-References @($assignment.role_id) $roleIds 'ENGAGEMENT_ROLE_REFERENCE_INVALID';$raciKeys+="$($assignment.deliverable_id)|$($assignment.role_id)|$($assignment.responsibility)"}
Assert-Unique $raciKeys 'ENGAGEMENT_RACI_DUPLICATE'
foreach($deliverableId in $deliverableIds){$rows=@($record.raci|Where-Object deliverable_id -eq $deliverableId);if(@($rows|Where-Object responsibility -eq 'A').Count-ne1-or@($rows|Where-Object responsibility -eq 'R').Count-lt1){throw 'ENGAGEMENT_RACI_INCOMPLETE'}}

foreach($gate in $record.gates){Assert-References @($gate.phase_id) $phaseIds 'ENGAGEMENT_PHASE_REFERENCE_INVALID';$phase=@($record.phases|Where-Object phase_id -eq $gate.phase_id)[0];if([datetime]$gate.due_date-lt[datetime]$phase.start_date-or[datetime]$gate.due_date-gt[datetime]$phase.end_date){throw 'ENGAGEMENT_GATE_DUE_DATE_INVALID'};if($gate.decision_id){Assert-References @($gate.decision_id) $decisionIds 'ENGAGEMENT_DECISION_REFERENCE_INVALID'};if($gate.status-eq'passed'-and@($gate.evidence_refs).Count-eq0){throw 'ENGAGEMENT_GATE_EVIDENCE_MISSING'}}
foreach($process in $record.processes){Assert-References @($process.owner_role) $roleIds 'ENGAGEMENT_ROLE_REFERENCE_INVALID';$steps=@($process.steps|Sort-Object sequence);for($i=0;$i-lt$steps.Count;$i++){if([int]$steps[$i].sequence-ne($i+1)){throw 'ENGAGEMENT_PROCESS_SEQUENCE_INVALID'};Assert-References @($steps[$i].actor_role) $roleIds 'ENGAGEMENT_ROLE_REFERENCE_INVALID'}}
foreach($useCase in $record.use_cases){Assert-References @($useCase.process_id) $processIds 'ENGAGEMENT_PROCESS_REFERENCE_INVALID'}

foreach($decision in $record.decisions){Assert-References @($decision.owner_role) $roleIds 'ENGAGEMENT_ROLE_REFERENCE_INVALID';Assert-References @($decision.selected_option_id) $optionIds 'ENGAGEMENT_OPTION_REFERENCE_INVALID';if($decision.status-eq'approved'-and(-not$decision.decided_at-or@($decision.evidence_refs).Count-eq0)){throw 'ENGAGEMENT_DECISION_EVIDENCE_INVALID'}}
foreach($assessment in $record.assessments){
  Assert-References @($assessment.process_id) $processIds 'ENGAGEMENT_PROCESS_REFERENCE_INVALID';Assert-References @($assessment.use_case_id) $useCaseIds 'ENGAGEMENT_USE_CASE_REFERENCE_INVALID';Assert-References @($assessment.assumption_ids) $assumptionIds 'ENGAGEMENT_ASSUMPTION_REFERENCE_INVALID';Assert-References @($assessment.scope_ids) $scopeIds 'ENGAGEMENT_SCOPE_REFERENCE_INVALID';Assert-References @($assessment.deliverable_ids) $deliverableIds 'ENGAGEMENT_DELIVERABLE_REFERENCE_INVALID'
  $localOptions=@($assessment.options|ForEach-Object option_id);if($localOptions-notcontains$assessment.recommended_option_id){throw 'ENGAGEMENT_RECOMMENDATION_INVALID'}
  if($assessment.status-eq'decided'){
    Assert-References @($assessment.decision_id) $decisionIds 'ENGAGEMENT_DECISION_REFERENCE_INVALID';$decision=@($record.decisions|Where-Object decision_id -eq $assessment.decision_id)[0]
    if($decision.status-ne'approved'-or$decision.selected_option_id-ne$assessment.recommended_option_id){throw 'ENGAGEMENT_DECISION_MISMATCH'}
  }
}
$questionTargets=$scopeIds+$phaseIds+$deliverableIds+@($record.gates|ForEach-Object gate_id)+$processIds+$useCaseIds+@($record.assessments|ForEach-Object assessment_id)+$decisionIds
foreach($question in $record.open_questions){Assert-References @($question.owner_role) $roleIds 'ENGAGEMENT_ROLE_REFERENCE_INVALID';Assert-References @($question.related_ids) $questionTargets 'ENGAGEMENT_QUESTION_REFERENCE_INVALID';if($question.decision_id){Assert-References @($question.decision_id) $decisionIds 'ENGAGEMENT_DECISION_REFERENCE_INVALID'};if($question.status-eq'answered'-and([string]::IsNullOrWhiteSpace($question.answer)-or@($question.source_refs).Count-eq0)){throw 'ENGAGEMENT_QUESTION_EVIDENCE_INVALID'}}

if($record.classification-eq'synthetic-fixture'-and($record.synthetic-ne$true-or$record.truth_boundary.source_of_truth-ne'synthetic-fixture')){throw 'ENGAGEMENT_TRUTH_BOUNDARY_INVALID'}
$blocking=@()
$blocking+=@($record.assumptions|Where-Object status -ne 'confirmed'|ForEach-Object{"ASSUMPTION:$($_.assumption_id)"})
$blocking+=@($record.assessments|Where-Object{$_.status-ne'decided'-or$_.fit_status-eq'unresolved'}|ForEach-Object{"ASSESSMENT:$($_.assessment_id)"})
$blocking+=@($record.gates|Where-Object status -ne 'passed'|ForEach-Object{"GATE:$($_.gate_id)"})
$blocking+=@($record.deliverables|Where-Object status -ne 'accepted'|ForEach-Object{"DELIVERABLE:$($_.deliverable_id)"})
$blocking+=@($record.open_questions|Where-Object{$_.blocks_gate-and$_.status-ne'answered'}|ForEach-Object{"QUESTION:$($_.question_id)"})
if($record.readiness.status-eq'fit_to_standard_ready'-and$blocking.Count-gt0){throw 'ENGAGEMENT_READINESS_FALSE_CLAIM'}
if($record.readiness.status-eq'fit_to_standard_ready'-and@($record.readiness.blocking_reasons).Count-ne0){throw 'ENGAGEMENT_READINESS_SUMMARY_INVALID'}
if($record.readiness.status-eq'blocked'-and@($record.readiness.blocking_reasons).Count-ne$blocking.Count){throw 'ENGAGEMENT_READINESS_SUMMARY_INVALID'}
Write-Host 'PASS: Engagement, Scope, RACI, Prozesse, Fit-/Gap-Entscheidungen und Readiness sind konsistent.'
