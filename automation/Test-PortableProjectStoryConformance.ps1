[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference='Stop'
$d=[IO.Path]::GetFullPath($Path)
$x=Get-Content (Join-Path $d 'project-story.json') -Raw | ConvertFrom-Json
if($x.project_id -notmatch '^PROJECT-' -or $x.story_id -notmatch '^STORY-' -or $x.classification -ne 'synthetic' -or $x.status -ne 'hypercare'){throw 'PORTABLE_IDENTITY_INVALID'}
# Kardinalitäten stammen aus der validierten Instanz und dem Profil. Synthetische
# Fixture-Größen sind kein Produktvertrag; keine feste Count-Prüfung verwenden.
$ids=@($x.offer.id)+@($x.pages|ForEach-Object id)+@($x.tickets|ForEach-Object id)+@($x.evidence|ForEach-Object id)+@($x.sessions|ForEach-Object id)+@($x.decisions|ForEach-Object id)+@($x.deliverables|ForEach-Object id)
if(@($ids|Sort-Object -Unique).Count -ne $ids.Count){throw 'PORTABLE_DUPLICATE_ID'}
$pageById=@{};$paths=@()
foreach($p in @($x.pages)){
  if($pageById.ContainsKey($p.id)){throw 'PORTABLE_DUPLICATE_ID'};$pageById[$p.id]=$p
  if($paths -contains $p.sourcePath){throw 'PORTABLE_DUPLICATE_SOURCEPATH'};$paths+=$p.sourcePath
  if($p.sourcePath -match '(^[A-Za-z]:|^/|\.\.|\\)'){throw 'PORTABLE_UNSAFE_PATH'}
  $file=Join-Path $d $p.sourcePath;if(-not(Test-Path $file -PathType Leaf)){throw 'PORTABLE_PAGE_MISSING'};$txt=Get-Content $file -Raw;if($txt -notmatch "id:\s*$($p.id)" -or $txt -notmatch "version:\s*$($p.version)" -or $txt -notmatch "status:\s*$($p.status)"){throw 'PORTABLE_PAGE_METADATA'}
}
foreach($page in @($x.pages)){if($page.parent -and -not $pageById.ContainsKey($page.parent)){throw 'PORTABLE_PAGE_PARENT'}}
foreach($p in @($x.pages)){$seen=@{};$cur=$p;while($cur.parent){if($seen.ContainsKey($cur.id)){throw 'PORTABLE_PAGE_CYCLE'};$seen[$cur.id]=$true;if(-not $pageById.ContainsKey($cur.parent)){throw 'PORTABLE_PAGE_PARENT'};$cur=$pageById[$cur.parent]}}
$hours=0;$cost=0
foreach($t in @($x.tickets)){
  if([string]::IsNullOrWhiteSpace($t.reporter) -or [string]::IsNullOrWhiteSpace($t.assignee)){throw 'PORTABLE_TICKET_FIELDS'}
  if(@($t.acceptance).Count -eq 0 -or @($t.evidence).Count -eq 0){throw 'PORTABLE_TICKET_FIELDS'}
  $history=@($t.status_history);if($history.Count -eq 0 -or $history[0].status -ne 'open' -or $history[-1].status -ne $t.status){throw 'PORTABLE_STATUS_TERMINAL'}
  for($i=1;$i -lt $history.Count;$i++){if([datetime]$history[$i].time -lt [datetime]$history[$i-1].time){throw 'PORTABLE_STATUS_HISTORY'}}
  if($t.status -in @('closed','done') -and @($t.comments|Where-Object {$_.type -eq 'closing'}).Count -ne 1){throw 'PORTABLE_CLOSING_COMMENT'}
  foreach($c in @($t.comments)){if([string]::IsNullOrWhiteSpace($c.author_role) -or [string]::IsNullOrWhiteSpace($c.text)){throw 'PORTABLE_COMMENT_FIELDS'}}
  foreach($w in @($t.worklogs)){if($w.hours -le 0){throw 'PORTABLE_WORKLOG_INVALID'};$hours+=$w.hours;$cost+=$w.cost}
}
if($hours -ne $x.offer.actual_hours -or $cost -ne $x.offer.actual_cost){throw 'PORTABLE_COST_MISMATCH'}
foreach($event in @($x.timeline)){foreach($reference in @($event.references)){if($ids -notcontains $reference){throw 'PORTABLE_TIMELINE_REFERENCE'}}}
for($i=1;$i -lt @($x.timeline).Count;$i++){if([datetime]$x.timeline[$i].time -lt [datetime]$x.timeline[$i-1].time){throw 'PORTABLE_TIMELINE_ORDER'}}
if([datetime]$x.timeline[0].time -lt [datetime]$x.offer.start_time -or [datetime]$x.timeline[-1].time -gt [datetime]$x.offer.end_time){throw 'PORTABLE_TIMELINE_RANGE'}
foreach($h in @($x.hypercare)){if($h.status -ne 'closed' -or $h.go_no_go -ne 'GO' -or [string]::IsNullOrWhiteSpace($h.daily_page) -or @($x.pages|Where-Object id -eq $h.daily_page).Count -ne 1 -or @($h.tickets).Count -eq 0){throw 'PORTABLE_HYPERCARE_EXIT'};foreach($tid in @($h.tickets)){if(@($x.tickets|Where-Object id -eq $tid).Count -ne 1){throw 'PORTABLE_HYPERCARE_TICKET_REFERENCE'}}}
if(@($x.tickets|Where-Object {$_.priority -in @('P1','P2') -and $_.status -notin @('closed','done')}).Count -gt 0){throw 'PORTABLE_HYPERCARE_OPEN_HIGH_PRIORITY'}
Write-Host 'PASS: Portable external project story conformance validated read-only.'
