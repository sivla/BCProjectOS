[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9][a-z0-9-]+$')]
    [string]$ChangeId,

    [switch]$Force
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Delivery.Common.ps1')

$root = Get-BlueprintRoot
$changeDir = Get-ChangeDirectory -ChangeId $ChangeId
$plan = Get-DeliveryPlan -ChangeId $ChangeId
$requirements = @(Get-ChangeRequirements -ChangeId $ChangeId)
$tasks = @(Get-ChangeTasks -ChangeId $ChangeId)
$requirementIds = @{}
foreach ($requirement in $requirements) { $requirementIds[$requirement.id] = $true }
foreach ($task in $tasks) {
    if (-not $requirementIds.ContainsKey($task.parentRequirementId)) {
        throw "Task '$($task.id)' references unknown story '$($task.parentRequirementId)'."
    }
}

$outputRoot = Join-Path $root "deliverables\$ChangeId"
$manifestPath = Join-Path $outputRoot 'manifest.json'
if ((Test-Path -LiteralPath $manifestPath -PathType Leaf) -and -not $Force) {
    throw "Generated package already exists. Use -Force to regenerate managed files: $outputRoot"
}

$generated = New-Object System.Collections.ArrayList
$header = "<!-- generated: bc-enterprise-blueprint; source-change: $ChangeId; do-not-edit -->"

