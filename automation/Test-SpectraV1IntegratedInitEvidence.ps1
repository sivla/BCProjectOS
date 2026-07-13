[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Path,
  [Parameter(Mandatory = $true)][string]$ProductRoot
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$file = [IO.Path]::GetFullPath($Path)
$product = [IO.Path]::GetFullPath($ProductRoot)
if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw 'INTEGRATED_PILOT_EVIDENCE_MISSING' }
if (-not (Test-Path -LiteralPath (Join-Path $product '.git'))) { throw 'INTEGRATED_PILOT_PRODUCT_INVALID' }

$before = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash
$evidence = Get-Content -LiteralPath $file -Raw | ConvertFrom-Json
. (Join-Path $PSScriptRoot 'Spectra.JsonSchema.ps1')
$schema = Get-Content -LiteralPath (Join-Path $PSScriptRoot '..\schemas\v1-integrated-init-pilot-evidence.schema.json') -Raw | ConvertFrom-Json
try {
  Test-SpectraJsonSchema -Value $evidence -Schema $schema -RootSchema $schema -Path root
} catch {
  throw 'INTEGRATED_PILOT_SCHEMA_INVALID'
}

if ([string]$evidence.release_tag -cne "spectra-v$([string]$evidence.release_version)") {
  throw 'INTEGRATED_PILOT_RELEASE_BINDING_INVALID'
}
$resolved = @(& git -C $product rev-parse "$([string]$evidence.release_tag)^{commit}" 2>$null)
if ($LASTEXITCODE -ne 0 -or ([string]($resolved | Select-Object -First 1)).Trim() -cne [string]$evidence.tag_commit) {
  throw 'INTEGRATED_PILOT_RELEASE_BINDING_INVALID'
}

$implementationExpected = @('BPC-BLANK-DOCUMENTS', 'BPC-CONFLUENCE-PROJECT', 'BPC-JIRA-PROJECT', 'BPC-METADATA')
$supportExpected = @('BPC-CONFLUENCE-PROJECT', 'BPC-JIRA-PROJECT', 'BPC-METADATA')
if ([string]$evidence.implementation.profile -cne 'implementation' -or
    (Compare-Object $implementationExpected @($evidence.implementation.selected_blueprints | Sort-Object))) {
  throw 'INTEGRATED_PILOT_IMPLEMENTATION_INVALID'
}
if ([string]$evidence.support_only.profile -cne 'support-only' -or
    (Compare-Object $supportExpected @($evidence.support_only.selected_blueprints | Sort-Object))) {
  throw 'INTEGRATED_PILOT_SUPPORT_INVALID'
}
foreach ($profile in @($evidence.implementation, $evidence.support_only)) {
  foreach ($field in @('init', 'validate', 'domain_flow', 'backup', 'restore', 'revalidate', 'status')) {
    if ([string]$profile.$field -cne 'PASS') { throw 'INTEGRATED_PILOT_PROFILE_INCOMPLETE' }
  }
}
if ([string]$evidence.documentation.status -cne 'PASS' -or
    [string]$evidence.documentation.language -cne 'de' -or
    [int]$evidence.documentation.commands_replayed -lt 6 -or
    [int]$evidence.documentation.files_checked -lt 2) {
  throw 'INTEGRATED_PILOT_DOCUMENTATION_INVALID'
}
if ([int]$evidence.open_product_p1 -ne 0 -or [int]$evidence.open_product_p2 -ne 0) {
  throw 'INTEGRATED_PILOT_OPEN_HIGH_PRIORITY'
}
if ([string]$evidence.decision -cne 'GO_FOR_V1_FINAL_REVIEW') {
  throw 'INTEGRATED_PILOT_DECISION_INVALID'
}
$raw = Get-Content -LiteralPath $file -Raw
if ($raw -match '(?i)(universaarl|uabc|customer_content_marker|credential_marker|tenant_marker)') {
  throw 'INTEGRATED_PILOT_FORBIDDEN_MARKER'
}
if ((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash -cne $before) {
  throw 'INTEGRATED_PILOT_VALIDATOR_MUTATED_SOURCE'
}

Write-Host 'PASS: Integrierte V1-Init-Pilotevidence ist releasegebunden, vollständig und read-only.'
