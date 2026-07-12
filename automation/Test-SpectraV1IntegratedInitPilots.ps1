[CmdletBinding()]
param([string]$EvidencePath)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$sandbox = Join-Path $env:TEMP ('spectra-v1-integrated-init-' + [guid]::NewGuid().ToString('N'))
$fixture = Join-Path $sandbox 'product-release'
$version = '9.8.0-alpha.1'
$utf8 = [Text.UTF8Encoding]::new($false)
$commandsReplayed = 0

function Write-Json([string]$Path, $Value) {
  [IO.File]::WriteAllText($Path, (($Value | ConvertTo-Json -Depth 20) + "`n"), $utf8)
}
function Assert-Exit([string]$Code) {
  if ($LASTEXITCODE -ne 0) { throw "$Code`:$LASTEXITCODE" }
}
function Invoke-Operator([hashtable]$Arguments) {
  $script:commandsReplayed++
  $json = & (Join-Path $root 'automation\Invoke-Spectra.ps1') @Arguments
  return $json | ConvertFrom-Json
}
function New-Answers([string]$Profile) {
  $blueprints = if ($Profile -eq 'implementation') {
    @('BPC-CONFLUENCE-PROJECT','BPC-JIRA-PROJECT','BPC-BLANK-DOCUMENTS','BPC-METADATA')
  } else {
    @('BPC-CONFLUENCE-PROJECT','BPC-JIRA-PROJECT','BPC-METADATA')
  }
  [ordered]@{
    mode = 'new'; project_id = "PRJ-V1-$($Profile.ToUpperInvariant())"; project_name = "Synthetischer V1-Pilot $Profile"
    profile = $Profile; language = 'de-DE'; processes = @('finance','p2p','o2c')
    collaboration = 'portable-atlassian'; project_space_id = "SPACE-V1-$($Profile.ToUpperInvariant())"; project_space_title = 'Synthetischer Projektbereich'
    referenced_spaces_path = $null; ticket_strategy = 'spectra-standard'; ticket_provider = 'jira'; ticket_mapping_version = '1.0.0'
    ticket_mapping_path = $null; blueprints = $blueprints; onboarding_source_path = $null
  }
}
function Test-BlueprintSelection([string]$Workspace, [string]$Profile) {
  $init = Get-Content -LiteralPath (Join-Path $Workspace 'governance\project-init.json') -Raw | ConvertFrom-Json
  $expected = @((New-Answers $Profile).blueprints | Sort-Object)
  $actual = @($init.blueprints | Sort-Object)
  if (Compare-Object $expected $actual) { throw "INTEGRATED_PILOT_BLUEPRINT_SELECTION_INVALID:$Profile" }
  foreach ($required in @('collaboration\pages\00 Support.md','collaboration\pages\01 Unternehmen.md','collaboration\pages\02 Business Central.md','collaboration\pages\03 Projekte.md','collaboration\pages\04 Handbücher.md','collaboration\pages\99 Archiv.md','collaboration\jira-project-blueprint.json','templates\metadata\snapshot.json')) {
    if (-not (Test-Path -LiteralPath (Join-Path $Workspace $required) -PathType Leaf)) { throw "INTEGRATED_PILOT_BLUEPRINT_MISSING:${Profile}:$required" }
  }
  $blank = Join-Path $Workspace 'templates\project-overview-scope.md'
  if ($Profile -eq 'implementation' -and -not (Test-Path -LiteralPath $blank -PathType Leaf)) { throw 'INTEGRATED_PILOT_IMPLEMENTATION_BLANKS_MISSING' }
  if ($Profile -eq 'support-only' -and (Test-Path -LiteralPath $blank)) { throw 'INTEGRATED_PILOT_SUPPORT_NOT_LEAN' }
  return $actual
}
function Invoke-DomainFlow([string]$Workspace, [string]$Profile) {
  $evidenceRoot = Join-Path $Workspace 'pilot-evidence'
  if ($Profile -eq 'implementation') {
    $setup = Join-Path $evidenceRoot 'setup-data'
    Invoke-Operator @{Command='generate-setup-data';Workspace=$setup;Profile=$Profile;Apply=$true} | Out-Null
    Invoke-Operator @{Command='validate-setup-data';Workspace=$setup} | Out-Null
  }
  $uat = Join-Path $evidenceRoot 'uat-training-defects'
  Invoke-Operator @{Command='generate-uat-training-defects';Workspace=$uat;Profile=$Profile;Apply=$true} | Out-Null
  Invoke-Operator @{Command='validate-uat-training-defects';Workspace=$uat} | Out-Null
  $operations = Join-Path $evidenceRoot 'cutover-operations'
  Invoke-Operator @{Command='generate-cutover-operations';Workspace=$operations;Profile=$Profile;Apply=$true} | Out-Null
  Invoke-Operator @{Command='validate-cutover-operations';Workspace=$operations} | Out-Null
}
function Test-DomainFlow([string]$Workspace, [string]$Profile) {
  $evidenceRoot = Join-Path $Workspace 'pilot-evidence'
  if ($Profile -eq 'implementation') { Invoke-Operator @{Command='validate-setup-data';Workspace=(Join-Path $evidenceRoot 'setup-data')} | Out-Null }
  Invoke-Operator @{Command='validate-uat-training-defects';Workspace=(Join-Path $evidenceRoot 'uat-training-defects')} | Out-Null
  Invoke-Operator @{Command='validate-cutover-operations';Workspace=(Join-Path $evidenceRoot 'cutover-operations')} | Out-Null
}
function Invoke-ProfilePilot([string]$Profile) {
  $answers = Join-Path $sandbox "$Profile-answers.json"
  Write-Json $answers (New-Answers $Profile)
  $workspace = Join-Path $sandbox "$Profile-workspace"
  $alias = "v1-$($Profile -replace '[^a-z]','')"
  $init = Invoke-Operator @{Command='init';Workspace=$workspace;Guided=$true;AnswersPath=$answers;Apply=$true;Profile=$Profile;Version=$version;CustomerAlias=$alias;ProductRoot=$fixture}
  if ($init.status -ne 'APPLIED' -or -not $init.writes_performed) { throw "INTEGRATED_PILOT_INIT_FAILED:$Profile" }
  $validate = Invoke-Operator @{Command='validate';Workspace=$workspace;ProductRoot=$fixture}
  if ($validate.status -ne 'VALIDATED') { throw "INTEGRATED_PILOT_VALIDATE_FAILED:$Profile" }
  $blueprints = Test-BlueprintSelection $workspace $Profile
  Invoke-DomainFlow $workspace $Profile

  $backup = Join-Path $sandbox "$Profile-backup"
  $restore = Join-Path $sandbox "$Profile-restored"
  Invoke-Operator @{Command='backup';Workspace=$workspace;Target=$backup} | Out-Null
  Invoke-Operator @{Command='backup';Workspace=$workspace;Target=$backup;Apply=$true} | Out-Null
  Invoke-Operator @{Command='restore';Workspace=$backup;Target=$restore} | Out-Null
  Invoke-Operator @{Command='restore';Workspace=$backup;Target=$restore;Apply=$true} | Out-Null
  Invoke-Operator @{Command='validate';Workspace=$restore;ProductRoot=$fixture} | Out-Null
  Test-DomainFlow $restore $Profile

  $workspaceHash = (Get-FileHash -LiteralPath (Join-Path $restore 'workspace.yaml') -Algorithm SHA256).Hash
  try {
    Invoke-Operator @{Command='restore';Workspace=$backup;Target=$restore;Apply=$true} | Out-Null
    throw "INTEGRATED_PILOT_EXISTING_RESTORE_ACCEPTED:$Profile"
  } catch {
    if ($_.Exception.Message -notmatch 'SPECTRA_DELEGATE_FAILED:restore:RESTORE_TARGET_NOT_EMPTY') { throw }
  }
  if ((Get-FileHash -LiteralPath (Join-Path $restore 'workspace.yaml') -Algorithm SHA256).Hash -cne $workspaceHash) {
    throw "INTEGRATED_PILOT_RECOVERY_MUTATED_TARGET:$Profile"
  }

  [ordered]@{
    profile=$Profile;init='PASS';validate='PASS';domain_flow='PASS';backup='PASS';restore='PASS';revalidate='PASS'
    selected_blueprints=$blueprints;status='PASS'
  }
}

