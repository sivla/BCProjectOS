Set-StrictMode -Version 2.0

function ConvertFrom-SpectraSemVer {
    param([Parameter(Mandatory=$true)][string]$Version)
    $match=[regex]::Match($Version,'^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$')
    if(-not $match.Success){throw 'VERSION_COMPARISON_UNSUPPORTED'}
    [pscustomobject]@{Major=[long]$match.Groups[1].Value;Minor=[long]$match.Groups[2].Value;Patch=[long]$match.Groups[3].Value;Prerelease=if($match.Groups[4].Success){$match.Groups[4].Value}else{$null}}
}

function Compare-SpectraVersion {
    param([Parameter(Mandatory=$true)][string]$A,[Parameter(Mandatory=$true)][string]$B)
    $left=ConvertFrom-SpectraSemVer $A;$right=ConvertFrom-SpectraSemVer $B
    foreach($field in @('Major','Minor','Patch')){$lv=[long]$left.$field;$rv=[long]$right.$field;if($lv-ne$rv){return [Math]::Sign($lv-$rv)}}
    if($null-eq$left.Prerelease-and$null-eq$right.Prerelease){return 0};if($null-eq$left.Prerelease){return 1};if($null-eq$right.Prerelease){return -1}
    [string[]]$li=[string]$left.Prerelease -split '\.';[string[]]$ri=[string]$right.Prerelease -split '\.';$limit=[Math]::Max($li.Count,$ri.Count)
    for($i=0;$i-lt$limit;$i++){
        if($i-ge$li.Count){return -1};if($i-ge$ri.Count){return 1};$ln=$li[$i]-match'^[0-9]+$';$rn=$ri[$i]-match'^[0-9]+$'
        if($ln-and$rn){$lv=[long]$li[$i];$rv=[long]$ri[$i];if($lv-ne$rv){return [Math]::Sign($lv-$rv)};continue};if($ln-and-not$rn){return -1};if(-not$ln-and$rn){return 1};$cmp=[string]::CompareOrdinal($li[$i],$ri[$i]);if($cmp-ne0){return [Math]::Sign($cmp)}
    }
    return 0
}
