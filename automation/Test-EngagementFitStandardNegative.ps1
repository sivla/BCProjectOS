[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$temp=Join-Path ([IO.Path]::GetTempPath()) ('spectra-engagement-negative-'+[guid]::NewGuid().ToString('N'))
$utf8=New-Object Text.UTF8Encoding($false)
function Invoke-Exact([string]$Directory){
  $start=[Diagnostics.ProcessStartInfo]::new();$start.FileName='powershell.exe';$start.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Run-EngagementFitStandardExact.ps1`" -Path `"$Directory`"";$start.UseShellExecute=$false;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
  $process=[Diagnostics.Process]::Start($start);$out=$process.StandardOutput.ReadToEnd().Trim();$err=$process.StandardError.ReadToEnd().Trim();$process.WaitForExit();[pscustomobject]@{Exit=$process.ExitCode;Raw=$out;Err=$err}
}
$cases=@(
  @{name='schema-required';code='ENGAGEMENT_SCHEMA_INVALID';mutate={param($x)$x.PSObject.Properties.Remove('offer')}},
  @{name='duplicate-id';code='ENGAGEMENT_DUPLICATE_ID';mutate={param($x)$x.scope_items[1].scope_id=$x.scope_items[0].scope_id}},
  @{name='offer-period';code='ENGAGEMENT_OFFER_PERIOD_INVALID';mutate={param($x)$x.offer.valid_from='2031-01-01'}},
  @{name='assumption-ref';code='ENGAGEMENT_ASSUMPTION_REFERENCE_INVALID';mutate={param($x)$x.scope_items[0].assumption_ids=@('ASM-UNKNOWN')}},
  @{name='phase-sequence';code='ENGAGEMENT_PHASE_SEQUENCE_INVALID';mutate={param($x)$x.phases[1].sequence=4}},
  @{name='phase-ref';code='ENGAGEMENT_PHASE_REFERENCE_INVALID';mutate={param($x)$x.deliverables[0].phase_id='PHA-UNKNOWN'}},
  @{name='raci-missing-a';code='ENGAGEMENT_RACI_INCOMPLETE';mutate={param($x)$x.raci=@($x.raci|Where-Object{!($_.deliverable_id-eq'DLV-SYN-SCOPE'-and$_.responsibility-eq'A')})}},
  @{name='raci-duplicate';code='ENGAGEMENT_RACI_DUPLICATE';mutate={param($x)$x.raci=@($x.raci+$x.raci[0])}},
  @{name='process-sequence';code='ENGAGEMENT_PROCESS_SEQUENCE_INVALID';mutate={param($x)$x.processes[0].steps[1].sequence=3}},
  @{name='process-ref';code='ENGAGEMENT_PROCESS_REFERENCE_INVALID';mutate={param($x)$x.use_cases[0].process_id='PRO-UNKNOWN'}},
  @{name='recommendation';code='ENGAGEMENT_RECOMMENDATION_INVALID';mutate={param($x)$x.assessments[0].recommended_option_id='OPT-UNKNOWN'}},
  @{name='decision-mismatch';code='ENGAGEMENT_DECISION_MISMATCH';mutate={param($x)$x.decisions[0].selected_option_id='OPT-SYN-P2P-CONFIG'}},
  @{name='gate-evidence';code='ENGAGEMENT_GATE_EVIDENCE_MISSING';mutate={param($x)$x.gates[0].evidence_refs=@()}},
  @{name='question-evidence';code='ENGAGEMENT_QUESTION_EVIDENCE_INVALID';mutate={param($x)$x.open_questions[0].source_refs=@()}},
  @{name='open-assumption-ready';code='ENGAGEMENT_READINESS_FALSE_CLAIM';mutate={param($x)$x.assumptions[0].status='open'}},
  @{name='open-question-ready';code='ENGAGEMENT_READINESS_FALSE_CLAIM';mutate={param($x)$x.open_questions[0].status='open';$x.open_questions[0].answer=$null}},
  @{name='undecided-gap-ready';code='ENGAGEMENT_READINESS_FALSE_CLAIM';mutate={param($x)$x.assessments[2].status='open'}},
  @{name='truth-boundary';code='ENGAGEMENT_TRUTH_BOUNDARY_INVALID';mutate={param($x)$x.truth_boundary.source_of_truth='product-template'}}
)
try{
  New-Item -ItemType Directory -Force $temp|Out-Null
  foreach($case in $cases){
    $directory=Join-Path $temp $case.name
    & (Join-Path $PSScriptRoot 'New-SyntheticEngagementFitStandard.ps1') -Destination $directory|Out-Null
    $path=Join-Path $directory 'engagement-fit-standard.json';$record=Get-Content $path -Raw|ConvertFrom-Json;& $case.mutate $record;[IO.File]::WriteAllText($path,(($record|ConvertTo-Json -Depth 40)+"`n"),$utf8)
    $result=Invoke-Exact $directory
    if($result.Exit-ne1-or$result.Err-ne''-or$result.Raw-cne$case.code){throw "ENGAGEMENT_NEGATIVE_ORACLE_FAILED:$($case.name):$($result.Exit):$($result.Raw):$($result.Err)"}
  }
  $oracle=Join-Path $temp 'oracle-self-test';& (Join-Path $PSScriptRoot 'New-SyntheticEngagementFitStandard.ps1') -Destination $oracle|Out-Null;$path=Join-Path $oracle 'engagement-fit-standard.json';$record=Get-Content $path -Raw|ConvertFrom-Json;$record.offer.valid_from='2031-01-01';$record.assumptions[0].status='open';[IO.File]::WriteAllText($path,(($record|ConvertTo-Json -Depth 40)+"`n"),$utf8);$result=Invoke-Exact $oracle
  if($result.Raw-ceq'ENGAGEMENT_READINESS_FALSE_CLAIM'-or$result.Raw-cne'ENGAGEMENT_OFFER_PERIOD_INVALID'){throw 'ENGAGEMENT_ORACLE_SELF_TEST_FAILED'}
  Write-Host "PASS: $($cases.Count) isolierte Engagement-Negativfälle und Oracle-Selbsttest."
}finally{if(Test-Path $temp){Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue}}
