[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference = 'Stop'
$d = [IO.Path]::GetFullPath($Path)
$schemaPath = Join-Path $PSScriptRoot '..\schemas\information-inbox.schema.json'
$schema = [IO.File]::ReadAllText($schemaPath, [Text.Encoding]::UTF8) | ConvertFrom-Json
$value = [IO.File]::ReadAllText((Join-Path $d 'information-inbox.json'), [Text.Encoding]::UTF8) | ConvertFrom-Json
foreach ($item in @($value.intake_items)) {
  if ($null -eq $item.source -or [string]::IsNullOrWhiteSpace([string]$item.source.revision) -or [string]::IsNullOrWhiteSpace([string]$item.source.sha256) -or [string]::IsNullOrWhiteSpace([string]$item.source.source_object_id)) { throw 'INBOX_PROVENANCE_REQUIRED' }
}
$script:RootSchema = $schema
$script:InvokeSchema = { param([AllowNull()]$v,$s,$p) . (Join-Path $PSScriptRoot 'Invoke-PortableSchemaValidation.ps1') -Value $v -Schema $s -RootSchema $script:RootSchema -Path $p }
try { . (Join-Path $PSScriptRoot 'Invoke-PortableSchemaValidation.ps1') -Value $value -Schema $schema -RootSchema $schema -Path root } catch { throw 'INBOX_SCHEMA_INVALID' }
function Fail([string]$Code) { throw $Code }
function Get-Items($Object) { if ($null -eq $Object) { @() } else { @($Object) } }
function Assert-SafeRelative([string]$Path) { if ([string]::IsNullOrWhiteSpace($Path) -or $Path -match '(^[A-Za-z]:|^/|\\|\.\.)') { Fail 'INBOX_PATH_UNSAFE' } }
if ($value.product_id -ne 'spectra') { Fail 'INBOX_SCHEMA_INVALID' }
$rootDir = $d
$intakes = Get-Items $value.intake_items
$intakeById = @{}
$sourceKeys = @{}
$sourceRevisions = @{}
foreach ($item in $intakes) {
  if ($intakeById.ContainsKey($item.id)) { Fail 'INBOX_DUPLICATE_PROCESSING' }
  $intakeById[$item.id] = $item
  if ($item.workspace_id -ne $value.workspace_id -or $item.customer_id -ne $value.customer_id) { Fail 'INBOX_PROVENANCE_REQUIRED' }
  $source = $item.source
  Assert-SafeRelative $source.relative_path
  if ([string]::IsNullOrWhiteSpace($source.revision) -or [string]::IsNullOrWhiteSpace($source.sha256) -or [string]::IsNullOrWhiteSpace($source.source_object_id)) { Fail 'INBOX_PROVENANCE_REQUIRED' }
  $sourceKey = "$($source.source_system)|$($source.source_object_id)|$($source.revision)"
  if ($sourceKeys.ContainsKey($sourceKey)) { Fail 'INBOX_DUPLICATE_PROCESSING' }
  $sourceKeys[$sourceKey] = $true
  $sourceRevisions[[string]$source.revision] = $true
  $sourceFile = Join-Path $rootDir $source.relative_path
  if (-not (Test-Path $sourceFile -PathType Leaf)) { Fail 'INBOX_PROVENANCE_REQUIRED' }
  $actualHash = (Get-FileHash $sourceFile -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($actualHash -cne ([string]$source.sha256).ToLowerInvariant()) { Fail 'INBOX_SOURCE_CHANGED' }
  $sourceText = [IO.File]::ReadAllText($sourceFile, [Text.Encoding]::UTF8)
  if ($sourceText -match '(?i)(BEGIN (RSA|OPENSSH|EC) PRIVATE KEY|password\s*=|api[_-]?token\s*=|client[_-]?secret\s*=)') { Fail 'INBOX_SENSITIVE_CONTENT_BLOCKED' }
}
$observationById = @{}
foreach ($observation in (Get-Items $value.observations)) {
  if ($observationById.ContainsKey($observation.id)) { Fail 'INBOX_DUPLICATE_PROCESSING' }
  if (-not $intakeById.ContainsKey($observation.intake_id)) { Fail 'INBOX_PROVENANCE_REQUIRED' }
  $observationById[$observation.id] = $observation
}
$auditById = @{}
foreach ($event in (Get-Items $value.audit_events)) {
  if ($auditById.ContainsKey($event.id)) { Fail 'INBOX_DUPLICATE_PROCESSING' }
  if ($null -ne $event.before -or $null -ne $event.after) {
    if ([string]::IsNullOrWhiteSpace([string]$event.source_revision)) { Fail 'INBOX_AUDIT_SOURCE_REQUIRED' }
  }
  $auditById[$event.id] = $event
}
$allowed = @{
  'neu' = @('geprüft')
  'geprüft' = @('angenommen','abgelehnt','zurückgestellt')
  'zurückgestellt' = @('geprüft')
  'angenommen' = @('umgesetzt')
  'abgelehnt' = @()
  'umgesetzt' = @()
}
$mojibakeU = [string][char]0x00C3 + [char]0x00BC
$geprueft = 'gepr' + [char]0x00FC + 'ft'
$zurueckgestellt = 'zur' + [char]0x00FC + 'ckgestellt'
$allowed = @{
  'neu' = @($geprueft)
  $geprueft = @('angenommen','abgelehnt',$zurueckgestellt)
  $zurueckgestellt = @($geprueft)
  'angenommen' = @('umgesetzt')
  'abgelehnt' = @()
  'umgesetzt' = @()
}
function Canonical-Status([string]$Status) {
  if ($Status -match '^gepr') { return $geprueft }
  if ($Status -match '^zur') { return $zurueckgestellt }
  return $Status.Replace($mojibakeU, ([string][char]0x00FC))
}
$knownTargets = @{}
if ($null -ne $value.support_case_id) { $knownTargets["support_case|$($value.support_case_id)"] = $true }
if ($null -ne $value.project_id) { $knownTargets["project_status|$($value.project_id)"] = $true }
foreach ($proposal in (Get-Items $value.proposals)) {
  if (-not $intakeById.ContainsKey($proposal.intake_id) -or -not $observationById.ContainsKey($proposal.observation_id)) { Fail 'INBOX_PROVENANCE_REQUIRED' }
  if ($proposal.change_type -ne 'create' -and -not $knownTargets.ContainsKey("$($proposal.target_domain)|$($proposal.target_id)")) { Fail 'INBOX_TARGET_UNKNOWN' }
  $proposalStatus = Canonical-Status ([string]$proposal.status)
  if ($proposal.proposer_role -eq $proposal.reviewer_role -and $proposalStatus -ne 'neu') { Fail 'INBOX_SELF_APPROVAL_FORBIDDEN' }
  $history = @(Get-Items $proposal.status_history)
  if ((Canonical-Status ([string]$history[0].status)) -ne 'neu' -or (Canonical-Status ([string]$history[-1].status)) -ne $proposalStatus) { Fail 'INBOX_STATUS_TRANSITION_INVALID' }
  for ($i = 1; $i -lt $history.Count; $i++) {
    $from = Canonical-Status ([string]$history[$i-1].status); $to = Canonical-Status ([string]$history[$i].status)
    if (-not $allowed.ContainsKey($from) -or $allowed[$from] -notcontains $to) { Fail 'INBOX_STATUS_TRANSITION_INVALID' }
    if ([datetime]$history[$i].at -lt [datetime]$history[$i-1].at) { Fail 'INBOX_STATUS_TRANSITION_INVALID' }
    if (-not $auditById.ContainsKey($history[$i].event_id)) { Fail 'INBOX_PROVENANCE_REQUIRED' }
  }
  if ($proposalStatus -eq 'angenommen' -or $proposalStatus -eq 'umgesetzt') {
    if ([string]::IsNullOrWhiteSpace($proposal.acceptance_event_id) -or -not $auditById.ContainsKey($proposal.acceptance_event_id)) { Fail 'INBOX_IMPLEMENTATION_EVIDENCE_REQUIRED' }
  }
  if ($proposalStatus -eq 'umgesetzt') {
    if ([string]::IsNullOrWhiteSpace($proposal.implementation_event_id) -or [string]::IsNullOrWhiteSpace($proposal.implementation_evidence) -or -not $auditById.ContainsKey($proposal.implementation_event_id)) { Fail 'INBOX_IMPLEMENTATION_EVIDENCE_REQUIRED' }
  }
}
foreach ($artifact in (Get-Items $value.target_artifacts)) {
  Assert-SafeRelative $artifact.relative_path
  if ($artifact.write_status -ne 'unchanged') { Fail 'INBOX_DIRECT_MUTATION_FORBIDDEN' }
  $file = Join-Path $rootDir $artifact.relative_path
  if (-not (Test-Path $file -PathType Leaf)) { Fail 'INBOX_DIRECT_MUTATION_FORBIDDEN' }
  $hash = (Get-FileHash $file -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($hash -cne ([string]$artifact.sha256_before).ToLowerInvariant() -or $hash -cne ([string]$artifact.sha256_after).ToLowerInvariant()) { Fail 'INBOX_DIRECT_MUTATION_FORBIDDEN' }
}
foreach ($snapshot in (Get-Items $value.snapshots)) { if ($snapshot.read_only -ne $true -or -not $sourceRevisions.ContainsKey([string]$snapshot.source_revision)) { Fail 'INBOX_PROVENANCE_REQUIRED' } }
Write-Host 'PASS: Information-Inbox read-only, provenancegebunden und statusvalidiert.'
