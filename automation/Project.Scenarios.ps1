function Get-SpectraProjectScenarioCatalog([string]$Root) {
  $path = Join-Path $Root 'contract\project-scenarios\catalog.json'
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw 'PROJECT_SCENARIO_CATALOG_MISSING' }
  return Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
}

function Test-SpectraProjectScenarioCatalog([string]$Root) {
  $catalog = Get-SpectraProjectScenarioCatalog $Root
  . (Join-Path $Root 'automation\Spectra.JsonSchema.ps1')
  $schema = Get-Content -LiteralPath (Join-Path $Root 'schemas\project-scenario-catalog.schema.json') -Raw | ConvertFrom-Json
  try {
    Test-SpectraJsonSchema -Value $catalog -Schema $schema -RootSchema $schema -Path root
  } catch {
    throw 'PROJECT_SCENARIO_CATALOG_SCHEMA_INVALID'
  }
  $expected = @('fit-gap', 'implementation', 'migration', 'support')
  $actual = @($catalog.scenarios.project_type | Sort-Object)
  if (Compare-Object $expected $actual) { throw 'PROJECT_SCENARIO_SET_INVALID' }
  . (Join-Path $Root 'automation\Blueprint.Catalog.ps1')
  $blueprints = @(Test-SpectraBlueprintCatalog $Root).blueprints.id
  foreach ($scenario in @($catalog.scenarios)) {
    if (@($scenario.recommended_blueprints | Group-Object | Where-Object Count -gt 1).Count -gt 0) { throw 'PROJECT_SCENARIO_BLUEPRINT_DUPLICATE' }
    foreach ($blueprint in @($scenario.recommended_blueprints)) {
      if ($blueprints -notcontains [string]$blueprint) { throw 'PROJECT_SCENARIO_BLUEPRINT_UNKNOWN' }
    }
    if (@($scenario.allowed_predecessor_types).Count -eq 0 -and @($scenario.allowed_relationships).Count -ne 0) { throw 'PROJECT_SCENARIO_TRANSITION_INVALID' }
    if (@($scenario.allowed_predecessor_types).Count -gt 0 -and @($scenario.allowed_relationships).Count -eq 0) { throw 'PROJECT_SCENARIO_TRANSITION_INVALID' }
  }
  return $catalog
}

function Get-SpectraProjectScenario([string]$Root, [string]$ProjectType) {
  $catalog = Test-SpectraProjectScenarioCatalog $Root
  $matches = @($catalog.scenarios | Where-Object { [string]$_.project_type -ceq $ProjectType })
  if ($matches.Count -ne 1) { throw 'PROJECT_SCENARIO_UNKNOWN' }
  return $matches[0]
}

function Test-SpectraProjectScenarioSelection {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$ProjectType,
    [Parameter(Mandatory = $true)][string]$Profile,
    [AllowNull()]$Predecessor,
    [Parameter(Mandatory = $true)][string]$ProjectId
  )
  $scenario = Get-SpectraProjectScenario $Root $ProjectType
  if ([string]$scenario.workspace_profile -cne $Profile) { throw 'PROJECT_SCENARIO_PROFILE_MISMATCH' }
  if ($null -ne $Predecessor) {
    if ([string]$Predecessor.project_id -ceq $ProjectId) { throw 'PROJECT_SCENARIO_SELF_REFERENCE' }
    if ($Predecessor.read_only -ne $true) { throw 'PROJECT_SCENARIO_PREDECESSOR_NOT_READ_ONLY' }
    if (@($scenario.allowed_predecessor_types) -notcontains [string]$Predecessor.project_type) { throw 'PROJECT_SCENARIO_PREDECESSOR_TYPE_INVALID' }
    if (@($scenario.allowed_relationships) -notcontains [string]$Predecessor.relationship) { throw 'PROJECT_SCENARIO_RELATIONSHIP_INVALID' }
  }
  return $scenario
}
