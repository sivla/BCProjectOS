function Get-SpectraJsonProperty {
  param($Object,[string]$Name)
  if($Object -is [Collections.IDictionary]){
    if($Object.Contains($Name)){return $Object[$Name]}
    return $null
  }
  $entry=@($Object.PSObject.Properties|Where-Object{$_.Name -ceq $Name})
  if($entry.Count -gt 1){throw "SPECTRA_SCHEMA_DUPLICATE_PROPERTY:$Name"}
  if($entry.Count -eq 1){return $entry[0].Value}
  return $null
}

function Test-SpectraJsonPropertyExists {
  param($Object,[string]$Name)
  if($Object -is [Collections.IDictionary]){return $Object.Contains($Name)}
  return @($Object.PSObject.Properties|Where-Object{$_.Name -ceq $Name}).Count -eq 1
}

function Get-SpectraJsonKind {
  param([AllowNull()]$Value)
  if($null -eq $Value){return 'null'}
  if($Value -is [bool]){return 'boolean'}
  if($Value -is [string]){return 'string'}
  if($Value -is [byte] -or $Value -is [sbyte] -or $Value -is [int16] -or $Value -is [uint16] -or $Value -is [int32] -or $Value -is [uint32] -or $Value -is [int64] -or $Value -is [uint64]){return 'integer'}
  if($Value -is [single] -or $Value -is [double] -or $Value -is [decimal]){return 'number'}
  if($Value -is [Collections.IList] -or $Value.GetType().IsArray){return 'array'}
  if($Value -is [Collections.IDictionary] -or @($Value.PSObject.Properties).Count -gt 0){return 'object'}
  return 'unknown'
}

function Test-SpectraJsonSchema {
  param(
    [Parameter(Mandatory=$true)][AllowNull()]$Value,
    [Parameter(Mandatory=$true)]$Schema,
    [Parameter(Mandatory=$true)]$RootSchema,
    [string]$Path='root'
  )
  $ref=Get-SpectraJsonProperty $Schema '$ref'
  if($ref){
    $prefix='#/$defs/'
    if(-not ([string]$ref).StartsWith($prefix,[StringComparison]::Ordinal)){throw "SPECTRA_SCHEMA_REF_UNSUPPORTED:$Path"}
    $defs=Get-SpectraJsonProperty $RootSchema '$defs'
    $Schema=Get-SpectraJsonProperty $defs ([string]$ref).Substring($prefix.Length)
    if($null -eq $Schema){throw "SPECTRA_SCHEMA_REF_UNKNOWN:$Path"}
  }
  $kind=Get-SpectraJsonKind $Value
  if(Test-SpectraJsonPropertyExists $Schema 'type'){
    $declaredTypes=@(Get-SpectraJsonProperty $Schema 'type')
    $typeValid=$false
    foreach($type in $declaredTypes){
      if($type -eq $kind -or ($type -eq 'number' -and $kind -eq 'integer')){$typeValid=$true}
    }
    if(-not $typeValid){throw "SPECTRA_SCHEMA_TYPE_INVALID:$Path"}
  }
  if(Test-SpectraJsonPropertyExists $Schema 'const'){
    if($Value -cne (Get-SpectraJsonProperty $Schema 'const')){throw "SPECTRA_SCHEMA_CONST_INVALID:$Path"}
  }
  if(Test-SpectraJsonPropertyExists $Schema 'enum'){
    $enum=@(Get-SpectraJsonProperty $Schema 'enum')
    if(@($enum|Where-Object{$_ -ceq $Value}).Count -eq 0){throw "SPECTRA_SCHEMA_ENUM_INVALID:$Path"}
  }
  if($kind -eq 'string'){
    $minLength=Get-SpectraJsonProperty $Schema 'minLength'
    if($null -ne $minLength -and $Value.Length -lt [int]$minLength){throw "SPECTRA_SCHEMA_MIN_LENGTH:$Path"}
    $pattern=Get-SpectraJsonProperty $Schema 'pattern'
    if($pattern -and $Value -cnotmatch [string]$pattern){throw "SPECTRA_SCHEMA_PATTERN_INVALID:$Path"}
  }
  if($kind -in @('integer','number')){
    $minimum=Get-SpectraJsonProperty $Schema 'minimum'
    if($null -ne $minimum -and [decimal]$Value -lt [decimal]$minimum){throw "SPECTRA_SCHEMA_MINIMUM_INVALID:$Path"}
  }
  if($kind -eq 'array'){
    $minItems=Get-SpectraJsonProperty $Schema 'minItems'
    if($null -ne $minItems -and $Value.Count -lt [int]$minItems){throw "SPECTRA_SCHEMA_MIN_ITEMS:$Path"}
    $items=Get-SpectraJsonProperty $Schema 'items'
    if($items){for($i=0;$i -lt $Value.Count;$i++){Test-SpectraJsonSchema -Value $Value[$i] -Schema $items -RootSchema $RootSchema -Path "$Path[$i]"}}
  }
  if($kind -eq 'object'){
    foreach($required in @(Get-SpectraJsonProperty $Schema 'required')){if(-not (Test-SpectraJsonPropertyExists $Value ([string]$required))){throw "SPECTRA_SCHEMA_REQUIRED:$Path.$required"}}
    $properties=Get-SpectraJsonProperty $Schema 'properties'
    foreach($property in @($Value.PSObject.Properties)){
      $propertySchema=if($properties){Get-SpectraJsonProperty $properties $property.Name}else{$null}
      if($null -eq $propertySchema -and (Get-SpectraJsonProperty $Schema 'additionalProperties') -eq $false){throw "SPECTRA_SCHEMA_ADDITIONAL_PROPERTY:$Path.$($property.Name)"}
      if($propertySchema){Test-SpectraJsonSchema -Value $property.Value -Schema $propertySchema -RootSchema $RootSchema -Path "$Path.$($property.Name)"}
    }
  }
}
