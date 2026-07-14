$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'));$base=Get-Content (Join-Path $root 'examples/production-onboarding/implementation.json') -Raw|ConvertFrom-Json
$cases=@(
  @{code='READINESS_PROFILE_UNKNOWN';m={param($x)$x.project_type='unknown'}},
  @{code='READINESS_DUPLICATE_ID';m={param($x)$x.project_id=$x.workspace_id}},
  @{code='READINESS_ABSOLUTE_PATH_FORBIDDEN';m={param($x)$x.product_binding.manifest_path='C:\runtime\manifest.json'}},
  @{code='READINESS_SECRET_VALUE_FORBIDDEN';m={param($x)$x.data_boundary.secret_references=@('not-a-runtime-reference')}},
  @{code='READINESS_RELEASE_EVIDENCE_MISSING';m={param($x)$x.product_binding.manifest_path='release/versions/missing/release-manifest.json'}},
  @{code='READINESS_CROSS_CUSTOMER_REFERENCE';m={param($x)$x.predecessor=[pscustomobject]@{customer_id='CUS-OTHER';project_id='PRJ-OLD'}}},
  @{code='READINESS_LIVE_APPLY_FORBIDDEN';m={param($x)$x.atlassian.live_apply=$true}},
  @{code='READINESS_SCHEMA_INVALID';m={param($x)$x.data_boundary.external_file_intake='direct-mutation'}}
)
$temp=Join-Path ([IO.Path]::GetTempPath()) ('spectra-readiness-neg-'+[guid]::NewGuid().ToString('N'));New-Item $temp -ItemType Directory|Out-Null
try{
  $passed=0
  foreach($case in $cases){$x=($base|ConvertTo-Json -Depth 20|ConvertFrom-Json);&$case.m $x;$path=Join-Path $temp ($passed.ToString()+'.json');$x|ConvertTo-Json -Depth 20|Set-Content $path -Encoding utf8;try{& (Join-Path $PSScriptRoot 'Invoke-ProductionCustomerOnboardingReadiness.ps1') -Command validate -InputPath $path -ProductRoot $root|Out-Null;throw 'NEGATIVE_ACCEPTED'}catch{if($_.Exception.Message.Split([Environment]::NewLine)[0]-cne$case.code){throw "NEGATIVE_WRONG_CODE:$($case.code):$($_.Exception.Message)"}};$passed++}
  $evidence=Get-Content (Join-Path $root 'release/production-readiness.json') -Raw|ConvertFrom-Json
  $evidence.assessments.customerGoLiveReady.status='passed';$evidence.assessments.customerGoLiveReady.evidenceMode='commit-bound'
  $evidencePath=Join-Path $temp 'invalid-evidence.json';$evidence|ConvertTo-Json -Depth 20|Set-Content $evidencePath -Encoding utf8
  try{& (Join-Path $PSScriptRoot 'Test-ProductionReadinessEvidence.ps1') -Path $evidencePath -ProductRoot $root;throw 'NEGATIVE_ACCEPTED'}catch{if($_.Exception.Message.Split([Environment]::NewLine)[0]-cne'READINESS_CUSTOMER_GOLIVE_FORBIDDEN'){throw "NEGATIVE_WRONG_CODE:READINESS_CUSTOMER_GOLIVE_FORBIDDEN:$($_.Exception.Message)"}};$passed++
  $distribution=Get-Content (Join-Path $root 'release/production-readiness.json') -Raw|ConvertFrom-Json;$distribution.distribution.status='public'
  $distributionPath=Join-Path $temp 'invalid-distribution.json';$distribution|ConvertTo-Json -Depth 20|Set-Content $distributionPath -Encoding utf8
  try{& (Join-Path $PSScriptRoot 'Test-ProductionReadinessEvidence.ps1') -Path $distributionPath -ProductRoot $root;throw 'NEGATIVE_ACCEPTED'}catch{if($_.Exception.Message.Split([Environment]::NewLine)[0]-cne'READINESS_DISTRIBUTION_LICENSE_REQUIRED'){throw "NEGATIVE_WRONG_CODE:READINESS_DISTRIBUTION_LICENSE_REQUIRED:$($_.Exception.Message)"}};$passed++
  Write-Host "PASS: $passed isolierte Readiness-Negativfaelle."
}finally{Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue}
