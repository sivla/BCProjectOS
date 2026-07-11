[CmdletBinding()]param([Parameter(Mandatory=$true)][string]$Destination)
$ErrorActionPreference='Stop';Set-StrictMode -Version 2.0;$dest=[IO.Path]::GetFullPath($Destination);if(Test-Path $dest){throw 'SYNTHETIC_TARGET_EXISTS'};New-Item -ItemType Directory -Force $dest|Out-Null
foreach($d in @('sales','purchasing','inventory','finance','projects','uat','evidence')){New-Item -ItemType Directory -Force (Join-Path $dest $d)|Out-Null}
$meta=[ordered]@{schema_version=1;artifact_type='spectra_synthetic_bc_basic_workspace';product_id='spectra';synthetic=$true;installable=$false;release_status='PENDING_BCPROJECTOS_RELEASE';areas=@('sales','purchasing','inventory','finance');process_chain=@('initialization','planning','setup','migration','process_execution','test_uat','evidence','cutover','hypercare','handover')};$meta|ConvertTo-Json -Depth 8|Set-Content (Join-Path $dest 'synthetic-bc-basic.json') -Encoding utf8
$records=@(
 [ordered]@{id='PRJ-SYNTHETIC-BASIC';type='project';status='draft';area='implementation'},
 [ordered]@{id='UAT-SYNTHETIC-BASIC';type='uat';status='draft';area='test_uat'},
 [ordered]@{id='EVD-SYNTHETIC-BASIC';type='evidence';status='draft';area='evidence'}
);$records|ConvertTo-Json -Depth 8|Set-Content (Join-Path $dest 'projects\records.json') -Encoding utf8;Write-Host 'PASS: Synthetic BC-Basic fixture created.'
