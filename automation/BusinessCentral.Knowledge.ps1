Set-StrictMode -Version 2.0

function Get-BCKnowledgeProductRoot { [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')) }
function Get-BCKnowledgeRegistry { Get-Content -LiteralPath (Join-Path (Get-BCKnowledgeProductRoot) 'catalogs\business-central-sources.json') -Raw|ConvertFrom-Json }
function Get-Sha256Text([string]$Text){$h=[Security.Cryptography.SHA256]::Create();try{([BitConverter]::ToString($h.ComputeHash([Text.UTF8Encoding]::new($false).GetBytes($Text)))).Replace('-','').ToLowerInvariant()}finally{$h.Dispose()}}
function Write-Utf8([string]$Path,[string]$Text){$parent=Split-Path $Path -Parent;if(-not(Test-Path $parent)){New-Item -ItemType Directory -Force -Path $parent|Out-Null};[IO.File]::WriteAllText($Path,($Text-replace"`r`n","`n"),[Text.UTF8Encoding]::new($false))}
function Read-Utf8Strict([string]$Path){try{[Text.UTF8Encoding]::new($false,$true).GetString([IO.File]::ReadAllBytes($Path))}catch{throw 'BC_KNOWLEDGE_INDEX_UTF8_INVALID'}}
function Invoke-BCJsonSchema($Value,[string]$SchemaName){
  $schema=Get-Content -LiteralPath (Join-Path (Get-BCKnowledgeProductRoot) "schemas\$SchemaName") -Raw|ConvertFrom-Json
  $script:RootSchema=$schema;$script:InvokeSchema={param([AllowNull()]$v,$s,$p).(Join-Path $PSScriptRoot 'Invoke-PortableSchemaValidation.ps1') -Value $v -Schema $s -RootSchema $script:RootSchema -Path $p}
  . (Join-Path $PSScriptRoot 'Invoke-PortableSchemaValidation.ps1') -Value $Value -Schema $schema -RootSchema $schema -Path 'root'
}

function Resolve-BCKnowledgeRoot([string]$Root){
  if([string]::IsNullOrWhiteSpace($Root)){$Root=$env:SPECTRA_KNOWLEDGE_ROOT}
  if([string]::IsNullOrWhiteSpace($Root)){throw 'BC_KNOWLEDGE_ROOT_MISSING'}
  $full=[IO.Path]::GetFullPath($Root);$product=Get-BCKnowledgeProductRoot
  if($full -eq [IO.Path]::GetPathRoot($full) -or $full -eq $product -or $full.StartsWith($product.TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'BC_KNOWLEDGE_ROOT_UNSAFE'}
  if(Test-Path $full){$item=Get-Item -LiteralPath $full -Force;if(($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0){throw 'BC_KNOWLEDGE_ROOT_REPARSE'}}
  $full
}

function Get-GitText([string]$Mirror,[string]$Revision,[string]$Path){
  $text=& git -C $Mirror show "$Revision`:$Path" 2>$null;if($LASTEXITCODE -ne 0){throw 'BC_KNOWLEDGE_GIT_BLOB_MISSING'};($text -join "`n")+"`n"
}
function Get-GitContentDigest([string]$Mirror,[string]$Commit){$tree=(& git -C $Mirror ls-tree -r $Commit);if($LASTEXITCODE -ne 0){throw 'BC_KNOWLEDGE_COMMIT_MISSING'};Get-Sha256Text (($tree -join "`n")+"`n")}
function Test-GitObjectExists([string]$Mirror,[string]$Object){$psi=[Diagnostics.ProcessStartInfo]::new();$psi.FileName='git';$psi.Arguments="-C `"$Mirror`" cat-file -e `"$Object`"";$psi.UseShellExecute=$false;$psi.RedirectStandardOutput=$true;$psi.RedirectStandardError=$true;$p=[Diagnostics.Process]::Start($psi);[void]$p.StandardOutput.ReadToEnd();[void]$p.StandardError.ReadToEnd();$p.WaitForExit();$ok=$p.ExitCode -eq 0;$p.Dispose();$ok}

function Test-BCKnowledgeLock([string]$Root,[string]$SnapshotId){
  $runtime=Resolve-BCKnowledgeRoot $Root;$lockPath=Join-Path $runtime "locks\$SnapshotId\sources.lock.json"
  if(-not(Test-Path $lockPath -PathType Leaf)){throw 'BC_KNOWLEDGE_LOCK_MISSING'}
  $lock=Get-Content $lockPath -Raw|ConvertFrom-Json;$registry=Get-BCKnowledgeRegistry
  if([int]$lock.schema_version -ne 1 -or [string]$lock.product_id -ne 'spectra' -or [string]$lock.snapshot_id -ne $SnapshotId -or [string]$lock.validation_status -ne 'validated'){throw 'BC_KNOWLEDGE_LOCK_CONTRACT_INVALID'}
  try{Invoke-BCJsonSchema $lock 'business-central-source-lock.schema.json'}catch{throw "BC_KNOWLEDGE_LOCK_SCHEMA_INVALID:$($_.Exception.Message.Split(':')[0])"}
  if([string]$lock.bc_version -notmatch '^[0-9]+\.[0-9]+$' -or @($lock.countries).Count -eq 0){throw 'BC_KNOWLEDGE_VERSION_BINDING_INVALID'}
  if(@($lock.sources).Count -ne 3 -or @($lock.sources|Group-Object source_id|Where-Object Count -gt 1).Count -gt 0){throw 'BC_KNOWLEDGE_SOURCE_SET_INVALID'}
  foreach($s in @($lock.sources)){
    $reg=@($registry.sources|Where-Object source_id -eq $s.source_id);if($reg.Count -ne 1 -or [string]$reg[0].canonical_url -ne [string]$s.canonical_url -or [string]$reg[0].role -ne [string]$s.role){throw 'BC_KNOWLEDGE_SOURCE_NOT_ALLOWED'}
    if([string]$s.ref_kind -notin @('commit','release') -or [string]$s.commit -notmatch '^[a-f0-9]{40}$' -or [string]$s.tree -notmatch '^[a-f0-9]{40}$'){throw 'BC_KNOWLEDGE_SOURCE_UNPINNED'}
    if([string]$s.mirror_name-notmatch'^[a-z0-9-]+\.git$'){throw 'BC_KNOWLEDGE_MIRROR_PATH_UNSAFE'}
    $mirror=Join-Path $runtime "sources\$($s.mirror_name)";if(-not(Test-Path $mirror -PathType Container)){throw 'BC_KNOWLEDGE_MIRROR_MISSING'}
    if((& git -C $mirror rev-parse --is-bare-repository).Trim()-ne'true'){throw 'BC_KNOWLEDGE_MIRROR_NOT_BARE'}
    if(-not(Test-GitObjectExists $mirror "$($s.commit)^{commit}")){throw 'BC_KNOWLEDGE_COMMIT_MISSING'}
    if((& git -C $mirror rev-parse "$($s.commit)^{tree}").Trim() -ne [string]$s.tree){throw 'BC_KNOWLEDGE_TREE_MISMATCH'}
    $license=Get-GitText $mirror ([string]$s.commit) ([string]$s.license_path);if((Get-Sha256Text $license) -ne [string]$s.license_blob_digest){throw 'BC_KNOWLEDGE_LICENSE_DIGEST_MISMATCH'}
    if((Get-GitContentDigest $mirror ([string]$s.commit)) -ne [string]$s.content_digest){throw 'BC_KNOWLEDGE_CONTENT_DIGEST_MISMATCH'}
  }
  $canonical=(@($lock.sources|Sort-Object source_id|ForEach-Object{"$($_.source_id)|$($_.commit)|$($_.tree)|$($_.license_blob_digest)|$($_.content_digest)"})-join"`n")+"`n"
  if((Get-Sha256Text $canonical) -ne [string]$lock.lock_digest){throw 'BC_KNOWLEDGE_LOCK_DIGEST_MISMATCH'}
  $lock
}

function Get-BCKnowledgeApp($Lock,[string]$Country){
  $apps=@($Lock.installed_apps|Where-Object country -eq $Country);if($apps.Count -eq 0){throw 'BC_KNOWLEDGE_APP_BINDING_MISSING'};$apps[0]
}
function Get-ALProperty([string]$Text,[string]$Name){$m=[regex]::Match($Text,"(?im)^\s*$([regex]::Escape($Name))\s*=\s*([^;]+);");if($m.Success){$m.Groups[1].Value.Trim(' ','"')}else{$null}}
function Convert-ALObject([string]$Text,[string]$Path,$Source,$Lock){
  $m=[regex]::Match($Text,'(?im)^\s*(tableextension|pageextension|table|page|report|codeunit|query|xmlport|enum|interface|permissionset)\s+(\d+)\s+"?([^"\r\n{]+?)"?(?:\s+extends\s+"?([^"\r\n{]+?)"?)?\s*\{')
  if(-not$m.Success){throw "BC_KNOWLEDGE_AL_DECLARATION_INVALID:$Path"}
  $type=$m.Groups[1].Value.ToLowerInvariant();$id=[int]$m.Groups[2].Value;$name=$m.Groups[3].Value.Trim();$extends=if($m.Groups[4].Success){$m.Groups[4].Value.Trim()}else{$null}
  $country=if($Path-match'/(DE)/'){'DE'}else{'W1'};$app=Get-BCKnowledgeApp $Lock $country;$namespace=$null;$nm=[regex]::Match($Text,'(?im)^\s*namespace\s+([^;]+);');if($nm.Success){$namespace=$nm.Groups[1].Value.Trim()}
  $caption=Get-ALProperty $Text 'Caption';$obsolete=Get-ALProperty $Text 'ObsoleteState';if($obsolete){$obsolete=$obsolete.ToLowerInvariant()}else{$obsolete='none'}
  $page=$null;$table=$null
  if($type -in @('page','pageextension')){$page=[ordered]@{page_type=Get-ALProperty $Text 'PageType';source_table=Get-ALProperty $Text 'SourceTable';extends=$extends}}
  if($type -in @('table','tableextension')){$fields=@([regex]::Matches($Text,'(?im)\bfield\((\d+)\s*;\s*"?([^";]+)"?\s*;')|ForEach-Object{"$($_.Groups[1].Value):$($_.Groups[2].Value.Trim())"});$keys=@([regex]::Matches($Text,'(?im)\bkey\(([^;]+);')|ForEach-Object{$_.Groups[1].Value.Trim()});$rels=@([regex]::Matches($Text,'(?im)TableRelation\s*=\s*([^;]+);')|ForEach-Object{$_.Groups[1].Value.Trim()});$table=[ordered]@{extends=$extends;fields=$fields;keys=$keys;relations=$rels}}
  [ordered]@{object_key="$($app.app_id)|$country|$type|$id";bc_version=[string]$Lock.bc_version;country=$country;object_type=$type;object_id=$id;name=$name;caption=$caption;namespace=$namespace;app=[ordered]@{app_id=$app.app_id;name=$app.name;publisher=$app.publisher;version=$app.version};layer=if($country-eq'DE'){'localization'}else{'base'};source=[ordered]@{source_id=$Source.source_id;path=$Path;line=($Text.Substring(0,$m.Index)-split"`n").Count;commit=$Source.commit};obsolete_state=$obsolete;page=$page;table=$table;purpose=[ordered]@{status='unknown';text=$null;provenance_ids=@()};process_tags=@()}
}

function Build-BCKnowledgeIndex([string]$Root,[string]$SnapshotId){
  $runtime=Resolve-BCKnowledgeRoot $Root;$lock=Test-BCKnowledgeLock $runtime $SnapshotId;$indexDir=Join-Path $runtime "indexes\$SnapshotId"
  if(Test-Path $indexDir){throw 'BC_KNOWLEDGE_INDEX_EXISTS'};New-Item -ItemType Directory -Path $indexDir|Out-Null
  $objects=@();$documents=@()
  foreach($s in @($lock.sources|Sort-Object source_id)){$mirror=Join-Path $runtime "sources\$($s.mirror_name)";$paths=@(& git -C $mirror ls-tree -r --name-only $s.commit);foreach($path in $paths|Sort-Object){if($path-match'(^|/)LICENSE'){continue};if($s.role-eq'canonical-application-source'-and$path.EndsWith('.al',[StringComparison]::OrdinalIgnoreCase)){$objects+=(Convert-ALObject (Get-GitText $mirror $s.commit $path) $path $s $lock)}elseif($s.role-like'*documentation'-and$path.EndsWith('.md',[StringComparison]::OrdinalIgnoreCase)){$text=Get-GitText $mirror $s.commit $path;$title=([regex]::Match($text,'(?m)^#\s+(.+)$')).Groups[1].Value;if([string]::IsNullOrWhiteSpace($title)){$title=[IO.Path]::GetFileNameWithoutExtension($path)};$documents+=[ordered]@{document_key="$($s.source_id)|$path";title=$title;role=$s.role;source_id=$s.source_id;path=$path;commit=$s.commit;content_digest=Get-Sha256Text $text}}}}
  if(@($objects|Group-Object { $_.object_key }|Where-Object Count -gt 1).Count -gt 0){throw 'BC_KNOWLEDGE_OBJECT_KEY_DUPLICATE'}
  foreach($object in $objects){try{Invoke-BCJsonSchema $object 'business-central-object-catalog.schema.json'}catch{throw "BC_KNOWLEDGE_OBJECT_SCHEMA_INVALID:$($_.Exception.Message.Split(':')[0])"}}
  $objectText=(@($objects|Sort-Object { $_.object_key }|ForEach-Object{$_|ConvertTo-Json -Depth 12 -Compress})-join"`n")+"`n";$documentText=(@($documents|Sort-Object { $_.document_key }|ForEach-Object{$_|ConvertTo-Json -Depth 8 -Compress})-join"`n")+"`n"
  $terms=@();foreach($o in $objects){$terms+=,[ordered]@{term=([string]$o.name).ToLowerInvariant();kind='object';key=$o.object_key};if($o.caption){$terms+=,[ordered]@{term=([string]$o.caption).ToLowerInvariant();kind='object';key=$o.object_key}}};foreach($d in $documents){$terms+=,[ordered]@{term=([string]$d.title).ToLowerInvariant();kind='document';key=$d.document_key}}
  $termText=(@($terms|Sort-Object { $_.term },{ $_.kind },{ $_.key }|ForEach-Object{$_|ConvertTo-Json -Compress})-join"`n")+"`n";$od=Get-Sha256Text $objectText;$dd=Get-Sha256Text $documentText;$td=Get-Sha256Text $termText;$indexDigest=Get-Sha256Text "$($lock.lock_digest)|$od|$dd|$td`n"
  Write-Utf8 (Join-Path $indexDir 'objects.jsonl') $objectText;Write-Utf8 (Join-Path $indexDir 'documents.jsonl') $documentText;Write-Utf8 (Join-Path $indexDir 'terms.jsonl') $termText
  $manifest=[ordered]@{schema_version=1;product_id='spectra';snapshot_id=$SnapshotId;knowledge_pack_id=$lock.knowledge_pack_id;bc_version=$lock.bc_version;countries=@($lock.countries);source_lock_digest=$lock.lock_digest;object_count=$objects.Count;document_count=$documents.Count;objects_digest=$od;documents_digest=$dd;terms_digest=$td;index_digest=$indexDigest;validation_status='validated'}
  Write-Utf8 (Join-Path $indexDir 'manifest.json') (($manifest|ConvertTo-Json -Depth 8)+"`n");$manifest
}

function Test-BCKnowledgeIndex([string]$Root,[string]$SnapshotId){
  $runtime=Resolve-BCKnowledgeRoot $Root;$lock=Test-BCKnowledgeLock $runtime $SnapshotId;$dir=Join-Path $runtime "indexes\$SnapshotId";$mf=Join-Path $dir 'manifest.json';if(-not(Test-Path $mf)){throw 'BC_KNOWLEDGE_INDEX_MISSING'};$m=Get-Content $mf -Raw|ConvertFrom-Json
  try{Invoke-BCJsonSchema $m 'business-central-search-index.schema.json'}catch{throw "BC_KNOWLEDGE_INDEX_SCHEMA_INVALID:$($_.Exception.Message.Split(':')[0])"}
  $ot=Read-Utf8Strict (Join-Path $dir 'objects.jsonl');$dt=Read-Utf8Strict (Join-Path $dir 'documents.jsonl');$tt=Read-Utf8Strict (Join-Path $dir 'terms.jsonl')
  if([string]$m.source_lock_digest -ne [string]$lock.lock_digest -or (Get-Sha256Text $ot) -ne [string]$m.objects_digest -or (Get-Sha256Text $dt) -ne [string]$m.documents_digest -or (Get-Sha256Text $tt) -ne [string]$m.terms_digest){throw 'BC_KNOWLEDGE_INDEX_STALE_OR_TAMPERED'}
  if((Get-Sha256Text "$($m.source_lock_digest)|$($m.objects_digest)|$($m.documents_digest)|$($m.terms_digest)`n") -ne [string]$m.index_digest){throw 'BC_KNOWLEDGE_INDEX_DIGEST_MISMATCH'}
  $objects=@($ot.TrimEnd("`r","`n")-split"`n"|Where-Object{$_}|ForEach-Object{ConvertFrom-Json $_});$documents=@($dt.TrimEnd("`r","`n")-split"`n"|Where-Object{$_}|ForEach-Object{ConvertFrom-Json $_})
  if($objects.Count -ne [int]$m.object_count -or $documents.Count -ne [int]$m.document_count){throw 'BC_KNOWLEDGE_INDEX_COUNT_MISMATCH'}
  $keys=@($objects.object_key);if(@($keys|Group-Object|Where-Object Count -gt 1).Count -gt 0){throw 'BC_KNOWLEDGE_OBJECT_KEY_DUPLICATE'}
  foreach($o in $objects){try{Invoke-BCJsonSchema $o 'business-central-object-catalog.schema.json'}catch{throw "BC_KNOWLEDGE_OBJECT_SCHEMA_INVALID:$($_.Exception.Message.Split(':')[0])"};if([string]$o.bc_version -ne [string]$lock.bc_version){throw 'BC_KNOWLEDGE_OBJECT_VERSION_MISMATCH'};if([string]$o.purpose.status -eq 'unknown' -and $null -ne $o.purpose.text){throw 'BC_KNOWLEDGE_OBJECT_PURPOSE_INVENTED'};if([string]$o.purpose.status -in @('official','curated') -and ([string]::IsNullOrWhiteSpace([string]$o.purpose.text) -or @($o.purpose.provenance_ids).Count -eq 0)){throw 'BC_KNOWLEDGE_OBJECT_PURPOSE_PROVENANCE_MISSING'}}
  $m
}

function Search-BCKnowledgeIndex([string]$Root,[string]$SnapshotId,[string]$Query,[string]$ObjectType,[string]$Country){
  $runtime=Resolve-BCKnowledgeRoot $Root;[void](Test-BCKnowledgeIndex $runtime $SnapshotId);$path=Join-Path $runtime "indexes\$SnapshotId\objects.jsonl";$items=@(Get-Content $path|Where-Object{$_}|ForEach-Object{ConvertFrom-Json $_});if($ObjectType){$items=@($items|Where-Object object_type -eq $ObjectType)};if($Country){$items=@($items|Where-Object country -eq $Country)};if($Query){$q=[regex]::Escape($Query);$items=@($items|Where-Object{"$($_.object_id) $($_.name) $($_.caption) $($_.app.name) $($_.process_tags -join ' ')"-match$q})};@($items|Sort-Object object_key)
}
