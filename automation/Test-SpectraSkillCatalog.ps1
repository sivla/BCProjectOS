[CmdletBinding()]param([string]$Root)
$ErrorActionPreference='Stop';Set-StrictMode -Version 2.0
function Fail([string]$Code){throw $Code}
if(-not$Root){$Root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))}else{$Root=[IO.Path]::GetFullPath($Root)}
$skillsRoot=Join-Path $Root 'skills';$catalogPath=Join-Path $Root 'contract\skills\catalog.json';$schemaPath=Join-Path $Root 'schemas\skill-catalog.schema.json'
foreach($path in @($skillsRoot,$catalogPath,$schemaPath)){if(-not(Test-Path -LiteralPath $path)){Fail 'SKILL_CATALOG_REQUIRED_PATH_MISSING'}}
try{$catalog=Get-Content $catalogPath -Raw|ConvertFrom-Json;$schema=Get-Content $schemaPath -Raw|ConvertFrom-Json}catch{Fail 'SKILL_CATALOG_JSON_INVALID'}
$script:RootSchema=$schema;$script:InvokeSchema={param([AllowNull()]$v,$s,$p).(Join-Path $PSScriptRoot 'Invoke-PortableSchemaValidation.ps1') -Value $v -Schema $s -RootSchema $script:RootSchema -Path $p}
try{. (Join-Path $PSScriptRoot 'Invoke-PortableSchemaValidation.ps1') -Value $catalog -Schema $schema -RootSchema $schema -Path root}catch{Fail ("SKILL_CATALOG_SCHEMA_INVALID:"+$_.Exception.Message.Split(':')[0])}
$entries=@($catalog.skills);if($entries.Count -ne 11){Fail 'SKILL_CATALOG_COUNT_INVALID'}
foreach($property in @('name','responsibility','trigger_phrase')){if(@($entries|Group-Object $property|Where-Object Count -gt 1).Count -gt 0){Fail ("SKILL_CATALOG_DUPLICATE_"+$property.ToUpperInvariant())}}
$expected=@($entries.name|Sort-Object);$actual=@(Get-ChildItem $skillsRoot -Directory|Where-Object Name -ne '_shared'|ForEach-Object Name|Sort-Object);if(($expected -join "`n") -cne ($actual -join "`n")){Fail 'SKILL_CATALOG_DIRECTORY_SET_INVALID'}
$shared=Join-Path $skillsRoot '_shared\safety-and-evidence.md';if(-not(Test-Path $shared -PathType Leaf)){Fail 'SKILL_SHARED_SAFETY_MISSING'}
foreach($entry in $entries){
  $folder=Join-Path $skillsRoot ([string]$entry.name);$skillPath=Join-Path $folder 'SKILL.md';$agentPath=Join-Path $folder 'agents\openai.yaml';$contractPath=Join-Path $folder 'references\contract.md'
  foreach($path in @($skillPath,$agentPath,$contractPath)){if(-not(Test-Path -LiteralPath $path -PathType Leaf)){Fail "SKILL_REQUIRED_FILE_MISSING:$($entry.name)"}}
  $skill=Get-Content $skillPath -Raw;$agent=Get-Content $agentPath -Raw;$contract=Get-Content $contractPath -Raw
  if($skill -match 'TODO|\[TODO'){Fail "SKILL_PLACEHOLDER_PRESENT:$($entry.name)"};if(@($skill -split"`n").Count -gt 120){Fail "SKILL_BODY_TOO_LONG:$($entry.name)"}
  $front=[regex]::Match($skill,'(?s)^---\r?\nname:\s*([^\r\n]+)\r?\ndescription:\s*([^\r\n]+)\r?\n---');if(-not$front.Success){Fail "SKILL_FRONTMATTER_INVALID:$($entry.name)"};if($front.Groups[1].Value.Trim() -cne [string]$entry.name){Fail "SKILL_NAME_MISMATCH:$($entry.name)"};$description=$front.Groups[2].Value.Trim();if($description.Length -lt 80){Fail "SKILL_DESCRIPTION_INCOMPLETE:$($entry.name)"}
  foreach($relative in @('references/contract.md','../_shared/safety-and-evidence.md')){$resolved=[IO.Path]::GetFullPath((Join-Path $folder $relative));if(-not$resolved.StartsWith($skillsRoot.TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase)-or-not(Test-Path $resolved -PathType Leaf)){Fail "SKILL_REFERENCE_MISSING:$($entry.name)"};if($skill -notmatch [regex]::Escape($relative)){Fail "SKILL_REFERENCE_NOT_LINKED:$($entry.name)"}}
  if($agent -notmatch 'display_name:\s*"[^\r\n]+"'-or$agent -notmatch 'short_description:\s*"([^\r\n]+)"'-or$agent -notmatch 'default_prompt:\s*"([^\r\n]+)"'){Fail "SKILL_AGENT_METADATA_INVALID:$($entry.name)"};$short=([regex]::Match($agent,'short_description:\s*"([^"]+)"')).Groups[1].Value;if($short.Length -lt 25-or$short.Length -gt 64){Fail "SKILL_SHORT_DESCRIPTION_LENGTH:$($entry.name)"};if($agent -notmatch [regex]::Escape('$'+[string]$entry.name)){Fail "SKILL_DEFAULT_PROMPT_MISSING_TRIGGER:$($entry.name)"}
  if(-not[bool]$entry.implicit_allowed -and $agent -notmatch 'allow_implicit_invocation:\s*false'){Fail "SKILL_IMPLICIT_POLICY_INVALID:$($entry.name)"}
  foreach($term in @('Freiheit:','Zulässige Writes:','Stop-Codes:','Reset/Rollback:')){if($contract -notmatch [regex]::Escape($term)){Fail "SKILL_SAFETY_CONTRACT_INCOMPLETE:$($entry.name)"}}
  foreach($forbidden in @($entry.forbidden_implicit_from)){if($expected -notcontains [string]$forbidden){Fail "SKILL_FORBIDDEN_TRIGGER_UNKNOWN:$($entry.name)"}}
  if(Get-ChildItem $folder -File -Recurse|Where-Object Name -in @('README.md','CHANGELOG.md','INSTALLATION_GUIDE.md','QUICK_REFERENCE.md')){Fail "SKILL_CLUTTER_FORBIDDEN:$($entry.name)"}
  $combined=$skill+"`n"+$agent+"`n"+$contract;if($combined -match 'Universaarl|UABC|@[A-Za-z0-9.-]+\.(com|de)'){Fail "SKILL_CUSTOMER_MARKER_FORBIDDEN:$($entry.name)"};if($combined -match '(api[_-]?token|client[_-]?secret|password)\s*[:=]\s*["''][^<$][^"'']+'){Fail "SKILL_SECRET_VALUE_FORBIDDEN:$($entry.name)"}
}
Write-Host 'PASS: Elf P0-Skillfamilien sind triggerklar, kompakt und sicherheitsgebunden.'
