$ErrorActionPreference='Stop'
$sourceRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$tmp=Join-Path $env:TEMP ('spectra-blueprint-negative-'+[guid]::NewGuid().ToString('N'))
function New-CaseRoot([string]$Name){
  $root=Join-Path $tmp $Name
  New-Item -ItemType Directory -Path (Join-Path $root 'automation') -Force|Out-Null
  New-Item -ItemType Directory -Path (Join-Path $root 'schemas') -Force|Out-Null
  New-Item -ItemType Directory -Path (Join-Path $root 'contract') -Force|Out-Null
  Copy-Item (Join-Path $sourceRoot 'automation\Spectra.JsonSchema.ps1') (Join-Path $root 'automation')
  Copy-Item (Join-Path $sourceRoot 'automation\Blueprint.Catalog.ps1') (Join-Path $root 'automation')
  Copy-Item (Join-Path $sourceRoot 'schemas\blueprint-catalog.schema.json') (Join-Path $root 'schemas')
  Copy-Item (Join-Path $sourceRoot 'contract\blueprints') (Join-Path $root 'contract') -Recurse
  return $root
}
function Expect-BlueprintFailure([string]$Name,[string]$Code,[scriptblock]$Mutate){
  $root=New-CaseRoot $Name
  $catalogPath=Join-Path $root 'contract\blueprints\catalog.json'
  $catalog=Get-Content $catalogPath -Raw|ConvertFrom-Json
  & $Mutate $catalog $root
  [IO.File]::WriteAllText($catalogPath,($catalog|ConvertTo-Json -Depth 20),(New-Object Text.UTF8Encoding($false)))
  . (Join-Path $root 'automation\Blueprint.Catalog.ps1')
  try{Test-SpectraBlueprintCatalog $root|Out-Null;throw "EXPECTED_BLUEPRINT_FAILURE_NOT_RAISED:$Name"}catch{if($_.Exception.Message-ne$Code){throw "BLUEPRINT_NEGATIVE_CODE_MISMATCH:${Name}:$($_.Exception.Message)"}}
}
try{
  New-Item -ItemType Directory -Path $tmp|Out-Null
  $cases=@(
    @('duplicate-blueprint','BLUEPRINT_ID_DUPLICATE',{param($x,$r)$x.blueprints[1].id=$x.blueprints[0].id}),
    @('duplicate-template','BLUEPRINT_TEMPLATE_ID_DUPLICATE',{param($x,$r)$x.blueprints[1].artifacts[0].template_id=$x.blueprints[0].artifacts[0].template_id}),
    @('unsafe-source','BLUEPRINT_SOURCE_PATH_UNSAFE',{param($x,$r)$x.blueprints[0].artifacts[0].source_path='../outside.md'}),
    @('unsafe-target','BLUEPRINT_TARGET_PATH_UNSAFE',{param($x,$r)$x.blueprints[0].artifacts[0].target_path='..\outside.md'}),
    @('duplicate-target','BLUEPRINT_TARGET_DUPLICATE',{param($x,$r)$x.blueprints[0].artifacts[1].target_path=$x.blueprints[0].artifacts[0].target_path}),
    @('missing-template','BLUEPRINT_TEMPLATE_MISSING',{param($x,$r)$x.blueprints[0].artifacts[0].source_path='contract/blueprints/templates/confluence/missing.md'}),
    @('not-blank','BLUEPRINT_TEMPLATE_NOT_BLANK',{param($x,$r)$p=Join-Path $r ($x.blueprints[0].artifacts[0].source_path-replace'/','\');(Get-Content $p -Raw)-replace'content_status: blank','content_status: filled'|Set-Content $p}),
    @('forbidden-content','BLUEPRINT_TEMPLATE_FORBIDDEN_CONTENT',{param($x,$r)$p=Join-Path $r ($x.blueprints[0].artifacts[0].source_path-replace'/','\');Add-Content $p ("`npass"+"word: "+"synthetic")})
  )
  foreach($case in $cases){Expect-BlueprintFailure $case[0] $case[1] $case[2]}
  Write-Host "PASS: $($cases.Count) Blueprint-Katalog-Negativfälle sind fail-closed."
}finally{if(Test-Path $tmp){Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue}}
