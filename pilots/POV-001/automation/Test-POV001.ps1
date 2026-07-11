[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$pilotRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$workspace = Join-Path $pilotRoot 'workspace'
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..'))
$findings = New-Object System.Collections.ArrayList

function Add-Finding([string]$Code, [string]$Message) {
    [void]$script:findings.Add([pscustomobject]@{ code=$Code; message=$Message })
}
function Read-JsonCompatible([string]$Path) {
    try { return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json }
    catch { Add-Finding 'STRUCTURED_SYNTAX_INVALID' "${Path}: $($_.Exception.Message)"; return $null }
}

$before = @{}
foreach ($file in Get-ChildItem -LiteralPath $pilotRoot -Recurse -File) {
    $before[$file.FullName] = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
}

$workspaceMeta = Read-JsonCompatible (Join-Path $workspace 'workspace.yaml')
if ($null -ne $workspaceMeta) {
    if ([string]$workspaceMeta.id -ne 'CUS-01J00000000000000000000100') { Add-Finding 'WORKSPACE_ID_INVALID' 'Unexpected synthetic workspace ID.' }
    if (@($workspaceMeta.openspec_roots).Count -ne 1 -or [string]$workspaceMeta.openspec_roots[0] -ne 'openspec') { Add-Finding 'OPENSPEC_ROOT_INVALID' 'Exactly one OpenSpec root is required.' }
    if ([string]$workspaceMeta.blueprint_version -notmatch '^\d+\.\d+\.\d+$') { Add-Finding 'BLUEPRINT_VERSION_INVALID' 'Blueprint version is not semantic.' }
}
$openSpecDirs = @(Get-ChildItem -LiteralPath $workspace -Recurse -Directory | Where-Object { $_.Name -eq 'openspec' })
if ($openSpecDirs.Count -ne 1) { Add-Finding 'OPENSPEC_ROOT_INVALID' "Expected one OpenSpec directory, found $($openSpecDirs.Count)." }

$canonicalText = (Get-ChildItem -LiteralPath $workspace -Recurse -File | Where-Object { $_.FullName -notmatch '[\\/]generated[\\/]' } | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }) -join "`n"
$knownIds = @{}
foreach ($match in [regex]::Matches($canonicalText, '\b(?:CUS|PRJ|SUP|MTG|FILE|KNO|PROC|BR|TKT|REQ|CHG|EVD)-[0-9A-HJKMNP-TV-Z]{26}\b')) { $knownIds[$match.Value] = $true }
foreach ($requiredPrefix in @('CUS','PRJ','SUP','MTG','FILE','KNO','BR','TKT','REQ','CHG','EVD')) {
    if (@($knownIds.Keys | Where-Object { $_ -like "$requiredPrefix-*" }).Count -eq 0) { Add-Finding 'ENTITY_COVERAGE_INVALID' "No $requiredPrefix entity found." }
}

