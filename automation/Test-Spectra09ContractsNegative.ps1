[CmdletBinding()]param()
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$base=Join-Path ([IO.Path]::GetTempPath()) ('spectra-09-negative-'+[guid]::NewGuid().ToString('N'))
$utf8=New-Object Text.UTF8Encoding($false)

function Write-Json([string]$Path,$Value){[IO.File]::WriteAllText($Path,(($Value|ConvertTo-Json -Depth 30)+"`n"),$utf8)}
function Update-Reconciliation([string]$Directory,[scriptblock]$Mutation){$path=Join-Path $Directory 'reconciliation\project-reconciliation.json';$value=Get-Content $path -Raw|ConvertFrom-Json;& $Mutation $value;Write-Json $path $value}
function Update-Provenance([string]$Directory,[scriptblock]$Mutation){$path=Join-Path $Directory 'adapter\adapter-provenance.json';$value=Get-Content $path -Raw|ConvertFrom-Json;& $Mutation $value;Write-Json $path $value}
function Invoke-Exact([string]$Validator,[string]$Directory){
  $start=[Diagnostics.ProcessStartInfo]::new();$start.FileName='powershell.exe';$start.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Run-Spectra09ValidationExact.ps1`" -Validator $Validator -Path `"$Directory`"";$start.UseShellExecute=$false;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
  $process=[Diagnostics.Process]::Start($start);$out=$process.StandardOutput.ReadToEnd().Trim();$err=$process.StandardError.ReadToEnd().Trim();$process.WaitForExit();[pscustomobject]@{Exit=$process.ExitCode;Raw=$out;Err=$err}
}

