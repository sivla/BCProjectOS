[CmdletBinding()]
param(
    [ValidatePattern('^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$')]
    [string]$Version = '0.1.0-alpha.1',

    [ValidatePattern('^[0-9]{4}-[0-9]{2}-[0-9]{2}$')]
    [string]$ReleaseDate = '2026-07-11',

    [Parameter(Mandatory=$true)]
    [Alias('SourceCommit')]
    [string]$CandidateSourceCommit
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$env:GIT_OPTIONAL_LOCKS = '0'

. (Join-Path $PSScriptRoot 'Release.Common.ps1')

$root = Get-BCProjectOSRoot
$repoRoot = $root
$resolvedOutput = @(& git -C $repoRoot rev-parse "$CandidateSourceCommit`^{commit}" 2>$null)
$resolvedSourceCommit = $resolvedOutput | Select-Object -First 1
if ($LASTEXITCODE -ne 0 -or [string]$resolvedSourceCommit -notmatch '^[0-9a-f]{40}$') { throw "CANDIDATE_SOURCE_COMMIT_INVALID:$CandidateSourceCommit" }
$head = (& git -C $repoRoot rev-parse 'HEAD^{commit}').Trim()
if ($resolvedSourceCommit -ne $head) { throw 'CANDIDATE_SOURCE_MUST_BE_HEAD' }
$sourceTree = (& git -C $repoRoot rev-parse "$resolvedSourceCommit`^{tree}").Trim()
$releaseMetadataPath = "release/versions/$Version/release-manifest.json"
$savedPreference=$ErrorActionPreference;$ErrorActionPreference='Continue';& git -C $repoRoot cat-file -e "$resolvedSourceCommit`:$releaseMetadataPath" 2>$null;$sourceContainsCandidate=$LASTEXITCODE-eq0;$ErrorActionPreference=$savedPreference
if ($sourceContainsCandidate) { throw 'CANDIDATE_SOURCE_SELF_REFERENCE' }
$scope = Get-BCProjectOSReleaseScope -Root $root -Revision $resolvedSourceCommit
$records = @(Get-BCProjectOSGitPayloadRecords -Root $root -Revision $resolvedSourceCommit -Scope $scope -IncludeMode)
$checksumsText = Get-BCProjectOSChecksumsText -Records $records -IncludeMode
$bundleDigest = Get-BCProjectOSTextSha256 -Text $checksumsText

$manifest = [ordered]@{
    schema_version = 4
    product_id = 'spectra'
    release_version = $Version
    release_kind = 'installable_blueprint'
    manifest_state = 'candidate'
    release_date = $ReleaseDate
    expected_tag = "spectra-v$Version"
    source_commit = $null
    source_tree = $null
    candidate_source_commit = $resolvedSourceCommit
    candidate_source_tree = $sourceTree
    consumer_mode = 'CONTRACT_REFERENCE_ONLY'
    installable_blueprint = $false
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
        'matching source commit and source tree',
        'matching payload bundle digest'
    )
    excluded_from_payload = @($scope.excluded_roots)
    known_limits = @(
        'Candidate provenance is bound but final source fields remain unset until promotion; candidate is not installable or published',
        'All profiles, pilots and forward tests are synthetic and provide no customer evidence',
        'The candidate is contract-reference-only until separate promotion, annotated tag and publication verification',
        'Live Business Central, Atlassian and customer-system mutations remain outside this candidate evidence'
    )
}

$releaseRoot = Join-Path $root ("release\versions\{0}" -f $Version)
$manifestPath = Join-Path $releaseRoot 'release-manifest.json'
$checksumsPath = Join-Path $releaseRoot 'checksums.sha256'
$manifestJson = ($manifest | ConvertTo-Json -Depth 10) + "`n"

Write-BCProjectOSUtf8File -Path $checksumsPath -Content $checksumsText
Write-BCProjectOSUtf8File -Path $manifestPath -Content $manifestJson

Write-Host "PASS: Prepared BCProjectOS $Version source-bound candidate manifest with $($records.Count) payload files."
Write-Host "Bundle digest: $bundleDigest"
Write-Host "Expected tag: spectra-v$Version"
Write-Host "Source commit: $resolvedSourceCommit"
Write-Host "Source tree: $sourceTree"
Write-Host 'PENDING: Candidate is non-installable until separate promotion, tag and release verification.'
