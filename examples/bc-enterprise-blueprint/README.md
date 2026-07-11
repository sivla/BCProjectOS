# BC Enterprise Blueprint

Dieses Beispiel verbindet dauerhaftes Unternehmenswissen mit Business-Central-Projekten und OpenSpec-Changes.

## Wissensebenen

1. `company/` beschreibt Unternehmen, Strategie, Leistungen und Organisation.
2. `business/` beschreibt Faehigkeiten, Prozesse, Geschaeftsfaelle und Regeln.
3. `application-landscape/` ordnet Systeme, Daten und Integrationen zu.
4. `projects/` beschreibt konkrete Projekte, Scope und Governance.
5. `governance/` definiert Ticket-, Confluence-, Schulungs- und Gate-Architektur.
6. `openspec/` steuert den Kern einer Aenderung bis zum verifizierbaren Taskplan.
7. `automation/` erzeugt und validiert alle lokalen Lieferobjekte.
8. `deliverables/<change-id>/` enthaelt generierte Tickets, UAT, Dokumentation, Schulung, Confluence-Seiten und Release-Pakete.

## Grundprinzip

OpenSpec ist nicht die einzige Wissensablage. Stabiles Unternehmenswissen lebt ausserhalb einzelner Changes. Ein Change referenziert dieses Wissen und beschreibt eine konkrete Verhaltensaenderung. `delivery-plan.json` waehlt die benoetigten Ausgaben; lokale Generatoren erzeugen daraus nachvollziehbare Lieferobjekte.

## Einstieg

1. Einmalig `npm install` ausfuehren, um die gepinnte lokale OpenSpec-Version zu installieren.
2. Platzhalter in `company/`, `business/` und `application-landscape/` ausfuellen.
3. Projektauftrag unter `projects/` anlegen.
4. Einen Change mit dem Schema `bc-delivery` erstellen.
5. Die sechs Kernartefakte in Abhaengigkeitsreihenfolge ausarbeiten.
6. Lokale Lieferobjekte generieren und das Planning-/BuildReady-Gate pruefen.
7. Implementierung und Tests gegen Anforderungen ausfuehren.
8. Evidence erfassen und das ReleaseReady-Gate pruefen.
9. Akzeptierte Specs synchronisieren und den Change archivieren.

```powershell
npx --no-install openspec new change example-change --schema bc-delivery
npx --no-install openspec status --change example-change
npx --no-install openspec validate example-change

powershell -ExecutionPolicy Bypass -File automation/Generate-Deliverables.ps1 -ChangeId example-change
powershell -ExecutionPolicy Bypass -File automation/Test-DeliveryGate.ps1 -ChangeId example-change -Gate Planning
powershell -ExecutionPolicy Bypass -File automation/Test-DeliveryGate.ps1 -ChangeId example-change -Gate BuildReady
powershell -ExecutionPolicy Bypass -File automation/Test-DeliveryGate.ps1 -ChangeId example-change -Gate ReleaseReady
```

## Datenschutz

Keine Zugangsdaten, Tokens, Tenant-IDs, personenbezogenen Daten oder echten Kundendaten eintragen. Identifizierende Werte werden durch freigegebene Aliase oder Platzhalter ersetzt.

## Aktueller Beispielstatus

Der Beispiel-Change ist absichtlich nur planungsfaehig. `Planning` besteht; `BuildReady` und `ReleaseReady` bleiben wegen offener Geschaeftsregel, offener Tasks und fehlender Evidence gesperrt.
