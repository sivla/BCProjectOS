[CmdletBinding()]param()
$ErrorActionPreference='Stop';$tmp=Join-Path $env:TEMP ('spectra-ops-negative-'+[guid]::NewGuid().ToString('N'));New-Item -ItemType Directory $tmp|Out-Null;$utf8=[Text.UTF8Encoding]::new($false)
$cases=@(
 @{code='OPS_SCHEMA_INVALID';mutate={param($x)$x.profile='unknown'}},
 @{code='CUTOVER_DEPENDENCY_INVALID';mutate={param($x)$x.cutover_tasks[2].depends_on=@()}},
 @{code='CUTOVER_SEQUENCE_INVALID';mutate={param($x)$x.cutover_tasks[2].sequence=9}},
 @{code='MOCK_CUTOVER_INCOMPLETE';mutate={param($x)$x.mock_cutover.task_refs[5]=$x.mock_cutover.task_refs[0]}},
 @{code='GO_LIVE_OPEN_HIGH_PRIORITY';mutate={param($x)$x.go_live_gate.open_p2=1}},
 @{code='HYPERCARE_CHRONOLOGY_INVALID';mutate={param($x)$x.hypercare_days[1].day='2030-03-01'}},
 @{code='HYPERCARE_RETEST_EVIDENCE_MISSING';mutate={param($x)$x.hypercare_days[0].issues[0].retest_evidence_ref='EVD-UNKNOWN'}},
 @{code='HYPERCARE_OPEN_HIGH_PRIORITY';mutate={param($x)$x.hypercare_days[0].issues[0].status='open'}},
 @{code='RESTART_RECOVERY_BINDING_MISSING';mutate={param($x)$x.restart_plan.backup_evidence_ref='EVD-UNKNOWN'}},
 @{code='SUPPORT_ACCEPTANCE_INVALID';mutate={param($x)$x.support_acceptance.backlog_refs=@('HC-UNKNOWN')}},
 @{code='HANDOVER_INCOMPLETE';mutate={param($x)$x.handover.evidence_refs[1]='EVD-UNKNOWN'}},
 @{code='OPS_CUSTOMER_OR_SECRET_MARKER';mutate={param($x)$x.handover.known_limits=@('credential_marker')}}
)
function Invoke-Exact([string]$Path){$s=[Diagnostics.ProcessStartInfo]::new();$s.FileName='powershell.exe';$s.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Run-CutoverOperationsExact.ps1`" -Path `"$Path`"";$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.RedirectStandardError=$true;$p=[Diagnostics.Process]::Start($s);$o=$p.StandardOutput.ReadToEnd().Trim();$e=$p.StandardError.ReadToEnd().Trim();$p.WaitForExit();[pscustomobject]@{Exit=$p.ExitCode;Raw=$o;Err=$e}}
try{$i=0;foreach($case in $cases){$i++;$d=Join-Path $tmp "case-$i";& (Join-Path $PSScriptRoot 'New-SyntheticCutoverOperationsHandover.ps1') -Destination $d|Out-Null;$p=Join-Path $d 'cutover-operations-handover.json';$x=Get-Content $p -Raw|ConvertFrom-Json;& $case.mutate $x;[IO.File]::WriteAllText($p,(($x|ConvertTo-Json -Depth 30)+"`n"),$utf8);$r=Invoke-Exact $d;if($r.Exit-ne1-or$r.Err-ne''-or$r.Raw-cne$case.code){throw "OPS_NEGATIVE_FAILED:${i}:$($case.code):$($r.Exit):$($r.Raw):$($r.Err)"}};Write-Host "PASS: $($cases.Count) isolierte Cutover-/Betriebs-Negativfälle."}finally{if(Test-Path $tmp){Remove-Item $tmp -Recurse -Force}}
