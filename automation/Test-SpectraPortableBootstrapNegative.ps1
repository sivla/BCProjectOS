[CmdletBinding()]param()
$ErrorActionPreference='Stop';Set-StrictMode -Version 2.0
. (Join-Path $PSScriptRoot 'Spectra.Bootstrap.ps1')
. (Join-Path $PSScriptRoot 'PortableSnapshot.Catalog.ps1')
$root=Get-SpectraBootstrapProductRoot;$temp=Join-Path $env:TEMP ('spectra-bootstrap-neg-'+[guid]::NewGuid().ToString('N'));$passed=0
function Expect([string]$Code,[scriptblock]$Action){try{&$Action;throw "NEGATIVE_ACCEPTED:$Code"}catch{if($_.Exception.Message-cne$Code){throw "NEGATIVE_WRONG:${Code}:$($_.Exception.Message)"}};$script:passed++}
try{
  New-Item -ItemType Directory -Path $temp|Out-Null;$registry=Join-Path $temp 'projects';Initialize-SpectraProjectRegistry $registry '2031-01-01T00:00:00Z' -Apply|Out-Null;$binding=Get-SpectraReleaseBinding $root '1.1.0-alpha.1';$workspace=Join-Path $registry 'one';& (Join-Path $PSScriptRoot 'New-CustomerWorkspace.ps1') -Destination $workspace -Profile implementation -ExpectedBlueprintVersion '1.1.0-alpha.1' -CustomerAlias 'SYNTHETIC-ONE' -ProductRoot $root|Out-Null
  Expect 'BOOTSTRAP_PATH_OUTSIDE_REGISTRY' {ConvertTo-SpectraRelativePath $registry (Join-Path $temp 'outside')|Out-Null}
  Register-SpectraProject $registry $workspace 'WS-SYN-ONE' 'PRJ-SYN-ONE' implementation new $binding '2031-01-01T00:00:00Z' $root|Out-Null
  Expect 'BOOTSTRAP_REGISTRY_CONFLICT' {Register-SpectraProject $registry (Join-Path $registry 'other') 'WS-SYN-ONE' 'PRJ-SYN-ONE' implementation new $binding '2031-01-01T00:00:00Z' $root|Out-Null}
  $bad=Read-SpectraBootstrapJson (Join-Path $registry 'spectra-projects.json');$bad.entries=@($bad.entries)+@($bad.entries[0]);Expect 'BOOTSTRAP_REGISTRY_DUPLICATE_ID' {Test-SpectraProjectRegistry $bad|Out-Null}
  Expect 'BOOTSTRAP_SNAPSHOT_MISSING' {New-SpectraTwinHandoff $workspace 'WS-SYN-ONE' 'PRJ-SYN-ONE' (Join-Path $workspace 'missing.json') $binding '2031-01-01T00:00:00Z'|Out-Null}
  $fixture=Join-Path $temp 'snapshot-fixture';& (Join-Path $PSScriptRoot 'New-SyntheticPortableSnapshotCatalog.ps1') -Destination $fixture|Out-Null;$catalog=Read-PortableJson (Join-Path $fixture 'catalog.json');$p=$catalog.customers[0].projects[0];$rPath=Join-Path $fixture ($p.release_manifest_path-replace'/',[IO.Path]::DirectorySeparatorChar);$r=Read-PortableJson $rPath;$incoming=Join-Path $workspace 'incoming.json';Copy-Item (Join-Path (Split-Path -Parent $rPath) $r.snapshot_path) $incoming;$s=Read-PortableJson $incoming;$ws=Read-SpectraBootstrapJson (Join-Path $workspace 'workspace.yaml');$s.customer_id=$ws.customer_id;$s.project_id='PRJ-SYN-ONE';Write-PortableJson $incoming $s;New-SpectraTwinHandoff $workspace 'WS-SYN-ONE' 'PRJ-SYN-ONE' $incoming $binding '2031-01-01T00:00:00Z'|Out-Null;$h=Read-SpectraBootstrapJson (Join-Path $workspace 'twin-handoff.json');$released=Join-Path $workspace ($h.snapshot_path-replace'/',[IO.Path]::DirectorySeparatorChar);[IO.File]::AppendAllText($released,'x');Expect 'BOOTSTRAP_SNAPSHOT_DIGEST_MISMATCH' {Test-SpectraTwinHandoff $workspace|Out-Null}
  Expect 'BOOTSTRAP_RELEASE_MANIFEST_MISSING' {Get-SpectraReleaseBinding $root '9.9.9'|Out-Null}
  Expect 'BOOTSTRAP_TOOL_MISSING:spectra-tool-does-not-exist' {Assert-SpectraToolAvailable 'spectra-tool-does-not-exist'|Out-Null}
  $secretConfig=Join-Path $temp 'secret.json';[IO.File]::WriteAllText($secretConfig,'{"customer_alias":"SYN","token":"not-allowed"}',[Text.UTF8Encoding]::new($false));Expect 'BOOTSTRAP_SECRET_LEAK' {Assert-SpectraPortableConfigFile $secretConfig|Out-Null}
  $badReference=Join-Path $temp 'bad-reference.json';[IO.File]::WriteAllText($badReference,'{"runtime_secret_keys":["ATLASSIAN_TOKEN"]}',[Text.UTF8Encoding]::new($false));Expect 'BOOTSTRAP_SECRET_REFERENCE_INVALID' {Assert-SpectraPortableConfigFile $badReference|Out-Null}
  $target=Join-Path $temp 'link-target';$link=Join-Path $registry 'linked-workspace';New-Item -ItemType Directory -Path $target|Out-Null
  try { New-Item -ItemType Junction -Path $link -Target $target -ErrorAction Stop|Out-Null;Expect 'BOOTSTRAP_REPARSE_PATH_FORBIDDEN' {Assert-SpectraNoLinkPath $registry $link} } catch { if($_.Exception.Message -notlike 'NEGATIVE_*' -and $_.Exception.Message -ne 'BOOTSTRAP_REPARSE_PATH_FORBIDDEN'){throw} }
  if($passed-ne10){throw 'BOOTSTRAP_NEGATIVE_COUNT_INVALID'};Write-Host "PASS: $passed isolierte Bootstrap-/macOS-Negativfaelle."
}finally{if(Test-Path $temp){Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue}}
