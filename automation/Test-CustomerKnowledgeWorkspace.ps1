[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$Path)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$root = [IO.Path]::GetFullPath($Path)
if (-not (Test-Path -LiteralPath $root -PathType Container)) { throw 'FOUNDATION_WORKSPACE_MISSING' }
$foundationPath = Join-Path $root 'customer-workspace-foundation.json'
$inboxPath = Join-Path $root 'knowledge-inbox.json'
$informationInboxPath = Join-Path $root 'information-inbox.json'
if (-not (Test-Path -LiteralPath $foundationPath -PathType Leaf)) { throw 'FOUNDATION_FILE_MISSING' }
if (-not (Test-Path -LiteralPath $inboxPath -PathType Leaf)) { throw 'INBOX_FILE_MISSING' }
$beforeFoundation = (Get-FileHash -LiteralPath $foundationPath -Algorithm SHA256).Hash
$beforeInbox = (Get-FileHash -LiteralPath $inboxPath -Algorithm SHA256).Hash
$beforeInformationInbox = if (Test-Path -LiteralPath $informationInboxPath -PathType Leaf) { (Get-FileHash -LiteralPath $informationInboxPath -Algorithm SHA256).Hash } else { $null }
$foundation = Get-Content -LiteralPath $foundationPath -Raw | ConvertFrom-Json
$inbox = Get-Content -LiteralPath $inboxPath -Raw | ConvertFrom-Json
. (Join-Path $PSScriptRoot 'Spectra.JsonSchema.ps1')
$foundationSchema = Get-Content -LiteralPath (Join-Path $PSScriptRoot '..\schemas\customer-workspace-foundation.schema.json') -Raw | ConvertFrom-Json
$inboxSchema = Get-Content -LiteralPath (Join-Path $PSScriptRoot '..\schemas\knowledge-inbox.schema.json') -Raw | ConvertFrom-Json
try { Test-SpectraJsonSchema -Value $foundation -Schema $foundationSchema -RootSchema $foundationSchema -Path root }
catch { throw 'FOUNDATION_SCHEMA_INVALID' }
try { Test-SpectraJsonSchema -Value $inbox -Schema $inboxSchema -RootSchema $inboxSchema -Path root }
catch { throw 'INBOX_SCHEMA_INVALID' }

$customerId = [string]$foundation.customer.id
$records = @($foundation.customer) + @($foundation.environments) + @($foundation.companies) + @($foundation.projects) + @($foundation.support_cases) + @($foundation.people) + @($foundation.role_assignments) + @($foundation.knowledge_items) + @($foundation.budgets) + @($foundation.commitments)
$ids = @($records | ForEach-Object { [string]$_.id })
if (@($ids | Group-Object | Where-Object Count -gt 1).Count -gt 0) { throw 'FOUNDATION_ID_DUPLICATE' }
foreach ($record in @($records | Where-Object { $_.PSObject.Properties['customer_id'] })) {
  if ([string]$record.customer_id -cne $customerId) { throw 'FOUNDATION_CUSTOMER_BOUNDARY' }
}
$environmentIds = @($foundation.environments.id)
$companyIds = @($foundation.companies.id)
$projectIds = @($foundation.projects | ForEach-Object { [string]$_.id })
$supportIds = @($foundation.support_cases.id)
$personIds = @($foundation.people.id)
$roleIds = @($foundation.role_assignments.id)
foreach ($company in @($foundation.companies)) {
  if ($environmentIds -notcontains [string]$company.environment_id) { throw 'FOUNDATION_ENVIRONMENT_REFERENCE' }
}
foreach ($project in @($foundation.projects)) {
  foreach ($companyId in @($project.company_ids)) { if ($companyIds -notcontains [string]$companyId) { throw 'FOUNDATION_COMPANY_REFERENCE' } }
}
foreach ($case in @($foundation.support_cases)) {
  if ($environmentIds -notcontains [string]$case.environment_id) { throw 'FOUNDATION_ENVIRONMENT_REFERENCE' }
  if ($null -ne $case.company_id -and $companyIds -notcontains [string]$case.company_id) { throw 'FOUNDATION_COMPANY_REFERENCE' }
  if ($null -ne $case.project_id -and $projectIds -notcontains [string]$case.project_id) { throw 'FOUNDATION_PROJECT_REFERENCE' }
}
if ([string]$foundation.profile -eq 'support-only' -and @($foundation.projects).Count -ne 0) { throw 'FOUNDATION_SUPPORT_PROJECT_UNEXPECTED' }
if ([string]$foundation.profile -eq 'implementation' -and @($foundation.projects).Count -eq 0) { throw 'FOUNDATION_IMPLEMENTATION_PROJECT_MISSING' }

