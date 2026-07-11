[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9][a-z0-9-]+$')]
    [string]$ChangeId,

    [ValidateSet('Planning', 'BuildReady', 'ReleaseReady')]
    [string]$Gate = 'Planning',

    [switch]$AsJson,

    [switch]$SkipOpenSpecValidation
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Delivery.Common.ps1')

$script:GateFindings = New-Object System.Collections.ArrayList
$coreParsed = $false

function Add-GateFinding {
    param([string]$Code, [string]$Message)
    [void]$script:GateFindings.Add([ordered]@{ code = $Code; message = $Message })
}

function Test-RecordedEvidence {
    param($Evidence, [string]$Name, [string]$ExpectedStatus)

    if (-not (Test-ObjectProperty -Object $Evidence -Name $Name)) {
        Add-GateFinding -Code 'EVIDENCE_FIELD_MISSING' -Message "Evidence field '$Name' is missing."
        return
    }
    $item = $Evidence.$Name
    if ([string]$item.status -ne $ExpectedStatus) {
        Add-GateFinding -Code 'EVIDENCE_STATUS_BLOCKED' -Message "Evidence '$Name' must be '$ExpectedStatus' but is '$($item.status)'."
        return
    }
    if (-not (Test-ObjectProperty -Object $item -Name 'evidence') -or @($item.evidence).Count -eq 0) {
        Add-GateFinding -Code 'EVIDENCE_REFERENCE_MISSING' -Message "Evidence '$Name' has status '$ExpectedStatus' but no evidence reference."
    }
}

try {
    $root = Get-BlueprintRoot
    $changeDir = Get-ChangeDirectory -ChangeId $ChangeId
    $plan = Get-DeliveryPlan -ChangeId $ChangeId
    $requirements = @(Get-ChangeRequirements -ChangeId $ChangeId)
    $tasks = @(Get-ChangeTasks -ChangeId $ChangeId)
    $coreParsed = $true
}
catch {
    Add-GateFinding -Code 'CORE_PARSE_FAILED' -Message $_.Exception.Message
}

if ($coreParsed) {
    $requirementIds = @{}
    foreach ($requirement in $requirements) { $requirementIds[$requirement.id] = $true }
    foreach ($task in $tasks) {
        if (-not $requirementIds.ContainsKey($task.parentRequirementId)) {
            Add-GateFinding -Code 'TASK_PARENT_UNKNOWN' -Message "Task '$($task.id)' references unknown story '$($task.parentRequirementId)'."
        }
    }

    if (-not $SkipOpenSpecValidation) {
        try {
            $openSpecCommand = Get-LocalOpenSpecCommand
            Push-Location $root
            try {
                $openSpecOutput = (& $openSpecCommand validate $ChangeId 2>&1 | Out-String).Trim()
                if ($LASTEXITCODE -ne 0) {
                    Add-GateFinding -Code 'OPENSPEC_INVALID' -Message "OpenSpec validation failed: $openSpecOutput"
                }
            }
            finally {
                Pop-Location
            }
        }
        catch {
            Add-GateFinding -Code 'OPENSPEC_UNAVAILABLE' -Message $_.Exception.Message
        }
    }
}

