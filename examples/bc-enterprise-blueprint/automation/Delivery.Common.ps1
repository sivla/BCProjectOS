Set-StrictMode -Version Latest

$script:BlueprintRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Get-BlueprintRoot {
    return $script:BlueprintRoot
}

function Get-LocalOpenSpecCommand {
    $path = Join-Path $script:BlueprintRoot 'node_modules\.bin\openspec.cmd'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Local OpenSpec CLI is missing. Run 'npm install' in $script:BlueprintRoot."
    }
    return $path
}

function Get-ChangeDirectory {
    param([Parameter(Mandatory = $true)][string]$ChangeId)

    $path = Join-Path $script:BlueprintRoot "openspec\changes\$ChangeId"
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        throw "OpenSpec change not found: $ChangeId"
    }
    return $path
}

function Read-JsonFile {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "JSON file not found: $Path"
    }
    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        throw "Invalid JSON in ${Path}: $($_.Exception.Message)"
    }
}

function Test-ObjectProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-DeliveryPlan {
    param([Parameter(Mandatory = $true)][string]$ChangeId)

    $changeDir = Get-ChangeDirectory -ChangeId $ChangeId
    $plan = Read-JsonFile -Path (Join-Path $changeDir 'delivery-plan.json')
    $required = @('schemaVersion', 'changeId', 'projectId', 'businessDomain', 'externalPublishingEnabled', 'ticketing', 'uat', 'documentation', 'training', 'release')
    foreach ($name in $required) {
        if (-not (Test-ObjectProperty -Object $plan -Name $name)) {
            throw "delivery-plan.json is missing property '$name'."
        }
    }
    if ([int]$plan.schemaVersion -ne 1) {
        throw "Unsupported delivery plan schemaVersion '$($plan.schemaVersion)'."
    }
    if ([string]$plan.changeId -ne $ChangeId) {
        throw "delivery-plan.json changeId '$($plan.changeId)' does not match '$ChangeId'."
    }
    if ($plan.externalPublishingEnabled -isnot [bool] -or [bool]$plan.externalPublishingEnabled) {
        throw 'External publishing must remain disabled in this local blueprint.'
    }
    if ([string]$plan.projectId -notmatch '^PRJ-[A-Z0-9-]+$') {
        throw "Invalid projectId '$($plan.projectId)'."
    }
    if ([string]$plan.businessDomain -notmatch '^[A-Z][A-Z0-9-]+$') {
        throw "Invalid businessDomain '$($plan.businessDomain)'."
    }
    if (-not (Test-ObjectProperty -Object $plan.ticketing -Name 'epic')) {
        throw "delivery-plan.json ticketing.epic is required."
    }
    foreach ($sectionName in @('ticketing', 'uat', 'documentation', 'training', 'release')) {
        $section = $plan.$sectionName
        if (-not (Test-ObjectProperty -Object $section -Name 'required') -or $section.required -isnot [bool]) {
            throw "delivery-plan.json $sectionName.required must be a boolean."
        }
    }
    if ([string]$plan.ticketing.epic.mode -notin @('existing', 'create')) {
        throw "ticketing.epic.mode must be 'existing' or 'create'."
    }
    if ([string]$plan.ticketing.epic.sourceId -notmatch '^EPIC-[A-Z0-9-]+$') {
        throw "Invalid ticketing.epic.sourceId '$($plan.ticketing.epic.sourceId)'."
    }
    if ([string]::IsNullOrWhiteSpace([string]$plan.ticketing.epic.title)) {
        throw 'ticketing.epic.title is required.'
    }
    if ([string]$plan.ticketing.storiesFrom -ne 'requirements' -or [string]$plan.ticketing.tasksFrom -ne 'tasks') {
        throw "ticketing storiesFrom/tasksFrom must be 'requirements' and 'tasks'."
    }
    if ($plan.documentation.confluenceStylePages -isnot [bool]) {
        throw 'documentation.confluenceStylePages must be a boolean.'
    }
    if ([bool]$plan.documentation.confluenceStylePages -and [string]::IsNullOrWhiteSpace([string]$plan.documentation.spaceAlias)) {
        throw 'documentation.spaceAlias is required for Confluence-style pages.'
    }
    if ([bool]$plan.training.required -and @($plan.training.audiences).Count -eq 0) {
        throw 'At least one training audience is required when training.required is true.'
    }
    if ([bool]$plan.training.required -and [string]::IsNullOrWhiteSpace([string]$plan.training.purpose)) {
        throw 'training.purpose is required when training.required is true.'
    }
    foreach ($audience in @($plan.training.audiences)) {
        foreach ($name in @('id', 'role', 'type')) {
            if (-not (Test-ObjectProperty -Object $audience -Name $name) -or [string]::IsNullOrWhiteSpace([string]$audience.$name)) {
                throw "Every training audience requires id, role, and type. Missing '$name'."
            }
        }
    }
    return $plan
}

