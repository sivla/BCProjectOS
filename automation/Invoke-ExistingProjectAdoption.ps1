[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][ValidateSet('inspect','configure','validate','plan','adopt','apply')][string]$Command,
  [string]$ConfigPath,[string]$DiscoveryPath,[string]$PlanPath,[string]$OutputPath,[string]$Destination,
  [string]$ExpectedPlanDigest,[switch]$Approve,[switch]$Remote
)
$ErrorActionPreference='Stop';Set-StrictMode -Version 2.0
. (Join-Path $PSScriptRoot 'ExistingProject.Adoption.ps1')
if(-not$DiscoveryPath){throw 'ADOPTION_DISCOVERY_REQUIRED'}
$discovery=Read-AdoptionJson $DiscoveryPath
switch($Command){
  'inspect'{Get-ExistingProjectInspection -DiscoveryPath $DiscoveryPath|ConvertTo-Json -Depth 20;break}
  'configure'{if(-not$ConfigPath-or-not$OutputPath){throw 'ADOPTION_CONFIGURE_ARGUMENTS_REQUIRED'};$config=Read-AdoptionJson $ConfigPath;Test-ExistingProjectAdoptionConfig -Config $config -Discovery $discovery -DiscoveryPath $DiscoveryPath|Out-Null;Write-AdoptionJson $OutputPath $config;[ordered]@{status='CONFIGURED';writes_performed=$true;output=[IO.Path]::GetFullPath($OutputPath)}|ConvertTo-Json -Compress;break}
  'validate'{
    if($Destination){Test-ExistingProjectAdoptionWorkspace -Path $Destination|Out-Null;[ordered]@{status='VALIDATED';scope='workspace';writes_performed=$false}|ConvertTo-Json -Compress;break}
    if(-not$ConfigPath){throw 'ADOPTION_CONFIG_REQUIRED'};$config=Read-AdoptionJson $ConfigPath;Test-ExistingProjectAdoptionConfig -Config $config -Discovery $discovery -DiscoveryPath $DiscoveryPath|Out-Null
    if($PlanPath){$plan=Read-AdoptionJson $PlanPath;Test-ExistingProjectAdoptionPlan -Plan $plan -Config $config -Discovery $discovery -DiscoveryPath $DiscoveryPath|Out-Null}
    [ordered]@{status='VALIDATED';scope=if($PlanPath){'plan'}else{'configuration'};writes_performed=$false}|ConvertTo-Json -Compress;break
  }
  'plan'{if(-not$ConfigPath){throw 'ADOPTION_CONFIG_REQUIRED'};$config=Read-AdoptionJson $ConfigPath;$plan=New-ExistingProjectAdoptionPlan -Config $config -Discovery $discovery -DiscoveryPath $DiscoveryPath;if($OutputPath){Write-AdoptionJson $OutputPath $plan};$plan|ConvertTo-Json -Depth 40;break}
  {$_ -in @('adopt','apply')}{if(-not$ConfigPath-or-not$PlanPath-or-not$Destination-or-not$ExpectedPlanDigest){throw 'ADOPTION_APPLY_ARGUMENTS_REQUIRED'};$config=Read-AdoptionJson $ConfigPath;$plan=Read-AdoptionJson $PlanPath;Invoke-ExistingProjectAdoptionApply -Config $config -Discovery $discovery -Plan $plan -DiscoveryPath $DiscoveryPath -Destination $Destination -ExpectedPlanDigest $ExpectedPlanDigest -Approve:$Approve -Remote:$Remote|ConvertTo-Json -Compress;break}
}
