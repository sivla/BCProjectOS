[CmdletBinding()]param()
$ErrorActionPreference='Stop';$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$cases=@(
 @{code='STORY_SCHEMA_TYPE_INVALID';mut={param($x) $x.offer.scope=123}},
 @{code='STORY_SCHEMA_ADDITIONAL_PROPERTY';mut={param($x) Add-Member -InputObject $x.offer -NotePropertyName extra -NotePropertyValue 'x'}},
 @{code='STORY_CLOSING_COMMENT_MISSING';mut={param($x) $x.tickets[0].comments=@($x.tickets[0].comments|? type -ne 'closing')}},
 @{code='STORY_WORKLOG_TOTAL_INVALID';mut={param($x) $x.offer.actual_hours=99}},
 @{code='STORY_STATUS_TIME_TRAVEL';mut={param($x) $x.tickets[0].status_history=@([ordered]@{status='open';time='2026-01-04T10:00:00Z'},[ordered]@{status='done';time='2026-01-03T10:00:00Z'})}},
 @{code='STORY_STATUS_TERMINAL_MISMATCH';mut={param($x) $x.tickets[0].status='open'}},
 @{code='STORY_PAGE_CYCLE';mut={param($x) $x.pages[0].parent='PAGE-HARD-002'}},
 @{code='STORY_PAGE_METADATA_MISMATCH';mut={param($x) $x.pages[0].version=2}},
 @{code='STORY_TIMELINE_REFERENCE_INVALID';mut={param($x) $x.timeline[0].references=@('UNKNOWN')}},
 @{code='STORY_TIMELINE_RANGE_INVALID';mut={param($x) $x.timeline[0].time='2025-01-01T00:00:00Z'}},
 @{code='STORY_HYPERCARE_OPEN_HIGH_PRIORITY';mut={param($x) $x.tickets[0].status='open';$x.tickets[0].status_history=@([ordered]@{status='open';time='2026-01-02T10:00:00Z'})}},
 @{code='STORY_SCHEMA_ENUM_INVALID';mut={param($x) $x.graph[0].type='unknown'}},
 @{code='STORY_GRAPH_INVERSE_MISSING';mut={param($x) $x.graph=@($x.graph|? { -not($_.from -eq 'OFR-HARD-001' -and $_.to -eq 'PAGE-HARD-001')})}},
 @{code='STORY_GRAPH_INVERSE_TYPE_MISMATCH';mut={param($x) $x.graph[1].type='ticket-story'}}
)
function Invoke-Validator([string]$dir){$psi=[Diagnostics.ProcessStartInfo]::new();$psi.FileName='powershell.exe';$psi.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Test-ProjectStoryContract.ps1`" -Path `"$dir`"";$psi.RedirectStandardOutput=$true;$psi.RedirectStandardError=$true;$psi.UseShellExecute=$false;$p=[Diagnostics.Process]::Start($psi);$stdout=$p.StandardOutput.ReadToEnd();$stderr=$p.StandardError.ReadToEnd();$p.WaitForExit();[pscustomobject]@{Code=$p.ExitCode;Text=$stdout+$stderr}}
foreach($case in $cases){$caseRoot=Join-Path ([IO.Path]::GetTempPath()) ('hard-neg-'+[guid]::NewGuid().ToString('N'));try{& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'automation/New-SyntheticProjectStoryHardening.ps1') -Destination $caseRoot|Out-Null;$x=Get-Content (Join-Path $caseRoot 'project-story.json') -Raw|ConvertFrom-Json;& $case.mut $x;$x|ConvertTo-Json -Depth 40|Set-Content (Join-Path $caseRoot 'project-story.json') -Encoding utf8;$r=Invoke-Validator $caseRoot;if($r.Code -eq 0 -or $r.Text -notmatch [regex]::Escape($case.code)){throw "STORY_NEGATIVE_EXPECTED_$($case.code)"};Write-Host "PASS: $($case.code)"}finally{if(Test-Path $caseRoot){Remove-Item $caseRoot -Recurse -Force -ErrorAction SilentlyContinue}}}
$self=Join-Path ([IO.Path]::GetTempPath()) ('hard-self-'+[guid]::NewGuid().ToString('N'));try{& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'automation/New-SyntheticProjectStoryHardening.ps1') -Destination $self|Out-Null;$sx=Get-Content (Join-Path $self 'project-story.json') -Raw|ConvertFrom-Json;Add-Member -InputObject $sx.offer -NotePropertyName extra -NotePropertyValue 'x';$sx.offer.scope=123;$sx|ConvertTo-Json -Depth 40|Set-Content (Join-Path $self 'project-story.json');$sr=Invoke-Validator $self;if($sr.Code -eq 0 -or $sr.Text -notmatch 'STORY_SCHEMA_TYPE_INVALID' -or $sr.Text -match 'STORY_SCHEMA_ADDITIONAL_PROPERTY'){throw 'STORY_HARNESS_ORACLE_SELFTEST_FAILED'};Write-Host 'PASS: STORY_HARNESS_ORACLE_SELFTEST'}finally{if(Test-Path $self){Remove-Item $self -Recurse -Force -ErrorAction SilentlyContinue}}
Write-Host "PASS: $($cases.Count) independent negative fixtures with raw exit/output assertions."
