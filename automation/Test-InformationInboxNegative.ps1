[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$utf8 = [Text.UTF8Encoding]::new($false)
function Invoke-Exact([string]$d) {
  $s=[Diagnostics.ProcessStartInfo]::new();$s.FileName='powershell.exe';$s.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Run-InformationInboxExact.ps1`" -Path `"$d`"";$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.RedirectStandardError=$true;$p=[Diagnostics.Process]::Start($s);$o=$p.StandardOutput.ReadToEnd().Trim();$e=$p.StandardError.ReadToEnd().Trim();$p.WaitForExit();[pscustomobject]@{Exit=$p.ExitCode;Output=$o;Error=$e}
}
function New-Case([string]$name,[scriptblock]$mutation,[string]$code) {
  $d=Join-Path ([IO.Path]::GetTempPath()) ("inbox-negative-$name-"+[guid]::NewGuid().ToString('N'))
  try {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'automation\New-SyntheticInformationInbox.ps1') -Destination $d | Out-Null
    $x=Get-Content (Join-Path $d 'information-inbox.json') -Raw|ConvertFrom-Json
    & $mutation $x $d
    [IO.File]::WriteAllText((Join-Path $d 'information-inbox.json'),(($x|ConvertTo-Json -Depth 40)+"`n"),$utf8)
    $r=Invoke-Exact $d
    if($r.Exit -ne 1 -or $r.Error -ne '' -or $r.Output -cne $code){throw "INBOX_NEGATIVE_FAILED:${name}:${code}:$($r.Exit):$($r.Output):$($r.Error)"}
    Write-Host "PASS: $name ($code)"
  } finally {if(Test-Path $d){Remove-Item $d -Recurse -Force -ErrorAction SilentlyContinue}}
}
$cases=@(
  @{name='missing-provenance';code='INBOX_PROVENANCE_REQUIRED';m={param($x,$d)$x.intake_items[0].source.revision=''}},
  @{name='source-changed';code='INBOX_SOURCE_CHANGED';m={param($x,$d)[IO.File]::AppendAllText((Join-Path $d 'source/meeting.md'),'changed')}} ,
  @{name='unknown-target';code='INBOX_TARGET_UNKNOWN';m={param($x,$d)$x.proposals[0].target_id='SUP-UNKNOWN'}},
  @{name='self-approval';code='INBOX_SELF_APPROVAL_FORBIDDEN';m={param($x,$d)$x.proposals[0].reviewer_role='consultant'}},
  @{name='direct-mutation';code='INBOX_DIRECT_MUTATION_FORBIDDEN';m={param($x,$d)[IO.File]::WriteAllText((Join-Path $d 'targets/status.md'),'changed',[Text.UTF8Encoding]::new($false))}},
  @{name='duplicate-processing';code='INBOX_DUPLICATE_PROCESSING';m={param($x,$d)$copy=($x.intake_items[0]|ConvertTo-Json -Depth 20|ConvertFrom-Json);$copy.id='INTAKE-SYN-002';$x.intake_items=@($x.intake_items)+$copy}},
  @{name='sensitive-content';code='INBOX_SENSITIVE_CONTENT_BLOCKED';m={param($x,$d)$p=Join-Path $d 'source/meeting.md';$s=('pass'+'word')+'='+('synthetic-'+'secret');[IO.File]::WriteAllText($p,$s,[Text.UTF8Encoding]::new($false));$x.intake_items[0].source.sha256=(Get-FileHash $p -Algorithm SHA256).Hash.ToLowerInvariant()}},
  @{name='unsafe-path';code='INBOX_PATH_UNSAFE';m={param($x,$d)$x.intake_items[0].source.relative_path='../outside.md'}},
  @{name='illegal-transition';code='INBOX_STATUS_TRANSITION_INVALID';m={param($x,$d)$x.proposals[0].status_history[1].status='umgesetzt'}},
  @{name='missing-implementation-evidence';code='INBOX_IMPLEMENTATION_EVIDENCE_REQUIRED';m={param($x,$d)$x.proposals[0].implementation_evidence=$null}},
  @{name='audit-without-source';code='INBOX_AUDIT_SOURCE_REQUIRED';m={param($x,$d)$x.audit_events[1].source_revision=$null}}
)
foreach($case in $cases){New-Case $case.name $case.m $case.code}
Write-Host "PASS: $($cases.Count) isolierte Information-Inbox-Negativfälle."
