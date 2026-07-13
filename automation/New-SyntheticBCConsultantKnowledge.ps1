[CmdletBinding()]
param([Parameter(Mandatory)][string]$Destination)

$ErrorActionPreference = 'Stop'
$destinationPath = [IO.Path]::GetFullPath($Destination)
if (Test-Path -LiteralPath $destinationPath) { throw 'BC_KNOWLEDGE_DESTINATION_EXISTS' }
New-Item -ItemType Directory -Path $destinationPath | Out-Null

$snapshotId = 'BCK-28.2-DE-SYNTHETIC'
$referenceRoot = Join-Path $destinationPath 'reference-library'
& (Join-Path $PSScriptRoot 'New-SyntheticBusinessCentralKnowledgeFixture.ps1') -Destination $referenceRoot -SnapshotId $snapshotId | Out-Null
. (Join-Path $PSScriptRoot 'BusinessCentral.Knowledge.ps1')
$index = Build-BCKnowledgeIndex $referenceRoot $snapshotId
$lock = Test-BCKnowledgeLock $referenceRoot $snapshotId
[void](Test-BCKnowledgeIndex $referenceRoot $snapshotId)
$objectsPath = Join-Path $referenceRoot "indexes\$snapshotId\objects.jsonl"
$referenceObjects = @(
  Get-Content -LiteralPath $objectsPath |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    ForEach-Object { $_ | ConvertFrom-Json }
)
$pageObjectKey = [string](@($referenceObjects | Where-Object { $_.object_type -eq 'page' } | Sort-Object object_key)[0].object_key)
$tableObjectKey = [string](@($referenceObjects | Where-Object { $_.object_type -eq 'table' } | Sort-Object object_key)[0].object_key)
if ([string]::IsNullOrWhiteSpace($pageObjectKey) -or [string]::IsNullOrWhiteSpace($tableObjectKey)) {
  throw 'BC_KNOWLEDGE_REFERENCE_OBJECT_MISSING'
}

$referenceSnapshot = [ordered]@{
  snapshot_id = $snapshotId
  knowledge_pack_id = [string]$lock.knowledge_pack_id
  source_lock_digest = [string]$lock.lock_digest
  index_digest = [string]$index.index_digest
  bc_version = [string]$lock.bc_version
  countries = @($lock.countries)
  source_ids = @($lock.sources | Sort-Object source_id | ForEach-Object { [string]$_.source_id })
  validation_status = 'validated'
}

$areas = @('company', 'general-setup', 'finance', 'vat', 'posting-groups', 'dimensions', 'number-series', 'purchase', 'sales', 'inventory', 'bank-payments', 'period-close', 'vat-preview', 'permissions', 'configuration-packages', 'testing', 'training', 'cutover', 'support')
$items = @()
$indexNumber = 0
foreach ($area in $areas) {
  $indexNumber++
  $items += [ordered]@{
    knowledge_id = ('KNOW-{0:D3}' -f $indexNumber)
    title = 'Synthetischer Startpunkt ' + $area
    knowledge_kind = 'official_documented'
    source_id = 'microsoft-bc-functional-docs'
    version = '28.2'
    locale = 'de-DE'
    process = $area
    role = if ($area -eq 'support') { 'support' } else { 'consultant' }
    object_refs = @(if (($indexNumber % 2) -eq 0) { $tableObjectKey } else { $pageObjectKey })
    project_phase = if ($area -in @('testing', 'training', 'cutover')) { $area } else { 'implementation' }
    task_type = if ($area -eq 'support') { 'support' } else { 'setup' }
    prerequisites = @('validated-reference-snapshot')
    expected_effect = 'Nur als gebundene Wissensaussage nutzbar'
    controls = @('readback-required')
    error_patterns = @('snapshot-or-version-mismatch')
    use_case_refs = @('UC-' + $area.ToUpperInvariant())
  }
}

$playthroughs = @(
  [ordered]@{playthrough_id='PT-COMPANY-PREFLIGHT';title='Company Preflight';mode='plan-only';baseline='existing_validated_company';customer_target='unbound';preconditions=@('environment-bound','role-authorized');steps=@('Version, Locale und Company pruefen');readback=@('Company und Version erneut lesen');error_handling=@('Bei Abweichung stoppen');stop_codes=@('BC_PLAN_BINDING_MISMATCH');direct_mutation=$false},
  [ordered]@{playthrough_id='PT-COMPANY-CREATE';title='Gesellschaft erstellen oder kopieren';mode='plan-only';baseline='microsoft_demo_baseline';customer_target='unbound';preconditions=@('preflight-pass','explicit-human-approval-required-for-future-execution');steps=@('Baseline waehlen','Create-or-copy als Vorschlag planen','kundenspezifisches Soll getrennt erfassen');readback=@('Neue Company separat pruefen','Sollabweichungen dokumentieren');error_handling=@('Nie CRONUS als kundenfertig markieren');stop_codes=@('BC_KNOWLEDGE_CRONUS_NOT_CUSTOMER_READY');direct_mutation=$false},
  [ordered]@{playthrough_id='PT-CONFIG-PACKAGE';title='Konfigurationspaket importieren validieren anwenden';mode='plan-only';baseline='existing_validated_company';customer_target='unbound';preconditions=@('package-classified','backup-planned');steps=@('Importvorschau','Validierung','Apply nur spaeter autorisiert');readback=@('Fehler und Summen vergleichen');error_handling=@('Fehler korrigieren und erneut validieren');stop_codes=@('BC_PLAN_PACKAGE_INVALID');direct_mutation=$false},
  [ordered]@{playthrough_id='PT-READBACK';title='Readback und Evidence';mode='plan-only';baseline='existing_validated_company';customer_target='unbound';preconditions=@('expected-state-defined');steps=@('sichtbaren Zustand lesen','Kontrollen vergleichen');readback=@('Abweichung und Quelle protokollieren');error_handling=@('Unbekannt sichtbar lassen');stop_codes=@('BC_PLAN_READBACK_MISMATCH');direct_mutation=$false},
  [ordered]@{playthrough_id='PT-ERROR';title='Fehlerbehandlung';mode='plan-only';baseline='existing_validated_company';customer_target='unbound';preconditions=@('error-observed');steps=@('Fehler klassifizieren','Stop-Code zuordnen','Retest planen');readback=@('Fehlerzustand erneut lesen');error_handling=@('Keine stille Reparatur');stop_codes=@('BC_PLAN_FAIL_CLOSED');direct_mutation=$false}
)

$root = [ordered]@{
  schema_version = 2
  product_id = 'spectra'
  knowledge_pack_id = [string]$lock.knowledge_pack_id
  bc_version = '28.2'
  locale = 'de-DE'
  reference_snapshot = $referenceSnapshot
  knowledge_items = $items
  playthroughs = $playthroughs
}
[IO.File]::WriteAllText((Join-Path $destinationPath 'bc-knowledge.json'), ($root | ConvertTo-Json -Depth 30), [Text.UTF8Encoding]::new($false))
Write-Output 'PASS: synthetischer BC-Wissenspack an validierten Reference-Snapshot gebunden.'
