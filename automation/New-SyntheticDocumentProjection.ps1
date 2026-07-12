[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Destination,
  [ValidateSet('implementation','support-only')][string]$Profile='implementation'
)
$ErrorActionPreference='Stop'
$target=[IO.Path]::GetFullPath($Destination)
if(Test-Path -LiteralPath $target){throw 'DOCUMENT_PROJECTION_TARGET_EXISTS'}
New-Item -ItemType Directory -Path $target|Out-Null
$customer='CUS-SYNTHETIC'
$provenance=@(
  [ordered]@{id='PRV-WORKSPACE';customer_id=$customer;source_system='spectra-workspace';source_object_id='workspace-foundation';source_revision=('a'*40);source_digest=('b'*64);validation_status='validated'}
)
$documents=@(
  [ordered]@{id='DOC-HOME';customer_id=$customer;title='Projektüberblick';content_mode='generated';source_path='generated/projektueberblick.md';blueprint_id='BPC-PROJECT-OVERVIEW';provenance_ids=@('PRV-WORKSPACE');authored_sections=@()},
  [ordered]@{id='DOC-KNOWLEDGE';customer_id=$customer;title='Führendes Fachwissen';content_mode='authored';source_path='authored/fachwissen.md';blueprint_id=$null;provenance_ids=@();authored_sections=@('Inhalt')}
)
$spaces=@([ordered]@{id='SPC-PROJECT';customer_id=$customer;name=if($Profile-eq'implementation'){'Projekt'}else{'Support und Wissen'};order=0;home_node_id='NOD-HOME';home_document_id='DOC-HOME';external=$null})
$nodes=@(
  [ordered]@{id='NOD-HOME';customer_id=$customer;space_id='SPC-PROJECT';parent_id=$null;document_id='DOC-HOME';order=0;initially_expanded=$true},
  [ordered]@{id='NOD-KNOWLEDGE';customer_id=$customer;space_id='SPC-PROJECT';parent_id='NOD-HOME';document_id='DOC-KNOWLEDGE';order=0;initially_expanded=$false}
)
$tickets=@();$views=@()
if($Profile-eq'implementation'){
  $tickets+=,[ordered]@{id='TKT-PLAN';customer_id=$customer;type='task';status='open';title='Synthetische Projektplanung'}
  $views+=,[ordered]@{id='VIW-ACTIVE';customer_id=$customer;name='Aktive Arbeit';ticket_ids=@('TKT-PLAN')}
}
$references=@(
  [ordered]@{id='REF-HOME';customer_id=$customer;from=[ordered]@{domain='space';id='SPC-PROJECT'};to=[ordered]@{domain='document';id='DOC-HOME'};relation_type='contains'},
  [ordered]@{id='REF-KNOWLEDGE';customer_id=$customer;from=[ordered]@{domain='document';id='DOC-HOME'};to=[ordered]@{domain='document';id='DOC-KNOWLEDGE'};relation_type='documents'}
)
$projection=[ordered]@{
  schema_version=1;product_id='spectra';classification='synthetic-template';customer_id=$customer
  snapshot=[ordered]@{id='SNP-PROJECTION';source_revision=('a'*40);source_digest=('b'*64);generated_at='2026-01-01T00:00:00Z'}
  documentation=[ordered]@{spaces=$spaces;nodes=$nodes;documents=$documents;references=$references;provenance=$provenance}
  jira=[ordered]@{tickets=$tickets;views=$views}
}
$json=($projection|ConvertTo-Json -Depth 20)+"`n"
[IO.File]::WriteAllText((Join-Path $target 'projection.json'),$json,[Text.UTF8Encoding]::new($false))
Write-Host "PASS: Synthetische Dokumentprojektion $Profile wurde deterministisch erzeugt."
