[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Destination,

    [Parameter(Mandatory = $true)]
    [ValidateSet('implementation','support-only','mixed')]
    [string]$Profile,

    [ValidatePattern('^[0-9]+\.[0-9]+\.[0-9]+$')]
    [string]$ExpectedBlueprintVersion,

    [switch]$SyntheticFixture
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

function Write-Utf8File([string]$Path, [string]$Content) {
    $directory = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $directory -PathType Container)) {
        [void](New-Item -ItemType Directory -Path $directory -Force)
    }
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ($Content -replace "`r`n", "`n"), $encoding)
}

function New-FixtureId {
    $alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ'
    $bytes = New-Object byte[] 26
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    $characters = for ($index = 0; $index -lt 26; $index++) { $alphabet[[int]$bytes[$index] % $alphabet.Length] }
    return 'TFX-' + ($characters -join '')
}

if (-not $SyntheticFixture) {
    throw 'INSTALLABLE_RELEASE_REQUIRED: Customer-workspace generation remains blocked until a verified installable release exists.'
}
if (-not [string]::IsNullOrWhiteSpace($ExpectedBlueprintVersion)) {
    throw 'SYNTHETIC_VERSION_FORBIDDEN: A synthetic fixture must not assert an expected or installed product version.'
}

$destinationPath = [System.IO.Path]::GetFullPath($Destination)
$parent = Split-Path -Parent $destinationPath
if ([string]::IsNullOrWhiteSpace($parent) -or -not (Test-Path -LiteralPath $parent -PathType Container)) {
    throw 'DESTINATION_PARENT_MISSING: The destination parent must already exist.'
}
if ((Get-Item -LiteralPath $parent -Force).Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
    throw 'DESTINATION_PARENT_REPARSE_POINT: Synthetic fixtures cannot be published through a reparse-point parent.'
}
if (Test-Path -LiteralPath $destinationPath) {
    throw 'DESTINATION_EXISTS: The requested destination must not exist.'
}

$staging = Join-Path $parent ('.bcprojectos-fixture-' + [Guid]::NewGuid().ToString('N'))
$createdStaging = $false
try {
    [void](New-Item -ItemType Directory -Path $staging)
    $createdStaging = $true

    $directories = @(
        'governance/catalogs','governance/policies','governance/decisions','company',
        'knowledge/items','knowledge/processes','knowledge/business-rules','knowledge/bc',
        'knowledge/bc/sales','knowledge/bc/purchasing','knowledge/bc/inventory','knowledge/bc/finance',
        'knowledge/application-landscape','projects','support/cases','support/board','meetings',
        'work/tickets','external-files/inbox','external-files/review','external-files/quarantine',
        'external-files/register','external-files/originals','external-files/derived','external-files/processing-log',
        'openspec/schemas','openspec/specs','openspec/changes','evidence','generated','automation','schemas',
        'migrations','backup/manifests'
    )
    foreach ($relative in $directories) { [void](New-Item -ItemType Directory -Path (Join-Path $staging $relative) -Force) }

    $catalogSource = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\catalogs'))
    $catalogTarget = Join-Path $staging 'governance\catalogs'
    foreach ($catalog in Get-ChildItem -LiteralPath $catalogSource -File | Sort-Object Name) {
        Copy-Item -LiteralPath $catalog.FullName -Destination $catalogTarget -Force
    }

    $metadata = [ordered]@{
        schema_version = 1
        artifact_type = 'bcprojectos_synthetic_workspace_fixture'
        fixture_id = New-FixtureId
        product_id = 'spectra'
        synthetic = $true
        installable = $false
        release_status = 'PENDING_BCPROJECTOS_RELEASE'
        profile = $Profile
        created_at = [DateTime]::UtcNow.ToString('o')
        openspec_roots = @('openspec')
    }
    Write-Utf8File -Path (Join-Path $staging 'synthetic-fixture.yaml') -Content (($metadata | ConvertTo-Json -Depth 5) + "`n")
    Write-Utf8File -Path (Join-Path $staging 'governance\policies\workspace-profile.yaml') -Content (([ordered]@{ schema_version=1; profile=$Profile } | ConvertTo-Json) + "`n")
    Write-Utf8File -Path (Join-Path $staging 'openspec\config.yaml') -Content "schema: spec-driven`n"
    Write-Utf8File -Path (Join-Path $staging 'README.md') -Content "# Synthetische BCProjectOS-Fixture`n`nNur fuer lokale Strukturtests. Nicht installierbar. Keine Kundeninstanz.`n"
    Write-Utf8File -Path (Join-Path $staging '.gitignore') -Content "external-files/originals/`n"
    foreach ($area in @('sales','purchasing','inventory','finance')) {
        Write-Utf8File -Path (Join-Path $staging "knowledge\bc\$area\README.md") -Content "# $area`n`nEs wurde kein Kundenwissen erfasst.`n"
    }

    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Test-SyntheticWorkspaceFixture.ps1') -Path $staging
    if ($LASTEXITCODE -ne 0) { throw 'SYNTHETIC_VALIDATION_FAILED: Staged fixture did not pass validation.' }

    Move-Item -LiteralPath $staging -Destination $destinationPath
    $createdStaging = $false
    Write-Host "PASS: Created non-installable synthetic fixture at $destinationPath"
    Write-Host 'PENDING_BCPROJECTOS_RELEASE'
}
finally {
    if ($createdStaging -and (Test-Path -LiteralPath $staging -PathType Container)) {
        Remove-Item -LiteralPath $staging -Recurse -Force
    }
}