function Write-GeneratedText {
    param([string]$RelativePath, [string]$Content)
    $path = Join-Path $outputRoot ($RelativePath -replace '/', '\')
    Write-Utf8File -Path $path -Content $Content
    [void]$generated.Add($path)
}

function Write-GeneratedJson {
    param([string]$RelativePath, $Value)
    $path = Join-Path $outputRoot ($RelativePath -replace '/', '\')
    Write-JsonFile -Path $path -Value $Value
    [void]$generated.Add($path)
}

function Escape-TableText {
    param([string]$Text)
    return (($Text -replace '\|', '\|') -replace "`r?`n", '<br>')
}

$epic = $plan.ticketing.epic
$epicAction = if ([string]$epic.mode -eq 'existing') { 'Reference existing Epic' } else { 'Create local Epic draft' }
$epicContent = @"
---
source_id: $($epic.sourceId)
ticket_type: Epic
mode: $($epic.mode)
status: Draft
external_key: null
---
$header

# $($epic.title)

Action: $epicAction

Business domain: $($plan.businessDomain)

Project: $($plan.projectId)

This local package does not publish or modify an external Epic.
"@
Write-GeneratedText -RelativePath 'tickets/epic.md' -Content $epicContent

$storyManifest = New-Object System.Collections.ArrayList
foreach ($requirement in $requirements) {
    $criteria = New-Object System.Collections.ArrayList
    foreach ($scenario in $requirement.scenarios) {
        [void]$criteria.Add("## Acceptance Criterion: $($scenario.title)`r`n`r`n$($scenario.body)")
    }
    $criteriaText = $criteria -join "`r`n`r`n"
    $requirementSourcePath = $requirement.sourcePath
    $storyContent = @"
---
source_id: $($requirement.id)
ticket_type: Story
parent_epic: $($epic.sourceId)
status: Draft
external_key: null
---
$header

# $($requirement.title)

$($requirement.description)

$criteriaText

Source: $requirementSourcePath
"@
    $relative = "tickets/stories/$($requirement.id).md"
    Write-GeneratedText -RelativePath $relative -Content $storyContent
    [void]$storyManifest.Add([ordered]@{ sourceId = $requirement.id; parentEpic = [string]$epic.sourceId; path = $relative })
}

$taskManifest = New-Object System.Collections.ArrayList
foreach ($task in $tasks) {
    $status = if ($task.complete) { 'Done' } else { 'Draft' }
    $taskContent = @"
---
source_id: $($task.id)
ticket_type: Task
parent_story: $($task.parentRequirementId)
status: $status
external_key: null
---
$header

# $($task.title)

Expected result: The task outcome is implemented and verified against $($task.parentRequirementId).

External publishing: Disabled
"@
    $relative = "tickets/tasks/$($task.id).md"
    Write-GeneratedText -RelativePath $relative -Content $taskContent
    [void]$taskManifest.Add([ordered]@{ sourceId = $task.id; parentStory = $task.parentRequirementId; complete = [bool]$task.complete; path = $relative })
}

$ticketManifest = [ordered]@{
    schemaVersion = 1
    changeId = $ChangeId
    epic = [ordered]@{ sourceId = [string]$epic.sourceId; mode = [string]$epic.mode; externalKey = $null }
    stories = @($storyManifest)
    tasks = @($taskManifest)
    externalPublishingEnabled = $false
}
Write-GeneratedJson -RelativePath 'tickets/ticket-manifest.json' -Value $ticketManifest

$uatRows = New-Object System.Collections.ArrayList
$exerciseSections = New-Object System.Collections.ArrayList
$knowledgeSections = New-Object System.Collections.ArrayList
$uatNumber = 1
foreach ($requirement in $requirements) {
    foreach ($scenario in $requirement.scenarios) {
        $uatId = 'UAT-{0:D3}' -f $uatNumber
        $expected = Escape-TableText -Text $scenario.body
        [void]$uatRows.Add("| $uatId | $($requirement.id) | $($scenario.title) | $expected | Not Run |")
        [void]$exerciseSections.Add("## Exercise $uatId - $($scenario.title)`r`n`r`nRequirement: `$($requirement.id)``r`n`r`nSteps: To be finalized against the verified BC build.`r`n`r`nExpected behavior:`r`n`r`n$($scenario.body)`r`n`r`nResult: Not Run")
        [void]$knowledgeSections.Add("## $uatId`r`n`r`nExplain or demonstrate the expected behavior for **$($scenario.title)**.`r`n`r`nExpected reference: `$($requirement.id)`.")
        $uatNumber++
    }
}

$uatContent = @"
$header
# UAT Plan

Status: Draft - Not Run

| UAT ID | Requirement | Scenario | Expected Result | Status |
|---|---|---|---|---|
$($uatRows -join "`r`n")

Only synthetic or approved anonymized data may be used. No test execution is claimed.
"@
if ([bool]$plan.uat.required) {
    Write-GeneratedText -RelativePath 'uat/uat-plan.md' -Content $uatContent
}

$audienceRows = New-Object System.Collections.ArrayList
foreach ($audience in @($plan.training.audiences)) {
    [void]$audienceRows.Add("| $($audience.id) | $($audience.role) | $($audience.type) |")
}
$learningRows = New-Object System.Collections.ArrayList
$learningNumber = 1
foreach ($requirement in $requirements) {
    [void]$learningRows.Add("| LEARN-{0:D3} | Explain and apply $($requirement.title) | $($requirement.id) | Scenario exercise |" -f $learningNumber)
    $learningNumber++
}
$participantSections = ($requirements | ForEach-Object { "## $($_.id) - $($_.title)`r`n`r`n$($_.description)" }) -join "`r`n`r`n"

if ([bool]$plan.training.required) {
    $trainingBrief = @"
$header
# Training Brief

Status: Draft - Not Delivered

## Purpose

$($plan.training.purpose)

## Audiences

| Audience ID | Role | Training Type |
|---|---|---|
$($audienceRows -join "`r`n")

## Learning Objectives

| Learning ID | Participant Can | Source | Verification |
|---|---|---|---|
$($learningRows -join "`r`n")

Training delivery, attendance, and learning outcomes are not claimed.
"@
    Write-GeneratedText -RelativePath 'training/training-brief.md' -Content $trainingBrief
    Write-GeneratedText -RelativePath 'training/trainer-guide.md' -Content "$header`r`n# Trainer Guide`r`n`r`nUse the approved business rule, verified BC build, UAT plan, and exercises. Screenshots and timings remain blocked until the implementation is stable.`r`n`r`n$($exerciseSections -join "`r`n`r`n")"
    Write-GeneratedText -RelativePath 'training/participant-guide.md' -Content "$header`r`n# Participant Guide`r`n`r`nPurpose: $($plan.training.purpose)`r`n`r`n$participantSections"
    Write-GeneratedText -RelativePath 'training/exercises.md' -Content "$header`r`n# Exercises`r`n`r`n$($exerciseSections -join "`r`n`r`n")"
    Write-GeneratedText -RelativePath 'training/knowledge-check.md' -Content "$header`r`n# Knowledge Check`r`n`r`n$($knowledgeSections -join "`r`n`r`n")"
}

$sourceList = (Get-ChangeSourceFiles -ChangeId $ChangeId | ForEach-Object { '- ' + (Get-RelativeBlueprintPath -Path $_.FullName) }) -join "`r`n"
$requirementSummary = ($requirements | ForEach-Object { '- ' + $_.id + ': ' + $_.title }) -join "`r`n"
$documentationContent = @"
$header
# Change Documentation Package

Status: Draft

## Purpose

This package is generated from the versioned OpenSpec change and remains subordinate to verified behavior.

## Requirements

$requirementSummary

## Sources

$sourceList

## Publication

Local Markdown only. External Confluence publishing is disabled.
"@
if ([bool]$plan.documentation.required) {
    Write-GeneratedText -RelativePath 'documentation/index.md' -Content $documentationContent
}

$proposal = Get-Content -LiteralPath (Join-Path $changeDir 'proposal.md') -Raw
$businessContext = Get-Content -LiteralPath (Join-Path $changeDir 'business-context.md') -Raw
$design = Get-Content -LiteralPath (Join-Path $changeDir 'design.md') -Raw
$confluenceRequirementSections = ($requirements | ForEach-Object {
    $scenarioSections = ($_.scenarios | ForEach-Object { "### $($_.title)`r`n`r`n$($_.body)" }) -join "`r`n`r`n"
    "## $($_.id) - $($_.title)`r`n`r`n$($_.description)`r`n`r`n$scenarioSections"
}) -join "`r`n`r`n"
$confluenceRoot = 'confluence'
if ([bool]$plan.documentation.confluenceStylePages) {
    Write-GeneratedText -RelativePath "$confluenceRoot/00-start/index.md" -Content "$header`r`n# BC Enterprise Knowledge`r`n`r`nGenerated local navigation for change `$ChangeId`."
    Write-GeneratedText -RelativePath "$confluenceRoot/10-unternehmen/unternehmensprofil.md" -Content "$header`r`n$(Get-Content -LiteralPath (Join-Path $root 'company\company-profile.md') -Raw)"
    Write-GeneratedText -RelativePath "$confluenceRoot/20-geschaeftsarchitektur/capability-map.md" -Content "$header`r`n$(Get-Content -LiteralPath (Join-Path $root 'business\capability-map.md') -Raw)"
    Write-GeneratedText -RelativePath "$confluenceRoot/20-geschaeftsarchitektur/process-catalog.md" -Content "$header`r`n$(Get-Content -LiteralPath (Join-Path $root 'business\processes\process-catalog.md') -Raw)"
    Write-GeneratedText -RelativePath "$confluenceRoot/30-anwendungslandschaft/business-central.md" -Content "$header`r`n$(Get-Content -LiteralPath (Join-Path $root 'application-landscape\business-central\solution-overview.md') -Raw)"
    Write-GeneratedText -RelativePath "$confluenceRoot/40-projekte/$($plan.projectId)/project-charter.md" -Content "$header`r`n$(Get-Content -LiteralPath (Join-Path $root 'projects\project-charter.md') -Raw)"
    Write-GeneratedText -RelativePath "$confluenceRoot/50-changes-und-releases/$ChangeId/index.md" -Content "$header`r`n# Change Overview`r`n`r`n$proposal`r`n`r`n# Referenced Business Context`r`n`r`n$businessContext"
    Write-GeneratedText -RelativePath "$confluenceRoot/50-changes-und-releases/$ChangeId/requirements.md" -Content "$header`r`n# Requirements`r`n`r`n$confluenceRequirementSections"
    Write-GeneratedText -RelativePath "$confluenceRoot/50-changes-und-releases/$ChangeId/design.md" -Content "$header`r`n$design"
    if ([bool]$plan.uat.required) { Write-GeneratedText -RelativePath "$confluenceRoot/50-changes-und-releases/$ChangeId/uat.md" -Content $uatContent }
    if ([bool]$plan.training.required) { Write-GeneratedText -RelativePath "$confluenceRoot/70-schulung/$ChangeId/index.md" -Content $trainingBrief }
    Write-GeneratedText -RelativePath "$confluenceRoot/60-betrieb-und-support/index.md" -Content "$header`r`n# Betrieb und Support`r`n`r`nOperational content remains draft until implementation and release evidence exist."
}

$evidencePath = Join-Path $outputRoot 'evidence.json'
if (-not (Test-Path -LiteralPath $evidencePath -PathType Leaf)) {
    $evidence = [ordered]@{
        schemaVersion = 1
        changeId = $ChangeId
        automatedTests = [ordered]@{ status = 'not_run'; evidence = @() }
        uat = [ordered]@{ status = $(if ([bool]$plan.uat.required) { 'not_run' } else { 'not_required' }); evidence = @() }
        documentation = [ordered]@{ status = $(if ([bool]$plan.documentation.required) { 'draft' } else { 'not_required' }); evidence = @() }
        training = [ordered]@{ status = $(if ([bool]$plan.training.required) { 'not_delivered' } else { 'not_required' }); evidence = @() }
        releaseApproval = [ordered]@{ status = $(if ([bool]$plan.release.required) { 'not_approved' } else { 'not_required' }); evidence = @() }
    }
    Write-JsonFile -Path $evidencePath -Value $evidence
}
$evidence = Read-JsonFile -Path $evidencePath

if ([bool]$plan.release.required) {
    $allTasksComplete = @($tasks | Where-Object { -not $_.complete }).Count -eq 0
    $releaseReady = $allTasksComplete -and
        [string]$evidence.automatedTests.status -eq 'passed' -and
        ((-not [bool]$plan.uat.required) -or [string]$evidence.uat.status -eq 'passed') -and
        ((-not [bool]$plan.documentation.required) -or [string]$evidence.documentation.status -eq 'approved') -and
        ((-not [bool]$plan.training.required) -or [string]$evidence.training.status -eq 'delivered') -and
        [string]$evidence.releaseApproval.status -eq 'approved'
    $releaseStatus = if ($releaseReady) { 'Ready' } else { 'Draft - Blocked' }
    $releaseNote = if ($releaseReady) {
        'All declared evidence states are ready. Run the local ReleaseReady gate to verify source and generated-file hashes before release.'
    }
    else {
        'Release remains blocked until tasks, automated tests, UAT, required training, documentation, source hashes, and approval evidence pass the local gate.'
    }
    $includedRequirements = $requirements.id -join ', '
    $releaseContent = @"
$header
# Release Package

Status: $releaseStatus

Change: $ChangeId

Included requirements: $includedRequirements

$releaseNote
"@
    Write-GeneratedText -RelativePath 'release/release.md' -Content $releaseContent
}

$sourceManifest = New-Object System.Collections.ArrayList
foreach ($file in Get-ChangeSourceFiles -ChangeId $ChangeId) {
    [void]$sourceManifest.Add([ordered]@{ path = Get-RelativeBlueprintPath -Path $file.FullName; sha256 = Get-FileSha256 -Path $file.FullName })
}
$generatedManifest = New-Object System.Collections.ArrayList
foreach ($path in $generated | Sort-Object) {
    [void]$generatedManifest.Add([ordered]@{ path = Get-RelativeBlueprintPath -Path $path; sha256 = Get-FileSha256 -Path $path })
}
$manifest = [ordered]@{
    schemaVersion = 1
    changeId = $ChangeId
    generatedAt = (Get-Date).ToUniversalTime().ToString('o')
    generator = 'automation/Generate-Deliverables.ps1'
    generatorSources = @(
        [ordered]@{ path = 'automation/Generate-Deliverables.ps1'; sha256 = Get-FileSha256 -Path $PSCommandPath },
        [ordered]@{ path = 'automation/Delivery.Common.ps1'; sha256 = Get-FileSha256 -Path (Join-Path $PSScriptRoot 'Delivery.Common.ps1') }
    )
    externalPublishingEnabled = $false
    sources = @($sourceManifest)
    generatedFiles = @($generatedManifest)
    evidencePath = Get-RelativeBlueprintPath -Path $evidencePath
    evidenceSha256 = Get-FileSha256 -Path $evidencePath
}
Write-JsonFile -Path $manifestPath -Value $manifest

Write-Host "Generated $($generated.Count) managed files for '$ChangeId'."
Write-Host "Output: $outputRoot"
