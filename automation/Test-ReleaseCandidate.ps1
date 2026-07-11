[CmdletBinding()]
param(
    [ValidatePattern('^[0-9]+\.[0-9]+\.[0-9]+$')]
    [string]$Version = '0.0.1',

    [switch]$RequirePublished
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$env:GIT_OPTIONAL_LOCKS = '0'

. (Join-Path $PSScriptRoot 'Release.Common.ps1')

$root = Get-BCProjectOSRoot
$repoRoot = $root
$manifestPath = Join-Path $root ("release\versions\{0}\release-manifest.json" -f $Version)
$checksumsPath = Join-Path $root ("release\versions\{0}\checksums.sha256" -f $Version)
$findings = New-Object System.Collections.ArrayList
$pending = New-Object System.Collections.ArrayList

function Add-Finding([string]$Code, [string]$Message) {
    [void]$script:findings.Add([pscustomobject]@{ code = $Code; message = $Message })
}

function Add-Pending([string]$Code, [string]$Message) {
    if ($RequirePublished) { Add-Finding -Code $Code -Message $Message }
    else { [void]$script:pending.Add([pscustomobject]@{ code = $Code; message = $Message }) }
}

if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    Add-Finding 'RELEASE_MANIFEST_MISSING' "Release manifest is missing: $manifestPath"
}
if (-not (Test-Path -LiteralPath $checksumsPath -PathType Leaf)) {
    Add-Finding 'RELEASE_CHECKSUMS_MISSING' "Checksums are missing: $checksumsPath"
}
if ($findings.Count -gt 0) {
    Write-Host 'BLOCKED: BCProjectOS release candidate validation failed.'
    foreach ($finding in $findings) { Write-Host "- [$($finding.code)] $($finding.message)" }
    exit 1
}

try { $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json }
catch { Add-Finding 'RELEASE_MANIFEST_INVALID' $_.Exception.Message; $manifest = $null }

if ($null -ne $manifest) {
    if ([int]$manifest.schema_version -ne 1 -or [string]$manifest.product_id -ne 'spectra') {
        Add-Finding 'RELEASE_IDENTITY_INVALID' 'Release manifest has an unsupported schema or product identity.'
    }
    if ([string]$manifest.release_version -ne $Version -or [string]$manifest.expected_tag -ne "spectra-v$Version") {
        Add-Finding 'RELEASE_VERSION_INVALID' 'Release version and expected tag do not match the requested version.'
    }
    if ([string]$manifest.release_kind -ne 'product_contract' -or [string]$manifest.consumer_mode -ne 'CONTRACT_REFERENCE_ONLY' -or $manifest.installable_blueprint -ne $false) {
        Add-Finding 'RELEASE_SCOPE_CLAIM_INVALID' 'Release must remain a non-installable product-contract reference.'
    }
}

try {
    $scope = Get-BCProjectOSReleaseScope -Root $root
    $actualFiles = @(Get-BCProjectOSPayloadFiles -Root $root -Scope $scope)
    $actualRecords = @(Get-BCProjectOSPayloadRecords -Files $actualFiles)
    $expectedChecksumsText = Get-BCProjectOSChecksumsText -Records $actualRecords
    $storedChecksumsText = ([System.IO.File]::ReadAllText($checksumsPath) -replace "`r`n", "`n")
    if ($storedChecksumsText -ne $expectedChecksumsText) {
        Add-Finding 'RELEASE_CHECKSUM_MISMATCH' 'Stored checksums do not match the current release payload.'
    }

    $actualBundleDigest = Get-BCProjectOSTextSha256 -Text $expectedChecksumsText
    if ($null -ne $manifest -and [string]$manifest.payload.bundle_digest -ne $actualBundleDigest) {
        Add-Finding 'RELEASE_BUNDLE_DIGEST_MISMATCH' 'Manifest bundle digest does not match the current payload.'
    }
    if ($null -ne $manifest -and [int]$manifest.payload.file_count -ne $actualRecords.Count) {
        Add-Finding 'RELEASE_FILE_COUNT_MISMATCH' 'Manifest file count does not match the current payload.'
    }

    $manifestRecords = @($manifest.payload.files)
    if ($manifestRecords.Count -ne $actualRecords.Count) {
        Add-Finding 'RELEASE_FILE_LIST_MISMATCH' 'Manifest file list does not match the current payload.'
    }
    else {
        for ($index = 0; $index -lt $actualRecords.Count; $index++) {
            $expected = $actualRecords[$index]
            $recorded = $manifestRecords[$index]
            if ([string]$recorded.path -ne [string]$expected.path -or [string]$recorded.sha256 -ne [string]$expected.sha256 -or [int64]$recorded.size_bytes -ne [int64]$expected.size_bytes) {
                Add-Finding 'RELEASE_FILE_LIST_MISMATCH' "Manifest record differs for payload index $index."
                break
            }
        }
    }
}
catch {
    Add-Finding 'RELEASE_PAYLOAD_INVALID' $_.Exception.Message
}

