# Proposal: Produktionsreife Kunden-Onboarding-Bereitschaft

## Warum

Der veröffentlichte Release `spectra-v1.2.0-alpha.12` ist plattformseitig installierbar, trennt aber Produktplattform, vollständigen Onboarding-Start und die reale Go-live-Freigabe eines Kundenprojekts noch nicht maschinenlesbar. Unabhängige Operatoren benötigen einen fail-closed Plan, der Kundeninhalte im isolierten Workspace belässt und keine Live-Systemreife erfindet.

## Scope

- Readinessvertrag für `platformReady`, `onboardingReady` und `customerGoLiveReady`;
- idempotenter `preflight`, `plan` und `validate` für Implementation, Support-only, Fit-Gap und Migration;
- Betriebsart, Lokalisierung, Umgebungsrollen, Atlassian-Modus, Datenklassifikation, Retention, External-File-Intake, Upgrade und Recovery;
- sanitisiertes deutsches Onboarding-Paket und commitgebundene `release/production-readiness.json`;
- synthetische positive und isolierte negative Tests sowie Fresh-Clone-Nachweise.

## Nicht-Scope

- keine Live-Atlassian-Mutation;
- keine Kundendaten, Secrets, Tenantwerte oder reale Go-live-Evidence;
- keine Lizenzentscheidung;
- kein Candidate, Tag, Push oder Release.

## Releasepfad

Nach `spectra-v1.2.0-alpha.12` wird kein Rücksprung auf eine niedrigere Version behauptet. Ein nächster RC-/Stable-Schritt wird erst in einem getrennten Releaseprozess nach SemVer- und Releaseplan festgelegt.
## Stable-Release-1.0-Erweiterung

Der vorhandene Produktvertrag wird für `spectra-v1.0.0` reproduzierbar gebunden. Installation, Upgrade-/Recovery-Pfade und Release-Evidence werden gegen den tatsächlich gebundenen Payload geprüft. Kundendaten, Live-Systemmutation und erfundene Veröffentlichungsevidence bleiben ausgeschlossen.