$catalogDocs = Read-JsonCompatible (Join-Path $repoRoot 'catalogs\document-types.yaml')
$catalogTags = Read-JsonCompatible (Join-Path $repoRoot 'catalogs\tags.yaml')
$registers = @(Get-ChildItem -LiteralPath (Join-Path $workspace 'external-files\register') -File -Filter '*.yaml' | Sort-Object Name)
if ($registers.Count -ne 5) { Add-Finding 'FILE_COUNT_INVALID' "Expected five registers, found $($registers.Count)." }
$fileIds = @{}
foreach ($registerFile in $registers) {
    $item = Read-JsonCompatible $registerFile.FullName
    if ($null -eq $item) { continue }
    $fileIds[[string]$item.id] = $item
    if (@($catalogDocs.values) -notcontains [string]$item.document_type) { Add-Finding 'DOCUMENT_TYPE_INVALID' "Invalid document type on $($item.id)." }
    foreach ($tag in $item.tags.PSObject.Properties) {
        if ($catalogTags.dimensions.PSObject.Properties.Name -notcontains $tag.Name -or @($catalogTags.dimensions.$($tag.Name)) -notcontains [string]$tag.Value) {
            Add-Finding 'TAG_INVALID' "Invalid controlled tag $($tag.Name) on $($item.id)."
        }
    }
    $blob = Join-Path $workspace ([string]$item.blob_path -replace '/', '\')
    if (-not (Test-Path -LiteralPath $blob -PathType Leaf)) { Add-Finding 'ORIGINAL_MISSING' "Original missing for $($item.id)."; continue }
    $hash = (Get-FileHash -LiteralPath $blob -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($hash -ne [string]$item.sha256 -or (Get-Item -LiteralPath $blob).Length -ne [long]$item.size_bytes) { Add-Finding 'ORIGINAL_INTEGRITY_INVALID' "Hash or size mismatch for $($item.id)." }
    $input = Join-Path $pilotRoot "input-corpus\$($item.original_name)"
    if (-not (Test-Path -LiteralPath $input -PathType Leaf) -or (Get-FileHash -LiteralPath $input -Algorithm SHA256).Hash.ToLowerInvariant() -ne $hash) {
        Add-Finding 'ORIGINAL_NOT_PRESERVED' "Intake bytes differ from original for $($item.id)."
    }
}
$requiredDocTypes = @('documentation','evidence','test-file','transcript','unknown')
foreach ($type in $requiredDocTypes) { if (@($fileIds.Values | Where-Object { $_.document_type -eq $type }).Count -ne 1) { Add-Finding 'DOCUMENT_TYPE_COVERAGE_INVALID' "Expected one $type file." } }

$log = Read-JsonCompatible (Join-Path $workspace 'external-files\processing-log\intake-run.json')
if ($null -ne $log) {
    if (@($log.files).Count -ne 5 -or [bool]$log.automatic_approval) { Add-Finding 'INTAKE_LOG_INVALID' 'Intake log count or automatic approval is invalid.' }
    foreach ($entry in @($log.files)) {
        if (-not $fileIds.ContainsKey([string]$entry.file_id) -or @($entry.steps).Count -lt 5 -or @($entry.context_ids).Count -eq 0) { Add-Finding 'INTAKE_TRACEABILITY_INVALID' "Incomplete intake trace for $($entry.file_id)." }
        foreach ($contextId in @($entry.context_ids)) {
            if (-not $knownIds.ContainsKey([string]$contextId) -or [string]$contextId -notmatch '^(PRJ|SUP|MTG|CHG)-') { Add-Finding 'INTAKE_CONTEXT_INVALID' "Unknown or invalid context '$contextId' for $($entry.file_id)." }
        }
    }
    $unknown = @($log.files | Where-Object { $_.file_id -eq 'FILE-01J00000000000000000000108' })[0]
    if ([string]$unknown.route -notin @('review','quarantine') -or -not [bool]$unknown.review_required -or [string]$unknown.effective_sensitivity -ne 'restricted') {
        Add-Finding 'UNKNOWN_FILE_NOT_FAIL_CLOSED' 'Unknown file is not routed fail-closed.'
    }
    $negative = Read-JsonCompatible (Join-Path $pilotRoot 'tests\invalid-unknown-route.json')
    $mutatedRoute = [string]$negative.invalid_route
    if ($mutatedRoute -in @('review','quarantine')) { Add-Finding 'NEGATIVE_FIXTURE_INVALID' 'Negative unknown-route fixture would not violate fail-closed routing.' }
}
if (-not (Test-Path -LiteralPath (Join-Path $workspace 'external-files\review\FILE-01J00000000000000000000108.yaml'))) { Add-Finding 'UNKNOWN_REVIEW_RECORD_MISSING' 'Unknown file has no review queue record.' }

$requiredMeeting = @('preparation.md','agenda.md','meeting-record.md','meeting.yaml')
$meetingRoot = Join-Path $workspace 'meetings\MTG-01J00000000000000000000103'
foreach ($name in $requiredMeeting) { if (-not (Test-Path -LiteralPath (Join-Path $meetingRoot $name) -PathType Leaf)) { Add-Finding 'MEETING_PACKAGE_INCOMPLETE' "$name is missing." } }
$meetingText = Get-Content -LiteralPath (Join-Path $meetingRoot 'meeting-record.md') -Raw
foreach ($marker in @('Status: Draft','Unbestaetigte Entscheidungsentwuerfe','Aufgabenentwuerfe','Offene Fragen','Risiken','Ticketkandidaten','Moegliche Wissensaenderungen','Menschliche Pruefung')) {
    if ($meetingText -notmatch [regex]::Escape($marker)) { Add-Finding 'MEETING_PACKAGE_INCOMPLETE' "Meeting marker missing: $marker" }
}
if ($meetingText -match '(?im)^Status:\s*(Approved|Done|Confirmed)') { Add-Finding 'FALSE_MEETING_CLAIM' 'Meeting implies confirmation.' }

$supportText = Get-Content -LiteralPath (Join-Path $workspace 'support\cases\SUP-01J00000000000000000000102\case.md') -Raw
foreach ($marker in @('Prioritaet','Budgetbezug','Evidence','Meeting','Promotion zu')) { if ($supportText -notmatch $marker) { Add-Finding 'SUPPORT_CASE_INCOMPLETE' "Support marker missing: $marker" } }

$entityFiles = @(Get-ChildItem -LiteralPath $workspace -Recurse -File -Filter '*.yaml' | Where-Object { $_.FullName -notmatch '[\\/]review[\\/]' -and $_.Name -ne 'config.yaml' })
$promotions = 0
foreach ($entityFile in $entityFiles) {
    $entity = Read-JsonCompatible $entityFile.FullName
    if ($null -eq $entity -or $entity.PSObject.Properties.Name -notcontains 'entity_type') { continue }
    foreach ($relation in @($entity.relations)) {
        if (-not $knownIds.ContainsKey([string]$relation.target_id)) { Add-Finding 'RELATION_TARGET_UNKNOWN' "$($entity.id) targets unknown ID $($relation.target_id)." }
        if ([string]$relation.type -eq 'promoted_to') { $promotions++ }
    }
}
if ($promotions -ne 1) { Add-Finding 'PROMOTION_COUNT_INVALID' "Expected exactly one promoted_to relation, found $promotions." }
$meetingMeta = Read-JsonCompatible (Join-Path $meetingRoot 'meeting.yaml')
$meetingTargets = @($meetingMeta.relations | ForEach-Object { $_.target_id })
foreach ($target in @('PRJ-01J00000000000000000000101','SUP-01J00000000000000000000102','FILE-01J00000000000000000000107')) { if ($meetingTargets -notcontains $target) { Add-Finding 'MEETING_RELATION_MISSING' "Meeting relation missing: $target" } }
$changeRoot = Join-Path $workspace 'openspec\changes\clarify-partial-delivery-shipping-costs'
$changeMeta = Read-JsonCompatible (Join-Path $changeRoot 'change.yaml')
$changeTargets = @($changeMeta.relations | ForEach-Object { $_.target_id })
foreach ($target in @('PRJ-01J00000000000000000000101','SUP-01J00000000000000000000102','MTG-01J00000000000000000000103','REQ-01J0000000000000000000010D')) { if ($changeTargets -notcontains $target) { Add-Finding 'CHANGE_RELATION_MISSING' "Change relation missing: $target" } }

$budget = Read-JsonCompatible (Join-Path $workspace 'projects\PRJ-01J00000000000000000000101\budget.json')
if ($null -ne $budget) {
    foreach ($name in @('planned','actual','remaining','forecast')) {
        $sum = (@($budget.work_packages) | Measure-Object -Property $name -Sum).Sum
        if ([double]$sum -ne [double]$budget.totals.$name) { Add-Finding 'BUDGET_TOTAL_INVALID' "$name total is inconsistent." }
    }
    if ([bool]$budget.accounting_source_of_truth) { Add-Finding 'ACCOUNTING_BOUNDARY_VIOLATION' 'Pilot budget claims accounting authority.' }
    foreach ($wp in @('WP-MEETING-PREP','WP-MEETING','WP-MEETING-FOLLOWUP')) { if (@($budget.work_packages | Where-Object { $_.id -eq $wp }).Count -ne 1) { Add-Finding 'MEETING_EFFORT_MISSING' "$wp missing." } }
}

$binding = Read-JsonCompatible (Join-Path $changeRoot 'delivery-binding.json')
if ($null -ne $binding) {
    if ([string]$binding.engine -ne 'examples/bc-enterprise-blueprint/automation' -or [string]$binding.epic.source_id -ne 'EPIC-SALES' -or [bool]$binding.external_publishing_enabled) { Add-Finding 'DELIVERY_BINDING_INVALID' 'Delivery spike binding is invalid.' }
    if (@($binding.selected_pilot_outputs) -contains 'training' -or @($binding.selected_pilot_outputs) -contains 'confluence') { Add-Finding 'DELIVERY_OUTPUT_SCOPE_INVALID' 'Unneeded output selected.' }
}
$generatedPilotRoot = Join-Path $workspace 'generated\CHG-01J0000000000000000000010C'
foreach ($unneeded in @('training','confluence')) { if (Test-Path -LiteralPath (Join-Path $generatedPilotRoot $unneeded)) { Add-Finding 'DELIVERY_OUTPUT_SCOPE_INVALID' "Unneeded pilot output exists: $unneeded" } }
$changeText = (Get-Content -LiteralPath (Join-Path $changeRoot 'business-context.md') -Raw) + (Get-Content -LiteralPath (Join-Path $changeRoot 'design.md') -Raw)
if ($changeText -notmatch 'BLOCKER' -or $changeText -notmatch 'TBD') { Add-Finding 'CHANGE_BLOCKER_MISSING' 'Pilot change must retain explicit blockers.' }

$gatePath = Join-Path $workspace 'generated\CHG-01J0000000000000000000010C\gate-results.json'
if (-not (Test-Path -LiteralPath $gatePath -PathType Leaf)) { Add-Finding 'GATE_RESULTS_MISSING' 'Run Run-POV001.ps1 first.' }
else {
    $gates = Read-JsonCompatible $gatePath
    if (-not [bool]$gates.open_spec_validation.passed) { Add-Finding 'OPENSPEC_VALIDATION_FAILED' 'Bound OpenSpec change did not validate.' }
    foreach ($expected in @(@('Planning',$true),@('BuildReady',$false),@('ReleaseReady',$false))) {
        $actual = @($gates.gates | Where-Object { $_.gate -eq $expected[0] })
        if ($actual.Count -ne 1 -or [bool]$actual[0].passed -ne [bool]$expected[1]) { Add-Finding 'GATE_OUTCOME_INVALID' "Unexpected $($expected[0]) outcome." }
    }
}

$allText = (Get-ChildItem -LiteralPath $pilotRoot -Recurse -File | Where-Object { $_.Extension -in @('.md','.json','.yaml','.ps1','.txt','.csv','.dat') } | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }) -join "`n"
if ($allText -match '(?im)(client_secret|access_token|connection_string|tenant_id)\s*[:=]\s*["'']?[A-Za-z0-9-]{8,}') { Add-Finding 'SENSITIVE_VALUE_DETECTED' 'Credential- or tenant-shaped value detected.' }

$after = @(Get-ChildItem -LiteralPath $pilotRoot -Recurse -File)
if ($after.Count -ne $before.Count) { Add-Finding 'VALIDATOR_WRITE_DETECTED' 'Pilot file count changed during validation.' }
foreach ($file in $after) {
    if (-not $before.ContainsKey($file.FullName) -or $before[$file.FullName] -ne (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash) { Add-Finding 'VALIDATOR_WRITE_DETECTED' "Changed during validation: $($file.FullName)" }
}

if ($findings.Count -gt 0) {
    Write-Host 'BLOCKED: POV-001 validation failed.'
    foreach ($finding in $findings) { Write-Host "- [$($finding.code)] $($finding.message)" }
    exit 1
}
Write-Host 'PASS: POV-001 has one synthetic customer workspace and one OpenSpec root.'
Write-Host 'PASS: Five originals match intake bytes, hashes, sizes, metadata, classifications, tags, routes, and contexts.'
Write-Host 'PASS: Unknown content is fail-closed in review and the negative route is rejected.'
Write-Host 'PASS: Meeting, support, project/budget, promotion, selected delivery outputs, and gate outcomes are traceable.'
Write-Host 'PASS: No sensitive value was detected and the validator changed no pilot file.'
