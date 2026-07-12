[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Destination)
$ErrorActionPreference='Stop'
Set-StrictMode -Version 2.0
$root=[IO.Path]::GetFullPath($Destination)
if(Test-Path -LiteralPath $root){throw 'ENGAGEMENT_TARGET_EXISTS'}
New-Item -ItemType Directory -Path $root -Force|Out-Null
$roles=@(
  [ordered]@{role_id='ROL-SYN-PROJECT-SPONSOR';name='Synthetischer Projektsponsor';side='synthetic';accountability='Freigaben und Eskalationen'},
  [ordered]@{role_id='ROL-SYN-PROJECT-MANAGER';name='Synthetische Projektleitung';side='synthetic';accountability='Projektsteuerung'},
  [ordered]@{role_id='ROL-SYN-PROCESS-OWNER';name='Synthetische Prozessverantwortung';side='synthetic';accountability='Fachprozess und Abnahme'},
  [ordered]@{role_id='ROL-SYN-BC-CONSULTANT';name='Synthetische BC-Beratung';side='synthetic';accountability='Fit-to-Standard und Lösungsoptionen'},
  [ordered]@{role_id='ROL-SYN-ARCHITECT';name='Synthetische Lösungsarchitektur';side='synthetic';accountability='Architektur und Integrationsgrenzen'}
)
$phases=@(
  [ordered]@{phase_id='PHA-SYN-DISCOVERY';sequence=1;name='Discovery';status='completed';start_date='2030-01-07';end_date='2030-01-18'},
  [ordered]@{phase_id='PHA-SYN-FIT';sequence=2;name='Fit-to-Standard';status='completed';start_date='2030-01-21';end_date='2030-02-08'},
  [ordered]@{phase_id='PHA-SYN-DESIGN';sequence=3;name='Solution Design';status='completed';start_date='2030-02-11';end_date='2030-02-22'},
  [ordered]@{phase_id='PHA-SYN-PLANNING';sequence=4;name='Delivery Planning';status='completed';start_date='2030-02-25';end_date='2030-03-01'}
)
$deliverables=@(
  [ordered]@{deliverable_id='DLV-SYN-SCOPE';phase_id='PHA-SYN-DISCOVERY';title='Abgestimmter synthetischer Scope';status='accepted';due_date='2030-01-18';acceptance_criteria=@('Scope, Annahmen und Ausschlüsse sind referenziert.');evidence_refs=@('EVD-SYN-SCOPE')},
  [ordered]@{deliverable_id='DLV-SYN-PROCESS-MAP';phase_id='PHA-SYN-FIT';title='Synthetische Prozesslandkarte';status='accepted';due_date='2030-02-05';acceptance_criteria=@('E2E-Fälle besitzen Owner und erwartetes Ergebnis.');evidence_refs=@('EVD-SYN-PROCESS')},
  [ordered]@{deliverable_id='DLV-SYN-FIT-GAP';phase_id='PHA-SYN-FIT';title='Fit-/Gap-Entscheidungslog';status='accepted';due_date='2030-02-08';acceptance_criteria=@('Jeder Gap besitzt eine entschiedene Behandlung.');evidence_refs=@('EVD-SYN-FIT')},
  [ordered]@{deliverable_id='DLV-SYN-DELIVERY-PLAN';phase_id='PHA-SYN-PLANNING';title='Synthetischer Lieferplan';status='accepted';due_date='2030-03-01';acceptance_criteria=@('Phasen, Rollen und Gates sind vollständig.');evidence_refs=@('EVD-SYN-PLAN')}
)
$raci=@()
foreach($deliverable in $deliverables){
  $raci+=@(
    [ordered]@{deliverable_id=$deliverable.deliverable_id;role_id='ROL-SYN-PROJECT-MANAGER';responsibility='R'},
    [ordered]@{deliverable_id=$deliverable.deliverable_id;role_id='ROL-SYN-PROJECT-SPONSOR';responsibility='A'},
    [ordered]@{deliverable_id=$deliverable.deliverable_id;role_id='ROL-SYN-BC-CONSULTANT';responsibility='C'}
  )
}
$processes=@(
  [ordered]@{process_id='PRO-SYN-O2C';bc_area='o2c';name='Auftrag bis Zahlung';owner_role='ROL-SYN-PROCESS-OWNER';steps=@(
    [ordered]@{step_id='PST-SYN-O2C-01';sequence=1;actor_role='ROL-SYN-PROCESS-OWNER';action='Kundenauftrag fachlich prüfen';outcome='Freigegebener Auftrag'},
    [ordered]@{step_id='PST-SYN-O2C-02';sequence=2;actor_role='ROL-SYN-PROCESS-OWNER';action='Lieferung und Rechnung simulieren';outcome='Nachvollziehbarer Belegfluss'})},
  [ordered]@{process_id='PRO-SYN-P2P';bc_area='p2p';name='Bedarf bis Zahlung';owner_role='ROL-SYN-PROCESS-OWNER';steps=@(
    [ordered]@{step_id='PST-SYN-P2P-01';sequence=1;actor_role='ROL-SYN-PROCESS-OWNER';action='Beschaffungsbedarf prüfen';outcome='Freigegebener Bedarf'},
    [ordered]@{step_id='PST-SYN-P2P-02';sequence=2;actor_role='ROL-SYN-PROCESS-OWNER';action='Eingang und Rechnung abstimmen';outcome='Nachvollziehbare Verbindlichkeit'})},
  [ordered]@{process_id='PRO-SYN-FINANCE';bc_area='finance';name='Monatsabschluss';owner_role='ROL-SYN-PROCESS-OWNER';steps=@(
    [ordered]@{step_id='PST-SYN-FIN-01';sequence=1;actor_role='ROL-SYN-PROCESS-OWNER';action='Offene Sachverhalte prüfen';outcome='Dokumentierte Abschlussliste'},
    [ordered]@{step_id='PST-SYN-FIN-02';sequence=2;actor_role='ROL-SYN-PROCESS-OWNER';action='Abschlusskontrollen simulieren';outcome='Synthetischer Reviewstatus'})}
)
$useCases=@(
  [ordered]@{use_case_id='UCS-SYN-O2C-STANDARD';process_id='PRO-SYN-O2C';title='Standardauftrag vollständig abwickeln';preconditions=@('Synthetische Stammdaten sind freigegeben.');scenario='Ein Standardauftrag wird ohne Sonderlogik durchgeführt.';expected_outcome='Beleg- und Wertefluss sind nachvollziehbar.'},
  [ordered]@{use_case_id='UCS-SYN-P2P-APPROVAL';process_id='PRO-SYN-P2P';title='Beschaffung mit Freigabe';preconditions=@('Synthetische Freigaberolle ist zugeordnet.');scenario='Ein Bedarf wird geprüft und freigegeben.';expected_outcome='Entscheidung und Belegfluss sind referenziert.'},
  [ordered]@{use_case_id='UCS-SYN-FIN-CLOSE';process_id='PRO-SYN-FINANCE';title='Monatsabschluss vorbereiten';preconditions=@('Synthetische Periode ist definiert.');scenario='Kontrollen werden in definierter Reihenfolge ausgeführt.';expected_outcome='Offene Punkte und Entscheidungen sind sichtbar.'}
)
$decisions=@(
  [ordered]@{decision_id='DEC-SYN-O2C-STANDARD';title='Standardprozess für O2C verwenden';status='approved';owner_role='ROL-SYN-PROCESS-OWNER';rationale='Die synthetische Anforderung wird durch den Standardprozess abgedeckt.';selected_option_id='OPT-SYN-O2C-STANDARD';evidence_refs=@('EVD-SYN-O2C');decided_at='2030-02-01T10:00:00Z'},
  [ordered]@{decision_id='DEC-SYN-P2P-CONFIG';title='Freigabe konfigurierbar abbilden';status='approved';owner_role='ROL-SYN-PROCESS-OWNER';rationale='Konfiguration genügt im synthetischen Referenzfall.';selected_option_id='OPT-SYN-P2P-CONFIG';evidence_refs=@('EVD-SYN-P2P');decided_at='2030-02-02T10:00:00Z'},
  [ordered]@{decision_id='DEC-SYN-FIN-PROCESS';title='Abschlusskontrolle organisatorisch ergänzen';status='approved';owner_role='ROL-SYN-PROCESS-OWNER';rationale='Die synthetische Lücke wird als Prozessänderung behandelt.';selected_option_id='OPT-SYN-FIN-PROCESS';evidence_refs=@('EVD-SYN-FIN');decided_at='2030-02-03T10:00:00Z'}
)
$assessments=@(
  [ordered]@{assessment_id='GAP-SYN-O2C';process_id='PRO-SYN-O2C';use_case_id='UCS-SYN-O2C-STANDARD';fit_status='fit';treatment='standard';business_need='Standardaufträge transparent abwickeln.';standard_capability='Business Central Standardbelegfluss.';options=@([ordered]@{option_id='OPT-SYN-O2C-STANDARD';title='Standard verwenden';impact='Keine kundenspezifische Erweiterung.'});recommended_option_id='OPT-SYN-O2C-STANDARD';decision_id='DEC-SYN-O2C-STANDARD';assumption_ids=@('ASM-SYN-STANDARD-FIRST');scope_ids=@('SCP-SYN-DISCOVERY');deliverable_ids=@('DLV-SYN-PROCESS-MAP');evidence_refs=@('EVD-SYN-O2C');status='decided'},
  [ordered]@{assessment_id='GAP-SYN-P2P';process_id='PRO-SYN-P2P';use_case_id='UCS-SYN-P2P-APPROVAL';fit_status='partial';treatment='configuration';business_need='Beschaffungsbedarfe kontrolliert freigeben.';standard_capability='Konfigurierbare Genehmigungsworkflows.';options=@([ordered]@{option_id='OPT-SYN-P2P-CONFIG';title='Workflow konfigurieren';impact='Rollen und Schwellenwerte werden später kundenseitig festgelegt.'});recommended_option_id='OPT-SYN-P2P-CONFIG';decision_id='DEC-SYN-P2P-CONFIG';assumption_ids=@('ASM-SYN-ROLES');scope_ids=@('SCP-SYN-DISCOVERY');deliverable_ids=@('DLV-SYN-FIT-GAP');evidence_refs=@('EVD-SYN-P2P');status='decided'},
  [ordered]@{assessment_id='GAP-SYN-FIN';process_id='PRO-SYN-FINANCE';use_case_id='UCS-SYN-FIN-CLOSE';fit_status='gap';treatment='process-change';business_need='Abschlusskontrollen mit klarer Verantwortlichkeit durchführen.';standard_capability='Buchungs- und Auswertungsfunktionen; organisatorische Kontrolle bleibt kundenseitig.';options=@([ordered]@{option_id='OPT-SYN-FIN-PROCESS';title='Prozesskontrolle ergänzen';impact='Keine Produktiverweiterung; organisatorischer Schritt.'});recommended_option_id='OPT-SYN-FIN-PROCESS';decision_id='DEC-SYN-FIN-PROCESS';assumption_ids=@('ASM-SYN-STANDARD-FIRST');scope_ids=@('SCP-SYN-DISCOVERY');deliverable_ids=@('DLV-SYN-FIT-GAP');evidence_refs=@('EVD-SYN-FIN');status='decided'}
)
$record=[ordered]@{
  schema_version=1;contract_version='1.0';record_type='engagement-fit-standard';engagement_id='ENG-SYN-BC-BASIC';product_id='spectra';project_id='PRJ-SYN-BC-BASIC';customer_id='CUS-SYN-BC-BASIC';profile='implementation';classification='synthetic-fixture';synthetic=$true
  offer=[ordered]@{offer_id='OFR-SYN-BC-BASIC';version=2;status='approved';currency='XTS';planned_hours=120;planned_cost=14400;valid_from='2030-01-01';valid_to='2030-03-31';change_history=@(
    [ordered]@{version=1;status='superseded';planned_hours=96;planned_cost=11520;valid_from='2030-01-01';valid_to='2030-02-28';change_reason='Erste synthetische Scopebaseline.';scope_ids=@('SCP-SYN-DISCOVERY')},
    [ordered]@{version=2;status='approved';planned_hours=120;planned_cost=14400;valid_from='2030-01-01';valid_to='2030-03-31';change_reason='Synthetische Lieferplanung ergänzt.';scope_ids=@('SCP-SYN-DISCOVERY','SCP-SYN-DELIVERY-PLAN')}
  )}
  scope_items=@(
    [ordered]@{scope_id='SCP-SYN-DISCOVERY';category='project-management';title='Discovery und Fit-to-Standard';outcome='in-scope';planned_hours=80;planned_cost=9600;acceptance_criteria=@('Scope, E2E-Prozesse und Fit-/Gap-Entscheidungen sind nachvollziehbar.');assumption_ids=@('ASM-SYN-STANDARD-FIRST');deliverable_ids=@('DLV-SYN-SCOPE','DLV-SYN-PROCESS-MAP','DLV-SYN-FIT-GAP')},
    [ordered]@{scope_id='SCP-SYN-DELIVERY-PLAN';category='project-management';title='Lieferplanung';outcome='in-scope';planned_hours=40;planned_cost=4800;acceptance_criteria=@('Phasen, RACI und Gates sind planbar.');assumption_ids=@('ASM-SYN-ROLES');deliverable_ids=@('DLV-SYN-DELIVERY-PLAN')}
  )
  exclusions=@([ordered]@{exclusion_id='EXC-SYN-LIVE-SYSTEMS';title='Keine Live-Systemaktivität';reason='Der Produktnachweis ist ausschließlich synthetisch.'})
  assumptions=@(
    [ordered]@{assumption_id='ASM-SYN-STANDARD-FIRST';statement='Standardfunktionen werden vor Erweiterungen bewertet.';owner_role='ROL-SYN-PROJECT-SPONSOR';status='confirmed';source_refs=@('SRC-SYN-PROJECT-CHARTER')},
    [ordered]@{assumption_id='ASM-SYN-ROLES';statement='Rollen werden vor der Umsetzungsplanung bestätigt.';owner_role='ROL-SYN-PROJECT-MANAGER';status='confirmed';source_refs=@('SRC-SYN-RACI-WORKSHOP')}
  )
  phases=$phases;deliverables=$deliverables;roles=$roles;raci=$raci
  gates=@(
    [ordered]@{gate_id='GAT-SYN-DISCOVERY';phase_id='PHA-SYN-DISCOVERY';due_date='2030-01-18';criteria=@('Scope und Annahmen bestätigt.');status='passed';decision_id='DEC-SYN-O2C-STANDARD';evidence_refs=@('EVD-SYN-SCOPE')},
    [ordered]@{gate_id='GAT-SYN-FIT';phase_id='PHA-SYN-FIT';due_date='2030-02-08';criteria=@('Alle Assessments entschieden.');status='passed';decision_id='DEC-SYN-FIN-PROCESS';evidence_refs=@('EVD-SYN-FIT')}
  )
  processes=$processes;use_cases=$useCases;assessments=$assessments;decisions=$decisions
  open_questions=@(
    [ordered]@{question_id='QUE-SYN-CUSTOMER-OWNER';category='customer';question='Welche synthetische Rolle bestätigt den Prozess?';owner_role='ROL-SYN-PROJECT-MANAGER';due_date='2030-02-05';status='answered';blocks_gate=$true;answer='Synthetisch: ROL-SYN-PROCESS-OWNER.';decision_id=$null;related_ids=@('GAT-SYN-DISCOVERY','PRO-SYN-O2C');source_refs=@('SRC-SYN-RACI-WORKSHOP')},
    [ordered]@{question_id='QUE-SYN-TAX-BOUNDARY';category='tax';question='Welche steuerliche Prüfung wäre in einem realen Projekt erforderlich?';owner_role='ROL-SYN-PROJECT-SPONSOR';due_date='2030-02-05';status='answered';blocks_gate=$true;answer='Synthetischer Modellhinweis; reale steuerliche Bewertung bleibt außerhalb von Spectra.';decision_id=$null;related_ids=@('GAP-SYN-FIN');source_refs=@('SRC-SYN-OFFICIAL-REFERENCE-PLACEHOLDER')}
  )
  truth_boundary=[ordered]@{source_of_truth='synthetic-fixture';customer_data_in_product=$false;external_activity_claim=$false;tax_or_legal_advice_claim=$false}
  readiness=[ordered]@{status='fit_to_standard_ready';calculated=$true;blocking_reasons=@()}
}
$json=($record|ConvertTo-Json -Depth 40)+"`n"
[IO.File]::WriteAllText((Join-Path $root 'engagement-fit-standard.json'),$json,(New-Object Text.UTF8Encoding($false)))
Write-Host 'PASS: Synthetisches Engagement-/Fit-to-Standard-Fixture wurde deterministisch erzeugt.'