function Test-Scope([string]$Type, [string]$Id) {
  switch ($Type) {
    'customer' { return $Id -ceq $customerId }
    'environment' { return $environmentIds -contains $Id }
    'company' { return $companyIds -contains $Id }
    'project' { return $projectIds -contains $Id }
    'support' { return $supportIds -contains $Id }
    default { return $false }
  }
}
foreach ($person in @($foundation.people)) {
  if ([string]$person.identity_source -cne 'customer-workspace') { throw 'FOUNDATION_PERSON_SOURCE_INVALID' }
}
foreach ($role in @($foundation.role_assignments)) {
  if (-not (Test-Scope ([string]$role.scope_type) ([string]$role.scope_id))) { throw 'FOUNDATION_ROLE_SCOPE_INVALID' }
  if ([string]$role.occupant_status -eq 'assigned') {
    if ($personIds -notcontains [string]$role.person_id) { throw 'FOUNDATION_ROLE_PERSON_INVALID' }
  } elseif ($null -ne $role.person_id) {
    throw 'FOUNDATION_UNASSIGNED_ROLE_HAS_PERSON'
  }
}
foreach ($record in @($foundation.knowledge_items) + @($foundation.budgets) + @($foundation.commitments)) {
  if (-not (Test-Scope ([string]$record.scope_type) ([string]$record.scope_id))) { throw 'FOUNDATION_SCOPE_REFERENCE' }
}

$relationIds = @($foundation.relations.id)
if (@($relationIds | Group-Object | Where-Object Count -gt 1).Count -gt 0) { throw 'FOUNDATION_RELATION_DUPLICATE' }
$inverseTypes = @{
  'customer-environment'='environment-customer';'environment-customer'='customer-environment'
  'environment-company'='company-environment';'company-environment'='environment-company'
  'customer-project'='project-customer';'project-customer'='customer-project'
  'customer-support'='support-customer';'support-customer'='customer-support'
  'company-project'='project-company';'project-company'='company-project'
}
foreach ($relation in @($foundation.relations)) {
  if ($ids -notcontains [string]$relation.from_id -or $ids -notcontains [string]$relation.to_id) { throw 'FOUNDATION_RELATION_ENDPOINT_UNKNOWN' }
  $inverse = @($foundation.relations | Where-Object { [string]$_.id -ceq [string]$relation.inverse_relation_id })
  if ($inverse.Count -ne 1) { throw 'FOUNDATION_RELATION_INVERSE_MISSING' }
  if ([string]$inverse[0].from_id -cne [string]$relation.to_id -or [string]$inverse[0].to_id -cne [string]$relation.from_id -or [string]$inverse[0].type -cne [string]$inverseTypes[[string]$relation.type]) { throw 'FOUNDATION_RELATION_INVERSE_INVALID' }
}

