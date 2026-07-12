[CmdletBinding()]param()
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$base=Join-Path ([IO.Path]::GetTempPath()) ('spectra-graph-coverage-negative-'+[guid]::NewGuid().ToString('N'))
$utf8=New-Object Text.UTF8Encoding($false)
function Read-Record([string]$Directory){Get-Content (Join-Path $Directory 'graph\reference-graph-coverage.json') -Raw|ConvertFrom-Json}
function Write-Record([string]$Directory,$Value){[IO.File]::WriteAllText((Join-Path $Directory 'graph\reference-graph-coverage.json'),(($Value|ConvertTo-Json -Depth 30)+"`n"),$utf8)}
function Invoke-Exact([string]$Directory){
  $start=[Diagnostics.ProcessStartInfo]::new();$start.FileName='powershell.exe';$start.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Run-ReferenceGraphCoverageExact.ps1`" -Path `"$Directory`"";$start.UseShellExecute=$false;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
  $process=[Diagnostics.Process]::Start($start);$out=$process.StandardOutput.ReadToEnd().Trim();$err=$process.StandardError.ReadToEnd().Trim();$process.WaitForExit();[pscustomobject]@{Exit=$process.ExitCode;Raw=$out;Err=$err}
}
$cases=@(
  @{name='missing-class';code='GRAPH_COVERAGE_CLASS_MISSING';mutate={param($x)$x.mappings=@($x.mappings|Where-Object native_class -ne 'internal-display-order')}},
  @{name='false-sums';code='GRAPH_COVERAGE_SUMMARY_MISMATCH';mutate={param($x)$x.summary.native_total=13}},
  @{name='unknown-reason';code='GRAPH_COVERAGE_REASON_UNKNOWN';mutate={param($x)$x.mappings[0].reason_code='invented'}},
  @{name='manipulated-digest';code='GRAPH_COVERAGE_DIGEST_MISMATCH';mutate={param($x)$x.provenance.source.sha256=('0'*64)}},
  @{name='unexplained-exclusion';code='GRAPH_COVERAGE_EXCLUSION_UNEXPLAINED';mutate={param($x)$x.mappings[3].reason_code='direct'}},
  @{name='duplicate-mapping';code='GRAPH_COVERAGE_DUPLICATE_MAPPING';mutate={param($x)$copy=$x.mappings[0]|ConvertTo-Json|ConvertFrom-Json;$copy.mapping_id='MAP-DUPLICATE-PAGE-TICKET';$x.mappings=@($x.mappings+$copy)}},
  @{name='unsafe-path';code='GRAPH_COVERAGE_PATH_UNSAFE';mutate={param($x)$x.provenance.source.path='../native-relations.json'}},
  @{name='invented-completeness';code='GRAPH_COVERAGE_COMPLETENESS_CLAIM_INVALID';mutate={param($x)$x.claims.complete_projection_claim=$true}}
)
try{
  New-Item -ItemType Directory -Force $base|Out-Null
  foreach($case in $cases){
    $directory=Join-Path $base $case.name;& (Join-Path $PSScriptRoot 'New-SyntheticReferenceGraphCoverage.ps1') -Destination $directory|Out-Null
    $record=Read-Record $directory;& $case.mutate $record;Write-Record $directory $record
    $result=Invoke-Exact $directory
    if($result.Exit -ne 1 -or $result.Err -ne '' -or $result.Raw -cne $case.code){throw "GRAPH_COVERAGE_NEGATIVE_ORACLE_FAILED:$($case.name):$($result.Exit):$($result.Raw):$($result.Err)"}
  }
  $oracle=Join-Path $base 'oracle-self-test';& (Join-Path $PSScriptRoot 'New-SyntheticReferenceGraphCoverage.ps1') -Destination $oracle|Out-Null;$record=Read-Record $oracle;$record.provenance.source.path='../unsafe';$record.summary.native_total=99;Write-Record $oracle $record;$result=Invoke-Exact $oracle
  if($result.Raw -ceq 'GRAPH_COVERAGE_SUMMARY_MISMATCH' -or $result.Raw -cne 'GRAPH_COVERAGE_PATH_UNSAFE'){throw 'GRAPH_COVERAGE_ORACLE_SELF_TEST_FAILED'}
  Write-Host "PASS: $($cases.Count) isolierte Coverage-Negativfälle und Oracle-Selbsttest."
}finally{if(Test-Path $base){Remove-Item $base -Recurse -Force -ErrorAction SilentlyContinue}}
