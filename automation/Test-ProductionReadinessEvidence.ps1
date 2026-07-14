[CmdletBinding()]param([string]$Path,[string]$ProductRoot,[switch]$RequireCommitBound)
$ErrorActionPreference='Stop'
$root=if($ProductRoot){[IO.Path]::GetFullPath($ProductRoot)}else{[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))}
if(-not$Path){$Path=Join-Path $root 'release/production-readiness.json'}
. (Join-Path $PSScriptRoot 'Spectra.JsonSchema.ps1')
$schema=Get-Content (Join-Path $root 'schemas/component-production-readiness.schema.json') -Raw|ConvertFrom-Json
try{$value=Get-Content $Path -Raw|ConvertFrom-Json}catch{throw 'READINESS_EVIDENCE_SCHEMA_INVALID'}
if($value.assessments.customerGoLiveReady.status-ne'not-applicable' -or $value.assessments.customerGoLiveReady.evidenceMode-ne'none' -or @($value.assessments.customerGoLiveReady.evidence).Count-ne0 -or @($value.assessments.customerGoLiveReady.blockers).Count-ne0){throw 'READINESS_CUSTOMER_GOLIVE_FORBIDDEN'}
try{Test-SpectraJsonSchema -Value $value -Schema $schema -RootSchema $schema -Path root}catch{throw "READINESS_EVIDENCE_SCHEMA_INVALID:$($_.Exception.Message.Split([Environment]::NewLine)[0])"}
$allowed=@{platformReady=@('test-report','operator-guide','release-evidence','security-boundary','platform-matrix');onboardingReady=@('onboarding-runbook','input-contract','profile-proof','recovery-proof','source-register','readiness-validation')}
foreach($name in @('platformReady','onboardingReady')){
  $assessment=$value.assessments.$name
  if($assessment.status-eq'passed' -and ($assessment.evidenceMode-ne'commit-bound' -or @($assessment.evidence).Count-eq0 -or @($assessment.blockers).Count-ne0)){throw 'READINESS_PASSED_EVIDENCE_INVALID'}
  if($assessment.status-in@('pending','failed') -and @($assessment.blockers).Count-eq0){throw 'READINESS_PENDING_BLOCKER_MISSING'}
  foreach($evidence in @($assessment.evidence)){
    if($evidence.kind-notin$allowed[$name]){throw 'READINESS_EVIDENCE_KIND_INVALID'}
    $p=[string]$evidence.path
    if($p-eq'release/production-readiness.json' -or [IO.Path]::IsPathRooted($p) -or $p-match '(^|[\\/])\.\.([\\/]|$)'){throw 'READINESS_EVIDENCE_PATH_UNSAFE'}
    $full=Join-Path $root ($p-replace'/',[IO.Path]::DirectorySeparatorChar)
    if(-not(Test-Path $full -PathType Leaf)){throw 'READINESS_EVIDENCE_PATH_MISSING'}
    if($RequireCommitBound){git -C $root cat-file -e "HEAD:$p" 2>$null;if($LASTEXITCODE-ne0){throw 'READINESS_EVIDENCE_NOT_COMMIT_BOUND'}}
    $ext=[IO.Path]::GetExtension($full).ToLowerInvariant();if($ext-notin@('.md','.json','.yaml','.yml','.ps1')){throw 'READINESS_EVIDENCE_NOT_TEXT'}
  }
}
if($value.distribution.licenseDecision-eq'pending' -and $value.distribution.status-notin@('internal-only','pending')){throw 'READINESS_DISTRIBUTION_LICENSE_REQUIRED'}
Write-Host 'PASS: Commitgebundene Production-Readiness-Evidence ist konsistent.'
