[CmdletBinding()]param()
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$codes=@('STORY_CLOSING_COMMENT_MISSING','STORY_WORKLOG_TOTAL_INVALID','STORY_SCHEMA_REQUIRED','STORY_STATUS_TIME_TRAVEL','STORY_PAGE_CYCLE','STORY_TIMELINE_REFERENCE_INVALID','STORY_HYPERCARE_FIELDS_INVALID','STORY_GRAPH_INVERSE_MISSING')
$tmp=Join-Path ([IO.Path]::GetTempPath()) ('hard-neg-'+[guid]::NewGuid().ToString('N'))
try {
  & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'automation/New-SyntheticProjectStoryHardening.ps1') -Destination $tmp|Out-Null
  $base=Get-Content (Join-Path $tmp 'project-story.json') -Raw|ConvertFrom-Json
  for($i=0;$i -lt $codes.Count;$i++) {
    $x=$base|ConvertTo-Json -Depth 30|ConvertFrom-Json
    if($i -eq 0){$x.tickets[0].comments=@($x.tickets[0].comments|? type -ne 'closing')}
    if($i -eq 1){$x.offer.actual_hours=99}
    if($i -eq 2){$x.PSObject.Properties.Remove('offer')}
    if($i -eq 3){$x.tickets[0].status_history=@([ordered]@{status='done';time='2026-01-04T10:00:00Z'},[ordered]@{status='open';time='2026-01-03T10:00:00Z'})}
    if($i -eq 4){$x.pages[0].parent='PAGE-HARD-002'}
    if($i -eq 5){$x.timeline[0].references=@('UNKNOWN')}
    if($i -eq 6){$x.hypercare[0].tickets=@()}
    if($i -eq 7){$x.graph=@($x.graph|? { -not($_.from -eq 'OFR-HARD-001' -and $_.to -eq 'PAGE-HARD-001')})}
    $x|ConvertTo-Json -Depth 30|Set-Content (Join-Path $tmp 'project-story.json') -Encoding utf8
    $old=$ErrorActionPreference;$ErrorActionPreference='Continue';$out=& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'automation/Test-ProjectStoryContract.ps1') -Path $tmp 2>&1;$ErrorActionPreference=$old
    $text=$out -join "`n"
    if($LASTEXITCODE -eq 0 -or $text -notmatch $codes[$i]){throw "STORY_NEGATIVE_EXPECTED_$($codes[$i])"}
    Write-Host "PASS: $($codes[$i])"
  }
} finally { if(Test-Path $tmp){Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue} }
