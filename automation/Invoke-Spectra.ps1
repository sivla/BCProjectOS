[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Command,
  [Parameter(Mandatory=$true)][string]$Workspace,
  [string]$Target,
  [ValidateSet('implementation','support-only')][string]$Profile='implementation',
  [string]$Version,
  [string]$ProductRoot,
  [string]$CustomerAlias,
  [switch]$SyntheticPilot,
  [switch]$Apply,
  [switch]$Approve
)
$ErrorActionPreference='Stop'
$supportedCommands=@('init','validate','plan-upgrade','upgrade','backup','restore','candidate-check')
if($Command -notin $supportedCommands){throw 'SPECTRA_COMMAND_UNKNOWN'}

function Assert-SpectraDelegateExit {
  if($LASTEXITCODE -ne 0){throw "SPECTRA_DELEGATE_EXIT_$LASTEXITCODE"}
}
$product=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if($ProductRoot){$product=[IO.Path]::GetFullPath($ProductRoot)}
$workspacePath=[IO.Path]::GetFullPath($Workspace)
if($workspacePath -eq [IO.Path]::GetPathRoot($workspacePath)){throw 'SPECTRA_PATH_UNSAFE'}
if($Target){$targetPath=[IO.Path]::GetFullPath($Target);if($targetPath -eq [IO.Path]::GetPathRoot($targetPath)){throw 'SPECTRA_TARGET_PATH_UNSAFE'}}
$writeCommands=@('init','upgrade','backup','restore')
if($Apply -and $Command -notin $writeCommands){throw 'SPECTRA_APPLY_NOT_SUPPORTED'}
$mode=if($Apply){'apply'}else{'dry-run'}
$result=[ordered]@{product_id='spectra';command=$Command;mode=$mode;status='PLANNED';code='SPECTRA_OK';workspace=$workspacePath;target=if($Target){$targetPath}else{$null};writes_performed=$false;delegate=$null}
try{
  switch($Command){
    'init' {
      $result.delegate='New-CustomerWorkspace.ps1'
      if(-not $Apply){break}
      $global:LASTEXITCODE=0
      if($SyntheticPilot){& (Join-Path $PSScriptRoot 'New-CustomerWorkspace.ps1') -Destination $workspacePath -Profile $Profile -SyntheticFixture|Out-Null}
      else{if(-not $Version -or -not $CustomerAlias){throw 'SPECTRA_INIT_BINDING_REQUIRED'};& (Join-Path $PSScriptRoot 'New-CustomerWorkspace.ps1') -Destination $workspacePath -Profile $Profile -ExpectedBlueprintVersion $Version -CustomerAlias $CustomerAlias -ProductRoot $product|Out-Null}
      Assert-SpectraDelegateExit
      $result.status='APPLIED';$result.writes_performed=$true
    }
    'validate' {
      $result.delegate='Test-SyntheticWorkspaceFixture.ps1'
      $global:LASTEXITCODE=0
      & (Join-Path $PSScriptRoot 'Test-SyntheticWorkspaceFixture.ps1') -Path $workspacePath|Out-Null
      Assert-SpectraDelegateExit
      $result.status='VALIDATED'
    }
    'plan-upgrade' {
      $result.delegate='Plan-WorkspaceUpgrade.ps1'
      if(-not $Version -or -not $Target){throw 'SPECTRA_UPGRADE_ARGUMENTS_REQUIRED'}
      $global:LASTEXITCODE=0
      & (Join-Path $PSScriptRoot 'Plan-WorkspaceUpgrade.ps1') -WorkspacePath $workspacePath -TargetVersion $Version -ProductRoot $product -PlanPath $targetPath|Out-Null
      Assert-SpectraDelegateExit
      $result.status='PLANNED';$result.writes_performed=$true
    }
    'upgrade' {
      $result.delegate='Plan-WorkspaceUpgrade.ps1'
      if(-not $Version -or -not $Target){throw 'SPECTRA_UPGRADE_ARGUMENTS_REQUIRED'}
      $args=@{WorkspacePath=$workspacePath;TargetVersion=$Version;ProductRoot=$product;PlanPath=$targetPath}
      if($Apply){$args.Apply=$true;$args.Approve=[bool]$Approve}
      $global:LASTEXITCODE=0
      & (Join-Path $PSScriptRoot 'Plan-WorkspaceUpgrade.ps1') @args|Out-Null
      Assert-SpectraDelegateExit
      $result.status=if($Apply){'APPLIED'}else{'PLANNED'};$result.writes_performed=[bool]$Apply
    }
    'backup' {
      $result.delegate='Backup-Workspace.ps1';if(-not $Target){throw 'SPECTRA_BACKUP_TARGET_REQUIRED'}
      $global:LASTEXITCODE=0
      if($Apply){& (Join-Path $PSScriptRoot 'Backup-Workspace.ps1') -Source $workspacePath -Destination $targetPath|Out-Null;$result.status='APPLIED';$result.writes_performed=$true}
      else{& (Join-Path $PSScriptRoot 'Backup-Workspace.ps1') -Source $workspacePath -Destination $targetPath -DryRun|Out-Null}
      Assert-SpectraDelegateExit
    }
    'restore' {
      $result.delegate='Restore-Workspace.ps1';if(-not $Target){throw 'SPECTRA_RESTORE_TARGET_REQUIRED'}
      $global:LASTEXITCODE=0
      if($Apply){& (Join-Path $PSScriptRoot 'Restore-Workspace.ps1') -Backup $workspacePath -Destination $targetPath|Out-Null;$result.status='APPLIED';$result.writes_performed=$true}
      else{& (Join-Path $PSScriptRoot 'Restore-Workspace.ps1') -Backup $workspacePath -Destination $targetPath -DryRun|Out-Null}
      Assert-SpectraDelegateExit
    }
    'candidate-check' {
      $result.delegate='Test-ReleaseCandidate.ps1';if(-not $Version){throw 'SPECTRA_VERSION_REQUIRED'}
      $global:LASTEXITCODE=0
      & (Join-Path $PSScriptRoot 'Test-ReleaseCandidate.ps1') -Version $Version|Out-Null
      Assert-SpectraDelegateExit
      $result.status='VALIDATED'
    }
  }
}catch{
  $message=$_.Exception.Message.Split([Environment]::NewLine)[0]
  throw "SPECTRA_DELEGATE_FAILED:$Command`:$message"
}
$result|ConvertTo-Json -Compress
