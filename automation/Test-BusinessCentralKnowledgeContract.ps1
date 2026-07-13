$ErrorActionPreference='Stop';$temp=Join-Path $env:TEMP ('spectra-bc-knowledge-'+[guid]::NewGuid().ToString('N'));$snapshot='BCK-28.2-DE-SYNTHETIC'
try{
  $a=Join-Path $temp 'a';$b=Join-Path $temp 'b';& (Join-Path $PSScriptRoot 'New-SyntheticBusinessCentralKnowledgeFixture.ps1') -Destination $a -SnapshotId $snapshot;& (Join-Path $PSScriptRoot 'New-SyntheticBusinessCentralKnowledgeFixture.ps1') -Destination $b -SnapshotId $snapshot
  . (Join-Path $PSScriptRoot 'BusinessCentral.Knowledge.ps1');$ma=Build-BCKnowledgeIndex $a $snapshot;$mb=Build-BCKnowledgeIndex $b $snapshot
  if($ma.index_digest -ne $mb.index_digest -or $ma.object_count -ne 4 -or $ma.document_count -ne 2){throw 'BC_KNOWLEDGE_REBUILD_NOT_DETERMINISTIC'}
  [void](Test-BCKnowledgeIndex $a $snapshot);$all=@(Search-BCKnowledgeIndex $a $snapshot 'Purchase' $null $null);if($all.Count -ne 4){throw 'BC_KNOWLEDGE_SEARCH_INCOMPLETE'};$w1=@(Search-BCKnowledgeIndex $a $snapshot $null 'table' 'W1');$de=@(Search-BCKnowledgeIndex $a $snapshot $null 'table' 'DE');if($w1.Count -ne 1 -or $de.Count -ne 1 -or $w1[0].object_key -eq $de[0].object_key){throw 'BC_KNOWLEDGE_COUNTRY_COLLISION'}
  if(@($all|Where-Object{$_.purpose.status -ne 'unknown' -or $null -ne $_.purpose.text}).Count -ne 0){throw 'BC_KNOWLEDGE_PURPOSE_INVENTED'}
  Write-Host 'PASS: BC 28.2, W1/DE, drei gepinnte Quellen und vier AL-Objekte sind deterministisch offline suchbar.'
}finally{if(Test-Path $temp){Remove-Item $temp -Recurse -Force}}
