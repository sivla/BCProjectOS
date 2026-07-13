$ErrorActionPreference = 'Stop'
$root = Join-Path $PSScriptRoot '..'
$temp = Join-Path $env:TEMP ('bc-consultant-negative-' + [guid]::NewGuid().ToString('N'))
$utf8 = [Text.UTF8Encoding]::new($false)

$cases = @(
  @{name='missing-provenance';code='BC_KNOWLEDGE_PROVENANCE_MISSING';mutate={param($x) $x.reference_snapshot.snapshot_id=''}},
  @{name='ambiguous-provenance';code='BC_KNOWLEDGE_PROVENANCE_AMBIGUOUS';mutate={param($x) $x.reference_snapshot.source_ids=@($x.reference_snapshot.source_ids[0],$x.reference_snapshot.source_ids[0])}},
  @{name='invented-source';code='BC_KNOWLEDGE_SOURCE_UNAPPROVED';mutate={param($x) $x.knowledge_items[0].source_id='invented-source'}},
  @{name='unknown-snapshot';code='BC_KNOWLEDGE_REFERENCE_SNAPSHOT_INVALID';mutate={param($x) $x.reference_snapshot.snapshot_id='BCK-UNKNOWN'}},
  @{name='digest-mismatch';code='BC_KNOWLEDGE_REFERENCE_DIGEST_MISMATCH';mutate={param($x) $x.reference_snapshot.index_digest='0'*64}},
  @{name='pack-mismatch';code='BC_KNOWLEDGE_REFERENCE_PACK_MISMATCH';mutate={param($x) $x.knowledge_pack_id='BCKP-UNRELATED'}},
  @{name='inline-source-locks';code='BC_KNOWLEDGE_SCHEMA_INVALID';mutate={param($x) $x | Add-Member -NotePropertyName source_locks -NotePropertyValue @()}},
  @{name='absolute-path';code='BC_KNOWLEDGE_ABSOLUTE_PATH';mutate={param($x) $x.knowledge_items[0].title='C:\local\file'}},
  @{name='secret';code='BC_KNOWLEDGE_SECRET_BLOCKED';mutate={param($x) $x.knowledge_items[0].title=('pass'+'word')+'=value'}},
  @{name='customer-evidence';code='BC_KNOWLEDGE_CUSTOMER_DATA';mutate={param($x) $x.knowledge_items[0].title='customer-evidence'}},
  @{name='object-contradiction';code='BC_KNOWLEDGE_OBJECT_ID_CONTRADICTORY';mutate={param($x) $x.knowledge_items[0].object_refs=@('page:21','page:22')}},
  @{name='object-unknown';code='BC_KNOWLEDGE_OBJECT_REFERENCE_UNKNOWN';mutate={param($x) $x.knowledge_items[0].object_refs=@('page:999999')}},
  @{name='locale';code='BC_KNOWLEDGE_VERSION_LOCALE_MISMATCH';mutate={param($x) $x.knowledge_items[0].locale=''}},
  @{name='direct-mutation';code='BC_KNOWLEDGE_DIRECT_MUTATION';mutate={param($x) $x.playthroughs[0].direct_mutation=$true}},
  @{name='production-claim';code='BC_KNOWLEDGE_PRODUCTION_CLAIM';mutate={param($x) $x.knowledge_items[0].expected_effect='produktiv erfolgreich'}},
  @{name='cronus-ready';code='BC_KNOWLEDGE_CRONUS_NOT_CUSTOMER_READY';mutate={param($x) $x.playthroughs[1].title='CRONUS produktiv fertig'}}
)

function Invoke-Exact([string]$Path) {
  $start = [Diagnostics.ProcessStartInfo]::new()
  $start.FileName = 'powershell.exe'
  $start.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Run-BCConsultantKnowledgeExact.ps1`" -Path `"$Path`""
  $start.UseShellExecute = $false
  $start.RedirectStandardOutput = $true
  $start.RedirectStandardError = $true
  $process = [Diagnostics.Process]::Start($start)
  $stdout = $process.StandardOutput.ReadToEnd().Trim()
  $stderr = $process.StandardError.ReadToEnd().Trim()
  $process.WaitForExit()
  [pscustomobject]@{Exit=$process.ExitCode;Output=$stdout;Error=$stderr}
}

try {
  New-Item -ItemType Directory -Path $temp | Out-Null
  $base = Join-Path $temp 'base'
  & (Join-Path $PSScriptRoot 'New-SyntheticBCConsultantKnowledge.ps1') -Destination $base | Out-Null
  $index = 0
  foreach ($case in $cases) {
    $index++
    $path = Join-Path $temp "case-$index"
    Copy-Item -LiteralPath $base -Destination $path -Recurse
    $file = Join-Path $path 'bc-knowledge.json'
    $value = Get-Content -LiteralPath $file -Raw | ConvertFrom-Json
    & $case.mutate $value
    [IO.File]::WriteAllText($file, ($value | ConvertTo-Json -Depth 30), $utf8)
    $result = Invoke-Exact $path
    if ($result.Exit -ne 1 -or $result.Error -ne '' -or $result.Output -cne $case.code) {
      throw "BC_KNOWLEDGE_NEGATIVE_ORACLE:$($case.name):$($result.Exit):$($result.Output):$($result.Error)"
    }
    Write-Output "PASS $($case.name) ($($case.code))"
  }
  Write-Output "PASS: $($cases.Count) isolierte Consultant-Knowledge-Negativfaelle."
} finally {
  if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
