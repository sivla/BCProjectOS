[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Destination,
  [ValidateSet('implementation','support-only')][string]$Profile='implementation'
)
$ErrorActionPreference='Stop'
$full=[IO.Path]::GetFullPath($Destination)
if(Test-Path $full){throw 'SETUP_DATA_DESTINATION_EXISTS'}
New-Item -ItemType Directory -Path $full|Out-Null
$areas=@(
  @('SET-COMPANY-GL','Gesellschaft und Hauptbuch','Company Information / General Ledger Setup','SET-',1,'standard'),
  @('SET-ACCOUNTS-POSTING','Konten und Buchungsgruppen','Chart of Accounts / Posting Groups','SET-COMPANY-GL',2,'customer_parameter'),
  @('SET-VAT','VAT','VAT Posting Setup','SET-ACCOUNTS-POSTING',3,'localization_or_tax_confirmation'),
  @('SET-DIMENSIONS','Dimensionen','Dimensions','SET-COMPANY-GL',4,'customer_parameter'),
  @('SET-NUMBER-SERIES','Nummernserien','No. Series','SET-COMPANY-GL',5,'standard'),
  @('SET-PAYMENT-TERMS','Zahlungsbedingungen','Payment Terms','SET-COMPANY-GL',6,'customer_parameter'),
  @('SET-PAYMENT-METHODS','Zahlungsmethoden','Payment Methods','SET-PAYMENT-TERMS',7,'customer_parameter'),
  @('SET-REMINDERS','Mahnwesen','Reminder Terms','SET-PAYMENT-TERMS',8,'customer_parameter'),
  @('SET-BANK-RECON','Bankabstimmung','Bank Account Reconciliation','SET-PAYMENT-METHODS',9,'customer_parameter'),
  @('SET-PURCHASE','Einkauf','Purchases & Payables Setup','SET-ACCOUNTS-POSTING',10,'standard'),
  @('SET-SALES','Verkauf','Sales & Receivables Setup','SET-ACCOUNTS-POSTING',11,'standard'),
  @('SET-INVENTORY','Lager','Inventory Setup','SET-ACCOUNTS-POSTING',12,'customer_parameter'),
  @('SET-PERIODS','Perioden','General Ledger Setup / Inventory Periods','SET-INVENTORY',13,'localization_or_tax_confirmation'),
  @('SET-REPORTING','Standardreporting','Account Schedules / Reports','SET-DIMENSIONS',14,'standard')
)
$steps=@();foreach($a in $areas){$deps=@();if($a[3]-ne'SET-'){$deps=@($a[3])};$suffix=($a[0]-replace'^SET-','');$steps+=,[ordered]@{id=$a[0];area=$a[1];sequence=[int]$a[4];entry='Vorgaenger und fachliche Entscheidung liegen vor';exit='Pruefschritt und erwartetes Ergebnis sind dokumentiert';depends_on=$deps;parameters=@([ordered]@{id="PAR-$suffix-01";bc_search=$a[2];field='Generischer Setup-Parameter';value_classification=$a[5];owner_role='ROLE-SETUP-CONSULTANT';effect="Steuert $($a[1]) im Standardprozess";verification_step='Konfiguration read-only gegen Sollentscheidung pruefen';expected_result='Sollwert, Wirkung und Abweichung sind nachvollziehbar';process_ref="PROC-$suffix";uat_ref="UAT-$suffix";deviation_path=if($a[5]-eq'standard'){'standard'}else{'parameterize'}})}}
$roles=@(
  [ordered]@{id='ROLE-SETUP-CONSULTANT';allowed_task='Setupentscheidung vorbereiten und pruefen';permission_need='Konfiguration lesen und in freigegebener Sandbox pflegen';forbidden_with=@('ROLE-APPROVER');positive_probe='Freigegebene Setupseite lesen';denied_probe='Eigene kritische Aenderung nicht selbst freigeben'},
  [ordered]@{id='ROLE-DATA-OPERATOR';allowed_task='Dry-run und Datenkorrektur ausfuehren';permission_need='Importstaging lesen und validierte Daten vorbereiten';forbidden_with=@('ROLE-APPROVER');positive_probe='Synthetischen Dry-run ausfuehren';denied_probe='Ungepruefte Welle nicht buchen'},
  [ordered]@{id='ROLE-APPROVER';allowed_task='Kontrollen und Abweichungen freigeben';permission_need='Kontrollergebnisse lesen und Entscheidung dokumentieren';forbidden_with=@('ROLE-DATA-OPERATOR','ROLE-SETUP-CONSULTANT');positive_probe='Kontrollreport lesen';denied_probe='Quelldaten nicht selbst veraendern'}
)
$types=@('gl_account','dimension','customer','vendor','item','bank_account','opening_balance','open_document');$templates=@();foreach($t in $types){$id='TPL-'+($t.ToUpperInvariant()-replace'_','-');$refs=@();if($t-in@('customer','vendor','item','bank_account','opening_balance','open_document')){$refs=@('TPL-GL-ACCOUNT')};$templates+=,[ordered]@{id=$id;type=$t;required_fields=@('external_key','description');format_rules=@('UTF-8','trimmed identifiers');reference_rules=$refs;contains_customer_data=$false}}
$zero=('0'*64);$waves=@(
  [ordered]@{id='WAVE-FOUNDATION';name='foundation';sequence=1;template_refs=@('TPL-GL-ACCOUNT','TPL-DIMENSION');dry_run=$true;source_count=20;accepted_count=20;rejected_count=0;control_total=$zero;error_classes=@();correction='Keine Korrektur erforderlich';retest_status='PASS'},
  [ordered]@{id='WAVE-MASTER';name='master_data';sequence=2;template_refs=@('TPL-CUSTOMER','TPL-VENDOR','TPL-ITEM','TPL-BANK-ACCOUNT');dry_run=$true;source_count=40;accepted_count=39;rejected_count=1;control_total=('1'*64);error_classes=@('invalid_reference');correction='Synthetische Referenz korrigieren und erneut pruefen';retest_status='CORRECTION_REQUIRED'},
  [ordered]@{id='WAVE-OPENING';name='opening_and_open_items';sequence=3;template_refs=@('TPL-OPENING-BALANCE','TPL-OPEN-DOCUMENT');dry_run=$true;source_count=10;accepted_count=10;rejected_count=0;control_total=('2'*64);error_classes=@();correction='Kontrollsumme abstimmen';retest_status='PASS'}
)
$record=[ordered]@{schema_version=1;product_id='spectra';profile=$Profile;project_id="SYN-SETUP-DATA-$($Profile.ToUpperInvariant())";setup_steps=$steps;roles=$roles;data_templates=$templates;migration_waves=$waves;readiness=[ordered]@{dry_run=$true;customer_content_embedded=$false;localization_tax_confirmed=$false;status='CONFIRMATION_REQUIRED'}}
$utf8=New-Object Text.UTF8Encoding($false);[IO.File]::WriteAllText((Join-Path $full 'setup-permissions-data.json'),(($record|ConvertTo-Json -Depth 20)+"`n"),$utf8)
Write-Host "PASS: Synthetisches Setup-/Berechtigungs-/Datenprofil $Profile wurde deterministisch erzeugt."
