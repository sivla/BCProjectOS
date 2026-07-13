[CmdletBinding()]
param(
    [ValidatePattern('^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$')][string]$Version = '0.1.0-alpha.1',
    [switch]$RequirePublished,
    [switch]$SkipProductContract
)
$ErrorActionPreference='Stop';Set-StrictMode -Version 2.0;$env:GIT_OPTIONAL_LOCKS='0'
. (Join-Path $PSScriptRoot 'Release.Common.ps1')
$root=Get-BCProjectOSRoot;$manifestPath=Join-Path $root "release\versions\$Version\release-manifest.json";$checksumsPath=Join-Path $root "release\versions\$Version\checksums.sha256"
$findings=New-Object Collections.ArrayList;$pending=New-Object Collections.ArrayList
function Add-Finding([string]$Code,[string]$Message){[void]$script:findings.Add([pscustomobject]@{code=$Code;message=$Message})}
function Add-Pending([string]$Code,[string]$Message){if($RequirePublished){Add-Finding $Code $Message}else{[void]$script:pending.Add([pscustomobject]@{code=$Code;message=$Message})}}
function Get-Value($Object,[string]$Name){if($null-ne$Object-and$Object.PSObject.Properties.Name-contains$Name){return $Object.$Name};return $null}
if(-not(Test-Path $manifestPath -PathType Leaf)){Add-Finding 'RELEASE_MANIFEST_MISSING' "Release manifest is missing: $manifestPath"}
if(-not(Test-Path $checksumsPath -PathType Leaf)){Add-Finding 'RELEASE_CHECKSUMS_MISSING' "Checksums are missing: $checksumsPath"}
if($findings.Count){Write-Host 'BLOCKED: BCProjectOS release candidate validation failed.';foreach($f in $findings){Write-Host "- [$($f.code)] $($f.message)"};exit 1}
try{$manifest=Get-Content $manifestPath -Raw|ConvertFrom-Json}catch{Add-Finding 'RELEASE_MANIFEST_INVALID' $_.Exception.Message;$manifest=$null}

$state='';$schemaVersion=0;$sourceCommit='';$sourceTree='';$candidateSourceCommit='';$candidateSourceTree=''
if($null-ne$manifest){
    $schemaVersion=[int]$manifest.schema_version;$state=[string]$manifest.manifest_state;$sourceCommit=[string](Get-Value $manifest 'source_commit')
    $sourceTree=if($manifest.PSObject.Properties.Name -contains 'source_tree'){[string]$manifest.source_tree}else{''}
    $candidateSourceCommit=[string](Get-Value $manifest 'candidate_source_commit');$candidateSourceTree=[string](Get-Value $manifest 'candidate_source_tree')
    if($schemaVersion -notin @(1,2,3,4)-or[string]$manifest.product_id-ne'spectra'){Add-Finding 'RELEASE_IDENTITY_INVALID' 'Unsupported manifest schema or product identity.'}
    if([string]$manifest.release_version-ne$Version-or[string]$manifest.expected_tag-ne"spectra-v$Version"){Add-Finding 'RELEASE_VERSION_INVALID' 'Version and expected tag differ from the requested version.'}
    if($state -eq 'candidate'){
        if($schemaVersion -ne 4){Add-Finding 'LEGACY_UNBOUND_CANDIDATE_REJECTED' 'Legacy candidates must be regenerated under the schema-v4 mode-bound provenance contract.'}
        if([string]$manifest.release_kind-ne'installable_blueprint'-or[string]$manifest.consumer_mode-ne'CONTRACT_REFERENCE_ONLY'-or$manifest.installable_blueprint-ne$false-or[string]$manifest.blueprint_version-ne$Version){Add-Finding 'CANDIDATE_SCOPE_CLAIM_INVALID' 'Candidate must be non-installable and contract-reference-only.'}
        if(-not[string]::IsNullOrWhiteSpace($sourceCommit)-or-not[string]::IsNullOrWhiteSpace($sourceTree)){Add-Finding 'CANDIDATE_FINAL_SOURCE_PRESENT' 'Final source fields must remain null until promotion.'}
        if([string]::IsNullOrWhiteSpace($candidateSourceCommit)){Add-Finding 'CANDIDATE_SOURCE_COMMIT_MISSING' 'Candidate provenance commit is required.'}
        if([string]::IsNullOrWhiteSpace($candidateSourceTree)){Add-Finding 'CANDIDATE_SOURCE_TREE_MISSING' 'Candidate provenance tree is required.'}
        $sourceCommit=$candidateSourceCommit;$sourceTree=$candidateSourceTree
        Add-Pending 'RELEASE_MANIFEST_NOT_FINAL' 'Candidate has not been promoted to a final manifest.'
    }elseif($state -eq 'final'){
        if([string]$manifest.release_kind-ne'installable_blueprint'-or[string]$manifest.consumer_mode-ne'INSTALLABLE_BLUEPRINT'-or$manifest.installable_blueprint-ne$true-or[string]$manifest.blueprint_version-ne$Version){Add-Finding 'RELEASE_SCOPE_CLAIM_INVALID' 'Final release must describe an installable Spectra blueprint.'}
        if(-not[string]::IsNullOrWhiteSpace($candidateSourceCommit)-or-not[string]::IsNullOrWhiteSpace($candidateSourceTree)){Add-Finding 'FINAL_CANDIDATE_PROVENANCE_PRESENT' 'Final manifest must not retain candidate provenance values.'}
    }else{Add-Finding 'RELEASE_MANIFEST_STATE_INVALID' 'Manifest state is neither candidate nor final.'}
}

