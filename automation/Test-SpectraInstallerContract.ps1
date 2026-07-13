[CmdletBinding()]param()
$ErrorActionPreference='Stop';Set-StrictMode -Version 2.0
$root=Split-Path -Parent $PSScriptRoot;$passed=0
function Require([bool]$Condition,[string]$Code){if(-not$Condition){throw $Code};$script:passed++}
$installer=Get-Content (Join-Path $root 'install.ps1') -Raw
$shell=Get-Content (Join-Path $root 'install.sh') -Raw
$tokens=$null;$errors=$null;[Management.Automation.Language.Parser]::ParseFile((Join-Path $root 'install.ps1'),[ref]$tokens,[ref]$errors)|Out-Null;Require (@($errors).Count -eq 0) 'INSTALL_SCRIPT_PARSE_FAILED'
Require ($installer -match "ValidateSet\('install','doctor','init','adopt','register','validate','snapshot','uninstall'\)") 'INSTALL_COMMAND_SET_MISSING'
Require ($installer -match 'Get-SpectraReleaseBinding') 'INSTALL_RELEASE_BINDING_MISSING'
Require ($installer -match 'INSTALL_SOURCE_NOT_EXACT_RELEASE_TAG') 'INSTALL_BRANCH_GUARD_MISSING'
Require ($installer -match 'INSTALL_PAYLOAD_DIGEST_MISMATCH') 'INSTALL_DIGEST_GUARD_MISSING'
Require ($installer -match 'INSTALL_DESTINATION_INSIDE_PROJECT_REPOSITORY') 'INSTALL_PROJECT_REPOSITORY_GUARD_MISSING'
Require ($installer -match 'preserves_registry=\$true;preserves_config=\$true') 'UNINSTALL_PRESERVATION_MISSING'
Require ($shell -match 'exec pwsh -NoProfile') 'INSTALL_SH_NOT_THIN_PWSH_STARTER'
Require ($shell -notmatch '(?i)curl|wget|token|password') 'INSTALL_SH_SCOPE_INVALID'
Require ($installer -notmatch '(?i)powershell\.exe|\bpowershell\b') 'INSTALL_MAC_RUNTIME_INVALID'
Require ($installer -notmatch '(?i)\.env') 'INSTALL_ENV_FILE_FORBIDDEN'
$cli=Get-Content (Join-Path $root 'automation/Invoke-SpectraBootstrap.ps1') -Raw
Require ($installer -match '\[Parameter\(Mandatory\)\]\[string\]\$Version') 'INSTALL_VERSION_MUST_BE_EXPLICIT'
Require ($cli.Contains("'register'{") -and $cli.Contains("if(-not`$Apply)")) 'REGISTER_DRY_RUN_GATE_MISSING'
Require ($installer -match 'UNINSTALL_PAYLOAD_DRIFT') 'UNINSTALL_DRIFT_GUARD_MISSING'
Require ($installer -match '\.spectra-install-stage-') 'INSTALL_ATOMIC_STAGE_MISSING'
if($passed-ne15){throw 'INSTALL_CONTRACT_COUNT_INVALID'}
Write-Host "PASS: $passed portable Installer-/Uninstall-Vertragspruefungen."
