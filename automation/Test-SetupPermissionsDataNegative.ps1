[CmdletBinding()]param()
$ErrorActionPreference='Stop';$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'));$temp=Join-Path $env:TEMP ('spectra-setup-negative-'+[guid]::NewGuid().ToString('N'));$utf8=New-Object Text.UTF8Encoding($false)
function Invoke-Exact([string]$dir){$s=[Diagnostics.ProcessStartInfo]::new();$s.FileName='powershell.exe';$s.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Run-SetupPermissionsDataExact.ps1`" -Path `"$dir`"";$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.RedirectStandardError=$true;$p=[Diagnostics.Process]::Start($s);$o=$p.StandardOutput.ReadToEnd().Trim();$e=$p.StandardError.ReadToEnd().Trim();$p.WaitForExit();[pscustomobject]@{Exit=$p.ExitCode;Raw=$o;Err=$e}}
$cases=@(
  @{name='dependency';code='SETUP_DEPENDENCY_UNKNOWN';m={param($x)$x.setup_steps[1].depends_on=@('SET-UNKNOWN')}},
  @{name='classification';code='SETUP_DATA_SCHEMA_INVALID';m={param($x)$x.setup_steps[0].parameters[0].value_classification='unknown'}},
  @{name='sod';code='SOD_CONFLICT_ASYMMETRIC';m={param($x)$x.roles[2].forbidden_with=@()}},
  @{name='sequence';code='SETUP_SEQUENCE_INVALID';m={param($x)$x.setup_steps[1].sequence=1}},
  @{name='probe';code='SETUP_DATA_SCHEMA_INVALID';m={param($x)$x.roles[0].positive_probe=''}},
  @{name='reference';code='DATA_REFERENCE_INVALID';m={param($x)$x.data_templates[2].reference_rules=@('TPL-UNKNOWN')}},
  @{name='sum';code='DATA_CONTROL_TOTAL_MISMATCH';m={param($x)$x.migration_waves[0].accepted_count=19}},
  @{name='marker';code='SETUP_DATA_CUSTOMER_OR_SECRET_MARKER';m={param($x)$x.setup_steps[0].entry='customer_content_marker'}},
  @{name='digest';code='SETUP_DATA_SCHEMA_INVALID';m={param($x)$x.migration_waves[0].control_total='bad'}},
  @{name='wave-order';code='DATA_WAVE_SEQUENCE_INVALID';m={param($x)$x.migration_waves[1].sequence=3}}
)
try{foreach($c in $cases){$d=Join-Path $temp $c.name;& (Join-Path $PSScriptRoot 'New-SyntheticSetupPermissionsData.ps1') -Destination $d|Out-Null;$p=Join-Path $d 'setup-permissions-data.json';$x=Get-Content $p -Raw|ConvertFrom-Json;&$c.m $x;[IO.File]::WriteAllText($p,(($x|ConvertTo-Json -Depth 30)+"`n"),$utf8);$r=Invoke-Exact $d;if($r.Exit-ne1-or$r.Err-ne''-or$r.Raw-cne$c.code){throw "SETUP_NEGATIVE_FAILED:$($c.name):$($r.Exit):$($r.Raw):$($r.Err)"}};Write-Host "PASS: $($cases.Count) isolierte Setup-/SoD-/Daten-Negativfaelle."}finally{if(Test-Path $temp){Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue}}
