[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$productRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$root = [System.IO.Path]::GetFullPath($Path)
$findings = New-Object System.Collections.ArrayList

function Add-Finding([string]$Code, [string]$Message) {
    [void]$script:findings.Add([pscustomobject]@{ code = $Code; message = $Message })
}

if (-not (Test-Path -LiteralPath $root -PathType Container)) {
    Write-Host "BLOCKED: Synthetic fixture does not exist: $root"
    exit 1
}

$requiredDirectories = @(
    'governance/catalogs','governance/policies','governance/decisions','company',
    'knowledge/items','knowledge/processes','knowledge/business-rules','knowledge/bc',
    'knowledge/bc/sales','knowledge/bc/purchasing','knowledge/bc/inventory','knowledge/bc/finance',
    'knowledge/application-landscape','projects','support/cases','support/board','meetings',
    'work/tickets','external-files/inbox','external-files/review','external-files/quarantine',
    'external-files/register','external-files/originals','external-files/derived',
    'external-files/processing-log','openspec/schemas','openspec/specs','openspec/changes',
    'evidence','generated','automation','schemas','migrations','backup/manifests'
)

foreach ($relative in $requiredDirectories) {
    $full = [System.IO.Path]::GetFullPath((Join-Path $root $relative))
    $prefix = $root.TrimEnd('\','/') + [System.IO.Path]::DirectorySeparatorChar
    if (-not $full.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $full -PathType Container)) {
        Add-Finding 'REQUIRED_DIRECTORY_MISSING' "Required fixture directory is missing: $relative"
    }
}

foreach ($item in Get-ChildItem -LiteralPath $root -Recurse -Force) {
    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        Add-Finding 'REPARSE_POINT_FORBIDDEN' "Fixture contains a reparse point: $($item.FullName)"
    }
}

if (Test-Path -LiteralPath (Join-Path $root 'workspace.yaml')) {
    Add-Finding 'SYNTHETIC_WORKSPACE_METADATA_FORBIDDEN' 'Synthetic fixtures must not contain workspace.yaml.'
}

$metadataPath = Join-Path $root 'synthetic-fixture.yaml'
if (-not (Test-Path -LiteralPath $metadataPath -PathType Leaf)) {
    Add-Finding 'SYNTHETIC_METADATA_MISSING' 'synthetic-fixture.yaml is required.'
    $metadata = $null
}
else {
    try { $metadata = Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json }
    catch { Add-Finding 'SYNTHETIC_METADATA_INVALID' $_.Exception.Message; $metadata = $null }
}

if ($null -ne $metadata) {
    $expectedProperties = @('schema_version','artifact_type','fixture_id','product_id','synthetic','installable','release_status','profile','created_at','openspec_roots')
    $actualProperties = @($metadata.PSObject.Properties.Name | Sort-Object)
    if (($actualProperties -join '|') -ne (($expectedProperties | Sort-Object) -join '|')) {
        Add-Finding 'SYNTHETIC_METADATA_PROPERTIES_INVALID' 'Synthetic metadata has missing or additional properties.'
    }
    if ([int]$metadata.schema_version -ne 1 -or [string]$metadata.artifact_type -ne 'bcprojectos_synthetic_workspace_fixture' -or
        [string]$metadata.product_id -ne 'bcprojectos' -or $metadata.synthetic -ne $true -or $metadata.installable -ne $false -or
        [string]$metadata.release_status -ne 'PENDING_BCPROJECTOS_RELEASE') {
        Add-Finding 'SYNTHETIC_IDENTITY_INVALID' 'Synthetic fixture identity or release state is invalid.'
    }
    if ([string]$metadata.fixture_id -notmatch '^TFX-[0-9A-HJKMNP-TV-Z]{26}$') {
        Add-Finding 'SYNTHETIC_FIXTURE_ID_INVALID' 'Synthetic fixture ID is invalid.'
    }
    if (@('implementation','support-only','mixed') -notcontains [string]$metadata.profile) {
        Add-Finding 'SYNTHETIC_PROFILE_INVALID' 'Synthetic fixture profile is invalid.'
    }
    if (@($metadata.openspec_roots).Count -ne 1 -or [string]$metadata.openspec_roots[0] -ne 'openspec') {
        Add-Finding 'OPENSPEC_ROOT_COUNT_INVALID' 'Exactly one OpenSpec root is required.'
    }
}

$catalogSource = Join-Path $productRoot 'catalogs'
$sourceCatalogs = @(Get-ChildItem -LiteralPath $catalogSource -File | Sort-Object Name)
$targetCatalogs = @(Get-ChildItem -LiteralPath (Join-Path $root 'governance\catalogs') -File | Sort-Object Name)
if (($sourceCatalogs.Name -join '|') -ne ($targetCatalogs.Name -join '|')) {
    Add-Finding 'CATALOG_SET_INVALID' 'Fixture catalog names do not match the product catalogs.'
}
else {
    for ($index = 0; $index -lt $sourceCatalogs.Count; $index++) {
        if ((Get-FileHash -LiteralPath $sourceCatalogs[$index].FullName -Algorithm SHA256).Hash -ne
            (Get-FileHash -LiteralPath $targetCatalogs[$index].FullName -Algorithm SHA256).Hash) {
            Add-Finding 'CATALOG_HASH_MISMATCH' "Catalog differs: $($sourceCatalogs[$index].Name)"
        }
    }
}

$allowedFiles = @('synthetic-fixture.yaml','README.md','.gitignore','governance/policies/workspace-profile.yaml','openspec/config.yaml')
$allowedFiles += @($sourceCatalogs | ForEach-Object { "governance/catalogs/$($_.Name)" })
$allowedFiles += @('knowledge/bc/sales/README.md','knowledge/bc/purchasing/README.md','knowledge/bc/inventory/README.md','knowledge/bc/finance/README.md')
$actualFiles = @(Get-ChildItem -LiteralPath $root -Recurse -Force -File | ForEach-Object { $_.FullName.Substring($root.Length + 1) -replace '\\','/' } | Sort-Object)
if (($actualFiles -join '|') -ne (($allowedFiles | Sort-Object) -join '|')) {
    Add-Finding 'SYNTHETIC_FILE_SET_INVALID' 'Synthetic fixture contains missing or unexpected files.'
}

if ($findings.Count -gt 0) {
    Write-Host 'BLOCKED: Synthetic BCProjectOS fixture validation failed.'
    foreach ($finding in $findings) { Write-Host "- [$($finding.code)] $($finding.message)" }
    exit 1
}

Write-Host 'PASS: Synthetic BCProjectOS fixture is structurally valid and non-installable.'
Write-Host 'PASS: No workspace.yaml or product version claim exists.'
Write-Host 'PASS: Catalogs and the single OpenSpec root are valid.'