if ($coreParsed -and $Gate -in @('BuildReady', 'ReleaseReady')) {
    foreach ($name in @('proposal.md', 'business-context.md', 'design.md')) {
        $path = Join-Path $changeDir $name
        $content = Get-Content -LiteralPath $path -Raw
        if ($content -match '(?m)\bTBD\b') {
            Add-GateFinding -Code 'UNRESOLVED_TBD' -Message "$name contains unresolved TBD markers."
        }
        if ($content -match '(?m)^\s*-?\s*BLOCKER:') {
            Add-GateFinding -Code 'EXPLICIT_BLOCKER' -Message "$name contains an explicit BLOCKER marker."
        }
    }

    $contextText = (Get-Content -LiteralPath (Join-Path $changeDir 'business-context.md') -Raw) + "`r`n" + (Get-Content -LiteralPath (Join-Path $changeDir 'proposal.md') -Raw)
    $ruleIds = [regex]::Matches($contextText, '\bBR-[A-Z0-9]+(?:-[A-Z0-9]+)*\b') | ForEach-Object { $_.Value } | Sort-Object -Unique
    foreach ($ruleId in $ruleIds) {
        $matches = @(Get-ChildItem -LiteralPath (Join-Path $root 'business\business-rules') -File -Filter "*$ruleId*.md")
        if ($matches.Count -ne 1) {
            Add-GateFinding -Code 'BUSINESS_RULE_UNRESOLVED' -Message "Expected exactly one source file for '$ruleId', found $($matches.Count)."
            continue
        }
        $statusLine = Get-Content -LiteralPath $matches[0].FullName | Where-Object { $_ -match '^Status:' } | Select-Object -First 1
        $statusValue = if ($null -eq $statusLine) { '' } else { ($statusLine -replace '^Status:\s*', '').Trim() }
        if ($statusValue -notmatch '(?i)^(approved|freigegeben)\b') {
            Add-GateFinding -Code 'BUSINESS_RULE_NOT_APPROVED' -Message "Business rule '$ruleId' is not approved: $statusLine"
        }
    }

    $outputRoot = Join-Path $root "deliverables\$ChangeId"
    $manifestPath = Join-Path $outputRoot 'manifest.json'
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        Add-GateFinding -Code 'MANIFEST_MISSING' -Message "Generate local deliverables first: $manifestPath"
    }
    else {
        try {
            $manifest = Read-JsonFile -Path $manifestPath
            if ([bool]$manifest.externalPublishingEnabled) {
                Add-GateFinding -Code 'EXTERNAL_PUBLISHING_ENABLED' -Message 'Generated manifest enables external publishing.'
            }
            foreach ($generatorSource in @($manifest.generatorSources)) {
                $generatorPath = Join-Path $root ([string]$generatorSource.path -replace '/', '\')
                if (-not (Test-Path -LiteralPath $generatorPath -PathType Leaf) -or (Get-FileSha256 -Path $generatorPath) -ne [string]$generatorSource.sha256) {
                    Add-GateFinding -Code 'GENERATOR_STALE' -Message "Generated package was created by a different generator version: $($generatorSource.path)"
                }
            }
            $manifestSources = @{}
            foreach ($source in @($manifest.sources)) { $manifestSources[[string]$source.path] = [string]$source.sha256 }
            foreach ($sourceFile in Get-ChangeSourceFiles -ChangeId $ChangeId) {
                $relative = Get-RelativeBlueprintPath -Path $sourceFile.FullName
                if (-not $manifestSources.ContainsKey($relative)) {
                    Add-GateFinding -Code 'SOURCE_NOT_MANIFESTED' -Message "Current source is absent from manifest: $relative"
                }
                elseif ((Get-FileSha256 -Path $sourceFile.FullName) -ne $manifestSources[$relative]) {
                    Add-GateFinding -Code 'SOURCE_STALE' -Message "Generated package is stale for source: $relative"
                }
            }
            foreach ($generatedFile in @($manifest.generatedFiles)) {
                $path = Join-Path $root ([string]$generatedFile.path -replace '/', '\')
                if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
                    Add-GateFinding -Code 'GENERATED_FILE_MISSING' -Message "Generated file is missing: $($generatedFile.path)"
                }
                elseif ((Get-FileSha256 -Path $path) -ne [string]$generatedFile.sha256) {
                    Add-GateFinding -Code 'GENERATED_FILE_CHANGED' -Message "Generated file changed outside the generator: $($generatedFile.path)"
                }
            }
            $manifestEvidencePath = Join-Path $root ([string]$manifest.evidencePath -replace '/', '\')
            if (-not (Test-Path -LiteralPath $manifestEvidencePath -PathType Leaf)) {
                Add-GateFinding -Code 'EVIDENCE_MISSING' -Message "Manifest evidence file is missing: $($manifest.evidencePath)"
            }
            elseif ((Get-FileSha256 -Path $manifestEvidencePath) -ne [string]$manifest.evidenceSha256) {
                Add-GateFinding -Code 'EVIDENCE_STALE' -Message 'Evidence changed after generation. Regenerate the package before evaluating readiness.'
            }
        }
        catch {
            Add-GateFinding -Code 'MANIFEST_INVALID' -Message $_.Exception.Message
        }
    }

    $requiredOutputs = New-Object System.Collections.ArrayList
    if ([bool]$plan.ticketing.required) { [void]$requiredOutputs.Add('tickets/ticket-manifest.json') }
    if ([bool]$plan.uat.required) { [void]$requiredOutputs.Add('uat/uat-plan.md') }
    if ([bool]$plan.documentation.required) { [void]$requiredOutputs.Add('documentation/index.md') }
    if ([bool]$plan.documentation.confluenceStylePages) { [void]$requiredOutputs.Add('confluence/00-start/index.md') }
    if ([bool]$plan.training.required) { [void]$requiredOutputs.Add('training/training-brief.md') }
    if ([bool]$plan.release.required) { [void]$requiredOutputs.Add('release/release.md') }
    foreach ($relative in $requiredOutputs) {
        $path = Join-Path $outputRoot ($relative -replace '/', '\')
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            Add-GateFinding -Code 'REQUIRED_OUTPUT_MISSING' -Message "Required local output is missing: $relative"
        }
    }
}

if ($coreParsed -and $Gate -eq 'ReleaseReady') {
    foreach ($task in $tasks | Where-Object { -not $_.complete }) {
        Add-GateFinding -Code 'TASK_INCOMPLETE' -Message "Task is incomplete: $($task.id)"
    }

    $evidencePath = Join-Path $root "deliverables\$ChangeId\evidence.json"
    if (-not (Test-Path -LiteralPath $evidencePath -PathType Leaf)) {
        Add-GateFinding -Code 'EVIDENCE_MISSING' -Message "Evidence file is missing: $evidencePath"
    }
    else {
        try {
            $evidence = Read-JsonFile -Path $evidencePath
            Test-RecordedEvidence -Evidence $evidence -Name 'automatedTests' -ExpectedStatus 'passed'
            if ([bool]$plan.uat.required) { Test-RecordedEvidence -Evidence $evidence -Name 'uat' -ExpectedStatus 'passed' }
            if ([bool]$plan.documentation.required) { Test-RecordedEvidence -Evidence $evidence -Name 'documentation' -ExpectedStatus 'approved' }
            if ([bool]$plan.training.required) { Test-RecordedEvidence -Evidence $evidence -Name 'training' -ExpectedStatus 'delivered' }
            if ([bool]$plan.release.required) { Test-RecordedEvidence -Evidence $evidence -Name 'releaseApproval' -ExpectedStatus 'approved' }
        }
        catch {
            Add-GateFinding -Code 'EVIDENCE_INVALID' -Message $_.Exception.Message
        }
    }
}

$result = [ordered]@{
    changeId = $ChangeId
    gate = $Gate
    passed = $script:GateFindings.Count -eq 0
    findings = @($script:GateFindings)
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 8
}
elseif ($result.passed) {
    Write-Host "PASS: $Gate gate passed for '$ChangeId'."
}
else {
    Write-Host "BLOCKED: $Gate gate failed for '$ChangeId'."
    foreach ($finding in $script:GateFindings) {
        Write-Host "- [$($finding.code)] $($finding.message)"
    }
}

if (-not $result.passed) { exit 1 }