try {
  New-Item -ItemType Directory -Path $fixture -Force | Out-Null
  foreach ($relative in @('AGENTS.md','README.md','automation','catalogs','contract','examples\minimal-contract','schemas','tests\invalid','release')) {
    $source = Join-Path $root $relative
    $target = Join-Path $fixture $relative
    $parent = Split-Path -Parent $target
    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    Copy-Item -LiteralPath $source -Destination $target -Recurse -Force
  }
  git -C $fixture init -b main | Out-Null
  git -C $fixture config core.autocrlf false
  git -C $fixture config user.email 'spectra-fixture@example.invalid'
  git -C $fixture config user.name 'Spectra Fixture'
  git -C $fixture remote add origin 'https://github.com/sivla/BCProjectOS.git'
  git -C $fixture add -A
  git -C $fixture commit -m source | Out-Null
  git -C $fixture checkout -- .
  $sourceCommit = (git -C $fixture rev-parse HEAD).Trim()
  & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixture 'automation\New-ReleaseCandidate.ps1') -Version $version -ReleaseDate 2026-07-12 -SourceCommit $sourceCommit | Out-Null
  Assert-Exit 'INTEGRATED_PILOT_CANDIDATE_FAILED'
  git -C $fixture add "release/versions/$version"
  git -C $fixture commit -m candidate | Out-Null
  & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixture 'automation\Promote-ReleaseCandidate.ps1') -RepositoryRoot $fixture -Version $version -SyntheticRepository | Out-Null
  Assert-Exit 'INTEGRATED_PILOT_PROMOTION_FAILED'
  $tagCommit = (git -C $fixture rev-parse "spectra-v$version^{commit}").Trim()

  $implementation = Invoke-ProfilePilot 'implementation'
  $support = Invoke-ProfilePilot 'support-only'
  $docs = @('notes\spectra-release-bound-init.md','notes\spectra-v1-integrated-init-quickstart.md')
  foreach ($relative in $docs) {
    $path = Join-Path $root $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf) -or (Get-Item -LiteralPath $path).Length -lt 200) { throw "INTEGRATED_PILOT_DOCUMENTATION_MISSING:$relative" }
    $text = Get-Content -LiteralPath $path -Raw
    if ($text -notmatch '(?i)(Initialisierung|Workspace|Sicherung|Wiederherstellung|Prüfung)') { throw "INTEGRATED_PILOT_DOCUMENTATION_INVALID:$relative" }
  }
  $evidence = [ordered]@{
    schema_version=1;product_id='spectra';classification='synthetic_non_production';release_version=$version;release_tag="spectra-v$version";tag_commit=$tagCommit
    implementation=$implementation;support_only=$support
    documentation=[ordered]@{status='PASS';language='de';commands_replayed=$commandsReplayed;files_checked=$docs.Count}
    open_product_p1=0;open_product_p2=0;decision='GO_FOR_V1_FINAL_REVIEW'
    known_limits=@('Ausschließlich synthetische Pilotevidence; keine reale Kundenabnahme.','Ein stabiler Hauptrelease benötigt weiterhin getrennte unabhängige Kontrolle.')
  }
  $output = if ($EvidencePath) { [IO.Path]::GetFullPath($EvidencePath) } else { Join-Path $sandbox 'integrated-init-evidence.json' }
  $outputParent = Split-Path -Parent $output
  if (-not (Test-Path -LiteralPath $outputParent)) { New-Item -ItemType Directory -Path $outputParent -Force | Out-Null }
  Write-Json $output $evidence
  & (Join-Path $root 'automation\Test-SpectraV1IntegratedInitEvidence.ps1') -Path $output -ProductRoot $fixture | Out-Null
  Write-Host "PASS: Zwei releasegebundene Guided-Init-Piloten, $commandsReplayed Operatoraufrufe, Backup/Restore und V1-GO-Evidence."
} finally {
  if (Test-Path -LiteralPath $sandbox) { Remove-Item -LiteralPath $sandbox -Recurse -Force -ErrorAction SilentlyContinue }
}
