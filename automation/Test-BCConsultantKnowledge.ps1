[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$Path,
  [string]$Process,
  [string]$Role,
  [string]$Object,
  [string]$ProjectPhase,
  [string]$TaskType
)

$ErrorActionPreference = 'Stop'
function Fail([string]$Code) { throw $Code }

$root = [IO.Path]::GetFullPath($Path)
$file = Join-Path $root 'bc-knowledge.json'
if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { Fail 'BC_KNOWLEDGE_FILE_MISSING' }
$raw = Get-Content -LiteralPath $file -Raw
try { $value = $raw | ConvertFrom-Json } catch { Fail 'BC_KNOWLEDGE_SCHEMA_INVALID' }
if ($raw -match '(?i)password\s*=|api[_-]?token|client[_-]?secret') { Fail 'BC_KNOWLEDGE_SECRET_BLOCKED' }
if ($raw -match '(?i)Universaarl|UABC|customer-evidence') { Fail 'BC_KNOWLEDGE_CUSTOMER_DATA' }
if ($raw -match '[A-Za-z]:\\') { Fail 'BC_KNOWLEDGE_ABSOLUTE_PATH' }
if ($value.product_id -ne 'spectra') { Fail 'BC_KNOWLEDGE_SCHEMA_INVALID' }

$binding = $value.reference_snapshot
if ($null -eq $binding -or [string]::IsNullOrWhiteSpace([string]$binding.snapshot_id)) { Fail 'BC_KNOWLEDGE_PROVENANCE_MISSING' }
$sourceIds = @($binding.source_ids)
if (@($sourceIds | Group-Object | Where-Object Count -gt 1).Count -gt 0) { Fail 'BC_KNOWLEDGE_PROVENANCE_AMBIGUOUS' }

$referenceRoot = Join-Path $root 'reference-library'
try {
  . (Join-Path $PSScriptRoot 'BusinessCentral.Knowledge.ps1')
  $lock = Test-BCKnowledgeLock $referenceRoot ([string]$binding.snapshot_id)
  $index = Test-BCKnowledgeIndex $referenceRoot ([string]$binding.snapshot_id)
} catch {
  Fail 'BC_KNOWLEDGE_REFERENCE_SNAPSHOT_INVALID'
}
if ([string]$value.knowledge_pack_id -cne [string]$binding.knowledge_pack_id) {
  Fail 'BC_KNOWLEDGE_REFERENCE_PACK_MISMATCH'
}
if (
  [string]$binding.knowledge_pack_id -cne [string]$lock.knowledge_pack_id -or
  [string]$binding.source_lock_digest -cne [string]$lock.lock_digest -or
  [string]$binding.index_digest -cne [string]$index.index_digest
) { Fail 'BC_KNOWLEDGE_REFERENCE_DIGEST_MISMATCH' }
if ([string]$binding.bc_version -cne [string]$lock.bc_version -or [string]$value.bc_version -cne [string]$lock.bc_version) { Fail 'BC_KNOWLEDGE_VERSION_LOCALE_MISMATCH' }
if (Compare-Object @($binding.countries | Sort-Object) @($lock.countries | Sort-Object)) { Fail 'BC_KNOWLEDGE_REFERENCE_SNAPSHOT_INVALID' }
$lockedSourceIds = @($lock.sources | Sort-Object source_id | ForEach-Object { [string]$_.source_id })
if (Compare-Object @($sourceIds | Sort-Object) $lockedSourceIds) { Fail 'BC_KNOWLEDGE_REFERENCE_SNAPSHOT_INVALID' }
$objectKeys = @{}
$objectsPath = Join-Path $referenceRoot "indexes\$([string]$binding.snapshot_id)\objects.jsonl"
foreach ($line in @(Get-Content -LiteralPath $objectsPath)) {
  if ([string]::IsNullOrWhiteSpace($line)) { continue }
  $catalogObject = $line | ConvertFrom-Json
  $key = [string]$catalogObject.object_key
  if ([string]::IsNullOrWhiteSpace($key) -or $objectKeys.ContainsKey($key)) { Fail 'BC_KNOWLEDGE_REFERENCE_SNAPSHOT_INVALID' }
  $objectKeys[$key] = $true
}

$ids = @{}
foreach ($item in @($value.knowledge_items)) {
  if ($ids.ContainsKey($item.knowledge_id)) { Fail 'BC_KNOWLEDGE_ID_DUPLICATE' }
  $ids[$item.knowledge_id] = $true
  if ($lockedSourceIds -notcontains [string]$item.source_id) { Fail 'BC_KNOWLEDGE_SOURCE_UNAPPROVED' }
  if ([string]::IsNullOrWhiteSpace($item.locale) -or [string]::IsNullOrWhiteSpace($item.version) -or $item.locale -ne $value.locale -or $item.version -ne $value.bc_version) { Fail 'BC_KNOWLEDGE_VERSION_LOCALE_MISMATCH' }
  if ($item.knowledge_kind -notin @('official_documented', 'derived_standard_metadata', 'tested_generic_procedure', 'open_assumption')) { Fail 'BC_KNOWLEDGE_KIND_UNKNOWN' }
  if (@($item.object_refs | Where-Object { $_ -match '^page:21$' }).Count -gt 0 -and @($item.object_refs | Where-Object { $_ -match '^page:22$' }).Count -gt 0) { Fail 'BC_KNOWLEDGE_OBJECT_ID_CONTRADICTORY' }
  foreach ($objectRef in @($item.object_refs)) {
    if (-not $objectKeys.ContainsKey([string]$objectRef)) { Fail 'BC_KNOWLEDGE_OBJECT_REFERENCE_UNKNOWN' }
  }
  if ($item.expected_effect -match '(?i)produktiv erfolgreich|customer accepted') { Fail 'BC_KNOWLEDGE_PRODUCTION_CLAIM' }
}
foreach ($playthrough in @($value.playthroughs)) {
  if ($playthrough.mode -ne 'plan-only' -or $playthrough.direct_mutation) { Fail 'BC_KNOWLEDGE_DIRECT_MUTATION' }
  if ($playthrough.customer_target -ne 'unbound') { Fail 'BC_KNOWLEDGE_CUSTOMER_DATA' }
  if ($playthrough.baseline -eq 'microsoft_demo_baseline' -and $playthrough.title -match '(?i)fertig|produktiv') { Fail 'BC_KNOWLEDGE_CRONUS_NOT_CUSTOMER_READY' }
}

try {
  $schema = Get-Content -Raw (Join-Path $PSScriptRoot '..\schemas\bc-consultant-knowledge.schema.json') | ConvertFrom-Json
  . (Join-Path $PSScriptRoot 'Invoke-PortableSchemaValidation.ps1') -Value $value -Schema $schema -RootSchema $schema -Path root
} catch {
  Fail 'BC_KNOWLEDGE_SCHEMA_INVALID'
}

$query = @(
  $value.knowledge_items |
    Where-Object {
      (-not $Process -or $_.process -eq $Process) -and
      (-not $Role -or $_.role -eq $Role) -and
      (-not $Object -or $_.object_refs -contains $Object) -and
      (-not $ProjectPhase -or $_.project_phase -eq $ProjectPhase) -and
      (-not $TaskType -or $_.task_type -eq $TaskType)
    } |
    Sort-Object knowledge_id
)
[pscustomobject]@{status='validated';snapshot_id=[string]$binding.snapshot_id;index_digest=[string]$binding.index_digest;count=$query.Count;items=$query}
