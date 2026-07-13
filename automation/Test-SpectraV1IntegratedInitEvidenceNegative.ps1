[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$temp = Join-Path $env:TEMP ('spectra-integrated-evidence-negative-' + [guid]::NewGuid().ToString('N'))
$repo = Join-Path $temp 'repo'
$utf8 = [Text.UTF8Encoding]::new($false)

function Write-Json([string]$Path, $Value) {
  [IO.File]::WriteAllText($Path, (($Value | ConvertTo-Json -Depth 20) + "`n"), $utf8)
}
function New-BaseEvidence([string]$Commit) {
  [ordered]@{
    schema_version = 1; product_id = 'spectra'; classification = 'synthetic_non_production'
    release_version = '9.8.0-alpha.1'; release_tag = 'spectra-v9.8.0-alpha.1'; tag_commit = $Commit
    implementation = [ordered]@{profile='implementation';init='PASS';validate='PASS';domain_flow='PASS';backup='PASS';restore='PASS';revalidate='PASS';selected_blueprints=@('BPC-CONFLUENCE-PROJECT','BPC-JIRA-PROJECT','BPC-BLANK-DOCUMENTS','BPC-METADATA');status='PASS'}
    support_only = [ordered]@{profile='support-only';init='PASS';validate='PASS';domain_flow='PASS';backup='PASS';restore='PASS';revalidate='PASS';selected_blueprints=@('BPC-CONFLUENCE-PROJECT','BPC-JIRA-PROJECT','BPC-METADATA');status='PASS'}
    documentation = [ordered]@{status='PASS';language='de';commands_replayed=14;files_checked=2}
    open_product_p1 = 0; open_product_p2 = 0; decision = 'GO_FOR_V1_FINAL_REVIEW'
    known_limits = @('Ausschließlich synthetische Pilotevidence.', 'Finaler Hauptrelease benötigt getrennte Kontrolle.')
  }
}
function Invoke-Exact([string]$EvidencePath) {
  $start = [Diagnostics.ProcessStartInfo]::new()
  $start.FileName = 'powershell.exe'
  $start.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Run-SpectraV1IntegratedInitEvidenceExact.ps1`" -Path `"$EvidencePath`" -ProductRoot `"$repo`""
  $start.UseShellExecute = $false
  $start.RedirectStandardOutput = $true
  $start.RedirectStandardError = $true
  $process = [Diagnostics.Process]::Start($start)
  $stdout = $process.StandardOutput.ReadToEnd().Trim()
  $stderr = $process.StandardError.ReadToEnd().Trim()
  $process.WaitForExit()
  [pscustomobject]@{ Exit = $process.ExitCode; Raw = $stdout; Err = $stderr }
}

try {
  New-Item -ItemType Directory -Path $repo -Force | Out-Null
  git -C $repo init -b main | Out-Null
  git -C $repo config user.email 'spectra-fixture@example.invalid'
  git -C $repo config user.name 'Spectra Fixture'
  Set-Content -LiteralPath (Join-Path $repo 'fixture.txt') -Value 'synthetic' -Encoding ascii
  git -C $repo add fixture.txt
  git -C $repo commit -m fixture | Out-Null
  git -C $repo tag -a spectra-v9.8.0-alpha.1 -m 'synthetic release'
  $commit = (git -C $repo rev-parse 'spectra-v9.8.0-alpha.1^{commit}').Trim()
  $baseJson = New-BaseEvidence $commit | ConvertTo-Json -Depth 20
  $cases = @(
    @{ code='INTEGRATED_PILOT_RELEASE_BINDING_INVALID'; mutate={param($x) $x.tag_commit = '0' * 40} },
    @{ code='INTEGRATED_PILOT_IMPLEMENTATION_INVALID'; mutate={param($x) $x.implementation.selected_blueprints = @('BPC-CONFLUENCE-PROJECT','BPC-JIRA-PROJECT','BPC-METADATA')} },
    @{ code='INTEGRATED_PILOT_SUPPORT_INVALID'; mutate={param($x) $x.support_only.selected_blueprints += 'BPC-BLANK-DOCUMENTS'} },
    @{ code='INTEGRATED_PILOT_PROFILE_INCOMPLETE'; mutate={param($x) $x.implementation.restore = 'FAIL'} },
    @{ code='INTEGRATED_PILOT_DOCUMENTATION_INVALID'; mutate={param($x) $x.documentation.commands_replayed = 1} },
    @{ code='INTEGRATED_PILOT_OPEN_HIGH_PRIORITY'; mutate={param($x) $x.open_product_p1 = 1} },
    @{ code='INTEGRATED_PILOT_DECISION_INVALID'; mutate={param($x) $x.decision = 'NO_GO'} }
  )
  $index = 0
  foreach ($case in $cases) {
    $index++
    $value = $baseJson | ConvertFrom-Json
    & $case.mutate $value
    $path = Join-Path $temp "case-$index.json"
    Write-Json $path $value
    $result = Invoke-Exact $path
    if ($result.Exit -ne 1 -or $result.Err -ne '' -or $result.Raw -cne $case.code) {
      throw "INTEGRATED_PILOT_NEGATIVE_FAILED:${index}:$($case.code):$($result.Exit):$($result.Raw):$($result.Err)"
    }
  }
  Write-Host "PASS: $($cases.Count) isolierte integrierte V1-Init-Negativfälle."
} finally {
  if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
