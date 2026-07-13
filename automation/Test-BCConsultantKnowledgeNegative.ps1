$ErrorActionPreference='Stop';$root=Join-Path $PSScriptRoot '..'
$cases=@(
 @{n='missing-provenance';c='BC_KNOWLEDGE_PROVENANCE_MISSING';m={param($x)$x.source_locks[0].title=''}},
 @{n='ambiguous-provenance';c='BC_KNOWLEDGE_PROVENANCE_AMBIGUOUS';m={param($x)$x.source_locks[1].source_id=$x.source_locks[0].source_id}},
 @{n='invented-source';c='BC_KNOWLEDGE_SOURCE_UNAPPROVED';m={param($x)$x.source_locks[0].canonical_url='https://example.invalid/invented.git'}},
 @{n='absolute-path';c='BC_KNOWLEDGE_ABSOLUTE_PATH';m={param($x)$x.knowledge_items[0].title='C:\\local\\file'}},
 @{n='secret';c='BC_KNOWLEDGE_SECRET_BLOCKED';m={param($x)$x.knowledge_items[0].title=('pass'+'word')+'=value'}},
 @{n='customer-evidence';c='BC_KNOWLEDGE_CUSTOMER_DATA';m={param($x)$x.knowledge_items[0].title='customer-evidence'}},
 @{n='unbound-source';c='BC_KNOWLEDGE_PROVENANCE_UNBOUND';m={param($x)$x.source_locks[0].commit='main'}},
 @{n='object-contradiction';c='BC_KNOWLEDGE_OBJECT_ID_CONTRADICTORY';m={param($x)$x.knowledge_items[0].object_refs=@('page:21','page:22')}},
 @{n='locale';c='BC_KNOWLEDGE_VERSION_LOCALE_MISMATCH';m={param($x)$x.knowledge_items[0].locale=''}},
 @{n='direct-mutation';c='BC_KNOWLEDGE_DIRECT_MUTATION';m={param($x)$x.playthroughs[0].direct_mutation=$true}},
 @{n='production-claim';c='BC_KNOWLEDGE_PRODUCTION_CLAIM';m={param($x)$x.knowledge_items[0].expected_effect='produktiv erfolgreich'}},
 @{n='cronus-ready';c='BC_KNOWLEDGE_CRONUS_NOT_CUSTOMER_READY';m={param($x)$x.playthroughs[1].title='CRONUS produktiv fertig'}}
)
foreach($case in $cases){$d=Join-Path $env:TEMP ('bc-knowledge-neg-'+[guid]::NewGuid().ToString('N'));try{& (Join-Path $PSScriptRoot 'New-SyntheticBCConsultantKnowledge.ps1') -Destination $d|Out-Null;$p=Join-Path $d 'bc-knowledge.json';$x=Get-Content -Raw $p|ConvertFrom-Json;&$case.m $x;[IO.File]::WriteAllText($p,($x|ConvertTo-Json -Depth 30),[Text.UTF8Encoding]::new($false));$s=[Diagnostics.ProcessStartInfo]::new();$s.FileName='powershell.exe';$s.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Run-BCConsultantKnowledgeExact.ps1`" -Path `"$d`"";$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.RedirectStandardError=$true;$proc=[Diagnostics.Process]::Start($s);$o=$proc.StandardOutput.ReadToEnd().Trim();$e=$proc.StandardError.ReadToEnd().Trim();$proc.WaitForExit();if($proc.ExitCode -ne 1 -or $e -ne '' -or $o -cne $case.c){throw "BC_KNOWLEDGE_NEGATIVE_ORACLE:$($case.n):$o"};Write-Output "PASS $($case.n) ($($case.c))"}finally{if(Test-Path $d){Remove-Item $d -Recurse -Force}}}
Write-Output "PASS: $($cases.Count) isolierte Consultant-Knowledge-Negativfaelle."