$productOutput = @(& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'automation\Test-ProductContract.ps1') 2>&1)
if ($LASTEXITCODE -ne 0) {
    Add-Finding 'PRODUCT_CONTRACT_FAILED' ($productOutput -join ' ')
}

$head = (& git -C $repoRoot rev-parse --verify --quiet 'HEAD^{commit}' 2>$null | Select-Object -First 1)
$headExists = $LASTEXITCODE -eq 0 -and [string]$head -match '^[0-9a-f]{40}$'
if (-not $headExists) {
    Add-Pending 'INITIAL_COMMIT_MISSING' 'Repository has no commit history.'
}

$payloadRepoPaths = @($actualRecords | ForEach-Object { [string]$_.path })
$payloadStatus = @(& git -C $repoRoot status --porcelain --untracked-files=all -- @payloadRepoPaths 2>$null)
if ($payloadStatus.Count -gt 0) {
    Add-Pending 'PAYLOAD_NOT_COMMITTED' 'Release payload is untracked or differs from the current commit.'
}

$sourceCommit = if ($null -ne $manifest) { [string]$manifest.source_commit } else { '' }
if ([string]::IsNullOrWhiteSpace($sourceCommit)) {
    Add-Pending 'SOURCE_COMMIT_PENDING' 'Manifest has no immutable source commit.'
}
elseif ($sourceCommit -notmatch '^[0-9a-f]{40}$') {
    Add-Finding 'SOURCE_COMMIT_INVALID' 'Manifest source commit is not a full Git SHA.'
}

$tagName = "spectra-v$Version"
& git -C $repoRoot show-ref --verify --quiet "refs/tags/$tagName"
$tagExists = $LASTEXITCODE -eq 0
if (-not $tagExists) {
    Add-Pending 'RELEASE_TAG_MISSING' "Annotated release tag is missing: $tagName"
}
else {
    $tagType = (& git -C $repoRoot cat-file -t "refs/tags/$tagName" 2>$null | Select-Object -First 1)
    if ([string]$tagType -ne 'tag') {
        Add-Pending 'RELEASE_TAG_NOT_ANNOTATED' "Release tag is not annotated: $tagName"
    }
    $tagCommit = (& git -C $repoRoot rev-parse "refs/tags/$tagName`^{commit}" 2>$null | Select-Object -First 1)
    if ($LASTEXITCODE -ne 0 -or [string]$tagCommit -notmatch '^[0-9a-f]{40}$') {
        Add-Finding 'RELEASE_TAG_COMMIT_INVALID' 'Release tag does not resolve to a commit.'
    }
    else {
        $releaseMetadataPaths = @(
            "release/versions/$Version/release-manifest.json",
            "release/versions/$Version/checksums.sha256"
        )
        foreach ($metadataPath in $releaseMetadataPaths) {
            & git -C $repoRoot cat-file -e "$tagCommit`:$metadataPath" 2>$null
            if ($LASTEXITCODE -ne 0) {
                Add-Finding 'RELEASE_METADATA_NOT_TAGGED' "Release tag does not contain $metadataPath."
            }
        }
        & git -C $repoRoot diff --quiet $tagCommit -- @releaseMetadataPaths
        if ($LASTEXITCODE -ne 0) {
            Add-Finding 'RELEASE_METADATA_DIFFERS_FROM_TAG' 'Working release metadata differs from the tagged commit.'
        }
        if (-not [string]::IsNullOrWhiteSpace($sourceCommit)) {
            & git -C $repoRoot merge-base --is-ancestor $sourceCommit $tagCommit 2>$null
            if ($LASTEXITCODE -ne 0) {
                Add-Finding 'SOURCE_COMMIT_NOT_IN_RELEASE' 'Manifest source commit is not an ancestor of the release tag.'
            }
            & git -C $repoRoot diff --quiet $sourceCommit $tagCommit -- @payloadRepoPaths
            if ($LASTEXITCODE -ne 0) {
                Add-Finding 'PAYLOAD_CHANGED_AFTER_SOURCE_COMMIT' 'Release payload changed between source commit and release tag.'
            }
        }
    }
}

if ($RequirePublished -and $null -ne $manifest -and [string]$manifest.manifest_state -ne 'final') {
    Add-Finding 'RELEASE_MANIFEST_NOT_FINAL' 'Published validation requires a final manifest.'
}

if ($findings.Count -gt 0) {
    Write-Host 'BLOCKED: BCProjectOS release candidate validation failed.'
    foreach ($finding in $findings) { Write-Host "- [$($finding.code)] $($finding.message)" }
    exit 1
}

Write-Host "PASS: BCProjectOS $Version release payload and product contract are valid."
Write-Host "Bundle digest: $($manifest.payload.bundle_digest)"
if ($pending.Count -gt 0) {
    Write-Host 'PENDING: Content is prepared, but publication is not complete.'
    foreach ($item in $pending) { Write-Host "- [$($item.code)] $($item.message)" }
}
else {
    Write-Host "PASS: Annotated tag $tagName, commit binding, and payload digest are valid."
}
