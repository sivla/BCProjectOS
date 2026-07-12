function Assert-SpectraRelativePath([string]$Path,[string]$Code){
  if([string]::IsNullOrWhiteSpace($Path)-or[IO.Path]::IsPathRooted($Path)-or$Path-match'(^|[\\/])\.\.([\\/]|$)|\\'){throw $Code}
}
function Get-SpectraBlueprintCatalog([string]$Root){
  $catalogPath=Join-Path $Root 'contract\blueprints\catalog.json'
  if(-not(Test-Path -LiteralPath $catalogPath -PathType Leaf)){throw 'BLUEPRINT_CATALOG_MISSING'}
  return Get-Content -LiteralPath $catalogPath -Raw|ConvertFrom-Json
}
function Test-SpectraBlueprintCatalog([string]$Root){
  $catalog=Get-SpectraBlueprintCatalog $Root
  . (Join-Path $Root 'automation\Spectra.JsonSchema.ps1')
  $schema=Get-Content -LiteralPath (Join-Path $Root 'schemas\blueprint-catalog.schema.json') -Raw|ConvertFrom-Json
  try{Test-SpectraJsonSchema -Value $catalog -Schema $schema -RootSchema $schema -Path root}catch{throw 'BLUEPRINT_CATALOG_SCHEMA_INVALID'}
  if(@($catalog.blueprints|Group-Object id|Where-Object Count -gt 1).Count-gt0){throw 'BLUEPRINT_ID_DUPLICATE'}
  $templateIds=@();$targets=@()
  foreach($blueprint in @($catalog.blueprints)){
    foreach($artifact in @($blueprint.artifacts)){
      if($templateIds-contains[string]$artifact.template_id){throw 'BLUEPRINT_TEMPLATE_ID_DUPLICATE'};$templateIds+=,[string]$artifact.template_id
      Assert-SpectraRelativePath ([string]$artifact.source_path) 'BLUEPRINT_SOURCE_PATH_UNSAFE'
      Assert-SpectraRelativePath ([string]$artifact.target_path) 'BLUEPRINT_TARGET_PATH_UNSAFE'
      if($targets-contains[string]$artifact.target_path){throw 'BLUEPRINT_TARGET_DUPLICATE'};$targets+=,[string]$artifact.target_path
      $source=Join-Path $Root ([string]$artifact.source_path -replace'/','\')
      if(-not(Test-Path -LiteralPath $source -PathType Leaf)){throw 'BLUEPRINT_TEMPLATE_MISSING'}
      $raw=Get-Content -LiteralPath $source -Raw
      $templateMarker=($raw-match'(?m)^spectra_template:\s*true\s*$'-or$raw-match'"spectra_template"\s*:\s*true')
      $blankMarker=($raw-match'(?m)^content_status:\s*blank\s*$'-or$raw-match'"content_status"\s*:\s*"blank"')
      if(-not$templateMarker-or-not$blankMarker){throw 'BLUEPRINT_TEMPLATE_NOT_BLANK'}
      if($raw-match'(?i)(password|api[_-]?token|credential_marker|customer_content_marker|approval_status:\s*(approved|accepted)|evidence_status:\s*(accepted|verified))'){throw 'BLUEPRINT_TEMPLATE_FORBIDDEN_CONTENT'}
    }
  }
  return $catalog
}
