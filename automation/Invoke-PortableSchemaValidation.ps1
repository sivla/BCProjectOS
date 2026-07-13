[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][AllowNull()]$Value,
  [Parameter(Mandatory=$true)]$Schema,
  [Parameter(Mandatory=$false)]$RootSchema,
  [string]$Path='root'
)
$ErrorActionPreference='Stop'

function Get-JsonPropertyEntry {
  param($Object,[string]$Name)
  if($Object -is [Collections.IDictionary]) {
    if(-not $Object.Contains($Name)){ return $null }
    return [pscustomobject]@{ Name=$Name; Value=$Object[$Name] }
  }
  $entries=@($Object.PSObject.Properties | Where-Object { $_.Name -ceq $Name })
  if($entries.Count -eq 0){ return $null }
  if($entries.Count -gt 1){ throw "PORTABLE_SCHEMA_DUPLICATE_PROPERTY:$Name" }
  $entries[0]
}

function Get-JsonNodeKind {
  param($Node)
  if($null -eq $Node){ return 'null' }
  if($Node -is [bool] -or $Node -is [string] -or ($Node -is [ValueType] -and $Node -isnot [datetime] -and $Node -isnot [pscustomobject])){ return 'primitive' }
  if($Node -is [Collections.IList] -or $Node.GetType().IsArray){ return 'array' }
  if($Node -is [Collections.IDictionary]){ return 'object' }
  if(@($Node.PSObject.Properties).Count -gt 0){ return 'object' }
  return 'unknown'
}

function Get-JsonValue { param($Object,[string]$Name);$entry=Get-JsonPropertyEntry $Object $Name;if($null -ne $entry){$entry.Value} }

$kind=Get-JsonNodeKind $Value
$ref=Get-JsonValue $Schema '$ref'
if($ref){
  if($null -eq $RootSchema){$RootSchema=$script:RootSchema};$defs=Get-JsonValue $RootSchema '$defs'
  $prefix='#/$defs/';if(-not $ref.StartsWith($prefix,[StringComparison]::Ordinal)){throw 'PORTABLE_SCHEMA_REF_UNSUPPORTED'};$defName=$ref.Substring($prefix.Length);$Schema=Get-JsonValue $defs $defName;if($null -eq $Schema){throw "PORTABLE_SCHEMA_REF_UNKNOWN:$defName"}
}
$types=@(Get-JsonValue $Schema 'type');$valid=$false
foreach($type in $types){
  $valid=$valid -or ($type -eq 'object' -and $kind -eq 'object') -or ($type -eq 'array' -and $kind -eq 'array') -or ($type -eq 'string' -and $Value -is [string]) -or ($type -eq 'integer' -and $Value -is [int]) -or ($type -eq 'number' -and $kind -eq 'primitive') -or ($type -eq 'null' -and $kind -eq 'null')
  $valid=$valid -or ($type -eq 'boolean' -and $Value -is [bool])
}
if(-not $valid){throw "PORTABLE_SCHEMA_TYPE_INVALID:$Path"}
$min=Get-JsonValue $Schema 'minItems';if($null -ne $min -and $kind -eq 'array' -and $Value.Count -lt $min){throw "PORTABLE_SCHEMA_MINITEMS:$Path"}
if($kind -eq 'array'){$index=0;foreach($item in $Value){$items=Get-JsonValue $Schema 'items';if($items){& $script:InvokeSchema $item $items "$Path[$index]"};$index++};return}
if($kind -eq 'object'){
  foreach($required in @(Get-JsonValue $Schema 'required')){if($null -eq (Get-JsonPropertyEntry $Value $required)){throw "PORTABLE_SCHEMA_REQUIRED:$Path.$required"}}
  $properties=Get-JsonValue $Schema 'properties'
  foreach($property in @($Value.PSObject.Properties)){$spec=if($properties){Get-JsonValue $properties $property.Name};if($null -eq $spec -and (Get-JsonValue $Schema 'additionalProperties') -eq $false){throw "PORTABLE_SCHEMA_ADDITIONAL_PROPERTY:$Path.$($property.Name)"};if($spec){& $script:InvokeSchema $property.Value $spec "$Path.$($property.Name)"}}
}
