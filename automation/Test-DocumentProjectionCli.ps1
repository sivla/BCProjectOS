$ErrorActionPreference='Stop'
$temp=Join-Path $env:TEMP ('spectra-document-cli-'+[guid]::NewGuid().ToString('N'))
try{
  $dry=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command generate-document-projection -Workspace $temp|ConvertFrom-Json
  if($dry.status-ne'PLANNED'-or$dry.writes_performed-ne$false-or(Test-Path $temp)){throw 'DOCUMENT_PROJECTION_CLI_DRY_RUN_FAILED'}
  $apply=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command generate-document-projection -Workspace $temp -Profile support-only -Apply|ConvertFrom-Json
  if($apply.status-ne'APPLIED'-or$apply.writes_performed-ne$true){throw 'DOCUMENT_PROJECTION_CLI_APPLY_FAILED'}
  $validate=& (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command validate-document-projection -Workspace $temp|ConvertFrom-Json
  if($validate.status-ne'VALIDATED'-or$validate.writes_performed-ne$false){throw 'DOCUMENT_PROJECTION_CLI_VALIDATE_FAILED'}
  Write-Host 'PASS: Dokumentprojektions-CLI ist dry-run-first und validiert read-only.'
}finally{if(Test-Path $temp){Remove-Item $temp -Recurse -Force}}
