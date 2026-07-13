[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$temp = Join-Path ([IO.Path]::GetTempPath()) ('spectra-adoption-negative-' + [guid]::NewGuid().ToString('N'))
$commit = (git -C $root rev-parse HEAD).Trim()
$tree = (git -C $root rev-parse 'HEAD^{tree}').Trim()
. (Join-Path $PSScriptRoot 'ExistingProject.Adoption.ps1')
$passed = 0

function Copy-JsonValue($Value) { ($Value | ConvertTo-Json -Depth 50 -Compress) | ConvertFrom-Json }
function Assert-Equal([object]$Actual, [object]$Expected, [string]$Code) {
  if ([string]$Actual -cne [string]$Expected) { throw $Code }
}
function Assert-Fails([string]$Expected, [scriptblock]$Action) {
  $failed = $false
  try { & $Action | Out-Null } catch {
    $failed = $true
    if ($_.Exception.Message -notlike "*$Expected*") { throw "ADOPTION_WRONG_FAILURE:${Expected}:$($_.Exception.Message)" }
  }
  if (-not $failed) { throw "ADOPTION_NEGATIVE_ACCEPTED:$Expected" }
  $script:passed++
}

try {
  New-Item -ItemType Directory -Path $temp | Out-Null
  $fixture = Join-Path $temp 'fixture'
  & (Join-Path $PSScriptRoot 'New-SyntheticExistingProjectAdoption.ps1') -Destination $fixture -Profile implementation -ProductCommit $commit -ProductTree $tree -ProductDigest ('d' * 64) | Out-Null
  $discoveryPath = Join-Path $fixture 'discovery.json'
  $discovery = Read-AdoptionJson $discoveryPath
  $config = Read-AdoptionJson (Join-Path $fixture 'config.json')
  $plan = New-ExistingProjectAdoptionPlan -Config $config -Discovery $discovery -DiscoveryPath $discoveryPath

  $bad = Copy-JsonValue $config; Add-Member -InputObject $bad -NotePropertyName token -NotePropertyValue 'synthetic-secret-value'
  Assert-Fails 'ADOPTION_FORBIDDEN_CONTENT' { Test-ExistingProjectAdoptionConfig -Config $bad -Discovery $discovery -DiscoveryPath $discoveryPath }
  $bad = Copy-JsonValue $config; $bad.discovery_binding.relative_path = '../discovery.json'
  Assert-Fails 'ADOPTION_PATH_UNSAFE' { Test-ExistingProjectAdoptionConfig -Config $bad -Discovery $discovery -DiscoveryPath $discoveryPath }
  $bad = Copy-JsonValue $config; $bad.jira_binding.base_url = 'http://jira.example.test'
  Assert-Fails 'ADOPTION_SITE_INVALID' { Test-ExistingProjectAdoptionConfig -Config $bad -Discovery $discovery -DiscoveryPath $discoveryPath }
  $bad = Copy-JsonValue $config; $bad.jira_binding.site_id = 'WRONG-SITE'
  Assert-Fails 'ADOPTION_JIRA_SITE_MISMATCH' { Test-ExistingProjectAdoptionConfig -Config $bad -Discovery $discovery -DiscoveryPath $discoveryPath }
  $bad = Copy-JsonValue $config; $bad.jira_binding.board_id = 'WRONG-BOARD'
  Assert-Fails 'ADOPTION_JIRA_BOARD_MISMATCH' { Test-ExistingProjectAdoptionConfig -Config $bad -Discovery $discovery -DiscoveryPath $discoveryPath }
  $bad = Copy-JsonValue $config; $bad.confluence_bindings[0].space_id = 'UNKNOWN-SPACE'
  Assert-Fails 'ADOPTION_SPACE_BINDING_MISMATCH' { Test-ExistingProjectAdoptionConfig -Config $bad -Discovery $discovery -DiscoveryPath $discoveryPath }
  $bad = Copy-JsonValue $config; $bad.mapping.issue_types[0].source_id = 'UNKNOWN-TYPE'
  Assert-Fails 'ADOPTION_MAPPING_SOURCE_UNKNOWN_ISSUE_TYPES' { Test-ExistingProjectAdoptionConfig -Config $bad -Discovery $discovery -DiscoveryPath $discoveryPath }
  $bad = Copy-JsonValue $config; $bad.mapping.issue_types = @($bad.mapping.issue_types | Select-Object -Skip 1)
  Assert-Fails 'ADOPTION_MAPPING_INCOMPLETE_ISSUE_TYPES' { Test-ExistingProjectAdoptionConfig -Config $bad -Discovery $discovery -DiscoveryPath $discoveryPath }

  $drift = Copy-JsonValue $discovery; $drift.source_revision = 'e' * 64
  Assert-Fails 'ADOPTION_DISCOVERY_DRIFT' { Test-ExistingProjectAdoptionConfig -Config $config -Discovery $drift -DiscoveryPath $discoveryPath }
  $badDiscovery = Copy-JsonValue $discovery; $badDiscovery.jira.board.project_id = 'WRONG-PROJECT'
  Assert-Fails 'ADOPTION_BOARD_PROJECT_MISMATCH' { Test-ExistingProjectDiscovery $badDiscovery }
  $badPlan = Copy-JsonValue $plan; $badPlan.plan_digest = 'f' * 64
  Assert-Fails 'ADOPTION_PLAN_DIGEST_MISMATCH' { Test-ExistingProjectAdoptionPlan -Plan $badPlan -Config $config -Discovery $discovery -DiscoveryPath $discoveryPath }

  $destination = Join-Path $temp 'must-not-exist'
  Assert-Fails 'ADOPTION_APPROVAL_REQUIRED' { Invoke-ExistingProjectAdoptionApply -Config $config -Discovery $discovery -Plan $plan -DiscoveryPath $discoveryPath -Destination $destination -ExpectedPlanDigest $plan.plan_digest }
  if (Test-Path -LiteralPath $destination) { throw 'ADOPTION_REJECTED_APPLY_WROTE' }
  Assert-Fails 'ADOPTION_PLAN_DIGEST_EXPECTED_MISMATCH' { Invoke-ExistingProjectAdoptionApply -Config $config -Discovery $discovery -Plan $plan -DiscoveryPath $discoveryPath -Destination $destination -ExpectedPlanDigest ('0' * 64) -Approve }
  if (Test-Path -LiteralPath $destination) { throw 'ADOPTION_REJECTED_DIGEST_WROTE' }
  Assert-Fails 'ADOPTION_REMOTE_ADAPTER_NOT_CONFIGURED' { Invoke-ExistingProjectAdoptionApply -Config $config -Discovery $discovery -Plan $plan -DiscoveryPath $discoveryPath -Destination $destination -ExpectedPlanDigest $plan.plan_digest -Approve -Remote }
  if (Test-Path -LiteralPath $destination) { throw 'ADOPTION_REJECTED_REMOTE_WROTE' }

  New-Item -ItemType Directory -Path $destination | Out-Null
  [IO.File]::WriteAllText((Join-Path $destination 'foreign.txt'),'preserve',[Text.UTF8Encoding]::new($false))
  Assert-Fails 'ADOPTION_DESTINATION_CONFLICT' { Invoke-ExistingProjectAdoptionApply -Config $config -Discovery $discovery -Plan $plan -DiscoveryPath $discoveryPath -Destination $destination -ExpectedPlanDigest $plan.plan_digest -Approve }
  Assert-Equal ([IO.File]::ReadAllText((Join-Path $destination 'foreign.txt'))) 'preserve' 'ADOPTION_CONFLICT_CHANGED_FOREIGN_FILE'

  if ($passed -ne 15) { throw "ADOPTION_NEGATIVE_TEST_COUNT_INVALID:$passed" }
  Write-Host "PASS: $passed Secret-, Pfad-, Site-, Board-, Space-, Mapping-, Drift-, Remote-write- und Apply-Negativpruefungen."
} finally {
  if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue }
}
