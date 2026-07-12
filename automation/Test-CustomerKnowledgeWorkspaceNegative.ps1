[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$temp = Join-Path $env:TEMP ('spectra-foundation-negative-' + [guid]::NewGuid().ToString('N'))
$utf8 = [Text.UTF8Encoding]::new($false)

function Write-Json([string]$Path, $Value) { [IO.File]::WriteAllText($Path, (($Value | ConvertTo-Json -Depth 30) + "`n"), $utf8) }
function Invoke-Exact([string]$Workspace) {
  $start = [Diagnostics.ProcessStartInfo]::new()
  $start.FileName = 'powershell.exe'
  $start.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Run-CustomerKnowledgeWorkspaceExact.ps1`" -Path `"$Workspace`""
  $start.UseShellExecute = $false
  $start.RedirectStandardOutput = $true
  $start.RedirectStandardError = $true
  $process = [Diagnostics.Process]::Start($start)
  $stdout = $process.StandardOutput.ReadToEnd().Trim()
  $stderr = $process.StandardError.ReadToEnd().Trim()
  $process.WaitForExit()
  [pscustomobject]@{Exit=$process.ExitCode;Raw=$stdout;Err=$stderr}
}

$cases = @(
  @{name='foreign-customer';code='FOUNDATION_CUSTOMER_BOUNDARY';m={param($f,$i)$f.environments[0].customer_id='CUS-OTHER-001'}},
  @{name='unknown-environment';code='FOUNDATION_ENVIRONMENT_REFERENCE';m={param($f,$i)$f.companies[0].environment_id='ENV-OTHER-001'}},
  @{name='unknown-company';code='FOUNDATION_COMPANY_REFERENCE';m={param($f,$i)$f.projects[0].company_ids=@('CMP-OTHER-001')}},
  @{name='unknown-project';code='FOUNDATION_PROJECT_REFERENCE';m={param($f,$i)$f.support_cases[0].project_id='PRJ-OTHER-001'}},
  @{name='implementation-no-project';code='FOUNDATION_IMPLEMENTATION_PROJECT_MISSING';m={param($f,$i)$f.projects=@();$f.support_cases[0].project_id=$null}},
  @{name='unknown-scope';code='FOUNDATION_SCOPE_REFERENCE';m={param($f,$i)$f.knowledge_items[0].scope_id='PRJ-OTHER-002'}},
  @{name='duplicate-id';code='FOUNDATION_ID_DUPLICATE';m={param($f,$i)$copy=($f.knowledge_items[0]|ConvertTo-Json|ConvertFrom-Json);$f.knowledge_items+=,$copy}},
  @{name='relation-endpoint';code='FOUNDATION_RELATION_ENDPOINT_UNKNOWN';m={param($f,$i)$f.relations[0].to_id='ENV-OTHER-003'}},
  @{name='inverse-missing';code='FOUNDATION_RELATION_INVERSE_MISSING';m={param($f,$i)$f.relations=@($f.relations|Where-Object id -ne $f.relations[0].inverse_relation_id)}},
  @{name='role-scope';code='FOUNDATION_ROLE_SCOPE_INVALID';m={param($f,$i)$f.role_assignments[0].scope_id='PRJ-OTHER-004'}},
  @{name='pending-person';code='FOUNDATION_UNASSIGNED_ROLE_HAS_PERSON';m={param($f,$i)$f.role_assignments[1].person_id=$f.people[0].id}},
  @{name='inbox-customer';code='INBOX_CUSTOMER_BOUNDARY';m={param($f,$i)$i.customer_id='CUS-OTHER-005'}},
  @{name='unsafe-path';code='INBOX_SOURCE_PATH_UNSAFE';m={param($f,$i)$i.intake_items[0].source_path='../meeting.txt'}},
  @{name='source-hash';code='INBOX_SOURCE_HASH_MISMATCH';m={param($f,$i)$i.intake_items[0].sha256='0'*64}},
  @{name='source-changed';code='INBOX_SOURCE_CHANGED';m={param($f,$i)$i.intake_items[0].source_hash_after='0'*64}},
  @{name='duplicate-revision';code='INBOX_SOURCE_REVISION_DUPLICATE';m={param($f,$i)$copy=($i.intake_items[0]|ConvertTo-Json|ConvertFrom-Json);$copy.id='INT-SYN-DUPLICATE';$i.intake_items+=,$copy}},
  @{name='unknown-intake';code='INBOX_INTAKE_REFERENCE';m={param($f,$i)$i.observations[0].intake_id='INT-OTHER-001'}},
  @{name='stale-comparison';code='INBOX_COMPARISON_STALE';m={param($f,$i)$i.comparison_runs[0].foundation_digest='0'*64}},
  @{name='stale-proposal';code='INBOX_PROPOSAL_STALE';m={param($f,$i)$i.proposals[0].expected_foundation_digest='0'*64}},
  @{name='unknown-target';code='INBOX_TARGET_REFERENCE';m={param($f,$i)$i.proposals[0].target_id='PRJ-OTHER-006'}},
  @{name='decision-missing';code='INBOX_ACCEPTED_DECISION_MISSING';m={param($f,$i)$i.review_decisions[0].decision='deferred'}},
  @{name='automation-decision';code='INBOX_AUTOMATION_DECISION_FORBIDDEN';m={param($f,$i)$i.review_decisions[0].actor_type='playwright';$i.review_decisions[0].person_id=$null}},
  @{name='role-permission';code='INBOX_ROLE_PERMISSION_MISSING';sync=$true;m={param($f,$i)$f.role_assignments[0].permissions=@('execution')}},
  @{name='automatic-write';code='INBOX_SCHEMA_INVALID';m={param($f,$i)$i.target_mutation=$true}},
  @{name='open-conflict';code='INBOX_CONFLICT_UNRESOLVED';m={param($f,$i)$i.conflicts=@([ordered]@{id='CNF-SYN-001';proposal_ids=@($i.proposals[0].id);reason='Synthetischer Konflikt';status='open'})}},
  @{name='forbidden-marker';code='FOUNDATION_CUSTOMER_OR_SECRET_MARKER';m={param($f,$i)$i.observations[0].summary='credential_marker'}}
)

try {
  New-Item -ItemType Directory -Path $temp | Out-Null
  $index = 0
  foreach ($case in $cases) {
    $index++
    $workspace = Join-Path $temp "case-$index"
    & (Join-Path $PSScriptRoot 'New-SyntheticCustomerKnowledgeWorkspace.ps1') -Destination $workspace -Profile implementation | Out-Null
    $foundationPath = Join-Path $workspace 'customer-workspace-foundation.json'
    $inboxPath = Join-Path $workspace 'knowledge-inbox.json'
    $foundation = Get-Content -LiteralPath $foundationPath -Raw | ConvertFrom-Json
    $inbox = Get-Content -LiteralPath $inboxPath -Raw | ConvertFrom-Json
    & $case.m $foundation $inbox
    Write-Json $foundationPath $foundation
    if ($case.ContainsKey('sync') -and $case.sync) { $inbox.foundation_digest = (Get-FileHash -LiteralPath $foundationPath -Algorithm SHA256).Hash.ToLowerInvariant();$inbox.comparison_runs[0].foundation_digest=$inbox.foundation_digest;$inbox.proposals[0].expected_foundation_digest=$inbox.foundation_digest }
    Write-Json $inboxPath $inbox
    $result = Invoke-Exact $workspace
    if ($result.Exit -ne 1 -or $result.Err -ne '' -or $result.Raw -cne $case.code) { throw "FOUNDATION_NEGATIVE_FAILED:${index}:$($case.name):$($case.code):$($result.Exit):$($result.Raw):$($result.Err)" }
  }
  Write-Host "PASS: $($cases.Count) isolierte Kundenworkspace-/Inbox-Negativfälle."
} finally {
  if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
