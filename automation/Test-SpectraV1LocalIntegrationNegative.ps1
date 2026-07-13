[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$utf8 = [Text.UTF8Encoding]::new($false)

function Clone-Json($Value) { $Value | ConvertTo-Json -Depth 40 | ConvertFrom-Json }
function Assert-Code([string]$Name,[string]$Expected,[scriptblock]$Action) {
  try { & $Action; throw "V1_INTEGRATION_NEGATIVE_NOT_REJECTED:$Name" }
  catch {
    if ($_.Exception.Message -cne $Expected) { throw "V1_INTEGRATION_NEGATIVE_ORACLE:${Name}:$($_.Exception.Message)" }
  }
  Write-Output "PASS $Name ($Expected)"
}

. (Join-Path $root 'automation\Inbox.Compatibility.ps1')
. (Join-Path $root 'automation\V1.Integration.Release.ps1')
$foundationBase = [pscustomobject]@{
  customer = [pscustomobject]@{id='CUS-SYN-INTEGRATION'}
  projects = @([pscustomobject]@{id='PRJ-SYN-INTEGRATION'})
  support_cases = @([pscustomobject]@{id='SUP-SYN-INTEGRATION'})
}
$legacyBase = [pscustomobject]@{
  writes_performed=$false;target_mutation=$false;lifecycle_authority='foundation-read-only'
  intake_items=@([pscustomobject]@{source_object_id='SRC-SYN-INTEGRATION';source_revision='1';sha256=('a'*64)})
}
$informationBase = [pscustomobject]@{
  customer_id='CUS-SYN-INTEGRATION';project_id='PRJ-SYN-INTEGRATION';support_case_id='SUP-SYN-INTEGRATION'
  intake_items=@([pscustomobject]@{source=[pscustomobject]@{source_object_id='SRC-SYN-INTEGRATION';revision='1';sha256=('a'*64)}})
}
[void](Test-SpectraInboxCompatibility -Foundation $foundationBase -LegacyInbox $legacyBase -InformationInbox $informationBase)

Assert-Code 'legacy-write' 'INBOX_LEGACY_IMPLEMENTATION_FORBIDDEN' {
  $legacy=Clone-Json $legacyBase;$legacy.writes_performed=$true
  Test-SpectraInboxCompatibility -Foundation $foundationBase -LegacyInbox $legacy -InformationInbox $informationBase | Out-Null
}
Assert-Code 'legacy-authority' 'INBOX_LEGACY_AUTHORITY_FORBIDDEN' {
  $legacy=Clone-Json $legacyBase;$legacy.lifecycle_authority='legacy-leading'
  Test-SpectraInboxCompatibility -Foundation $foundationBase -LegacyInbox $legacy -InformationInbox $informationBase | Out-Null
}
Assert-Code 'inbox-truth' 'INBOX_LEADING_TRUTH_CONFLICT' {
  $information=Clone-Json $informationBase;$information.customer_id='CUS-OTHER'
  Test-SpectraInboxCompatibility -Foundation $foundationBase -LegacyInbox $legacyBase -InformationInbox $information | Out-Null
}
Assert-Code 'inbox-duplicate-source' 'INBOX_LEADING_SOURCE_DUPLICATE' {
  $legacy=Clone-Json $legacyBase;$legacy.intake_items=@($legacy.intake_items)+@(Clone-Json $legacy.intake_items[0])
  Test-SpectraInboxCompatibility -Foundation $foundationBase -LegacyInbox $legacy -InformationInbox $informationBase | Out-Null
}

$releasePaths = @(
  'release/release-scope.json',
  'release/versions/1.0.0/checksums.sha256',
  'release/versions/1.0.0/release-manifest.json',
  'release/versions/1.0.0/release-notes.md'
)
$releaseSourceCommit = '1' * 40
$releaseSourceTree = '2' * 40
$releaseManifest = [pscustomobject]@{
  schema_version = 4
  product_id = 'spectra'
  release_version = '1.0.0'
  expected_tag = 'spectra-v1.0.0'
  manifest_state = 'candidate'
  installable_blueprint = $false
  consumer_mode = 'CONTRACT_REFERENCE_ONLY'
  source_commit = $null
  source_tree = $null
  candidate_source_commit = $releaseSourceCommit
  candidate_source_tree = $releaseSourceTree
}
[void](Test-SpectraV1IntegrationReleaseDelta -Paths $releasePaths -CandidateManifest $releaseManifest -ExpectedCandidateSourceCommit $releaseSourceCommit -ExpectedCandidateSourceTree $releaseSourceTree)

Assert-Code 'release-path' 'V1_INTEGRATION_RELEASE_DELTA_FORBIDDEN' {
  Test-SpectraV1IntegrationReleaseDelta -Paths @($releasePaths + 'release/versions/1.0.0/unexpected.txt') -CandidateManifest $releaseManifest -ExpectedCandidateSourceCommit $releaseSourceCommit -ExpectedCandidateSourceTree $releaseSourceTree | Out-Null
}
Assert-Code 'release-evidence-incomplete' 'V1_INTEGRATION_CANDIDATE_EVIDENCE_INCOMPLETE' {
  Test-SpectraV1IntegrationReleaseDelta -Paths @($releasePaths | Where-Object { $_ -cne 'release/versions/1.0.0/checksums.sha256' }) -CandidateManifest $releaseManifest -ExpectedCandidateSourceCommit $releaseSourceCommit -ExpectedCandidateSourceTree $releaseSourceTree | Out-Null
}
Assert-Code 'release-manifest-final' 'V1_INTEGRATION_CANDIDATE_MANIFEST_INVALID' {
  $manifest = Clone-Json $releaseManifest
  $manifest.manifest_state = 'final'
  Test-SpectraV1IntegrationReleaseDelta -Paths $releasePaths -CandidateManifest $manifest -ExpectedCandidateSourceCommit $releaseSourceCommit -ExpectedCandidateSourceTree $releaseSourceTree | Out-Null
}
Assert-Code 'release-source' 'V1_INTEGRATION_CANDIDATE_SOURCE_INVALID' {
  $manifest = Clone-Json $releaseManifest
  $manifest.candidate_source_commit = '3' * 40
  Test-SpectraV1IntegrationReleaseDelta -Paths $releasePaths -CandidateManifest $manifest -ExpectedCandidateSourceCommit $releaseSourceCommit -ExpectedCandidateSourceTree $releaseSourceTree | Out-Null
}
Assert-Code 'release-tag' 'V1_INTEGRATION_RELEASE_TAG_FORBIDDEN' {
  Test-SpectraV1IntegrationReleaseDelta -Paths $releasePaths -CandidateManifest $releaseManifest -ExpectedCandidateSourceCommit $releaseSourceCommit -ExpectedCandidateSourceTree $releaseSourceTree -TagExists $true | Out-Null
}

. (Join-Path $root 'automation\Blueprint.Catalog.ps1')
Assert-Code 'blueprint-unknown-legacy' 'BLUEPRINT_LEGACY_REF_UNKNOWN' {
  Resolve-SpectraBlueprintCompatibility -Root $root -ProjectType implementation -Profile implementation -BcPackage custom-package -LegacyPackageIds @('BPC-UNKNOWN') | Out-Null
}
Assert-Code 'blueprint-mapping' 'BLUEPRINT_LEGACY_COMPATIBILITY_MISMATCH' {
  Resolve-SpectraBlueprintCompatibility -Root $root -ProjectType support -Profile support-only -BcPackage custom-package -LegacyPackageIds @('BPC-BLANK-DOCUMENTS') | Out-Null
}

& (Join-Path $root 'automation\Test-BCReferenceFoundationImportNegative.ps1') | Out-Null
Write-Output 'PASS foundation-divergence (BC_FOUNDATION_BLOB_MISMATCH)'

$temp = Join-Path ([IO.Path]::GetTempPath()) ('spectra-v1-integration-negative-' + [guid]::NewGuid().ToString('N'))
try {
  $base = Join-Path $temp 'base'
  New-Item -ItemType Directory -Path $temp | Out-Null
  & (Join-Path $root 'automation\New-SyntheticBCConsultantKnowledge.ps1') -Destination $base | Out-Null
  $knowledgeCases = @(
    @{name='knowledge-pack';code='BC_KNOWLEDGE_REFERENCE_PACK_MISMATCH';mutate={param($x)$x.knowledge_pack_id='BCKP-OTHER'}},
    @{name='knowledge-object';code='BC_KNOWLEDGE_OBJECT_REFERENCE_UNKNOWN';mutate={param($x)$x.knowledge_items[0].object_refs=@('page:999999')}}
  )
  foreach ($case in $knowledgeCases) {
    $casePath = Join-Path $temp $case.name
    Copy-Item -LiteralPath $base -Destination $casePath -Recurse
    $file = Join-Path $casePath 'bc-knowledge.json'
    $value = Get-Content -LiteralPath $file -Raw | ConvertFrom-Json
    & $case.mutate $value
    [IO.File]::WriteAllText($file,($value|ConvertTo-Json -Depth 40),$utf8)
    $start=[Diagnostics.ProcessStartInfo]::new();$start.FileName='powershell.exe';$start.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Run-BCConsultantKnowledgeExact.ps1`" -Path `"$casePath`"";$start.UseShellExecute=$false;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
    $process=[Diagnostics.Process]::Start($start);$stdout=$process.StandardOutput.ReadToEnd().Trim();$stderr=$process.StandardError.ReadToEnd().Trim();$process.WaitForExit()
    if ($process.ExitCode -ne 1 -or $stderr -ne '' -or $stdout -cne $case.code) {
      throw "V1_INTEGRATION_NEGATIVE_ORACLE:$($case.name):$($process.ExitCode):${stdout}:${stderr}"
    }
    Write-Output "PASS $($case.name) ($($case.code))"
  }
} finally { if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force } }

Write-Output 'PASS: 14 isolierte Integrations-Manipulationsfaelle.'
