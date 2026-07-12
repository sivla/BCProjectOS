[CmdletBinding()]param()
$ErrorActionPreference='Stop';$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'));$tmp=Join-Path $env:TEMP ('spectra-uat-negative-'+[guid]::NewGuid().ToString('N'));$utf8=New-Object Text.UTF8Encoding($false)
function Invoke-Exact([string]$d){$s=[Diagnostics.ProcessStartInfo]::new();$s.FileName='powershell.exe';$s.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Run-UatTrainingDefectsExact.ps1`" -Path `"$d`"";$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.RedirectStandardError=$true;$p=[Diagnostics.Process]::Start($s);$o=$p.StandardOutput.ReadToEnd().Trim();$e=$p.StandardError.ReadToEnd().Trim();$p.WaitForExit();[pscustomobject]@{Exit=$p.ExitCode;Raw=$o;Err=$e}}
$cases=@(
 @{name='schema';code='UAT_TRAINING_DEFECT_SCHEMA_INVALID';m={param($x)$x.profile='unknown'}},
 @{name='duplicate';code='UAT_DUPLICATE_ID';m={param($x)$x.test_cases[1].id=$x.test_cases[0].id}},
 @{name='coverage';code='UAT_CORE_PROCESS_COVERAGE_MISSING';m={param($x)$x.uat_plan.required_processes[6]='finance'}},
 @{name='entry';code='UAT_TRAINING_DEFECT_SCHEMA_INVALID';m={param($x)$x.uat_plan.entry_criteria=@()}},
 @{name='path';code='UAT_PATH_COVERAGE_MISSING';m={param($x)$x.test_cases=@($x.test_cases|Where-Object{$_.path_type-ne'negative'})}},
 @{name='reference';code='UAT_REFERENCE_UNKNOWN';m={param($x)$x.test_cases[0].role_ref='ROLE-UNKNOWN'}},
 @{name='evidence';code='UAT_TRAINING_DEFECT_SCHEMA_INVALID';m={param($x)$x.test_cases[0].evidence_refs=@()}},
 @{name='training-role';code='TRAINING_ROLE_UNKNOWN';m={param($x)$x.training_paths[0].role_ref='ROLE-UNKNOWN'}},
 @{name='competency';code='TRAINING_COMPETENCY_EVIDENCE_MISSING';m={param($x)$x.training_paths[0].competency_evidence_ref='EVD-UNKNOWN'}},
 @{name='smoke';code='UAT_TRAINING_DEFECT_SCHEMA_INVALID';m={param($x)$x.training_paths[0].operator_smoke=''}},
 @{name='reproduction';code='UAT_TRAINING_DEFECT_SCHEMA_INVALID';m={param($x)$x.defects[0].reproduction_steps=@()}},
 @{name='transition';code='DEFECT_STATUS_TRANSITION_INVALID';m={param($x)$x.defects[0].status_history[2].status='closed'}},
 @{name='fix-retest';code='DEFECT_FIX_RETEST_EVIDENCE_MISSING';m={param($x)$x.defects[0].retest_evidence_refs=@()}},
 @{name='waiver';code='DEFECT_WAIVER_DECISION_MISSING';m={param($x)$x.defects[1].waiver_decision_ref=$null}},
 @{name='open-p2';code='UAT_EXIT_OPEN_HIGH_PRIORITY';m={param($x)$x.defects[0].status='in_progress';$x.defects[0].status_history=@($x.defects[0].status_history[0],$x.defects[0].status_history[1],[pscustomobject]@{status='in_progress';time='2030-03-01T11:00:00Z';role_ref='ROLE-TEST-LEAD'});$x.exit_gate.status='GO'}},
 @{name='marker';code='UAT_CUSTOMER_OR_SECRET_MARKER';m={param($x)$x.uat_plan.entry_criteria[0]='customer_content_marker'}}
)
try{foreach($c in $cases){$d=Join-Path $tmp $c.name;& (Join-Path $PSScriptRoot 'New-SyntheticUatTrainingDefects.ps1') -Destination $d|Out-Null;$p=Join-Path $d 'uat-training-defects.json';$x=Get-Content $p -Raw|ConvertFrom-Json;&$c.m $x;[IO.File]::WriteAllText($p,(($x|ConvertTo-Json -Depth 40)+"`n"),$utf8);$r=Invoke-Exact $d;if($r.Exit-ne1-or$r.Err-ne''-or$r.Raw-cne$c.code){throw "UAT_NEGATIVE_FAILED:$($c.name):$($r.Exit):$($r.Raw):$($r.Err)"}};Write-Host "PASS: $($cases.Count) isolierte UAT-/Training-/Defect-Negativfälle."}finally{if(Test-Path $tmp){Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue}}
