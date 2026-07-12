[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Destination,
  [Parameter(Mandatory = $true)][ValidateSet('implementation', 'support-only')][string]$Profile
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$destinationPath = [IO.Path]::GetFullPath($Destination)
if ($destinationPath -eq [IO.Path]::GetPathRoot($destinationPath)) { throw 'FOUNDATION_DESTINATION_UNSAFE' }
$parent = Split-Path -Parent $destinationPath
if (-not (Test-Path -LiteralPath $parent -PathType Container)) { throw 'FOUNDATION_DESTINATION_PARENT_MISSING' }
if (Test-Path -LiteralPath $destinationPath) { throw 'FOUNDATION_DESTINATION_EXISTS' }
$utf8 = [Text.UTF8Encoding]::new($false)

function Write-Json([string]$Path, $Value) {
  $folder = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $folder)) { New-Item -ItemType Directory -Path $folder -Force | Out-Null }
  [IO.File]::WriteAllText($Path, (($Value | ConvertTo-Json -Depth 30) + "`n"), $utf8)
}
function Write-Text([string]$Path, [string]$Value) {
  $folder = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $folder)) { New-Item -ItemType Directory -Path $folder -Force | Out-Null }
  [IO.File]::WriteAllText($Path, ($Value -replace "`r`n", "`n"), $utf8)
}
function Text-Sha([string]$Text) {
  $sha = [Security.Cryptography.SHA256]::Create()
  try { return ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($Text)))).Replace('-', '').ToLowerInvariant() }
  finally { $sha.Dispose() }
}

$suffix = if ($Profile -eq 'implementation') { 'IMPL' } else { 'SUPPORT' }
$customerId = "CUS-SYN-$suffix"
$environmentId = "ENV-SYN-$suffix"
$companyId = "CMP-SYN-$suffix"
$projectId = "PRJ-SYN-$suffix"
$supportId = "SUP-SYN-$suffix"
$scopeType = if ($Profile -eq 'implementation') { 'project' } else { 'support' }
$scopeId = if ($Profile -eq 'implementation') { $projectId } else { $supportId }
$personId = "PEO-SYN-$suffix"
$ownerRoleId = "ROL-SYN-$suffix-OWNER"

$relations = @(
  [ordered]@{id="REL-$suffix-CUS-ENV";from_id=$customerId;to_id=$environmentId;type='customer-environment';inverse_relation_id="REL-$suffix-ENV-CUS"},
  [ordered]@{id="REL-$suffix-ENV-CUS";from_id=$environmentId;to_id=$customerId;type='environment-customer';inverse_relation_id="REL-$suffix-CUS-ENV"},
  [ordered]@{id="REL-$suffix-ENV-CMP";from_id=$environmentId;to_id=$companyId;type='environment-company';inverse_relation_id="REL-$suffix-CMP-ENV"},
  [ordered]@{id="REL-$suffix-CMP-ENV";from_id=$companyId;to_id=$environmentId;type='company-environment';inverse_relation_id="REL-$suffix-ENV-CMP"},
  [ordered]@{id="REL-$suffix-CUS-SUP";from_id=$customerId;to_id=$supportId;type='customer-support';inverse_relation_id="REL-$suffix-SUP-CUS"},
  [ordered]@{id="REL-$suffix-SUP-CUS";from_id=$supportId;to_id=$customerId;type='support-customer';inverse_relation_id="REL-$suffix-CUS-SUP"}
)
$projects = @()
if ($Profile -eq 'implementation') {
  $projects = @([ordered]@{id=$projectId;customer_id=$customerId;project_type='implementation';status='active';company_ids=@($companyId)})
  $relations += @(
    [ordered]@{id="REL-$suffix-CUS-PRJ";from_id=$customerId;to_id=$projectId;type='customer-project';inverse_relation_id="REL-$suffix-PRJ-CUS"},
    [ordered]@{id="REL-$suffix-PRJ-CUS";from_id=$projectId;to_id=$customerId;type='project-customer';inverse_relation_id="REL-$suffix-CUS-PRJ"},
    [ordered]@{id="REL-$suffix-CMP-PRJ";from_id=$companyId;to_id=$projectId;type='company-project';inverse_relation_id="REL-$suffix-PRJ-CMP"},
    [ordered]@{id="REL-$suffix-PRJ-CMP";from_id=$projectId;to_id=$companyId;type='project-company';inverse_relation_id="REL-$suffix-CMP-PRJ"}
  )
}