function Get-ChangeRequirements {
    param([Parameter(Mandatory = $true)][string]$ChangeId)

    $changeDir = Get-ChangeDirectory -ChangeId $ChangeId
    $specDir = Join-Path $changeDir 'specs'
    $requirements = New-Object System.Collections.ArrayList
    $seen = @{}

    if (-not (Test-Path -LiteralPath $specDir -PathType Container)) {
        throw "No specs directory found for change '$ChangeId'."
    }

    foreach ($file in Get-ChildItem -LiteralPath $specDir -Recurse -File -Filter '*.md' | Sort-Object FullName) {
        $content = Get-Content -LiteralPath $file.FullName -Raw
        $pattern = '(?ms)^### Requirement:\s+(?<id>REQ-[A-Z0-9-]+)\s+-\s+(?<title>[^\r\n]+)\r?\n(?<body>.*?)(?=^### Requirement:|\z)'
        foreach ($match in [regex]::Matches($content, $pattern)) {
            $id = $match.Groups['id'].Value.Trim()
            if ($seen.ContainsKey($id)) {
                throw "Duplicate requirement ID '$id'."
            }
            $seen[$id] = $true
            $body = $match.Groups['body'].Value.Trim()
            $scenarioPattern = '(?ms)^#### Scenario:\s*(?<title>[^\r\n]+)\r?\n(?<body>.*?)(?=^#### Scenario:|\z)'
            $scenarios = New-Object System.Collections.ArrayList
            foreach ($scenarioMatch in [regex]::Matches($body, $scenarioPattern)) {
                [void]$scenarios.Add([pscustomobject]@{
                    title = $scenarioMatch.Groups['title'].Value.Trim()
                    body = $scenarioMatch.Groups['body'].Value.Trim()
                })
            }
            if ($scenarios.Count -eq 0) {
                throw "Requirement '$id' has no scenarios."
            }
            $description = ($body -split '(?m)^#### Scenario:', 2)[0].Trim()
            $relativePath = $file.FullName.Substring($script:BlueprintRoot.Length).TrimStart('\') -replace '\\', '/'
            [void]$requirements.Add([pscustomobject]@{
                id = $id
                title = $match.Groups['title'].Value.Trim()
                description = $description
                scenarios = @($scenarios)
                sourcePath = $relativePath
            })
        }
    }
    if ($requirements.Count -eq 0) {
        throw "No requirements with stable REQ IDs found for '$ChangeId'."
    }
    return @($requirements)
}

function Get-ChangeTasks {
    param([Parameter(Mandatory = $true)][string]$ChangeId)

    $changeDir = Get-ChangeDirectory -ChangeId $ChangeId
    $taskPath = Join-Path $changeDir 'tasks.md'
    if (-not (Test-Path -LiteralPath $taskPath -PathType Leaf)) {
        throw "tasks.md not found for '$ChangeId'."
    }
    $tasks = New-Object System.Collections.ArrayList
    $checkboxCount = 0
    $seen = @{}
    foreach ($line in Get-Content -LiteralPath $taskPath) {
        if ($line -match '^- \[[ xX]\]') {
            $checkboxCount++
            if ($line -notmatch '^- \[(?<done>[ xX])\]\s+(?<id>TASK-[A-Z0-9-]+)\s+\[STORY:(?<parent>REQ-[A-Z0-9-]+)\]\s+(?<title>.+)$') {
                throw "Task does not match required TASK/STORY format: $line"
            }
            if ($seen.ContainsKey($Matches.id)) {
                throw "Duplicate task ID '$($Matches.id)'."
            }
            $seen[$Matches.id] = $true
            [void]$tasks.Add([pscustomobject]@{
                id = $Matches.id
                parentRequirementId = $Matches.parent
                title = $Matches.title.Trim()
                complete = $Matches.done -match '[xX]'
            })
        }
    }
    if ($checkboxCount -eq 0) {
        throw "No tasks found for '$ChangeId'."
    }
    return @($tasks)
}

function Get-ChangeSourceFiles {
    param([Parameter(Mandatory = $true)][string]$ChangeId)

    $changeDir = Get-ChangeDirectory -ChangeId $ChangeId
    $files = New-Object System.Collections.ArrayList
    $seen = @{}
    foreach ($name in @('proposal.md', 'business-context.md', 'design.md', 'delivery-plan.json', 'tasks.md')) {
        $path = Join-Path $changeDir $name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Required source file missing: $path"
        }
        $item = Get-Item -LiteralPath $path
        $seen[$item.FullName.ToLowerInvariant()] = $true
        [void]$files.Add($item)
    }
    foreach ($file in Get-ChildItem -LiteralPath (Join-Path $changeDir 'specs') -Recurse -File -Filter '*.md' | Sort-Object FullName) {
        if (-not $seen.ContainsKey($file.FullName.ToLowerInvariant())) {
            $seen[$file.FullName.ToLowerInvariant()] = $true
            [void]$files.Add($file)
        }
    }

    foreach ($relativePath in @(
        'company/company-profile.md',
        'business/capability-map.md',
        'business/processes/process-catalog.md',
        'application-landscape/business-central/solution-overview.md',
        'projects/project-charter.md'
    )) {
        $path = Join-Path $script:BlueprintRoot ($relativePath -replace '/', '\')
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Required enterprise source file missing: $path"
        }
        $item = Get-Item -LiteralPath $path
        if (-not $seen.ContainsKey($item.FullName.ToLowerInvariant())) {
            $seen[$item.FullName.ToLowerInvariant()] = $true
            [void]$files.Add($item)
        }
    }

    $context = Get-Content -LiteralPath (Join-Path $changeDir 'business-context.md') -Raw
    $referencePattern = '`(?<path>(?:company|business|application-landscape|projects)/[^`]+\.md)`'
    foreach ($match in [regex]::Matches($context, $referencePattern)) {
        $path = Join-Path $script:BlueprintRoot ($match.Groups['path'].Value -replace '/', '\')
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Referenced enterprise source file missing: $path"
        }
        $item = Get-Item -LiteralPath $path
        if (-not $seen.ContainsKey($item.FullName.ToLowerInvariant())) {
            $seen[$item.FullName.ToLowerInvariant()] = $true
            [void]$files.Add($item)
        }
    }
    return @($files)
}

function Get-RelativeBlueprintPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $full = [System.IO.Path]::GetFullPath($Path)
    if (-not $full.StartsWith($script:BlueprintRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path is outside blueprint root: $Path"
    }
    return $full.Substring($script:BlueprintRoot.Length).TrimStart('\') -replace '\\', '/'
}

function Get-FileSha256 {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Write-Utf8File {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Content
    )

    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        [void](New-Item -ItemType Directory -Path $parent -Force)
    }
    [System.IO.File]::WriteAllText($Path, ($Content.TrimEnd() + [Environment]::NewLine), $script:Utf8NoBom)
}

function Write-JsonFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Value,
        [int]$Depth = 12
    )
    Write-Utf8File -Path $Path -Content ($Value | ConvertTo-Json -Depth $Depth)
}
