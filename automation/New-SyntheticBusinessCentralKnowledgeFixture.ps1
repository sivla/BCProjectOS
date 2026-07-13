[CmdletBinding()]param([Parameter(Mandatory=$true)][string]$Destination,[string]$SnapshotId='BCK-28.2-DE-SYNTHETIC')
$ErrorActionPreference='Stop';$root=[IO.Path]::GetFullPath($Destination);if(Test-Path $root){throw 'BC_KNOWLEDGE_FIXTURE_TARGET_EXISTS'};New-Item -ItemType Directory -Path $root|Out-Null
. (Join-Path $PSScriptRoot 'BusinessCentral.Knowledge.ps1');$registry=Get-BCKnowledgeRegistry;New-Item -ItemType Directory -Force -Path (Join-Path $root 'sources')|Out-Null
$records=@();$date='2026-01-01T00:00:00Z'
foreach($source in @($registry.sources|Sort-Object source_id)){
  $work=Join-Path $root ('.fixture-'+$source.source_id);New-Item -ItemType Directory -Path $work|Out-Null
  & git -C $work init --quiet;if($LASTEXITCODE-ne0){throw 'FIXTURE_GIT_INIT_FAILED'};& git -C $work config user.name 'Spectra Synthetic';& git -C $work config user.email 'spectra.synthetic@invalid.example';& git -C $work config core.autocrlf false
  Write-Utf8 (Join-Path $work 'LICENSE') "Synthetic fixture license for deterministic tests only.`n"
  switch($source.source_id){
    'microsoft-bc-functional-docs' {Write-Utf8 (Join-Path $work 'business-central\purchasing.md') "# Einkauf in Business Central`n`nSynthetische offizielle-Dokumentationsfixture für P2P.`n"}
    'microsoft-bc-devitpro-docs' {Write-Utf8 (Join-Path $work 'dev-itpro\developer\object-overview.md') "# AL-Objekte`n`nSynthetische Developer-Dokumentationsfixture.`n"}
    'microsoft-bcapps' {
      Write-Utf8 (Join-Path $work 'src\Apps\W1\Base\src\PurchaseHeader.Table.al') "namespace Microsoft.Purchases.Document;`n`ntable 38 `"Purchase Header`"`n{`n    Caption = 'Purchase Header';`n    field(1; `"Document Type`"; Integer) { }`n    key(PK; `"Document Type`") { }`n}`n"
      Write-Utf8 (Join-Path $work 'src\Apps\W1\Base\src\PurchaseOrder.Page.al') "namespace Microsoft.Purchases.Document;`n`npage 50 `"Purchase Order`"`n{`n    PageType = Document;`n    SourceTable = `"Purchase Header`";`n    Caption = 'Purchase Order';`n}`n"
      Write-Utf8 (Join-Path $work 'src\Apps\DE\Local\src\PurchaseHeaderDE.Table.al') "namespace Microsoft.Purchases.Document.DE;`n`ntable 38 `"Purchase Header DE`"`n{`n    Caption = 'Purchase Header DE';`n    field(1; `"Document Type`"; Integer) { }`n}`n"
      Write-Utf8 (Join-Path $work 'src\Apps\DE\Local\src\PurchaseHeaderDE.TableExt.al') "namespace Microsoft.Purchases.Document.DE;`n`ntableextension 50000 `"Purchase Header DE Extension`" extends `"Purchase Header`"`n{`n    field(50000; `"Synthetic Reference`"; Text[20]) { }`n}`n"
    }
  }
  & git -C $work add .;$env:GIT_AUTHOR_DATE=$date;$env:GIT_COMMITTER_DATE=$date;& git -C $work commit --quiet -m 'Synthetic pinned source';Remove-Item Env:GIT_AUTHOR_DATE,Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
  $commit=(& git -C $work rev-parse HEAD).Trim();$tree=(& git -C $work rev-parse 'HEAD^{tree}').Trim();$mirrorName="$($source.source_id).git";$mirror=Join-Path $root "sources\$mirrorName";& git clone --bare --quiet $work $mirror;if($LASTEXITCODE-ne0){throw 'FIXTURE_BARE_CLONE_FAILED'}
  $license=Get-GitText $mirror $commit 'LICENSE';$records+=,[ordered]@{source_id=$source.source_id;canonical_url=$source.canonical_url;role=$source.role;ref_kind='commit';commit=$commit;tree=$tree;mirror_name=$mirrorName;bare=$true;allowed_paths=@($source.allowed_paths);license_id=[string]$source.license_ids[0];license_path='LICENSE';license_blob_digest=Get-Sha256Text $license;content_digest=Get-GitContentDigest $mirror $commit;update_status='pinned'}
  Remove-Item $work -Recurse -Force
}
$lock=[ordered]@{schema_version=1;product_id='spectra';snapshot_id=$SnapshotId;knowledge_pack_id='BCKP-BC-28.2-DE';knowledge_pack_version='1.0.0';bc_version='28.2';platform_version='28.0.52048.0';application_version='28.2.50931.52241';al_runtime='17.0';countries=@('W1','DE');installed_apps=@([ordered]@{app_id='00000000-0000-0000-0000-000000000001';name='Base Application';publisher='Microsoft';version='28.2.50931.52241';country='W1'},[ordered]@{app_id='00000000-0000-0000-0000-000000000002';name='DE Localization';publisher='Microsoft';version='28.2.50931.52241';country='DE'});retrieved_at=$date;sources=$records;lock_digest=('0'*64);validation_status='validated'}
$lockPath=Join-Path $root "locks\$SnapshotId\sources.lock.json";Write-Utf8 $lockPath (($lock|ConvertTo-Json -Depth 12)+"`n")
$normalized=Get-Content $lockPath -Raw|ConvertFrom-Json;$canonical=(@($normalized.sources|Sort-Object source_id|ForEach-Object{"$($_.source_id)|$($_.commit)|$($_.tree)|$($_.license_blob_digest)|$($_.content_digest)"})-join"`n")+"`n";$normalized.lock_digest=Get-Sha256Text $canonical;Write-Utf8 $lockPath (($normalized|ConvertTo-Json -Depth 12)+"`n")
Write-Host 'PASS: Synthetischer BC-Knowledge-Cache mit drei Bare-Mirrors wurde erzeugt.'
