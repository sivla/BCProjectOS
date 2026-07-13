[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Destination)
$ErrorActionPreference = 'Stop'
$d = [IO.Path]::GetFullPath($Destination)
if (Test-Path -LiteralPath $d) { throw 'INBOX_TARGET_EXISTS' }
New-Item -ItemType Directory -Force (Join-Path $d 'source'), (Join-Path $d 'targets') | Out-Null
$sourcePath = Join-Path $d 'source/meeting.md'
$targetPath = Join-Path $d 'targets/status.md'
[IO.File]::WriteAllText($sourcePath, "Synthetisches Meetingprotokoll: Prozessbeobachtung und offene Frage.`n", [Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText($targetPath, "Synthetischer Zielstand bleibt unverändert.`n", [Text.UTF8Encoding]::new($false))
$sourceHash = (Get-FileHash $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant()
$targetHash = (Get-FileHash $targetPath -Algorithm SHA256).Hash.ToLowerInvariant()
$source = [ordered]@{source_system='meeting';source_object_id='SRC-SYN-001';revision='REV-001';sha256=$sourceHash;relative_path='source/meeting.md';observed_at='2026-07-13T09:00:00Z';imported_at='2026-07-13T09:05:00Z';actor_role='consultant';classification='meeting_information';sensitivity='internal'}
$intake = [ordered]@{id='INTAKE-SYN-001';workspace_id='WS-SYN-001';customer_id='CUS-SYN-001';project_id=$null;support_case_id='SUP-SYN-001';source=$source;status='processed'}
$observation = [ordered]@{id='OBS-SYN-001';intake_id='INTAKE-SYN-001';statement='Ein synthetischer Supportfall benötigt eine belegte Rückfrage.';confidence='high';observed_at='2026-07-13T09:10:00Z'}
$history = @([ordered]@{status='neu';at='2026-07-13T09:11:00Z';actor_role='consultant';event_id='AUD-REVIEW-001'},[ordered]@{status='geprüft';at='2026-07-13T09:20:00Z';actor_role='reviewer';event_id='AUD-REVIEW-001'},[ordered]@{status='angenommen';at='2026-07-13T09:30:00Z';actor_role='customer_reviewer';event_id='AUD-ACCEPT-001'},[ordered]@{status='umgesetzt';at='2026-07-13T09:45:00Z';actor_role='operator';event_id='AUD-IMPLEMENT-001'})
$proposal = [ordered]@{id='PROP-SYN-001';intake_id='INTAKE-SYN-001';observation_id='OBS-SYN-001';proposer_role='consultant';target_domain='support_case';target_id='SUP-SYN-001';change_type='link';rationale='Belegte Zuordnung zur Supportbearbeitung.';conflicts=@();open_questions=@('Welche fachliche Antwort bestätigt die Kundenrolle?');risk='low';reviewer_role='customer_reviewer';status_history=$history;status='umgesetzt';acceptance_event_id='AUD-ACCEPT-001';implementation_event_id='AUD-IMPLEMENT-001';implementation_evidence='EVID-SYN-IMPLEMENT-001'}
$audit = @(
  [ordered]@{id='AUD-INTAKE-001';event_type='intake';actor_role='consultant';occurred_at='2026-07-13T09:05:00Z';source_revision='REV-001';before=$null;after=[ordered]@{intake_id='INTAKE-SYN-001'};decision='captured';references=@('INTAKE-SYN-001')},
  [ordered]@{id='AUD-REVIEW-001';event_type='proposal_review';actor_role='reviewer';occurred_at='2026-07-13T09:20:00Z';source_revision='REV-001';before=[ordered]@{status='neu'};after=[ordered]@{status='geprüft'};decision='reviewed';references=@('PROP-SYN-001')},
  [ordered]@{id='AUD-ACCEPT-001';event_type='proposal_acceptance';actor_role='customer_reviewer';occurred_at='2026-07-13T09:30:00Z';source_revision='REV-001';before=[ordered]@{status='geprüft'};after=[ordered]@{status='angenommen'};decision='accepted';references=@('PROP-SYN-001','SUP-SYN-001')},
  [ordered]@{id='AUD-IMPLEMENT-001';event_type='proposal_implementation';actor_role='operator';occurred_at='2026-07-13T09:45:00Z';source_revision='REV-001';before=[ordered]@{status='angenommen'};after=[ordered]@{status='umgesetzt'};decision='implemented';references=@('PROP-SYN-001','SUP-SYN-001')}
)
$story = [ordered]@{schema_version=1;product_id='spectra';workspace_id='WS-SYN-001';customer_id='CUS-SYN-001';project_id=$null;support_case_id='SUP-SYN-001';intake_items=@($intake);observations=@($observation);proposals=@($proposal);audit_events=$audit;snapshots=@([ordered]@{id='SNAP-SYN-001';source_revision='REV-001';created_at='2026-07-13T10:00:00Z';digest=('b'*64);read_only=$true});target_artifacts=@([ordered]@{relative_path='targets/status.md';sha256_before=$targetHash;sha256_after=$targetHash;write_status='unchanged'})}
$story | ConvertTo-Json -Depth 40 | Set-Content (Join-Path $d 'information-inbox.json') -Encoding utf8
Write-Host 'PASS: Synthetischer Information-Inbox-Vertrag erzeugt.'
