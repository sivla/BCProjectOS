[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$temp = Join-Path ([IO.Path]::GetTempPath()) ('spectra-adoption-positive-' + [guid]::NewGuid().ToString('N'))
$commit = (git -C $root rev-parse HEAD).Trim()
$tree = (git -C $root rev-parse 'HEAD^{tree}').Trim()
$productDigest = 'c' * 64
. (Join-Path $PSScriptRoot 'ExistingProject.Adoption.ps1')

function Assert-Equal([object]$Actual, [object]$Expected, [string]$Code) {
  if ([string]$Actual -cne [string]$Expected) { throw $Code }
}

function Get-FixtureHashes([string]$Path) {
  @(
    Get-ChildItem -LiteralPath $Path -File -Recurse |
      Sort-Object FullName |
      ForEach-Object { '{0}:{1}' -f $_.Name,(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash }
  ) -join '|'
}

try {
  New-Item -ItemType Directory -Path $temp | Out-Null
  $profiles = @('implementation','support-only')
  $passed = 0
  foreach ($profile in $profiles) {
    $fixtureA = Join-Path $temp "$profile-a"
    $fixtureB = Join-Path $temp "$profile-b"
    & (Join-Path $PSScriptRoot 'New-SyntheticExistingProjectAdoption.ps1') -Destination $fixtureA -Profile $profile -ProductCommit $commit -ProductTree $tree -ProductDigest $productDigest | Out-Null
    & (Join-Path $PSScriptRoot 'New-SyntheticExistingProjectAdoption.ps1') -Destination $fixtureB -Profile $profile -ProductCommit $commit -ProductTree $tree -ProductDigest $productDigest | Out-Null
    Assert-Equal (Get-FixtureHashes $fixtureA) (Get-FixtureHashes $fixtureB) "ADOPTION_FIXTURE_NOT_DETERMINISTIC:$profile"
    $passed++

    $discoveryPath = Join-Path $fixtureA 'discovery.json'
    $configPath = Join-Path $fixtureA 'config.json'
    $discovery = Read-AdoptionJson $discoveryPath
    $config = Read-AdoptionJson $configPath
    $inspection = Get-ExistingProjectInspection -DiscoveryPath $discoveryPath
    Assert-Equal $inspection.writes_performed $false "ADOPTION_INSPECT_WROTE:$profile"
    Test-ExistingProjectAdoptionConfig -Config $config -Discovery $discovery -DiscoveryPath $discoveryPath | Out-Null
    $passed++

    $cliInspection = (& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Invoke-ExistingProjectAdoption.ps1') -Command inspect -DiscoveryPath $discoveryPath | Out-String) | ConvertFrom-Json
    Assert-Equal $cliInspection.discovery_id $discovery.discovery_id "ADOPTION_CLI_INSPECTION_INVALID:$profile"
    Assert-Equal $cliInspection.writes_performed $false "ADOPTION_CLI_INSPECTION_WROTE:$profile"
    $passed++

    if ($profile -eq 'support-only') {
      if ($null -ne $discovery.jira.project -or $null -ne $config.jira_binding.project_id -or $null -ne $config.workspace.project_id) { throw 'ADOPTION_SUPPORT_PROJECT_INVENTED' }
    } elseif ($null -eq $discovery.jira.project -or [string]::IsNullOrWhiteSpace([string]$config.workspace.project_id)) { throw 'ADOPTION_IMPLEMENTATION_PROJECT_MISSING' }
    $passed++

    $planA = New-ExistingProjectAdoptionPlan -Config $config -Discovery $discovery -DiscoveryPath $discoveryPath
    $planB = New-ExistingProjectAdoptionPlan -Config (Read-AdoptionJson (Join-Path $fixtureB 'config.json')) -Discovery (Read-AdoptionJson (Join-Path $fixtureB 'discovery.json')) -DiscoveryPath (Join-Path $fixtureB 'discovery.json')
    Assert-Equal $planA.plan_digest $planB.plan_digest "ADOPTION_PLAN_NOT_DETERMINISTIC:$profile"
    if (@($planA.operations | Where-Object remote_action -ne 'none').Count -ne 0 -or $planA.remote_mutation_allowed) { throw "ADOPTION_PLAN_REMOTE_WRITE:$profile" }
    $passed++

    $workspace = Join-Path $temp "$profile-workspace"
    $apply = Invoke-ExistingProjectAdoptionApply -Config $config -Discovery $discovery -Plan $planA -DiscoveryPath $discoveryPath -Destination $workspace -ExpectedPlanDigest $planA.plan_digest -Approve
    Assert-Equal $apply.status 'APPLIED' "ADOPTION_APPLY_FAILED:$profile"
    Test-ExistingProjectAdoptionWorkspace -Path $workspace | Out-Null
    $passed++

    $repeat = Invoke-ExistingProjectAdoptionApply -Config $config -Discovery $discovery -Plan $planA -DiscoveryPath $discoveryPath -Destination $workspace -ExpectedPlanDigest $planA.plan_digest -Approve
    Assert-Equal $repeat.status 'ALREADY_APPLIED' "ADOPTION_REPEAT_STATUS_INVALID:$profile"
    Assert-Equal $repeat.writes_performed $false "ADOPTION_REPEAT_WROTE:$profile"
    $passed++

    $backup = Join-Path $temp "$profile-backup"
    $restored = Join-Path $temp "$profile-restored"
    & (Join-Path $PSScriptRoot 'Backup-Workspace.ps1') -Source $workspace -Destination $backup | Out-Null
    & (Join-Path $PSScriptRoot 'Restore-Workspace.ps1') -Backup $backup -Destination $restored | Out-Null
    Test-ExistingProjectAdoptionWorkspace -Path $restored | Out-Null
    Assert-Equal (Get-AdoptionFileDigest (Join-Path $workspace 'workspace.json')) (Get-AdoptionFileDigest (Join-Path $restored 'workspace.json')) "ADOPTION_RESTORE_CHANGED_WORKSPACE:$profile"
    $passed++
  }
  if ($passed -ne 16) { throw 'ADOPTION_POSITIVE_TEST_COUNT_INVALID' }
  Write-Host "PASS: $passed Existing-Project-Adoption-Positiv-, Determinismus-, Idempotenz- und Backup/Restore-Pruefungen fuer zwei Profile."
} finally {
  if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue }
}
