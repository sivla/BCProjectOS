[CmdletBinding()]
param(
    [ValidatePattern('^[0-9]+\.[0-9]+\.[0-9]+-[0-9A-Za-z.-]+$')]
    [string]$Version = '0.1.0-alpha.1',

    [ValidatePattern('^[0-9]{4}-[0-9]{2}-[0-9]{2}$')]
    [string]$ReleaseDate = '2026-07-11',

    [string]$SourceCommit
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$env:GIT_OPTIONAL_LOCKS = '0'

. (Join-Path $PSScriptRoot 'Release.Common.ps1')

$root = Get-BCProjectOSRoot
$repoRoot = $root
$scope = Get-BCProjectOSReleaseScope -Root $root
$files = @(Get-BCProjectOSPayloadFiles -Root $root -Scope $scope)
$records = @(Get-BCProjectOSPayloadRecords -Files $files)
$checksumsText = Get-BCProjectOSChecksumsText -Records $records
$bundleDigest = Get-BCProjectOSTextSha256 -Text $checksumsText
$resolvedSourceCommit = $null
$manifestState = 'candidate'

if (-not [string]::IsNullOrWhiteSpace($SourceCommit)) {
    $resolvedOutput = @(& git -C $repoRoot rev-parse "$SourceCommit`^{commit}" 2>$null)
    $resolvedExitCode = $LASTEXITCODE
    $resolvedSourceCommit = $resolvedOutput | Select-Object -First 1
    if ($resolvedExitCode -ne 0 -or [string]$resolvedSourceCommit -notmatch '^[0-9a-f]{40}$') {
        throw "Source commit cannot be resolved: $SourceCommit"
    }
    $manifestState = 'final'
}

$records = if ($null -ne $resolvedSourceCommit) { @(Get-BCProjectOSGitPayloadRecords -Root $root -Revision $resolvedSourceCommit -Scope $scope) } else { @(Get-BCProjectOSGitPayloadRecords -Root $root -Revision 'HEAD' -Scope $scope) }
$checksumsText = Get-BCProjectOSChecksumsText -Records $records
$bundleDigest = Get-BCProjectOSTextSha256 -Text $checksumsText

$manifest = [ordered]@{
    schema_version = 1
    product_id = 'spectra'
    release_version = $Version
    release_kind = 'installable_blueprint'
    manifest_state = $manifestState
    release_date = $ReleaseDate
    expected_tag = "spectra-v$Version"
    source_commit = $resolvedSourceCommit
    consumer_mode = 'INSTALLABLE_BLUEPRINT'
    installable_blueprint = $true
    blueprint_version = $Version
    payload = [ordered]@{
        digest_algorithm = 'SHA-256'
        bundle_digest = $bundleDigest
        file_count = $records.Count
        checksums_file = 'checksums.sha256'
        files = $records
    }
    binding_requirements = @(
        'annotated immutable release tag',
        'resolved tag commit',
        'matching source commit',
        'matching payload bundle digest'
    )
    excluded_from_payload = @($scope.excluded_roots)
    known_limits = @(
        'Candidate is not binding-eligible until promotion, annotated tag and final manifest verification',
        'Operator pilots use isolated synthetic workspaces and provide no customer evidence',
        'Baseline reconciliation and adapter provenance remain deferred pending commit-bound evidence',
        'No Project Twin or live external-system integration'
    )
}

$releaseRoot = Join-Path $root ("release\versions\{0}" -f $Version)
$manifestPath = Join-Path $releaseRoot 'release-manifest.json'
$checksumsPath = Join-Path $releaseRoot 'checksums.sha256'
$manifestJson = ($manifest | ConvertTo-Json -Depth 10) + "`n"

Write-BCProjectOSUtf8File -Path $checksumsPath -Content $checksumsText
Write-BCProjectOSUtf8File -Path $manifestPath -Content $manifestJson

Write-Host "PASS: Prepared BCProjectOS $Version $manifestState manifest with $($records.Count) payload files."
Write-Host "Bundle digest: $bundleDigest"
Write-Host "Expected tag: spectra-v$Version"
if ($manifestState -eq 'candidate') {
    Write-Host 'PENDING: No source commit is recorded; this candidate is not binding-eligible.'
}
