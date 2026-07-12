[CmdletBinding()]param()
$ErrorActionPreference='Stop';$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
function Invoke-V([string]$d){$s=[Diagnostics.ProcessStartInfo]::new();$s.FileName='powershell.exe';$s.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Run-PortableConformanceExact.ps1`" -Path `"$d`"";$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.RedirectStandardError=$true;$p=[Diagnostics.Process]::Start($s);$o=$p.StandardOutput.ReadToEnd().Trim();$e=$p.StandardError.ReadToEnd().Trim();$p.WaitForExit();[pscustomobject]@{Exit=$p.ExitCode;Raw=$o;Err=$e}}
function Invoke-V([string]$d){$s=[Diagnostics.ProcessStartInfo]::new();$s.FileName='powershell.exe';$s.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Test-PortableProjectStoryConformance.ps1`" -Path `"$d`"";$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.RedirectStandardError=$true;$p=[Diagnostics.Process]::Start($s);$o=$p.StandardOutput.ReadToEnd();$e=$p.StandardError.ReadToEnd();$p.WaitForExit();[pscustomobject]@{Exit=$p.ExitCode;Raw=$o+$e}}
function Remove-Prop($o,$n){$o.PSObject.Properties.Remove($n)};function Unknown-Ref($x,$domain){$x.timeline[0].references=@("UNKNOWN-$domain")};function Drop-Edge($x){$x.graph=@($x.graph|Select-Object -First 1)}
function Invoke-V([string]$d){$s=[Diagnostics.ProcessStartInfo]::new();$s.FileName='powershell.exe';$s.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Run-PortableConformanceExact.ps1`" -Path `"$d`"";$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.RedirectStandardError=$true;$p=[Diagnostics.Process]::Start($s);$o=$p.StandardOutput.ReadToEnd().Trim();$e=$p.StandardError.ReadToEnd().Trim();$p.WaitForExit();[pscustomobject]@{Exit=$p.ExitCode;Raw=$o;Err=$e}}
$cases=@(
 @{code='PORTABLE_SCHEMA_REQUIRED';m={param($x)Remove-Prop $x 'project_id'}},
 @{code='PORTABLE_SCHEMA_TYPE_INVALID';m={param($x)$x.story_id=42}},
 @{code='PORTABLE_SCHEMA_ADDITIONAL_PROPERTY';m={param($x)Add-Member -InputObject $x.offer -NotePropertyName extra -NotePropertyValue x}},
 @{code='PORTABLE_TIMELINE_RANGE';m={param($x)$x.offer.end_time='2020-01-01T00:00:00Z'}},
 @{code='PORTABLE_DUPLICATE_ID';m={param($x)$x.pages[1].id=$x.pages[0].id}},
 @{code='PORTABLE_DUPLICATE_SOURCEPATH';m={param($x)$x.pages[1].sourcePath=$x.pages[0].sourcePath}},
 @{code='PORTABLE_PAGE_PARENT';m={param($x)$x.pages[1].parent='UNKNOWN'}},
 @{code='PORTABLE_PAGE_CYCLE';m={param($x)$x.pages[0].parent='PAGE-PORT-02';$x.pages[1].parent='PAGE-PORT-01'}},
 @{code='PORTABLE_PAGE_METADATA';m={param($x)$x.pages[0].version=2}},
 @{code='PORTABLE_STATUS_HISTORY';m={param($x)$x.tickets[0].status_history[1].time='2026-01-01T00:00:00Z'}},
 @{code='PORTABLE_STATUS_TERMINAL';m={param($x)$x.tickets[0].status='open'}},
 @{code='PORTABLE_SCHEMA_MINITEMS';m={param($x)$x.tickets[0].acceptance=@()}},
 @{code='PORTABLE_SCHEMA_MINITEMS';m={param($x)$x.tickets[0].evidence=@()}},
 @{code='PORTABLE_SCHEMA_MINITEMS';m={param($x)$x.tickets[0].comments=@($x.tickets[0].comments|? type -ne closing)}},
 @{code='PORTABLE_WORKLOG_INVALID';m={param($x)$x.tickets[0].worklogs[0].hours=0}},
 @{code='PORTABLE_COST_MISMATCH';m={param($x)$x.offer.actual_hours=1}},
 @{code='PORTABLE_TIMELINE_REFERENCE';domain='page';m={param($x)Unknown-Ref $x page}},
 @{code='PORTABLE_TIMELINE_REFERENCE';domain='ticket';m={param($x)Unknown-Ref $x ticket}},
 @{code='PORTABLE_TIMELINE_REFERENCE';domain='evidence';m={param($x)Unknown-Ref $x evidence}},
 @{code='PORTABLE_TIMELINE_REFERENCE';domain='session';m={param($x)Unknown-Ref $x session}},
 @{code='PORTABLE_TIMELINE_REFERENCE';domain='decision';m={param($x)Unknown-Ref $x decision}},
 @{code='PORTABLE_TIMELINE_REFERENCE';domain='deliverable';m={param($x)Unknown-Ref $x deliverable}},
 @{code='PORTABLE_TIMELINE_RANGE';m={param($x)$x.timeline[0].time='2020-01-01T00:00:00Z'}},
 @{code='PORTABLE_TIMELINE_ORDER';m={param($x)$x.timeline[1].time='2026-01-01T00:00:00Z'}},
 @{code='PORTABLE_HYPERCARE_EXIT';m={param($x)$x.hypercare[0].daily_page='UNKNOWN'}},
 @{code='PORTABLE_HYPERCARE_OPEN_HIGH_PRIORITY';m={param($x)$x.tickets[0].priority='P1';$x.tickets[0].status='open';$x.tickets[0].status_history=@([ordered]@{status='open';time='2026-02-01T09:00:00Z'})}},
 @{code='PORTABLE_GRAPH_ORPHAN';m={param($x)$x.graph[0].from='UNKNOWN'}},
 @{code='PORTABLE_GRAPH_INVERSE';m={param($x)$x.graph=@($x.graph+([ordered]@{from='PAGE-PORT-01';to='TKT-PORT-01';type='page-ticket'}))}},
 @{code='PORTABLE_GRAPH_INVERSE';m={param($x)Drop-Edge $x}},
 @{code='PORTABLE_GRAPH_INVERSE';m={param($x)$x.graph[1].type='page-ticket'}},
 @{code='PORTABLE_UNSAFE_PATH';m={param($x)$x.pages[0].sourcePath='../secret.txt'}}
)
foreach($c in $cases){$d=Join-Path ([IO.Path]::GetTempPath()) ('portable-neg-'+[guid]::NewGuid().ToString('N'));try{& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'automation/New-PortableProjectStoryFixture.ps1') -Destination $d|Out-Null;$x=Get-Content (Join-Path $d 'project-story.json') -Raw|ConvertFrom-Json;& $c.m $x;$x|ConvertTo-Json -Depth 40|Set-Content (Join-Path $d 'project-story.json');$r=Invoke-V $d;if($r.Exit -eq 0 -or $r.Raw -notmatch [regex]::Escape($c.code)){throw "PORTABLE_NEGATIVE_EXPECTED_$($c.code)"};Write-Host "PASS: $($c.code)"}finally{if(Test-Path $d){Remove-Item $d -Recurse -Force -ErrorAction SilentlyContinue}}}
$self=Join-Path ([IO.Path]::GetTempPath()) ('portable-self-'+[guid]::NewGuid().ToString('N'));try{& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'automation/New-PortableProjectStoryFixture.ps1') -Destination $self|Out-Null;$sx=Get-Content (Join-Path $self 'project-story.json') -Raw|ConvertFrom-Json;$sx.offer.actual_cost=1;$sx|ConvertTo-Json -Depth 40|Set-Content (Join-Path $self 'project-story.json');$sr=Invoke-V $self;if($sr.Exit -eq 0 -or $sr.Raw -notmatch 'PORTABLE_COST_MISMATCH'){throw 'PORTABLE_HARNESS_ORACLE_SELFTEST_FAILED'};Write-Host 'PASS: PORTABLE_HARNESS_ORACLE_SELFTEST'}finally{if(Test-Path $self){Remove-Item $self -Recurse -Force -ErrorAction SilentlyContinue}}
Write-Host "PASS: $($cases.Count) data-driven portable negative fixtures."
