$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$d=Join-Path $env:TEMP ('bc-foundation-negative-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $d|Out-Null
try{
  $m=Get-Content -Raw (Join-Path $root 'contract\foundation-imports\bc-reference-library.json')|ConvertFrom-Json
  $m.files[0].blob='0000000000000000000000000000000000000000'
  $p=Join-Path $d 'manifest.json'
  [IO.File]::WriteAllText($p,($m|ConvertTo-Json -Depth 20),[Text.UTF8Encoding]::new($false))
  $s=[Diagnostics.ProcessStartInfo]::new()
  $s.FileName='powershell.exe'
  $s.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Test-BCReferenceFoundationImport.ps1`" -ProductRoot `"$root`" -ManifestPath `"$p`""
  $s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.RedirectStandardError=$true
  $proc=[Diagnostics.Process]::Start($s);$o=$proc.StandardOutput.ReadToEnd();$e=$proc.StandardError.ReadToEnd();$proc.WaitForExit()
  if($proc.ExitCode -eq 0 -or "$o`n$e" -notmatch 'BC_FOUNDATION_BLOB_MISMATCH'){throw 'BC_FOUNDATION_NEGATIVE_ORACLE'}
  Write-Output 'PASS: Foundation-Divergenz wird fail-closed abgelehnt.'
}finally{if(Test-Path $d){Remove-Item $d -Recurse -Force}}
