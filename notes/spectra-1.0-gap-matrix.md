# Spectra 1.0.0 Gap-Matrix nach RC.1 und lokaler Vertragsintegration

## Statusgrenze

Einzig veroeffentlichte Basis ist `spectra-v1.0.0-rc.1` auf Commit `0c4542f8e69c3a7d52807b96b9bdd50a54309371`. Alle nachfolgenden Init-, Workspace-, Dokument-, Wissens-, Skill-, Inbox- und Blueprint-Bloecke sind lokale Produktstaende. Der Integrationsbranch ist keine neue Version und bleibt `PENDING_BCPROJECTOS_RELEASE`.

## Integrierter lokaler Stand

| Bereich | Veroeffentlicht in RC.1 | Lokal integriert | Noch unbewiesen / spaeteres Gate |
|---|---|---|---|
| BC-Basic-Fachstrecke bis Handover | ja | unveraendert regressionsfaehig | finaler 1.0.0-Releaseproof |
| Init, Projektarten und Ticketmapping | nein | P0-Linie | unabhaengiger Candidate-/Releaseprozess |
| Customer Workspace und Basis-Inbox | nein | Foundation unter Proposal-Schicht | integrierter End-to-End-Consumerproof |
| Information Inbox und Proposals | nein | fuehrender Intake-/Review-/Umsetzungsvertrag | reale Kundeninstanz bleibt ausserhalb Spectra |
| Dokumentprojektion | nein | generated/authored und source-defined Hierarchie | Connector-Materialisierung separat |
| Blueprint-Katalog | nein | V2 fuehrend, kuratierter V1-Pfad nur Legacy | unabhaengige Migrations-/Consumerreview |
| BC Reference Library | nein | einmalig, gepinnt und blobgebunden | Runtime-Cache bleibt extern und kundenspezifische Symbole separat |
| Consultant Knowledge/Playthrough | nein | fachliche Schicht ueber Reference Library | keine Live-BC-Ausfuehrung oder Kundenevidence |
| P0-Skillkatalog | nein | 11 Skillfamilien lokal | Forward- und Consumerabnahme im finalen Integrationsrelease |
| Variable Project-Story-Kardinalitaet | nein | instanzabgeleitete Mengen | weitere reale Strukturen nur anonymisiert als Tests |

## Fuehrende Vertraege

1. Workspace-Foundation fuehrt Customer-, Environment-, Company-, Project- und Supportidentitaet.
2. Information Inbox fuehrt Intake, Proposalstatus, Review, Annahme und getrennte Umsetzung.
3. Blueprint-Katalog V2 fuehrt neue Vorschauen; der kuratierte Katalog bleibt Legacy-Herkunft.
4. BC Reference Library fuehrt Source-Lock, Objektkatalog und Query; Consultant Knowledge liegt darueber.
5. Project-Story-Kardinalitaet wird aus der Instanz abgeleitet, nie aus einer festen Ticketzahl.

## Verbleibender Pfad zu 1.0.0

1. Lokalen Integrationsstand commitgebunden vollstaendig pruefen und unabhaengig reviewen.
2. In einem separaten Releasezyklus Candidate, Manifest, Digest und beide Profile aus frischem Clone pruefen.
3. `1.0.0` erst nach normaler Integration, unabhaengigem Release-GO, finalem Manifest, annotiertem Tag, Veroeffentlichung und Postcheck ausgeben.

## Wahrheitsgrenzen

- Keine Kunden-Source-of-Truth, Kunden-Evidence, Tenantwerte oder Secrets werden in Spectra uebernommen.
- Synthetische Fixtures, Skill-Forward-Tests und technische Automation sind keine Kundenfreigabe.
- Reale fachliche, steuerliche, rechtliche und betriebliche Entscheidungen entstehen ausschließlich im isolierten Kundenworkspace.
- Historische RC2/RC3-Candidate-Evidence bleibt historische Evidence und bindet diesen Integrationsbranch nicht.
