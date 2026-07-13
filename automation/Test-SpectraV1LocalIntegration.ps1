[CmdletBinding()]
param([string]$ProductRoot)

$ErrorActionPreference = 'Stop'
$root = if ($ProductRoot) { [IO.Path]::GetFullPath($ProductRoot) } else { [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')) }
$p0Commit = '2c02c5970b7592fac3fd1fc810b202319c7318ba'
$contractsCommit = '6c22c4a9cff7808bb63c14880fdaba9973733fab'
$publishedBase = '0c4542f8e69c3a7d52807b96b9bdd50a54309371'

function Fail([string]$Code) { throw $Code }
function Invoke-Git([string[]]$Arguments) {
  $output = @(& git -C $root @Arguments 2>$null)
  if ($LASTEXITCODE -ne 0) { Fail 'V1_INTEGRATION_GIT_EVIDENCE_INVALID' }
  @($output)
}

. (Join-Path $root 'automation\V1.Integration.Release.ps1')

if ([string](@(Invoke-Git @('rev-parse','--show-toplevel'))[0]).Replace('\','/') -cne $root.Replace('\','/')) { Fail 'V1_INTEGRATION_ROOT_INVALID' }
foreach ($commit in @($p0Commit,$contractsCommit,$publishedBase)) { [void](Invoke-Git @('cat-file','-e',"$commit^{commit}")) }
$mergeBase = [string](@(Invoke-Git @('merge-base',$p0Commit,$contractsCommit))[0])
if ($mergeBase -cne $publishedBase) { Fail 'V1_INTEGRATION_MERGE_BASE_INVALID' }
foreach ($commit in @($p0Commit,$contractsCommit)) {
  & git -C $root merge-base --is-ancestor $commit HEAD
  if ($LASTEXITCODE -ne 0) { Fail 'V1_INTEGRATION_SOURCE_ANCESTRY_MISSING' }
}
$releaseDelta = @(Invoke-Git @('diff','--name-only',$publishedBase,'HEAD','--','release'))
$candidateManifestPath = 'release/versions/1.0.0/release-manifest.json'
$candidateManifest = $null
$candidateSourceCommit = $null
$candidateSourceTree = $null

if ($candidateManifestPath -cin $releaseDelta) {
  $candidateManifestText = (@(Invoke-Git @('show',"HEAD:$candidateManifestPath")) -join "`n")
  try {
    $candidateManifest = $candidateManifestText | ConvertFrom-Json
  } catch {
    Fail 'V1_INTEGRATION_CANDIDATE_MANIFEST_INVALID'
  }
  $candidateSourceCommit = [string](@(Invoke-Git @('rev-parse','HEAD^'))[0])
  $candidateSourceTree = [string](@(Invoke-Git @('rev-parse',"$candidateSourceCommit^{tree}"))[0])
}

& git -C $root show-ref --verify --quiet 'refs/tags/spectra-v1.0.0'
$candidateTagExists = ($LASTEXITCODE -eq 0)
[void](Test-SpectraV1IntegrationReleaseDelta `
  -Paths $releaseDelta `
  -CandidateManifest $candidateManifest `
  -ExpectedCandidateSourceCommit $candidateSourceCommit `
  -ExpectedCandidateSourceTree $candidateSourceTree `
  -TagExists $candidateTagExists)

$activeChanges = @(
  Get-ChildItem -LiteralPath (Join-Path $root 'openspec\changes') -Directory |
    Where-Object { $_.Name -ne 'archive' }
)
if ($activeChanges.Count -ne 1 -or $activeChanges[0].Name -cne 'spectra-v1-local-integration') { Fail 'V1_INTEGRATION_WIP_INVALID' }

& (Join-Path $root 'automation\Test-BCReferenceFoundationImport.ps1') -ProductRoot $root | Out-Null

. (Join-Path $root 'automation\Blueprint.Catalog.ps1')
$allLegacy = @('BPC-CONFLUENCE-PROJECT','BPC-JIRA-PROJECT','BPC-BLANK-DOCUMENTS','BPC-METADATA')
$supportLegacy = @('BPC-CONFLUENCE-PROJECT','BPC-JIRA-PROJECT','BPC-METADATA')
$implementation = Resolve-SpectraBlueprintCompatibility -Root $root -ProjectType implementation -Profile implementation -BcPackage custom-package -LegacyPackageIds $allLegacy
$support = Resolve-SpectraBlueprintCompatibility -Root $root -ProjectType support -Profile support-only -BcPackage custom-package -LegacyPackageIds $supportLegacy
$bcBasic = Resolve-SpectraBlueprintCompatibility -Root $root -ProjectType implementation -Profile implementation -BcPackage bc-basic-standard -LegacyPackageIds $allLegacy
if ($implementation.contract -cne 'blueprint-catalog-v2' -or $implementation.canonical_blueprint_id -cne 'bp-customer-implementation') { Fail 'V1_INTEGRATION_BLUEPRINT_AUTHORITY_INVALID' }
if ($support.canonical_blueprint_id -cne 'bp-customer-support' -or (Compare-Object @($support.page_tree_refs) @('customer'))) { Fail 'V1_INTEGRATION_BLUEPRINT_AUTHORITY_INVALID' }
if ($bcBasic.canonical_blueprint_id -cne 'bp-bc-basic' -or (Compare-Object @($bcBasic.page_tree_refs | Sort-Object) @('consulting','customer','product'))) { Fail 'V1_INTEGRATION_BLUEPRINT_AUTHORITY_INVALID' }

$workspace = Join-Path ([IO.Path]::GetTempPath()) ('spectra-v1-integration-workspace-' + [guid]::NewGuid().ToString('N'))
$knowledge = Join-Path ([IO.Path]::GetTempPath()) ('spectra-v1-integration-knowledge-' + [guid]::NewGuid().ToString('N'))
try {
  & (Join-Path $root 'automation\New-SyntheticCustomerKnowledgeWorkspace.ps1') -Destination $workspace -Profile implementation | Out-Null
  & (Join-Path $root 'automation\Test-CustomerKnowledgeWorkspace.ps1') -Path $workspace | Out-Null
  $foundation = Get-Content -LiteralPath (Join-Path $workspace 'customer-workspace-foundation.json') -Raw | ConvertFrom-Json
  $legacyInbox = Get-Content -LiteralPath (Join-Path $workspace 'knowledge-inbox.json') -Raw | ConvertFrom-Json
  $informationInbox = Get-Content -LiteralPath (Join-Path $workspace 'information-inbox.json') -Raw | ConvertFrom-Json
  . (Join-Path $root 'automation\Inbox.Compatibility.ps1')
  $inboxBinding = Test-SpectraInboxCompatibility -Foundation $foundation -LegacyInbox $legacyInbox -InformationInbox $informationInbox
  if ($inboxBinding.authority -cne 'information-inbox' -or $inboxBinding.legacy_mode -cne 'foundation-read-only' -or $inboxBinding.implementation_allowed_from_legacy -ne $false) { Fail 'V1_INTEGRATION_INBOX_AUTHORITY_INVALID' }

  & (Join-Path $root 'automation\New-SyntheticBCConsultantKnowledge.ps1') -Destination $knowledge | Out-Null
  $knowledgeResult = & (Join-Path $root 'automation\Test-BCConsultantKnowledge.ps1') -Path $knowledge
  $knowledgeValue = Get-Content -LiteralPath (Join-Path $knowledge 'bc-knowledge.json') -Raw | ConvertFrom-Json
  if ($knowledgeResult.status -cne 'validated' -or [string]$knowledgeValue.knowledge_pack_id -cne [string]$knowledgeValue.reference_snapshot.knowledge_pack_id) { Fail 'V1_INTEGRATION_KNOWLEDGE_AUTHORITY_INVALID' }
  if ($null -ne $knowledgeValue.PSObject.Properties['source_locks']) { Fail 'V1_INTEGRATION_KNOWLEDGE_DUPLICATE_REGISTRY' }
} finally {
  foreach ($path in @($workspace,$knowledge)) { if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Recurse -Force } }
}

$skillContracts = @(
  'skills/process-project-intake/references/contract.md',
  'skills/initialize-customer-workspace/references/contract.md',
  'skills/research-business-central/references/contract.md'
)
$skillText = ($skillContracts | ForEach-Object { Get-Content -LiteralPath (Join-Path $root $_) -Raw }) -join "`n"
foreach ($requiredGuard in @('information-inbox','blueprint-catalog-v2','reference_snapshot')) {
  if ($skillText -notmatch [regex]::Escape($requiredGuard)) { Fail 'V1_INTEGRATION_SKILL_GUARD_MISSING' }
}

& (Join-Path $root 'automation\Test-PortableProjectStoryCardinality.ps1') | Out-Null
Write-Output 'PASS: V1-Linien integriert; Inbox, Blueprint, Knowledge, Skills und Kardinalitaet besitzen je eine fuehrende Autoritaet.'