$foundationDigest = (Get-FileHash -LiteralPath $foundationPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ([string]$inbox.customer_id -cne $customerId) { throw 'INBOX_CUSTOMER_BOUNDARY' }
if ([string]$inbox.foundation_digest -cne $foundationDigest) { throw 'INBOX_FOUNDATION_DIGEST_MISMATCH' }
if ($inbox.writes_performed -ne $false -or $inbox.target_mutation -ne $false) { throw 'INBOX_AUTOMATIC_WRITE_FORBIDDEN' }

$intakeIds = @($inbox.intake_items.id)
$sourceKeys = @()
foreach ($item in @($inbox.intake_items)) {
  if ([string]$item.customer_id -cne $customerId) { throw 'INBOX_CUSTOMER_BOUNDARY' }
  $key = "$([string]$item.source_system)|$([string]$item.source_object_id)|$([string]$item.source_revision)"
  if ($sourceKeys -contains $key) { throw 'INBOX_SOURCE_REVISION_DUPLICATE' }
  $sourceKeys += $key
  $relative = [string]$item.source_path
  if ([IO.Path]::IsPathRooted($relative) -or $relative -match '(^|[\/])\.\.([\/]|$)|\\') { throw 'INBOX_SOURCE_PATH_UNSAFE' }
  $sourcePath = Join-Path $root ($relative -replace '/', '\')
  if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { throw 'INBOX_SOURCE_MISSING' }
  $actualHash = (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($actualHash -cne [string]$item.sha256 -or (Get-Item -LiteralPath $sourcePath).Length -ne [int64]$item.size_bytes) { throw 'INBOX_SOURCE_HASH_MISMATCH' }
  if ([string]$item.source_hash_after -cne [string]$item.sha256) { throw 'INBOX_SOURCE_CHANGED' }
}

$observationIds = @($inbox.observations.id)
foreach ($observation in @($inbox.observations)) {
  if ($intakeIds -notcontains [string]$observation.intake_id) { throw 'INBOX_INTAKE_REFERENCE' }
  $item = @($inbox.intake_items | Where-Object { [string]$_.id -ceq [string]$observation.intake_id })[0]
  if ([string]$observation.source_revision -cne [string]$item.source_revision) { throw 'INBOX_OBSERVATION_REVISION_MISMATCH' }
  if (-not (Test-Scope ([string]$observation.scope_type) ([string]$observation.scope_id))) { throw 'INBOX_SCOPE_REFERENCE' }
}
foreach ($meeting in @($inbox.meeting_packages)) {
  foreach ($id in @($meeting.intake_ids)) { if ($intakeIds -notcontains [string]$id) { throw 'INBOX_INTAKE_REFERENCE' } }
  foreach ($id in @($meeting.observation_ids)) { if ($observationIds -notcontains [string]$id) { throw 'INBOX_OBSERVATION_REFERENCE' } }
}

$comparisonIds = @($inbox.comparison_runs.id)
$proposalIds = @($inbox.proposals.id)
foreach ($comparison in @($inbox.comparison_runs)) {
  if ([string]$comparison.foundation_digest -cne $foundationDigest -or $comparison.stale -ne $false) { throw 'INBOX_COMPARISON_STALE' }
  foreach ($id in @($comparison.observation_ids)) { if ($observationIds -notcontains [string]$id) { throw 'INBOX_OBSERVATION_REFERENCE' } }
  foreach ($id in @($comparison.proposal_ids)) { if ($proposalIds -notcontains [string]$id) { throw 'INBOX_PROPOSAL_REFERENCE' } }
}
foreach ($proposal in @($inbox.proposals)) {
  if ($comparisonIds -notcontains [string]$proposal.comparison_id) { throw 'INBOX_COMPARISON_REFERENCE' }
  if ([string]$proposal.expected_foundation_digest -cne $foundationDigest) { throw 'INBOX_PROPOSAL_STALE' }
  foreach ($id in @($proposal.observation_ids)) { if ($observationIds -notcontains [string]$id) { throw 'INBOX_OBSERVATION_REFERENCE' } }
  if (-not (Test-Scope ([string]$proposal.target_type) ([string]$proposal.target_id)) -and [string]$proposal.target_type -notin @('knowledge','budget','commitment')) { throw 'INBOX_TARGET_REFERENCE' }
  if ([string]$proposal.target_type -eq 'knowledge' -and @($foundation.knowledge_items.id) -notcontains [string]$proposal.target_id) { throw 'INBOX_TARGET_REFERENCE' }
  if ([string]$proposal.target_type -eq 'budget' -and @($foundation.budgets.id) -notcontains [string]$proposal.target_id) { throw 'INBOX_TARGET_REFERENCE' }
  if ([string]$proposal.target_type -eq 'commitment' -and @($foundation.commitments.id) -notcontains [string]$proposal.target_id) { throw 'INBOX_TARGET_REFERENCE' }
  if ($proposal.writes_performed -ne $false) { throw 'INBOX_AUTOMATIC_WRITE_FORBIDDEN' }
}
foreach ($decision in @($inbox.review_decisions)) {
  if ($proposalIds -notcontains [string]$decision.proposal_id) { throw 'INBOX_REVIEW_REFERENCE' }
  if ($null -ne $decision.execution_plan_id -or $decision.writes_performed -ne $false) { throw 'INBOX_AUTOMATIC_WRITE_FORBIDDEN' }
  if ($roleIds -notcontains [string]$decision.acting_role_id) { throw 'INBOX_ACTING_ROLE_UNKNOWN' }
  $role = @($foundation.role_assignments | Where-Object { [string]$_.id -ceq [string]$decision.acting_role_id })[0]
  if ([string]$decision.actor_type -eq 'human') {
    if ($personIds -notcontains [string]$decision.person_id -or [string]$role.person_id -cne [string]$decision.person_id) { throw 'INBOX_HUMAN_ACTOR_UNBOUND' }
  } else {
    if ($null -ne $decision.person_id) { throw 'INBOX_AUTOMATION_PERSON_FORBIDDEN' }
    if ([string]$decision.decision -in @('accepted', 'rejected')) { throw 'INBOX_AUTOMATION_DECISION_FORBIDDEN' }
  }
  if ([string]$decision.decision -in @('accepted', 'rejected') -and @($role.permissions) -notcontains 'internal-decision') { throw 'INBOX_ROLE_PERMISSION_MISSING' }
}
foreach ($proposal in @($inbox.proposals | Where-Object { [string]$_.status -eq 'accepted' })) {
  $accepted = @($inbox.review_decisions | Where-Object { [string]$_.proposal_id -ceq [string]$proposal.id -and [string]$_.decision -eq 'accepted' })
  if ($accepted.Count -ne 1) { throw 'INBOX_ACCEPTED_DECISION_MISSING' }
}
foreach ($conflict in @($inbox.conflicts)) {
  foreach ($id in @($conflict.proposal_ids)) { if ($proposalIds -notcontains [string]$id) { throw 'INBOX_PROPOSAL_REFERENCE' } }
  if ([string]$conflict.status -eq 'open') {
    foreach ($id in @($conflict.proposal_ids)) {
      $proposal = @($inbox.proposals | Where-Object { [string]$_.id -ceq [string]$id })[0]
      if ([string]$proposal.status -ne 'conflicted') { throw 'INBOX_CONFLICT_UNRESOLVED' }
    }
  }
}

if (Test-Path -LiteralPath $informationInboxPath -PathType Leaf) {
  & (Join-Path $PSScriptRoot 'Test-InformationInbox.ps1') -Path $root *> $null
  $informationInbox = Get-Content -LiteralPath $informationInboxPath -Raw | ConvertFrom-Json
  . (Join-Path $PSScriptRoot 'Inbox.Compatibility.ps1')
  [void](Test-SpectraInboxCompatibility -Foundation $foundation -LegacyInbox $inbox -InformationInbox $informationInbox)
}

$scan = (Get-Content -LiteralPath $foundationPath -Raw) + (Get-Content -LiteralPath $inboxPath -Raw)
foreach ($item in @($inbox.intake_items)) { $scan += Get-Content -LiteralPath (Join-Path $root ([string]$item.source_path -replace '/', '\')) -Raw }
if ($scan -match '(?i)(universaarl|uabc|credential_marker|tenant_marker|client[_-]?secret|access[_-]?token|password\s*[:=])') { throw 'FOUNDATION_CUSTOMER_OR_SECRET_MARKER' }
if ((Get-FileHash -LiteralPath $foundationPath -Algorithm SHA256).Hash -cne $beforeFoundation -or (Get-FileHash -LiteralPath $inboxPath -Algorithm SHA256).Hash -cne $beforeInbox) { throw 'FOUNDATION_VALIDATOR_MUTATED_SOURCE' }
if ($null -ne $beforeInformationInbox -and (Get-FileHash -LiteralPath $informationInboxPath -Algorithm SHA256).Hash -cne $beforeInformationInbox) { throw 'FOUNDATION_VALIDATOR_MUTATED_SOURCE' }
Write-Host 'PASS: Kundenworkspace, Supportkontext und Knowledge Inbox sind referenziell, proposal-only und read-only valide.'
