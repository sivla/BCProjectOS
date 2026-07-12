[CmdletBinding()]param()
$ErrorActionPreference='Stop';. (Join-Path $PSScriptRoot 'SemVer.Common.ps1')
$cases=@(@('0.14.0-alpha.1','1.0.0-rc.1',-1),@('1.0.0-alpha.9','1.0.0-beta.1',-1),@('1.0.0-beta.2','1.0.0-rc.1',-1),@('1.0.0-rc.1','1.0.0-rc.2',-1),@('1.0.0-rc.2','1.0.0',-1),@('1.0.0','1.0.0-rc.2',1),@('1.0.0-rc.1','1.0.0-rc.1',0),@('1.0.0-1','1.0.0-alpha',-1))
foreach($case in $cases){$actual=Compare-SpectraVersion $case[0] $case[1];if($actual-ne[int]$case[2]){throw "SEMVER_COMPARISON_FAILED:$($case[0]):$($case[1]):$actual"}}
try{Compare-SpectraVersion '1.0' '1.0.0'|Out-Null;throw 'SEMVER_INVALID_ACCEPTED'}catch{if($_.Exception.Message-ne'VERSION_COMPARISON_UNSUPPORTED'){throw}}
Write-Host "PASS: $($cases.Count) SemVer-Vergleiche einschließlich Alpha, Beta, RC und Final."
