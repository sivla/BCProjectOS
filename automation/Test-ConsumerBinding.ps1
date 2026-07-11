[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [string]$RepositoryRoot
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$canonicalRepositoryUrl = 'https://github.com/sivla/BCProjectOS.git'
$requiredProperties = @('schema_version','binding_status','product_id','repository_url','release_version','release_tag','tag_commit','manifest_path','manifest_source_commit','consumer_mode','installable_blueprint','digest_algorithm','payload_bundle_digest')
$releaseProperties = @('release_version','release_tag','tag_commit','manifest_path','manifest_source_commit','consumer_mode','installable_blueprint','digest_algorithm','payload_bundle_digest')
$findings = New-Object System.Collections.ArrayList

function Add-Finding([string]$Code, [string]$Message) {
    [void]$script:findings.Add("[$Code] $Message")
}

function Get-TextSha256([string]$Text) {
    $encoding = New-Object System.Text.UTF8Encoding($false)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try { return ([System.BitConverter]::ToString($sha256.ComputeHash($encoding.GetBytes($Text)))).Replace('-', '').ToLowerInvariant() }
    finally { $sha256.Dispose() }
}

if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    Add-Finding 'BINDING_FILE_MISSING' "Consumer binding does not exist: $Path"
}
else {
    try { $binding = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json }
    catch { Add-Finding 'BINDING_SYNTAX_INVALID' $_.Exception.Message; $binding = $null }
}

