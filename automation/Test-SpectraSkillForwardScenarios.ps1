$ErrorActionPreference='Stop';$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'));$catalog=Get-Content (Join-Path $root 'contract\skills\catalog.json') -Raw|ConvertFrom-Json
$cases=@(
  @('Support-only-Kundenworkspace neu anlegen','initialize-customer-workspace','materialize-atlassian-project'),
  @('Meetingtranskript als Intake und Proposals verarbeiten','process-project-intake','materialize-atlassian-project'),
  @('Forecast, Risiken und nächste Aktionen aktualisieren','manage-project-status-budget','materialize-atlassian-project'),
  @('Validierten Snapshot als Projektdokumentation rendern','render-project-documentation','materialize-atlassian-project'),
  @('Freigegebenen Jira-Confluence-Dry-run planen','materialize-atlassian-project','process-project-intake'),
  @('Apps aus gepinntem Repositorycommit inventarisieren','index-project-repository','operate-bc-pilot-sandbox'),
  @('BC-Objekt aus lokalem Knowledge-Pack recherchieren','research-business-central','operate-bc-pilot-sandbox'),
  @('Gebundenen P2P-Schritt in der Pilotsandbox ausführen','operate-bc-pilot-sandbox','capture-bc-click-guide'),
  @('Read-only Klickanleitung aus Browserflow erzeugen','capture-bc-click-guide','operate-bc-pilot-sandbox'),
  @('Rollenbezogene UAT- und Trainingsübergabe vorbereiten','run-bc-uat-training-handover','operate-bc-pilot-sandbox'),
  @('Snapshot vor Twin-Übergabe fail-closed prüfen','validate-project-snapshot','materialize-atlassian-project')
)
foreach($case in $cases){$expected=@($catalog.skills|Where-Object name -eq $case[1]);$forbidden=@($catalog.skills|Where-Object name -eq $case[2]);if($expected.Count-ne1-or$forbidden.Count-ne1){throw 'SKILL_FORWARD_CATALOG_MISSING'};if(-not$expected[0].trigger_example-or$expected[0].responsibility-eq$forbidden[0].responsibility){throw "SKILL_FORWARD_AMBIGUOUS:$($case[1])"};if($expected[0].name-in@('materialize-atlassian-project','operate-bc-pilot-sandbox')-and$expected[0].implicit_allowed-ne$false){throw "SKILL_FORWARD_HIGH_RISK_IMPLICIT:$($case[1])"}}
Write-Host 'PASS: Elf minimal kontextualisierte Triggerfälle bleiben getrennt; Schreibskills sind nicht implizit.'
