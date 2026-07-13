[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$RepositoryRoot,
    [Parameter(Mandatory=$true)][ValidatePattern('^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$')][string]$Version,
    [switch]$SyntheticRepository,
    [switch]$AllowRealRepository
)
$ErrorActionPreference='Stop';Set-StrictMode -Version 2.0
if(-not$SyntheticRepository-and-not$AllowRealRepository){throw 'REAL_REPOSITORY_EXPLICIT_APPROVAL_REQUIRED'}
$root=[IO.Path]::GetFullPath($RepositoryRoot);if(-not(Test-Path (Join-Path $root '.git') -PathType Container)){throw 'REPOSITORY_INVALID'}
. (Join-Path $PSScriptRoot 'Release.Common.ps1')
$manifestPath=Join-Path $root "release\versions\$Version\release-manifest.json";$checksumsPath=Join-Path $root "release\versions\$Version\checksums.sha256";$tagName="spectra-v$Version"
if(-not(Test-Path $manifestPath -PathType Leaf)-or-not(Test-Path $checksumsPath -PathType Leaf)){throw 'CANDIDATE_FILES_MISSING'}
if(@(& git -C $root status --porcelain).Count){throw 'WORKTREE_NOT_CLEAN'};& git -C $root show-ref --verify --quiet "refs/tags/$tagName";if($LASTEXITCODE-eq0){throw 'TAG_ALREADY_EXISTS'}
$manifest=Get-Content $manifestPath -Raw|ConvertFrom-Json
if([int]$manifest.schema_version-ne4-or[string]$manifest.product_id-ne'spectra'-or[string]$manifest.release_version-ne$Version-or[string]$manifest.manifest_state-ne'candidate'-or[string]$manifest.release_kind-ne'installable_blueprint'-or[string]$manifest.consumer_mode-ne'CONTRACT_REFERENCE_ONLY'-or$manifest.installable_blueprint-ne$false-or$null-ne$manifest.source_commit-or$null-ne$manifest.source_tree-or[string]$manifest.candidate_source_commit-notmatch'^[0-9a-f]{40}$'-or[string]$manifest.candidate_source_tree-notmatch'^[0-9a-f]{40}$'){throw 'CANDIDATE_NOT_BOUND_OR_INCONSISTENT'}
$candidateSource=[string]$manifest.candidate_source_commit;$treeOutput=@(& git -C $root rev-parse "$candidateSource`^{tree}" 2>$null);$treeExit=$LASTEXITCODE;$actualTree=([string]($treeOutput|Select-Object -First 1)).Trim();if($treeExit-ne0-or$actualTree-ne[string]$manifest.candidate_source_tree){throw 'CANDIDATE_SOURCE_TREE_MISMATCH'}
$head=(& git -C $root rev-parse 'HEAD^{commit}').Trim();& git -C $root merge-base --is-ancestor $candidateSource $head 2>$null;if($LASTEXITCODE-ne0){throw 'CANDIDATE_SOURCE_NOT_ANCESTOR'};$savedPreference=$ErrorActionPreference;$ErrorActionPreference='Continue';& git -C $root cat-file -e "$candidateSource`:release/versions/$Version/release-manifest.json" 2>$null;$sourceContainsCandidate=$LASTEXITCODE-eq0;$ErrorActionPreference=$savedPreference;if($sourceContainsCandidate){throw 'CANDIDATE_SOURCE_SELF_REFERENCE'}
$scope=Get-BCProjectOSReleaseScope -Root $root -Revision $candidateSource;$sourceRecords=@(Get-BCProjectOSGitPayloadRecords -Root $root -Revision $candidateSource -Scope $scope -IncludeMode);$headRecords=@(Get-BCProjectOSGitPayloadRecords -Root $root -Revision $head -Scope $scope -IncludeMode);$expected=Get-BCProjectOSChecksumsText $sourceRecords -IncludeMode
if((Get-BCProjectOSChecksumsText $headRecords -IncludeMode)-ne$expected){throw 'PAYLOAD_CHANGED_AFTER_SOURCE_COMMIT'};$actual=([IO.File]::ReadAllText($checksumsPath)-replace"`r`n","`n");if($actual-ne$expected){throw 'CANDIDATE_CHECKSUM_MISMATCH'};$digest=Get-BCProjectOSTextSha256 $expected;if([string]$manifest.payload.bundle_digest-ne$digest){throw 'CANDIDATE_DIGEST_MISMATCH'}
$finalSource=$head;$finalTree=(& git -C $root rev-parse "$finalSource`^{tree}").Trim();$final=[ordered]@{};foreach($p in $manifest.PSObject.Properties){if($p.Name -notin @('candidate_source_commit','candidate_source_tree')){$final[$p.Name]=$p.Value}};$final.manifest_state='final';$final.source_commit=$finalSource;$final.source_tree=$finalTree;$final.consumer_mode='INSTALLABLE_BLUEPRINT';$final.installable_blueprint=$true;$final.expected_tag=$tagName
$temp=Join-Path (Split-Path -Parent $manifestPath) ('.release-manifest.final-'+[Guid]::NewGuid().ToString('N')+'.tmp');Write-BCProjectOSUtf8File $temp (($final|ConvertTo-Json -Depth 20)+"`n");Move-Item $temp $manifestPath -Force
& git -C $root add -- $manifestPath $checksumsPath;& git -C $root commit -m "Promote Spectra $Version candidate"|Out-Null;if($LASTEXITCODE-ne0){throw 'FINAL_MANIFEST_COMMIT_FAILED'};& git -C $root tag -a $tagName -m "Spectra $Version";if($LASTEXITCODE-ne0){throw 'ANNOTATED_TAG_FAILED'}
$tagCommit=(& git -C $root rev-parse "refs/tags/$tagName`^{commit}").Trim();if($tagCommit-ne(& git -C $root rev-parse HEAD).Trim()){throw 'TAG_COMMIT_MISMATCH'}
Write-Host "PASS: Promoted Spectra $Version.";Write-Host "SOURCE_COMMIT=$finalSource";Write-Host "SOURCE_TREE=$finalTree";Write-Host "TAG_COMMIT=$tagCommit";Write-Host "PAYLOAD_DIGEST=$digest"
