$ErrorActionPreference='Stop';$temp=Join-Path $env:TEMP ('spectra-bc-knowledge-cli-'+[guid]::NewGuid().ToString('N'));$snapshot='BCK-28.2-DE-SYNTHETIC'
try{
  & (Join-Path $PSScriptRoot 'New-SyntheticBusinessCentralKnowledgeFixture.ps1') -Destination $temp -SnapshotId $snapshot|Out-Null
  $plan=& (Join-Path $PSScriptRoot 'Invoke-BusinessCentralKnowledge.ps1') -Command plan-update -Root $temp|ConvertFrom-Json;if($plan.status-ne'PLANNED'-or$plan.writes_performed-ne$false-or@($plan.sources).Count-ne3){throw 'BC_KNOWLEDGE_PLAN_INVALID'}
  $status=& (Join-Path $PSScriptRoot 'Invoke-BusinessCentralKnowledge.ps1') -Command status -Root $temp -SnapshotId $snapshot|ConvertFrom-Json;if($status.index_status-ne'missing'){throw 'BC_KNOWLEDGE_STATUS_INVALID'}
  $built=& (Join-Path $PSScriptRoot 'Invoke-BusinessCentralKnowledge.ps1') -Command build -Root $temp -SnapshotId $snapshot -Apply|ConvertFrom-Json;if($built.object_count-ne4){throw 'BC_KNOWLEDGE_BUILD_INVALID'}
  $found=& (Join-Path $PSScriptRoot 'Invoke-BusinessCentralKnowledge.ps1') -Command search -Root $temp -SnapshotId $snapshot -Query Purchase|ConvertFrom-Json;if(@($found).Count-ne4){throw 'BC_KNOWLEDGE_CLI_SEARCH_INVALID'}
  $shown=& (Join-Path $PSScriptRoot 'Invoke-BusinessCentralKnowledge.ps1') -Command show -Root $temp -SnapshotId $snapshot -ObjectKey $found[0].object_key|ConvertFrom-Json;if($shown.object_key-ne$found[0].object_key){throw 'BC_KNOWLEDGE_CLI_SHOW_INVALID'}
  Write-Host 'PASS: BC-Knowledge status, plan-update, build, search und show sind explizit und offline.'
}finally{if(Test-Path $temp){Remove-Item $temp -Recurse -Force}}
