[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$RepositoryRoot,
    [Parameter(Mandatory=$true)][ValidatePattern('^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$')][string]$Version,
    [switch]$SyntheticRepository,
    [switch]$AllowRealRepository
)
$ErrorActionPreference='Stop';Set-StrictMode -Version 2.0
if(-not $SyntheticRepository -and -not $AllowRealRepository){throw 'REAL_REPOSITORY_EXPLICIT_APPROVAL_REQUIRED'}
$root=[System.IO.Path]::GetFullPath($RepositoryRoot);if(-not(Test-Path -LiteralPath (Join-Path $root '.git') -PathType Container)){throw 'REPOSITORY_INVALID'}
. (Join-Path $PSScriptRoot 'Release.Common.ps1')
$manifestPath=Join-Path $root "release\versions\$Version\release-manifest.json";$checksumsPath=Join-Path $root "release\versions\$Version\checksums.sha256";$tagName="spectra-v$Version"
if(-not(Test-Path -LiteralPath $manifestPath -PathType Leaf)-or-not(Test-Path -LiteralPath $checksumsPath -PathType Leaf)){throw 'CANDIDATE_FILES_MISSING'}
if(@(& git -C $root status --porcelain).Count-ne 0){throw 'WORKTREE_NOT_CLEAN'};& git -C $root show-ref --verify --quiet "refs/tags/$tagName";if($LASTEXITCODE -eq 0){throw 'TAG_ALREADY_EXISTS'}
$manifest=Get-Content -LiteralPath $manifestPath -Raw|ConvertFrom-Json;if([string]$manifest.product_id-ne 'spectra'-or[string]$manifest.release_version-ne $Version-or[string]$manifest.manifest_state-ne 'candidate'-or[string]$manifest.release_kind-ne 'installable_blueprint'-or[string]$manifest.consumer_mode-ne 'INSTALLABLE_BLUEPRINT'-or$manifest.installable_blueprint-ne $true-or[string]$manifest.source_commit){throw 'CANDIDATE_NOT_UNBOUND_OR_INCONSISTENT'}
$scope=Get-BCProjectOSReleaseScope -Root $root;$records=@(Get-BCProjectOSGitPayloadRecords -Root $root -Revision 'HEAD' -Scope $scope);$expectedChecksums=Get-BCProjectOSChecksumsText -Records $records;$actualChecksums=([System.IO.File]::ReadAllText($checksumsPath)-replace "`r`n","`n");if($actualChecksums-ne $expectedChecksums){throw 'CANDIDATE_CHECKSUM_MISMATCH'};$digest=Get-BCProjectOSTextSha256 -Text $expectedChecksums;if([string]$manifest.payload.bundle_digest-ne $digest){throw 'CANDIDATE_DIGEST_MISMATCH'}
$sourceCommit=(& git -C $root rev-parse HEAD).Trim();if($sourceCommit-notmatch '^[0-9a-f]{40}$'){throw 'SOURCE_COMMIT_INVALID'}
$final=[ordered]@{};foreach($property in $manifest.PSObject.Properties){$final[$property.Name]=$property.Value};$final.manifest_state='final';$final.source_commit=$sourceCommit;$final.expected_tag=$tagName;$finalJson=($final|ConvertTo-Json -Depth 20)+"`n";$tempManifest=Join-Path (Split-Path -Parent $manifestPath) ('.release-manifest.final-'+[Guid]::NewGuid().ToString('N')+'.tmp');Write-BCProjectOSUtf8File -Path $tempManifest -Content $finalJson;Move-Item -LiteralPath $tempManifest -Destination $manifestPath -Force
& git -C $root add -- $manifestPath $checksumsPath;& git -C $root commit -m "Promote Spectra $Version candidate"|Out-Null;if($LASTEXITCODE-ne 0){throw 'FINAL_MANIFEST_COMMIT_FAILED'};& git -C $root tag -a $tagName -m "Spectra $Version";if($LASTEXITCODE-ne 0){throw 'ANNOTATED_TAG_FAILED'}
$tagCommit=(& git -C $root rev-parse "refs/tags/$tagName^{commit}").Trim();if($tagCommit-ne (& git -C $root rev-parse HEAD).Trim()){throw 'TAG_COMMIT_MISMATCH'};Write-Host "PASS: Promoted Spectra $Version.";Write-Host "SOURCE_COMMIT=$sourceCommit";Write-Host "TAG_COMMIT=$tagCommit";Write-Host "PAYLOAD_DIGEST=$digest"
