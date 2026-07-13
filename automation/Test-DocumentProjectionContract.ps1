$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'));$temp=Join-Path $env:TEMP ('spectra-doc-projection-'+[guid]::NewGuid().ToString('N'))
try{
  foreach($profile in @('implementation','support-only')){
    $a=Join-Path $temp "$profile-a";$b=Join-Path $temp "$profile-b";$ra=Join-Path $temp "$profile-render-a";$rb=Join-Path $temp "$profile-render-b"
    & (Join-Path $PSScriptRoot 'New-SyntheticDocumentProjection.ps1') -Destination $a -Profile $profile
    & (Join-Path $PSScriptRoot 'New-SyntheticDocumentProjection.ps1') -Destination $b -Profile $profile
    if((Get-FileHash (Join-Path $a 'projection.json')).Hash-ne(Get-FileHash (Join-Path $b 'projection.json')).Hash){throw 'DOCUMENT_PROJECTION_NONDETERMINISTIC'}
    & (Join-Path $PSScriptRoot 'Test-DocumentProjection.ps1') -Path $a
    & (Join-Path $PSScriptRoot 'Render-DocumentProjection.ps1') -Path $a -Destination $ra
    & (Join-Path $PSScriptRoot 'Render-DocumentProjection.ps1') -Path $b -Destination $rb
    $ha=(Get-ChildItem $ra -File -Recurse|Sort-Object FullName|ForEach-Object{(Get-FileHash $_.FullName).Hash})-join'|';$hb=(Get-ChildItem $rb -File -Recurse|Sort-Object FullName|ForEach-Object{(Get-FileHash $_.FullName).Hash})-join'|'
    if($ha-ne$hb){throw 'DOCUMENT_RENDER_NONDETERMINISTIC'}
    if(Test-Path (Join-Path $ra 'authored\fachwissen.md')){throw 'DOCUMENT_RENDER_AUTHORED_WRITE'}
  }
  Write-Host 'PASS: Implementation und Support-only werden deterministisch, ohne authored Writes, projiziert.'
}finally{if(Test-Path $temp){Remove-Item $temp -Recurse -Force}}
