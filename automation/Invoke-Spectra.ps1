[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][ValidateSet('init','validate','plan-upgrade','upgrade','backup','restore','candidate-check')][string]$Command,
  [Parameter(Mandatory=$true)][string]$Workspace,
  [switch]$Apply
)
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath($Workspace)
if($root -eq [IO.Path]::GetPathRoot($root)){throw 'SPECTRA_PATH_UNSAFE'}
$writeCommands=@('init','upgrade','backup','restore')
$mode=if($Apply){'apply'}else{'dry-run'}
if($Apply -and $Command -notin $writeCommands){throw 'SPECTRA_APPLY_NOT_SUPPORTED'}
$result=[ordered]@{product_id='spectra';command=$Command;mode=$mode;status='PLANNED';code='SPECTRA_OK';workspace=$root;writes_performed=$false}
if($Apply){$result.status='BLOCKED';$result.code='SPECTRA_APPLY_GATE_PENDING'}
$result|ConvertTo-Json -Compress