$head=(& git -C $root rev-parse 'HEAD^{commit}').Trim();$scope=$null;$sourceResolved=$false;$sourceRecords=@();$payloadPaths=@();$modeBound=$schemaVersion-ge4
if(-not[string]::IsNullOrWhiteSpace($sourceCommit)){
    $resolved=@(& git -C $root rev-parse "$sourceCommit`^{commit}" 2>$null)|Select-Object -First 1
    if($LASTEXITCODE-ne0-or[string]$resolved-notmatch'^[0-9a-f]{40}$'-or$resolved-ne$sourceCommit){Add-Finding 'CANDIDATE_SOURCE_COMMIT_INVALID' 'Source commit is not a resolvable full Git commit SHA.'}
    else{
        $sourceResolved=$true;$actualTree=(& git -C $root rev-parse "$sourceCommit`^{tree}").Trim();$scope=Get-BCProjectOSReleaseScope -Root $root -Revision $sourceCommit
        if($schemaVersion-ge2-and($sourceTree-notmatch'^[0-9a-f]{40}$'-or$sourceTree-ne$actualTree)){Add-Finding 'CANDIDATE_SOURCE_TREE_MISMATCH' 'Recorded source tree differs from the Git commit tree.'}
        & git -C $root merge-base --is-ancestor $sourceCommit $head 2>$null;if($LASTEXITCODE-ne0){Add-Finding 'CANDIDATE_SOURCE_NOT_ANCESTOR' 'Source commit is not an ancestor of HEAD.'}
        if($state-eq'candidate'){
            $savedPreference=$ErrorActionPreference;$ErrorActionPreference='Continue';& git -C $root cat-file -e "$sourceCommit`:release/versions/$Version/release-manifest.json" 2>$null;$sourceContainsCandidate=$LASTEXITCODE-eq0;$ErrorActionPreference=$savedPreference
            if($sourceContainsCandidate){Add-Finding 'CANDIDATE_SOURCE_SELF_REFERENCE' 'Source commit already contains its own candidate manifest.'}
        }
        $sourceRecords=@(Get-BCProjectOSGitPayloadRecords -Root $root -Revision $sourceCommit -Scope $scope -IncludeMode:$modeBound);$payloadPaths=@($sourceRecords|ForEach-Object path)
        $headRecords=@(Get-BCProjectOSGitPayloadRecords -Root $root -Revision $head -Scope $scope -IncludeMode:$modeBound)
        if((Get-BCProjectOSChecksumsText $headRecords -IncludeMode:$modeBound)-ne(Get-BCProjectOSChecksumsText $sourceRecords -IncludeMode:$modeBound)){Add-Finding 'PAYLOAD_CHANGED_AFTER_SOURCE_COMMIT' 'Product payload bytes or Git modes changed after the bound source commit.'}
    }
}