if ($null -ne $binding) {
    . (Join-Path $PSScriptRoot 'Release.Common.ps1')
    $actualProperties = @($binding.PSObject.Properties.Name | Sort-Object)
    if (($actualProperties -join '|') -ne (($requiredProperties | Sort-Object) -join '|')) {
        Add-Finding 'BINDING_PROPERTIES_INVALID' 'Binding has missing or additional properties.'
    }
    if ([int]$binding.schema_version -ne 1 -or [string]$binding.product_id -ne 'spectra' -or [string]$binding.repository_url -ne $canonicalRepositoryUrl) {
        Add-Finding 'BINDING_IDENTITY_INVALID' 'Binding product identity or canonical repository URL is invalid.'
    }

    if ([string]$binding.binding_status -eq 'PENDING_BCPROJECTOS_RELEASE') {
        foreach ($property in $releaseProperties) {
            if ($null -ne $binding.$property) { Add-Finding 'PENDING_RELEASE_VALUE_PRESENT' "Pending binding must keep '$property' null." }
        }
    }
    elseif ([string]$binding.binding_status -eq 'BOUND') {
        if ([string]$binding.release_version -notmatch '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$' -or [string]$binding.release_tag -ne "spectra-v$($binding.release_version)" -or
            [string]$binding.tag_commit -notmatch '^[0-9a-f]{40}$' -or [string]$binding.manifest_source_commit -notmatch '^[0-9a-f]{40}$' -or
            [string]$binding.manifest_path -notmatch '^release/versions/[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?/release-manifest\.json$' -or
            [string]$binding.digest_algorithm -ne 'SHA-256' -or [string]$binding.payload_bundle_digest -notmatch '^[0-9a-f]{64}$') {
            Add-Finding 'BOUND_SHAPE_INVALID' 'Bound binding has an invalid version, tag, commit, manifest path, or SHA-256 digest.'
        }
        if (([string]$binding.consumer_mode -eq 'INSTALLABLE_BLUEPRINT' -and $binding.installable_blueprint -ne $true) -or
            ([string]$binding.consumer_mode -eq 'CONTRACT_REFERENCE_ONLY' -and $binding.installable_blueprint -ne $false) -or
            @('INSTALLABLE_BLUEPRINT','CONTRACT_REFERENCE_ONLY') -notcontains [string]$binding.consumer_mode) {
            Add-Finding 'BOUND_CONSUMER_MODE_INVALID' 'Consumer mode and installable_blueprint must be consistent.'
        }
        if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
            Add-Finding 'BOUND_REPOSITORY_VERIFICATION_REQUIRED' 'BOUND is not accepted without repository verification.'
        }
        elseif (Test-Path -LiteralPath $RepositoryRoot -PathType Container) {
            $remoteOutput = @(& git -C $RepositoryRoot remote get-url origin 2>$null)
            $remoteExitCode = $LASTEXITCODE
            $remote = $remoteOutput | Select-Object -First 1
            if ($remoteExitCode -ne 0 -or [string]$remote -ne $canonicalRepositoryUrl) { Add-Finding 'BOUND_REMOTE_INVALID' 'Repository origin does not match the canonical product URL.' }
            & git -C $RepositoryRoot show-ref --verify --quiet "refs/tags/$($binding.release_tag)"
            $tagExists = $LASTEXITCODE -eq 0
            if (-not $tagExists) { Add-Finding 'BOUND_ANNOTATED_TAG_MISSING' 'Bound release tag is missing or not annotated.' }
            else {
                $tagTypeOutput = @(& git -C $RepositoryRoot cat-file -t "refs/tags/$($binding.release_tag)" 2>$null)
                $tagTypeExitCode = $LASTEXITCODE
                $tagType = $tagTypeOutput | Select-Object -First 1
                if ($tagTypeExitCode -ne 0 -or [string]$tagType -ne 'tag') { Add-Finding 'BOUND_ANNOTATED_TAG_MISSING' 'Bound release tag is not annotated.' }
                $tagCommitOutput = @(& git -C $RepositoryRoot rev-parse "refs/tags/$($binding.release_tag)^{commit}" 2>$null)
                $tagCommitExitCode = $LASTEXITCODE
                $tagCommit = $tagCommitOutput | Select-Object -First 1
                if ($tagCommitExitCode -ne 0 -or [string]$tagCommit -ne [string]$binding.tag_commit) { Add-Finding 'BOUND_TAG_COMMIT_MISMATCH' 'Bound tag does not resolve to tag_commit.' }
                $manifestText = (& git -C $RepositoryRoot show "$($binding.tag_commit):$($binding.manifest_path)" 2>$null)
                if ($LASTEXITCODE -ne 0) { Add-Finding 'BOUND_MANIFEST_MISSING' 'Bound manifest is absent from tag_commit.' }
                else {
                try { $manifest = ($manifestText -join "`n") | ConvertFrom-Json }
                catch { Add-Finding 'BOUND_MANIFEST_INVALID' $_.Exception.Message; $manifest = $null }
                if ($null -ne $manifest) {
                    if ([string]$manifest.manifest_state -ne 'final' -or [string]$manifest.release_version -ne [string]$binding.release_version -or [string]$manifest.expected_tag -ne [string]$binding.release_tag -or [string]$manifest.source_commit -ne [string]$binding.manifest_source_commit -or [string]$manifest.consumer_mode -ne [string]$binding.consumer_mode -or $manifest.installable_blueprint -ne $binding.installable_blueprint -or [string]$manifest.payload.digest_algorithm -ne 'SHA-256' -or [string]$manifest.payload.bundle_digest -ne [string]$binding.payload_bundle_digest) {
                        Add-Finding 'BOUND_MANIFEST_MISMATCH' 'Bound values do not match the final manifest at tag_commit.'
                    }
                    $actualRecords = New-Object System.Collections.ArrayList
                    foreach ($record in @($manifest.payload.files)) {
                        if ([string]$record.path -match '(^|[\\/])\.\.([\\/]|$)' -or [System.IO.Path]::IsPathRooted([string]$record.path)) {
                            Add-Finding 'BOUND_PAYLOAD_PATH_INVALID' "Manifest payload path is unsafe: $($record.path)"
                            continue
                        }
                        try {
                            $actual = Get-BCProjectOSGitBlobRecord -Root $RepositoryRoot -Revision $binding.tag_commit -RelativePath ([string]$record.path)
                            if ([int64]$actual.size_bytes -ne [int64]$record.size_bytes -or [string]$actual.sha256 -ne [string]$record.sha256) { Add-Finding 'BOUND_PAYLOAD_FILE_MISMATCH' "Manifest payload record differs from tagged content: $($record.path)" }
                            [void]$actualRecords.Add([pscustomobject]@{ path = [string]$record.path; sha256 = [string]$actual.sha256 })
                        }
                        catch { Add-Finding 'BOUND_PAYLOAD_FILE_MISSING' $_.Exception.Message }
                    }
                    $checksumText = Get-BCProjectOSChecksumsText -Records $actualRecords
                    if ((Get-TextSha256 -Text $checksumText) -ne [string]$binding.payload_bundle_digest) { Add-Finding 'BOUND_PAYLOAD_DIGEST_MISMATCH' 'Recomputed tagged payload digest differs from the bound digest.' }
                }
            }
            }
            if ($tagExists -and [string]$binding.tag_commit -match '^[0-9a-f]{40}$' -and [string]$binding.manifest_source_commit -match '^[0-9a-f]{40}$') {
                & git -C $RepositoryRoot merge-base --is-ancestor $binding.manifest_source_commit $binding.tag_commit 2>$null
                if ($LASTEXITCODE -ne 0) { Add-Finding 'BOUND_SOURCE_ANCESTRY_INVALID' 'Manifest source commit is not an ancestor of tag_commit.' }
            }
        }
        else { Add-Finding 'BOUND_REPOSITORY_ROOT_INVALID' "Repository root does not exist: $RepositoryRoot" }
    }
    else { Add-Finding 'BINDING_STATUS_INVALID' 'binding_status must be PENDING_BCPROJECTOS_RELEASE or BOUND.' }
}

if ($findings.Count -gt 0) {
    Write-Host 'BLOCKED: Spectra consumer binding validation failed.'
    foreach ($finding in $findings) { Write-Host "- $finding" }
    exit 1
}

Write-Host "PASS: Consumer binding is valid in status $($binding.binding_status)."
if ($binding.binding_status -eq 'PENDING_BCPROJECTOS_RELEASE') { Write-Host 'PASS: No release value is asserted from repository identity alone.' }
