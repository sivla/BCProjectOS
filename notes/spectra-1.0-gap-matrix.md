# Spectra 1.0.0 Gap-Matrix nach RC.1 und lokaler Vertragsintegration

## Statusgrenze

Einzig veroeffentlichte Basis ist `spectra-v1.0.0-rc.1` auf Commit `0c4542f8e69c3a7d52807b96b9bdd50a54309371`. Alle nachfolgenden Init-, Workspace-, Dokument-, Wissens-, Skill-, Inbox- und Blueprint-Bloecke sind lokale Produktstaende. Der lokale `1.0.0`-Candidate ist vollstaendig geprueft, aber keine veroeffentlichte Version und bleibt `PENDING_BCPROJECTOS_RELEASE`.

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
| P0-Skillkatalog | nein | 11 Skillfamilien lokal und im V1-Produktpayload gebunden | lokale Forward- und Consumerabnahme gruen; unabhaengige Remote-Review bleibt offen |
| Variable Project-Story-Kardinalitaet | nein | instanzabgeleitete Mengen | weitere reale Strukturen nur anonymisiert als Tests |

## Fuehrende Vertraege

1. Workspace-Foundation fuehrt Customer-, Environment-, Company-, Project- und Supportidentitaet.
2. Information Inbox fuehrt Intake, Proposalstatus, Review, Annahme und getrennte Umsetzung.
3. Blueprint-Katalog V2 fuehrt neue Vorschauen; der kuratierte Katalog bleibt Legacy-Herkunft.
4. BC Reference Library fuehrt Source-Lock, Objektkatalog und Query; Consultant Knowledge liegt darueber.
5. Project-Story-Kardinalitaet wird aus der Instanz abgeleitet, nie aus einer festen Ticketzahl.

## Verbleibender Pfad zu 1.0.0

1. Der minimale Releasevertragsfix fuer Stable-SemVer, Schema-v4-Dateimodi und den vollstaendigen Skill-Payload ist commitgebunden gruen.
2. Der daraus getrennt erzeugte lokale `1.0.0`-Candidate ist mit 294 Payloads, beiden Profilen und Digest `06674b877918d01be6698c18e806dcb14d5ff1fc540275936a6729051827a27b` aus frischen No-Hardlinks-Kopien gruen und bleibt nicht installierbar.
3. Offen sind ausschließlich unabhaengige Candidate-Review, normale Remoteintegration und ein getrenntes Release-GO. `1.0.0` darf erst nach finalem Manifest, annotiertem Tag, Veroeffentlichung und Postcheck ausgegeben werden.

## Wahrheitsgrenzen

- Keine Kunden-Source-of-Truth, Kunden-Evidence, Tenantwerte oder Secrets werden in Spectra uebernommen.
- Synthetische Fixtures, Skill-Forward-Tests und technische Automation sind keine Kundenfreigabe.
- Reale fachliche, steuerliche, rechtliche und betriebliche Entscheidungen entstehen ausschließlich im isolierten Kundenworkspace.
- Historische RC2/RC3-Candidate-Evidence bleibt historische Evidence und bindet diesen Integrationsbranch nicht.
