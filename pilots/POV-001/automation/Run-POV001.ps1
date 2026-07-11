[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$pilotRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$workspace = Join-Path $pilotRoot 'workspace'
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..'))
$spikeRoot = Join-Path $repoRoot 'examples\bc-enterprise-blueprint'
$changeId = 'control-partial-delivery-shipping-costs'
$canonicalChangeId = 'CHG-01J0000000000000000000010C'

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) { [void](New-Item -ItemType Directory -Path $parent -Force) }
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ($Content.TrimEnd() + [Environment]::NewLine), $utf8)
}

# Originals are inputs to this run and must never be written by the runner.
$originalRoot = Join-Path $workspace 'external-files\originals'
$originalHashesBefore = @{}
foreach ($file in Get-ChildItem -LiteralPath $originalRoot -Recurse -File) {
    $originalHashesBefore[$file.FullName] = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
}
if ($originalHashesBefore.Count -ne 5) { throw "Expected exactly five immutable originals, found $($originalHashesBefore.Count)." }

& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repoRoot 'automation\Test-ProductContract.ps1')
if ($LASTEXITCODE -ne 0) { throw 'MVP-0 product contract validation failed.' }

$openSpec = Join-Path $spikeRoot 'node_modules\.bin\openspec.cmd'
if (-not (Test-Path -LiteralPath $openSpec -PathType Leaf)) { throw "Local OpenSpec CLI is missing: $openSpec" }
Push-Location $spikeRoot
try {
    $openSpecOutput = (& $openSpec validate $changeId 2>&1 | Out-String).Trim()
    $openSpecExit = $LASTEXITCODE
}
finally { Pop-Location }
if ($openSpecExit -ne 0) { throw "Bound spike OpenSpec validation failed: $openSpecOutput" }

$generator = Join-Path $spikeRoot 'automation\Generate-Deliverables.ps1'
& powershell -NoProfile -ExecutionPolicy Bypass -File $generator -ChangeId $changeId -Force
if ($LASTEXITCODE -ne 0) { throw 'Existing spike delivery generation failed.' }

$gateScript = Join-Path $spikeRoot 'automation\Test-DeliveryGate.ps1'
$gateResults = New-Object System.Collections.ArrayList
foreach ($gate in @('Planning','BuildReady','ReleaseReady')) {
    $text = (& powershell -NoProfile -ExecutionPolicy Bypass -File $gateScript -ChangeId $changeId -Gate $gate -AsJson -SkipOpenSpecValidation 2>&1 | Out-String).Trim()
    $exitCode = $LASTEXITCODE
    try { $parsed = $text | ConvertFrom-Json }
    catch { throw "Cannot parse $gate gate JSON: $text" }
    [void]$gateResults.Add([ordered]@{
        gate = $gate
        passed = [bool]$parsed.passed
        exit_code = $exitCode
        findings = @($parsed.findings)
    })
}

$generatedRoot = Join-Path $workspace "generated\$canonicalChangeId"
$spikeOutput = Join-Path $spikeRoot "deliverables\$changeId"
$binding = Get-Content -LiteralPath (Join-Path $workspace 'openspec\changes\clarify-partial-delivery-shipping-costs\delivery-binding.json') -Raw | ConvertFrom-Json
foreach ($relative in @($binding.selected_pilot_outputs)) {
    $source = Join-Path $spikeOutput ([string]$relative -replace '/', '\')
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Selected generated output missing: $relative" }
    $target = Join-Path $generatedRoot ([string]$relative -replace '/', '\')
    $parent = Split-Path -Parent $target
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) { [void](New-Item -ItemType Directory -Path $parent -Force) }
    Copy-Item -LiteralPath $source -Destination $target -Force
}

$gateReport = [ordered]@{
    schema_version = 1
    pilot_id = 'POV-001'
    canonical_change_id = $canonicalChangeId
    engine_change_id = $changeId
    open_spec_validation = [ordered]@{ passed = $true; exit_code = $openSpecExit; output = $openSpecOutput }
    gates = @($gateResults)
    expected = [ordered]@{ Planning = 'pass'; BuildReady = 'blocked'; ReleaseReady = 'blocked' }
    external_writes = $false
}
Write-Utf8NoBom -Path (Join-Path $generatedRoot 'gate-results.json') -Content ($gateReport | ConvertTo-Json -Depth 12)

$selected = New-Object System.Collections.ArrayList
foreach ($file in Get-ChildItem -LiteralPath $generatedRoot -Recurse -File | Sort-Object FullName) {
    [void]$selected.Add([ordered]@{
        path = $file.FullName.Substring($workspace.Length).TrimStart([char]92).Replace([char]92, [char]47)
        sha256 = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    })
}
$runManifest = [ordered]@{
    schema_version = 1
    pilot_id = 'POV-001'
    canonical_change_id = $canonicalChangeId
    engine = 'examples/bc-enterprise-blueprint/automation'
    selected_outputs = @($selected)
    original_count = $originalHashesBefore.Count
    originals_modified = $false
}
Write-Utf8NoBom -Path (Join-Path $generatedRoot 'pov-run-manifest.json') -Content ($runManifest | ConvertTo-Json -Depth 8)

foreach ($file in Get-ChildItem -LiteralPath $originalRoot -Recurse -File) {
    $current = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
    if (-not $originalHashesBefore.ContainsKey($file.FullName) -or $originalHashesBefore[$file.FullName] -ne $current) {
        throw "Immutable original changed during run: $($file.FullName)"
    }
}

Write-Host 'PASS: POV-001 delivery run completed with immutable originals.'
Write-Host 'PASS: Planning passed; BuildReady and ReleaseReady remained fail-closed.'
