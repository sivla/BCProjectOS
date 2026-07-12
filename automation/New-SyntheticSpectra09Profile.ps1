[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Destination,
  [Parameter(Mandatory=$true)][ValidateSet('implementation','support-only')][string]$Profile
)
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath($Destination)
if(Test-Path $root){throw 'SPECTRA09_TARGET_EXISTS'}
$utf8=New-Object Text.UTF8Encoding($false)
function Write-Json([string]$Path,$Value){
  $directory=Split-Path -Parent $Path
  if(-not(Test-Path $directory)){New-Item -ItemType Directory -Force $directory|Out-Null}
  [IO.File]::WriteAllText($Path,(($Value|ConvertTo-Json -Depth 20)+"`n"),$utf8)
}
New-Item -ItemType Directory -Force $root|Out-Null
$fixture=[ordered]@{schema_version=1;artifact_type='spectra-09-synthetic-profile';product_id='spectra';profile=$Profile;classification='synthetic-fixture';synthetic=$true;customer_evidence=$false;contracts=@('project-reconciliation','adapter-provenance')}
Write-Json (Join-Path $root 'fixture.json') $fixture
$reconciliation=[ordered]@{
  schema_version=1;contract_version='1.0';record_type='project-reconciliation';reconciliation_id="REC-SYNTHETIC-$($Profile.ToUpperInvariant())";product_id='spectra';profile=$Profile;classification='synthetic-fixture';synthetic=$true
  baseline=[ordered]@{version=1;hours=16;rate=75;amount=1200;currency='XTS'}
  offer=[ordered]@{version=2;hours=18;rate=75;amount=1350;currency='XTS'}
  actual=[ordered]@{version=1;hours=17;rate=75;amount=1275;currency='XTS'}
  variance=[ordered]@{hours=-1;rate=0;amount=-75;reason_code='efficiency';reason='Synthetische Abweichung für die Vertragsprüfung.'}
  truth_boundary=[ordered]@{owner='synthetic-fixture';source_of_truth='synthetic-fixture';invoice_claim=$false;productive_activity_claim=$false;billing_status='not-applicable'}
}
Write-Json (Join-Path $root 'reconciliation\project-reconciliation.json') $reconciliation
$source=[ordered]@{artifact_type='synthetic-adapter-source';profile=$Profile;synthetic=$true}
$projection=[ordered]@{artifact_type='synthetic-adapter-projection';profile=$Profile;mapping_version='1.0.0';synthetic=$true}
$sourcePath=Join-Path $root 'adapter\source\source.json';$projectionPath=Join-Path $root 'adapter\projection\projection.json'
Write-Json $sourcePath $source;Write-Json $projectionPath $projection
$sourceHash=(Get-FileHash $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant();$projectionHash=(Get-FileHash $projectionPath -Algorithm SHA256).Hash.ToLowerInvariant()
$provenance=[ordered]@{
  schema_version=1;contract_version='1.0';record_type='adapter-provenance';provenance_id="PRV-SYNTHETIC-$($Profile.ToUpperInvariant())";product_id='spectra';profile=$Profile;classification='synthetic-fixture';synthetic=$true
  source=[ordered]@{blob_path='adapter/source/source.json';source_hash=$sourceHash;source_hash_after=$sourceHash;media_type='application/json'}
  mapping=[ordered]@{mapping_id='MAP-SYNTHETIC-GENERIC';mapping_version='1.0.0';deterministic=$true}
  projection=[ordered]@{projection_path='adapter/projection/projection.json';digest_algorithm='SHA-256';projection_digest=$projectionHash}
  source_of_truth=[ordered]@{owner='synthetic-fixture';unchanged=$true}
  write_protection=[ordered]@{source_mode='read-only';writes_performed=$false;projection_only=$true;overwrite_allowed=$false}
}
Write-Json (Join-Path $root 'adapter\adapter-provenance.json') $provenance
Write-Host "PASS: Synthetisches Spectra-0.9-Profil '$Profile' wurde isoliert erzeugt."