if($sourceResolved){
    $expected=Get-BCProjectOSChecksumsText $sourceRecords -IncludeMode:$modeBound;$stored=([IO.File]::ReadAllText($checksumsPath)-replace"`r`n","`n")
    if($stored-ne$expected){Add-Finding 'RELEASE_CHECKSUM_MISMATCH' 'Stored checksums differ from bound source Git blobs.'}
    $digest=Get-BCProjectOSTextSha256 $expected
    if([string]$manifest.payload.bundle_digest-ne$digest){Add-Finding 'RELEASE_BUNDLE_DIGEST_MISMATCH' 'Manifest digest differs from bound source payload.'}
    if([int]$manifest.payload.file_count-ne$sourceRecords.Count){Add-Finding 'RELEASE_FILE_COUNT_MISMATCH' 'Manifest file count differs from bound source payload.'}
    $listed=@($manifest.payload.files);if($listed.Count-ne$sourceRecords.Count){Add-Finding 'RELEASE_FILE_LIST_MISMATCH' 'Manifest file list count differs.'}else{for($i=0;$i-lt$sourceRecords.Count;$i++){if($modeBound-and($listed[$i].PSObject.Properties.Name-notcontains'mode'-or[string]$listed[$i].mode-notmatch'^100(644|755)$')){Add-Finding 'RELEASE_FILE_MODE_INVALID' "Manifest mode is missing or invalid at index $i.";break};if($modeBound-and[string]$listed[$i].mode-ne[string]$sourceRecords[$i].mode){Add-Finding 'RELEASE_FILE_MODE_MISMATCH' "Manifest Git mode differs at index $i.";break};if([string]$listed[$i].path-ne[string]$sourceRecords[$i].path-or[string]$listed[$i].sha256-ne[string]$sourceRecords[$i].sha256-or[int64]$listed[$i].size_bytes-ne[int64]$sourceRecords[$i].size_bytes){Add-Finding 'RELEASE_FILE_LIST_MISMATCH' "Manifest record differs at index $i.";break}}}
    $payloadStatus=@(& git -C $root status --porcelain --untracked-files=all -- @payloadPaths 2>$null);if($payloadStatus.Count){Add-Finding 'PAYLOAD_NOT_COMMITTED' 'Product payload differs from HEAD.'}
}

if(-not$SkipProductContract){$product=@(& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'automation\Test-ProductContract.ps1') 2>&1);if($LASTEXITCODE-ne0){Add-Finding 'PRODUCT_CONTRACT_FAILED' ($product-join' ')}}
$tagName="spectra-v$Version";& git -C $root show-ref --verify --quiet "refs/tags/$tagName";$tagExists=$LASTEXITCODE-eq0
if(-not$tagExists){Add-Pending 'RELEASE_TAG_MISSING' "Annotated release tag is missing: $tagName"}else{
    $tagType=(& git -C $root cat-file -t "refs/tags/$tagName" 2>$null|Select-Object -First 1);if($tagType-ne'tag'){Add-Finding 'RELEASE_TAG_NOT_ANNOTATED' 'Release tag is not annotated.'}
    $tagCommit=(& git -C $root rev-parse "refs/tags/$tagName`^{commit}").Trim();foreach($meta in @("release/versions/$Version/release-manifest.json","release/versions/$Version/checksums.sha256")){& git -C $root cat-file -e "$tagCommit`:$meta" 2>$null;if($LASTEXITCODE-ne0){Add-Finding 'RELEASE_METADATA_NOT_TAGGED' "Tag lacks $meta."}}
    if($sourceResolved){& git -C $root merge-base --is-ancestor $sourceCommit $tagCommit 2>$null;if($LASTEXITCODE-ne0){Add-Finding 'SOURCE_COMMIT_NOT_IN_RELEASE' 'Source commit is not an ancestor of tag commit.'};$tagRecords=@(Get-BCProjectOSGitPayloadRecords -Root $root -Revision $tagCommit -Scope $scope -IncludeMode:$modeBound);if((Get-BCProjectOSChecksumsText $tagRecords -IncludeMode:$modeBound)-ne(Get-BCProjectOSChecksumsText $sourceRecords -IncludeMode:$modeBound)){Add-Finding 'PAYLOAD_CHANGED_AFTER_SOURCE_COMMIT' 'Tagged payload bytes or Git modes differ from source payload.'}}
}
if($RequirePublished-and$state-ne'final'){Add-Finding 'RELEASE_MANIFEST_NOT_FINAL' 'Published validation requires final manifest.'}
if($findings.Count){Write-Host 'BLOCKED: BCProjectOS release candidate validation failed.';foreach($f in $findings){Write-Host "- [$($f.code)] $($f.message)"};exit 1}
Write-Host "PASS: BCProjectOS $Version bound payload and product contract are valid.";Write-Host "Bundle digest: $($manifest.payload.bundle_digest)"
if($pending.Count){Write-Host 'PENDING: Content is source-bound, but publication is not complete.';foreach($p in $pending){Write-Host "- [$($p.code)] $($p.message)"}}else{Write-Host "PASS: Annotated tag $tagName, commit binding and digest are valid."}
