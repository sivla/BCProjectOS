$ErrorActionPreference='Stop';$temp=Join-Path $env:TEMP ('spectra-bc-knowledge-negative-'+[guid]::NewGuid().ToString('N'));$snapshot='BCK-28.2-DE-SYNTHETIC'
. (Join-Path $PSScriptRoot 'BusinessCentral.Knowledge.ps1')
function Write-Lock($x,[string]$path){Write-Utf8 $path (($x|ConvertTo-Json -Depth 15)+"`n")}
function Rehash-Index([string]$root){$dir=Join-Path $root "indexes\$snapshot";$m=Get-Content (Join-Path $dir 'manifest.json') -Raw|ConvertFrom-Json;$ot=Read-Utf8Strict (Join-Path $dir 'objects.jsonl');$dt=Read-Utf8Strict (Join-Path $dir 'documents.jsonl');$tt=Read-Utf8Strict (Join-Path $dir 'terms.jsonl');$m.objects_digest=Get-Sha256Text $ot;$m.documents_digest=Get-Sha256Text $dt;$m.terms_digest=Get-Sha256Text $tt;$m.object_count=@($ot.TrimEnd("`r","`n")-split"`n"|?{$_}).Count;$m.index_digest=Get-Sha256Text "$($m.source_lock_digest)|$($m.objects_digest)|$($m.documents_digest)|$($m.terms_digest)`n";Write-Utf8 (Join-Path $dir 'manifest.json') (($m|ConvertTo-Json -Depth 8)+"`n")}
function Rehash-Lock($lock){$canonical=(@($lock.sources|Sort-Object source_id|ForEach-Object{"$($_.source_id)|$($_.commit)|$($_.tree)|$($_.license_blob_digest)|$($_.content_digest)"})-join"`n")+"`n";$lock.lock_digest=Get-Sha256Text $canonical}
function Add-ForbiddenPinnedAL([string]$root,$lock){$source=@($lock.sources|Where-Object source_id -eq 'microsoft-bcapps')[0];$mirror=Join-Path $root "sources\$($source.mirror_name)";$work=Join-Path $root '.forbidden-source';&git clone --quiet $mirror $work;&git -C $work config user.name 'Spectra Synthetic';&git -C $work config user.email 'spectra.synthetic@invalid.example';&git -C $work config core.autocrlf false;Write-Utf8 (Join-Path $work 'forbidden\Outside.Table.al') "table 99999 `"Outside`"`n{`n}`n";&git -C $work add .;$env:GIT_AUTHOR_DATE='2026-01-02T00:00:00Z';$env:GIT_COMMITTER_DATE=$env:GIT_AUTHOR_DATE;&git -C $work commit --quiet -m 'Add forbidden pinned AL';Remove-Item Env:GIT_AUTHOR_DATE,Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue;&git -C $work push --quiet origin HEAD:refs/heads/main;$source.commit=(&git -C $work rev-parse HEAD).Trim();$source.tree=(&git -C $work rev-parse 'HEAD^{tree}').Trim();$source.content_digest=Get-GitContentDigest $mirror $source.commit;$source.license_blob_digest=Get-Sha256Text (Get-GitText $mirror $source.commit $source.license_path);Rehash-Lock $lock;Remove-Item $work -Recurse -Force}
function Invoke-Exact([string]$root,[string]$op){$psi=[Diagnostics.ProcessStartInfo]::new();$psi.FileName='powershell.exe';$psi.Arguments="-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Run-BusinessCentralKnowledgeExact.ps1`" -Root `"$root`" -SnapshotId $snapshot -Operation $op";$psi.UseShellExecute=$false;$psi.RedirectStandardOutput=$true;$psi.RedirectStandardError=$true;$p=[Diagnostics.Process]::Start($psi);$o=$p.StandardOutput.ReadToEnd().Trim();$e=$p.StandardError.ReadToEnd().Trim();$p.WaitForExit();[pscustomobject]@{Exit=$p.ExitCode;Out=$o;Err=$e}}
$cases=@(
  @{code='BC_KNOWLEDGE_LOCK_SCHEMA_INVALID:PORTABLE_SCHEMA_ENUM_INVALID';op='lock';m={param($r,$l)$l.sources[0].ref_kind='main'}},
  @{code='BC_KNOWLEDGE_SOURCE_NOT_ALLOWED';op='lock';m={param($r,$l)$l.sources[0].canonical_url='https://github.com/example/untrusted.git'}},
  @{code='BC_KNOWLEDGE_LICENSE_DIGEST_MISMATCH';op='lock';m={param($r,$l)$l.sources[0].license_blob_digest=('c'*64)}},
  @{code='BC_KNOWLEDGE_CONTENT_DIGEST_MISMATCH';op='lock';m={param($r,$l)$l.sources[0].content_digest=('c'*64)}},
  @{code='BC_KNOWLEDGE_COMMIT_MISSING';op='lock';m={param($r,$l)$l.sources[0].commit=('c'*40)}},
  @{code='BC_KNOWLEDGE_TREE_MISMATCH';op='lock';m={param($r,$l)$l.sources[0].tree=('d'*40)}},
  @{code='BC_KNOWLEDGE_LOCK_DIGEST_MISMATCH';op='lock';m={param($r,$l)$l.lock_digest=('e'*64)}},
  @{code='BC_KNOWLEDGE_LOCK_SCHEMA_INVALID:PORTABLE_SCHEMA_ADDITIONAL_PROPERTY';op='lock';m={param($r,$l)$l|Add-Member -NotePropertyName extra -NotePropertyValue 'x'}},
  @{code='BC_KNOWLEDGE_MIRROR_NOT_BARE';op='lock';m={param($r,$l)$p=Join-Path $r "sources\$($l.sources[0].mirror_name)";Remove-Item $p -Recurse -Force;New-Item -ItemType Directory $p|Out-Null;&git -C $p init --quiet}},
  @{code='BC_KNOWLEDGE_INDEX_MISSING';op='query';m={param($r,$l)}},
  @{code='BC_KNOWLEDGE_INDEX_STALE_OR_TAMPERED';op='index';build=$true;m={param($r,$l)Add-Content (Join-Path $r "indexes\$snapshot\objects.jsonl") 'tampered'}},
  @{code='BC_KNOWLEDGE_OBJECT_KEY_DUPLICATE';op='index';build=$true;m={param($r,$l)$p=Join-Path $r "indexes\$snapshot\objects.jsonl";$lines=@(Get-Content $p);Write-Utf8 $p (($lines+@($lines[0])-join"`n")+"`n");Rehash-Index $r}},
  @{code='BC_KNOWLEDGE_OBJECT_VERSION_MISMATCH';op='index';build=$true;m={param($r,$l)$p=Join-Path $r "indexes\$snapshot\objects.jsonl";$items=@(Get-Content $p|%{ConvertFrom-Json $_});$items[0].bc_version='29.0';Write-Utf8 $p ((@($items|%{$_|ConvertTo-Json -Depth 12 -Compress})-join"`n")+"`n");Rehash-Index $r}},
  @{code='BC_KNOWLEDGE_OBJECT_PURPOSE_PROVENANCE_MISSING';op='index';build=$true;m={param($r,$l)$p=Join-Path $r "indexes\$snapshot\objects.jsonl";$items=@(Get-Content $p|%{ConvertFrom-Json $_});$items[0].purpose.status='official';$items[0].purpose.text='Belegt behauptet';Write-Utf8 $p ((@($items|%{$_|ConvertTo-Json -Depth 12 -Compress})-join"`n")+"`n");Rehash-Index $r}},
  @{code='BC_KNOWLEDGE_INDEX_UTF8_INVALID';op='index';build=$true;m={param($r,$l)[IO.File]::WriteAllBytes((Join-Path $r "indexes\$snapshot\objects.jsonl"),[byte[]](0xff,0xfe,0xfd))}},
  @{code='BC_KNOWLEDGE_PATH_NOT_ALLOWED';op='build';m={param($r,$l)Add-ForbiddenPinnedAL $r $l}},
  @{code='BC_KNOWLEDGE_PATH_REPARSE';op='lock';m={param($r,$l)$outside=Join-Path (Split-Path $r -Parent) ((Split-Path $r -Leaf)+'-outside-sources');Move-Item (Join-Path $r 'sources') $outside;New-Item -ItemType Junction -Path (Join-Path $r 'sources') -Target $outside|Out-Null}},
  @{code='BC_KNOWLEDGE_SOURCE_CHANGED_DURING_BUILD';op='mutating-build';assert_no_index=$true;m={param($r,$l)}}
)
try{
  $i=0
  foreach($c in $cases){
    $i++
    $r=Join-Path $temp "$i"
    & (Join-Path $PSScriptRoot 'New-SyntheticBusinessCentralKnowledgeFixture.ps1') -Destination $r -SnapshotId $snapshot|Out-Null
    $lp=Join-Path $r "locks\$snapshot\sources.lock.json"
    $l=Get-Content $lp -Raw|ConvertFrom-Json
    $build=$c.ContainsKey('build') -and [bool]$c.build
    if($build){[void](Build-BCKnowledgeIndex $r $snapshot)}
    &$c.m $r $l
    if(-not$build){Write-Lock $l $lp}
    $res=Invoke-Exact $r $c.op
    if($res.Exit -ne 1 -or $res.Err -ne '' -or $res.Out -cne $c.code){throw "NEGATIVE_FAILED:$i expected=$($c.code) exit=$($res.Exit) out=$($res.Out) err=$($res.Err)"}
    if($c.ContainsKey('assert_no_index') -and (Test-Path (Join-Path $r "indexes\$snapshot"))){throw "NEGATIVE_PARTIAL_INDEX:$i"}
  }
  $invalid=Join-Path $temp 'invalid-al';New-Item -ItemType Directory -Path $invalid|Out-Null;$res=Invoke-Exact $invalid 'invalid-al';if($res.Exit-ne1-or$res.Out-cne'BC_KNOWLEDGE_AL_DECLARATION_INVALID:fixture.al'){throw 'NEGATIVE_INVALID_AL_FAILED'}
  $res=Invoke-Exact (Get-BCKnowledgeProductRoot) 'lock';if($res.Exit-ne1-or$res.Out-cne'BC_KNOWLEDGE_ROOT_UNSAFE'){throw 'NEGATIVE_ROOT_FAILED'}
  $junctionTarget=Join-Path $temp 'junction-target';$junction=Join-Path $temp 'junction-root';New-Item -ItemType Directory -Path $junctionTarget|Out-Null;New-Item -ItemType Junction -Path $junction -Target $junctionTarget|Out-Null;$res=Invoke-Exact $junction 'lock';if($res.Exit-ne1-or$res.Out-cne'BC_KNOWLEDGE_ROOT_REPARSE'){throw 'NEGATIVE_REPARSE_FAILED'}
  Write-Host "PASS: $($cases.Count+3) isolierte BC-Knowledge-Negativfälle."
}finally{if(Test-Path $temp){Remove-Item $temp -Recurse -Force}}