$foundation = [ordered]@{
  schema_version=1;product_id='spectra';contract_version='1.0.0';record_type='customer-workspace-foundation';classification='synthetic-fixture';profile=$Profile
  customer=[ordered]@{id=$customerId;name="Synthetischer Kunde $suffix";status='active'}
  environments=@([ordered]@{id=$environmentId;customer_id=$customerId;name="Synthetische Sandbox $suffix";kind='sandbox';status='active'})
  companies=@([ordered]@{id=$companyId;customer_id=$customerId;environment_id=$environmentId;name="Synthetische Gesellschaft $suffix";status='active'})
  projects=$projects
  support_cases=@([ordered]@{id=$supportId;customer_id=$customerId;environment_id=$environmentId;company_id=$companyId;project_id=if($Profile-eq'implementation'){$projectId}else{$null};priority='P3';status='triage';summary='Synthetischer Supportkontext'})
  people=@([ordered]@{id=$personId;customer_id=$customerId;display_name="Synthetische Kundenrolle $suffix";identity_source='customer-workspace';status='active'})
  role_assignments=@(
    [ordered]@{id=$ownerRoleId;customer_id=$customerId;scope_type=$scopeType;scope_id=$scopeId;role_key='project-owner';occupant_status='assigned';person_id=$personId;permissions=@('execution','internal-decision')},
    [ordered]@{id="ROL-SYN-$suffix-UAT";customer_id=$customerId;scope_type='customer';scope_id=$customerId;role_key='customer-uat-approver';occupant_status='pending';person_id=$null;permissions=@('customer-uat-acceptance')},
    [ordered]@{id="ROL-SYN-$suffix-TAX";customer_id=$customerId;scope_type='customer';scope_id=$customerId;role_key='tax-legal-owner';occupant_status='unknown';person_id=$null;permissions=@('tax-legal-confirmation')},
    [ordered]@{id="ROL-SYN-$suffix-SUPPORT";customer_id=$customerId;scope_type='support';scope_id=$supportId;role_key='support-acceptance-owner';occupant_status='pending';person_id=$null;permissions=@('support-acceptance')}
  )
  knowledge_items=@([ordered]@{id="KNO-SYN-$suffix";customer_id=$customerId;scope_type=$scopeType;scope_id=$scopeId;title='Synthetischer Wissenskandidat';status='candidate';source_refs=@("INT-SYN-$suffix")})
  budgets=@([ordered]@{id="BUD-SYN-$suffix";customer_id=$customerId;scope_type=$scopeType;scope_id=$scopeId;currency='EUR';planned_hours=40;actual_hours=8;forecast_hours=42;planned_amount=4800;actual_amount=960;forecast_amount=5040;truth_boundary='project-forecast-not-accounting'})
  commitments=@([ordered]@{id="DLV-SYN-$suffix";customer_id=$customerId;scope_type=$scopeType;scope_id=$scopeId;title='Synthetische Lieferverpflichtung';status='planned';due_date='2030-06-30';acceptance_status='not-requested'})
  relations=$relations
}

$staging = Join-Path $parent ('.spectra-foundation-' + [guid]::NewGuid().ToString('N'))
try {
  New-Item -ItemType Directory -Path $staging | Out-Null
  $foundationPath = Join-Path $staging 'customer-workspace-foundation.json'
  Write-Json $foundationPath $foundation
  $foundationDigest = (Get-FileHash -LiteralPath $foundationPath -Algorithm SHA256).Hash.ToLowerInvariant()
  $sourceRelative = 'inbox/originals/meeting.txt'
  $sourcePath = Join-Path $staging ($sourceRelative -replace '/', '\')
  Write-Text $sourcePath "spectra_synthetic: true`ncontent_status: synthetic-fixture`nBeobachtung: Der synthetische Projektstatus soll überprüft werden.`n"
  $sourceDigest = (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant()
  $sourceSize = (Get-Item -LiteralPath $sourcePath).Length
  $proposalId = "PRO-SYN-$suffix"
  $observationId = "OBS-SYN-$suffix"
  $comparisonId = "CMP-RUN-SYN-$suffix"
  $inbox = [ordered]@{
    schema_version=1;product_id='spectra';record_type='knowledge-inbox';classification='synthetic-fixture';customer_id=$customerId;foundation_digest=$foundationDigest
    intake_items=@([ordered]@{id="INT-SYN-$suffix";customer_id=$customerId;source_system='meeting-export';source_object_id="MEETING-SYN-$suffix";source_revision='1';source_path=$sourceRelative;sha256=$sourceDigest;source_hash_after=$sourceDigest;size_bytes=$sourceSize;media_type='text/plain';classification='synthetic';imported_at='2030-05-02T09:00:00Z';status='processed'})
    observations=@([ordered]@{id=$observationId;intake_id="INT-SYN-$suffix";occurred_at='2030-05-02T08:30:00Z';summary='Synthetisch beobachteter Aktualisierungsbedarf.';certainty='observed';scope_type=$scopeType;scope_id=$scopeId;source_revision='1'})
    meeting_packages=@([ordered]@{id="MTG-SYN-$suffix";intake_ids=@("INT-SYN-$suffix");observation_ids=@($observationId);status='reviewed'})
    comparison_runs=@([ordered]@{id=$comparisonId;foundation_digest=$foundationDigest;baseline_digest=(Text-Sha "synthetic-baseline-$suffix");run_at='2030-05-02T09:05:00Z';status='complete';stale=$false;observation_ids=@($observationId);proposal_ids=@($proposalId)})
    proposals=@([ordered]@{id=$proposalId;comparison_id=$comparisonId;target_type=$scopeType;target_id=$scopeId;operation='update';expected_foundation_digest=$foundationDigest;observation_ids=@($observationId);summary='Statusprüfung als kontrollierte Folgehandlung vorschlagen.';status='accepted';writes_performed=$false})
    review_decisions=@([ordered]@{id="REV-SYN-$suffix";proposal_id=$proposalId;actor_type='human';person_id=$personId;acting_role_id=$ownerRoleId;decision='accepted';decided_at='2030-05-02T09:10:00Z';reason='Synthetische Annahme für einen späteren kontrollierten Plan.';execution_plan_id=$null;writes_performed=$false})
    conflicts=@();writes_performed=$false;target_mutation=$false
  }
  Write-Json (Join-Path $staging 'knowledge-inbox.json') $inbox
  Move-Item -LiteralPath $staging -Destination $destinationPath
  Write-Host "PASS: Synthetisches Kundenworkspace-/Knowledge-Inbox-Profil $Profile wurde deterministisch erzeugt."
} finally {
  if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force -ErrorAction SilentlyContinue }
}
