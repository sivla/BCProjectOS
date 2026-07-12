# Design

Ein versionierter Record verbindet UAT-Plan, Prozessabdeckung, Testszenarien, Schulungspfade, Defects, Evidence, Entscheidungen und Exit-Gate über stabile IDs. Der Validator prüft Schema, Referenzen, Pfadabdeckung, Statusübergänge, Fix-/Retest-/Waiver-Nachweise und blockiert den Exit bei offenen P1/P2.

Implementation und Support-only verwenden denselben Produktkern. Das Profil ändert die Nutzungsperspektive, nicht die Qualitätsregeln. Alle Fixtures sind synthetisch. Sandbox-Ergebnisse sind keine Produktions- oder Performance-Evidence; Profile ersetzen keinen Berechtigungsnachweis; technische Automation ersetzt keine fachliche UAT-Entscheidung.

## SemVer

Die Fähigkeit ist additiv und rückwärtskompatibel gegenüber `0.12.0-alpha.1`, daher `0.13.0-alpha.1`. Alpha bleibt erforderlich, weil Cutover/Betrieb und unabhängige RC-Pilotevidence fehlen.
