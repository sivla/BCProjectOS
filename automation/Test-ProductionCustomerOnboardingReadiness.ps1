$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$fixtures=Join-Path $root 'examples/production-onboarding'
$temp=Join-Path ([IO.Path]::GetTempPath()) ('spectra-readiness-'+[guid]::NewGuid().ToString('N'))
New-Item $temp -ItemType Directory|Out-Null
try{
  $passed=0
  foreach($profile in @('implementation','support-only','fit-gap','migration')){
    $input=Join-Path $fixtures ($profile+'.json');$a=Join-Path $temp ($profile+'-a.json');$b=Join-Path $temp ($profile+'-b.json')
    & (Join-Path $PSScriptRoot 'Invoke-ProductionCustomerOnboardingReadiness.ps1') -Command preflight -InputPath $input -ProductRoot $root|Out-Null
    & (Join-Path $PSScriptRoot 'Invoke-ProductionCustomerOnboardingReadiness.ps1') -Command plan -InputPath $input -OutputPath $a -ProductRoot $root|Out-Null
    $firstWrite=(Get-Item $a).LastWriteTimeUtc
    Start-Sleep -Milliseconds 20
    $repeat=& (Join-Path $PSScriptRoot 'Invoke-ProductionCustomerOnboardingReadiness.ps1') -Command plan -InputPath $input -OutputPath $a -ProductRoot $root|ConvertFrom-Json
    if($repeat.writes_performed -or (Get-Item $a).LastWriteTimeUtc-ne$firstWrite){throw 'READINESS_PLAN_IDEMPOTENCE_FAILED'}
    & (Join-Path $PSScriptRoot 'Invoke-ProductionCustomerOnboardingReadiness.ps1') -Command plan -InputPath $input -OutputPath $b -ProductRoot $root|Out-Null
    $ha=(Get-FileHash $a -Algorithm SHA256).Hash;$hb=(Get-FileHash $b -Algorithm SHA256).Hash;if($ha-ne$hb){throw 'READINESS_PLAN_NONDETERMINISTIC'}
    & (Join-Path $PSScriptRoot 'Invoke-ProductionCustomerOnboardingReadiness.ps1') -Command validate -InputPath $input -ProductRoot $root|Out-Null
    $passed++
  }
  & (Join-Path $PSScriptRoot 'Test-ProductionReadinessEvidence.ps1') -ProductRoot $root
  $passed++
  Write-Host "PASS: $passed Readiness-Positivgruppen."
}finally{Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue}
