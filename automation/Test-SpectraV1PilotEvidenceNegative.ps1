[CmdletBinding()]param()
$ErrorActionPreference='Stop';$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'));$temp=Join-Path $env:TEMP ('spectra-v1-pilot-neg-'+[guid]::NewGuid().ToString('N'));New-Item -ItemType Directory $temp|Out-Null;$utf8=[Text.UTF8Encoding]::new($false)
function Base-Evidence{$boundTagCommit=(&git -C $root rev-parse 'refs/tags/spectra-v0.14.0-alpha.1^{commit}').Trim();[ordered]@{schema_version=1;product_id='spectra';release_version='0.14.0-alpha.1';release_tag='spectra-v0.14.0-alpha.1';tag_commit=$boundTagCommit;simulation_boundary='synthetic_non_production';implementation=[ordered]@{profile='implementation';install='PASS';domain_flow='PASS';backup_restore='PASS';read_only_validation='PASS';status='PASS'};support_only=[ordered]@{profile='support-only';install='PASS';domain_flow='PASS';backup_restore='PASS';read_only_validation='PASS';status='PASS'};upgrade=[ordered]@{status='PASS';negative_cases=2};recovery=[ordered]@{status='PASS';negative_cases=3};documentation=[ordered]@{status='PASS';files_checked=6;language='de'};open_product_p1=0;open_product_p2=0;rc_decision='GO';known_limits=@('Synthetisch','Getrennter Release-Gate')}}
$cases=@(
 @{code='PILOT_RELEASE_BINDING_INVALID';m={param($x)$x.tag_commit=('0'*40)}},
 @{code='PILOT_EVIDENCE_SCHEMA_INVALID';m={param($x)$x.implementation.status='FAIL'}},
 @{code='PILOT_EVIDENCE_SCHEMA_INVALID';m={param($x)$x.support_only.status='FAIL'}},
 @{code='PILOT_EVIDENCE_SCHEMA_INVALID';m={param($x)$x.upgrade.status='FAIL'}},
 @{code='PILOT_EVIDENCE_SCHEMA_INVALID';m={param($x)$x.recovery.status='FAIL'}},
 @{code='PILOT_EVIDENCE_SCHEMA_INVALID';m={param($x)$x.documentation.files_checked=1}},
 @{code='PILOT_EVIDENCE_SCHEMA_INVALID';m={param($x)$x.open_product_p1=1}},
 @{code='PILOT_RC_DECISION_INVALID';m={param($x)$x.rc_decision='NO_GO'}},
 @{code='PILOT_CUSTOMER_OR_SECRET_MARKER';m={param($x)$x.known_limits=@('customer_content_marker','Getrennter Release-Gate')}}
)
function Invoke-Exact([string]$Path){$s=[Diagnostics.ProcessStartInfo]::new();$s.FileName='powershell.exe';$s.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Run-SpectraV1PilotEvidenceExact.ps1`" -Path `"$Path`" -ProductRoot `"$root`"";$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.RedirectStandardError=$true;$p=[Diagnostics.Process]::Start($s);$o=$p.StandardOutput.ReadToEnd().Trim();$e=$p.StandardError.ReadToEnd().Trim();$p.WaitForExit();[pscustomobject]@{Exit=$p.ExitCode;Raw=$o;Err=$e}}
try{$baseJson=(Base-Evidence|ConvertTo-Json -Depth 10);$i=0;foreach($case in $cases){$i++;$x=$baseJson|ConvertFrom-Json;&$case.m $x;$p=Join-Path $temp "case-$i.json";[IO.File]::WriteAllText($p,(($x|ConvertTo-Json -Depth 10)+"`n"),$utf8);$r=Invoke-Exact $p;if($r.Exit-ne1-or$r.Err-ne''-or$r.Raw-cne$case.code){$expectedTag=(&git -C $root rev-parse 'refs/tags/spectra-v0.14.0-alpha.1^{commit}').Trim();throw "PILOT_NEGATIVE_FAILED:${i}:$($case.code):$($r.Exit):$($r.Raw):$($r.Err):TAG=$($x.tag_commit):EXPECTED=$expectedTag"}};Write-Host "PASS: $($cases.Count) isolierte V1-Pilot-/RC-Negativfälle."}finally{if(Test-Path $temp){Remove-Item $temp -Recurse -Force}}