$cases=@(
  @{name='reconciliation-required';validator='reconciliation';code='RECONCILIATION_SCHEMA_INVALID';mutate={param($d)Update-Reconciliation $d {param($x)$x.PSObject.Properties.Remove('reconciliation_id')}}},
  @{name='reconciliation-additional';validator='reconciliation';code='RECONCILIATION_SCHEMA_INVALID';mutate={param($d)Update-Reconciliation $d {param($x)$x.offer|Add-Member extra 'not-allowed'}}},
  @{name='baseline-amount';validator='reconciliation';code='RECONCILIATION_BASELINE_AMOUNT_MISMATCH';mutate={param($d)Update-Reconciliation $d {param($x)$x.baseline.amount=1201}}},
  @{name='offer-amount';validator='reconciliation';code='RECONCILIATION_OFFER_AMOUNT_MISMATCH';mutate={param($d)Update-Reconciliation $d {param($x)$x.offer.amount=1351}}},
  @{name='actual-amount';validator='reconciliation';code='RECONCILIATION_ACTUAL_AMOUNT_MISMATCH';mutate={param($d)Update-Reconciliation $d {param($x)$x.actual.amount=1276}}},
  @{name='variance';validator='reconciliation';code='RECONCILIATION_VARIANCE_MISMATCH';mutate={param($d)Update-Reconciliation $d {param($x)$x.variance.hours=0}}},
  @{name='variance-reason';validator='reconciliation';code='RECONCILIATION_VARIANCE_REASON_REQUIRED';mutate={param($d)Update-Reconciliation $d {param($x)$x.variance.reason_code='none'}}},
  @{name='currency';validator='reconciliation';code='RECONCILIATION_CURRENCY_MISMATCH';mutate={param($d)Update-Reconciliation $d {param($x)$x.actual.currency='USD'}}},
  @{name='invoice-claim';validator='reconciliation';code='RECONCILIATION_TRUTH_BOUNDARY_INVALID';mutate={param($d)Update-Reconciliation $d {param($x)$x.truth_boundary.invoice_claim=$true}}},
  @{name='profile-boundary';validator='profile';code='SPECTRA09_PROFILE_BOUNDARY_INVALID';mutate={param($d)Update-Reconciliation $d {param($x)$x.profile='support-only'}}},
  @{name='provenance-required';validator='provenance';code='PROVENANCE_SCHEMA_INVALID';mutate={param($d)Update-Provenance $d {param($x)$x.mapping.PSObject.Properties.Remove('mapping_version')}}},
  @{name='provenance-additional';validator='provenance';code='PROVENANCE_SCHEMA_INVALID';mutate={param($d)Update-Provenance $d {param($x)$x.source|Add-Member extra 'not-allowed'}}},
  @{name='source-path';validator='provenance';code='PROVENANCE_PATH_UNSAFE';mutate={param($d)Update-Provenance $d {param($x)$x.source.blob_path='../source.json'}}},
  @{name='projection-path';validator='provenance';code='PROVENANCE_PATH_UNSAFE';mutate={param($d)Update-Provenance $d {param($x)$x.projection.projection_path='adapter\projection\projection.json'}}},
  @{name='source-hash';validator='provenance';code='PROVENANCE_SOURCE_HASH_MISMATCH';mutate={param($d)Update-Provenance $d {param($x)$x.source.source_hash=('0'*64);$x.source.source_hash_after=('0'*64)}}},
  @{name='source-bytes';validator='provenance';code='PROVENANCE_SOURCE_HASH_MISMATCH';mutate={param($d);[IO.File]::AppendAllText((Join-Path $d 'adapter\source\source.json'),'x')}},
  @{name='projection-digest';validator='provenance';code='PROVENANCE_PROJECTION_DIGEST_MISMATCH';mutate={param($d)Update-Provenance $d {param($x)$x.projection.projection_digest=('0'*64)}}},
  @{name='source-changed';validator='provenance';code='PROVENANCE_SOURCE_CHANGED';mutate={param($d)Update-Provenance $d {param($x)$x.source.source_hash_after=('0'*64)}}},
  @{name='mapping-deterministic';validator='provenance';code='PROVENANCE_MAPPING_NOT_DETERMINISTIC';mutate={param($d)Update-Provenance $d {param($x)$x.mapping.deterministic=$false}}},
  @{name='truth-owner';validator='provenance';code='PROVENANCE_TRUTH_BOUNDARY_INVALID';mutate={param($d)Update-Provenance $d {param($x)$x.source_of_truth.owner='customer-workspace'}}},
  @{name='writes-performed';validator='provenance';code='PROVENANCE_WRITE_PROTECTION_INVALID';mutate={param($d)Update-Provenance $d {param($x)$x.write_protection.writes_performed=$true}}},
  @{name='overwrite';validator='provenance';code='PROVENANCE_WRITE_PROTECTION_INVALID';mutate={param($d)Update-Provenance $d {param($x)$x.write_protection.overwrite_allowed=$true}}},
  @{name='path-collision';validator='provenance';code='PROVENANCE_PATH_COLLISION';mutate={param($d)Update-Provenance $d {param($x)$x.projection.projection_path=$x.source.blob_path}}}
)

try{
  New-Item -ItemType Directory -Force $base|Out-Null
  foreach($case in $cases){
    $directory=Join-Path $base $case.name
    & (Join-Path $PSScriptRoot 'New-SyntheticSpectra09Profile.ps1') -Destination $directory -Profile implementation|Out-Null
    & $case.mutate $directory
    $result=Invoke-Exact $case.validator $directory
    if($result.Exit -ne 1 -or $result.Err -ne '' -or $result.Raw -cne $case.code){throw "SPECTRA09_NEGATIVE_ORACLE_FAILED:$($case.name):$($result.Exit):$($result.Raw):$($result.Err)"}
  }
  $oracle=Join-Path $base 'oracle-self-test';& (Join-Path $PSScriptRoot 'New-SyntheticSpectra09Profile.ps1') -Destination $oracle -Profile implementation|Out-Null;Update-Reconciliation $oracle {param($x)$x.baseline.amount=1201;$x.variance.hours=0};$oracleResult=Invoke-Exact 'reconciliation' $oracle
  if($oracleResult.Raw -ceq 'RECONCILIATION_VARIANCE_MISMATCH' -or $oracleResult.Raw -cne 'RECONCILIATION_BASELINE_AMOUNT_MISMATCH'){throw 'SPECTRA09_ORACLE_SELF_TEST_FAILED'}
  Write-Host "PASS: $($cases.Count) isolierte Spectra-0.9-Negativfälle und Oracle-Selbsttest."
}finally{if(Test-Path $base){Remove-Item $base -Recurse -Force -ErrorAction SilentlyContinue}}
