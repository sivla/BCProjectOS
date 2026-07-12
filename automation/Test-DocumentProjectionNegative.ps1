$ErrorActionPreference='Stop'
$temp=Join-Path $env:TEMP ('spectra-doc-negative-'+[guid]::NewGuid().ToString('N'))
function Invoke-Exact([string]$path){$psi=[Diagnostics.ProcessStartInfo]::new();$psi.FileName='powershell.exe';$psi.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Run-DocumentProjectionExact.ps1`" -Path `"$path`"";$psi.UseShellExecute=$false;$psi.RedirectStandardOutput=$true;$psi.RedirectStandardError=$true;$p=[Diagnostics.Process]::Start($psi);$o=$p.StandardOutput.ReadToEnd().Trim();$e=$p.StandardError.ReadToEnd().Trim();$p.WaitForExit();[pscustomobject]@{Exit=$p.ExitCode;Out=$o;Err=$e}}
$cases=@(
  @{code='DOCUMENT_PROJECTION_DUPLICATE_ID';m={param($x)$x.documentation.documents[1].id=$x.documentation.documents[0].id}},
  @{code='DOCUMENT_PROJECTION_CROSS_CUSTOMER';m={param($x)$x.documentation.nodes[0].customer_id='CUS-OTHER'}},
  @{code='DOCUMENT_PROJECTION_PATH_UNSAFE';m={param($x)$x.documentation.documents[0].source_path='../outside.md'}},
  @{code='DOCUMENT_PROJECTION_SOURCE_PATH_DUPLICATE';m={param($x)$x.documentation.documents[1].source_path=$x.documentation.documents[0].source_path}},
  @{code='DOCUMENT_PROJECTION_PROVENANCE_MISSING';m={param($x)$x.documentation.documents[0].provenance_ids=@()}},
  @{code='DOCUMENT_PROJECTION_GENERATED_AUTHORED_CONFLICT';m={param($x)$x.documentation.documents[0].authored_sections=@('Manuell')}},
  @{code='DOCUMENT_PROJECTION_PARENT_UNKNOWN';m={param($x)$x.documentation.nodes[1].parent_id='NOD-UNKNOWN'}},
  @{code='DOCUMENT_PROJECTION_NODE_CYCLE';m={param($x)$x.documentation.nodes[0].parent_id='NOD-KNOWLEDGE';$x.documentation.nodes[1].parent_id='NOD-HOME'}},
  @{code='DOCUMENT_PROJECTION_ORDER_DUPLICATE';m={param($x)$copy=$x.documentation.nodes[1].PSObject.Copy();$copy.id='NOD-SECOND';$copy.document_id='DOC-HOME';$x.documentation.nodes+=@($copy)}},
  @{code='DOCUMENT_PROJECTION_HOME_MISMATCH';m={param($x)$x.documentation.spaces[0].home_document_id='DOC-KNOWLEDGE'}},
  @{code='DOCUMENT_PROJECTION_REFERENCE_UNKNOWN';m={param($x)$x.documentation.references[0].to.id='DOC-UNKNOWN'}},
  @{code='DOCUMENT_PROJECTION_VIEW_TICKET_UNKNOWN';m={param($x)$x.jira.views[0].ticket_ids=@('TKT-UNKNOWN')}}
)
try{
  $i=0;foreach($c in $cases){$i++;$d=Join-Path $temp "$i";& (Join-Path $PSScriptRoot 'New-SyntheticDocumentProjection.ps1') -Destination $d -Profile implementation|Out-Null;$f=Join-Path $d 'projection.json';$x=Get-Content $f -Raw|ConvertFrom-Json;& $c.m $x;[IO.File]::WriteAllText($f,(($x|ConvertTo-Json -Depth 20)+"`n"),[Text.UTF8Encoding]::new($false));$r=Invoke-Exact $d;if($r.Exit-ne1-or$r.Err-ne''-or$r.Out-cne$c.code){throw "NEGATIVE_ORACLE_FAILED:$i expected=$($c.code) exit=$($r.Exit) out=$($r.Out) err=$($r.Err)"}}
  Write-Host "PASS: $($cases.Count) isolierte Dokumentprojektions-Negativfälle."
}finally{if(Test-Path $temp){Remove-Item $temp -Recurse -Force}}
