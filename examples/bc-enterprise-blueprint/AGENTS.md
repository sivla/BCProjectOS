# BC Enterprise Blueprint Instructions

- Lies vor einer Aenderung zuerst die referenzierten Unternehmens-, Prozess-, System- und Projektdokumente.
- Trenne dokumentierten Ist-Zustand, freigegebenen Soll-Zustand und offene Annahmen.
- Erfinde keine Unternehmensdaten, Geschaeftsregeln, UAT-Ergebnisse oder Freigaben.
- Verwende stabile IDs fuer Faehigkeiten, Prozesse, Geschaeftsfaelle, Regeln, Anforderungen, Tickets und Tests.
- Halte technische Schluessel, Objekt-IDs und Integrationsvertraege unveraendert, sofern ihre Aenderung nicht spezifiziert ist.
- Erzeuge Lieferobjekte nur aus freigegebenen oder klar als Entwurf markierten Quellen.
- Bearbeite Dateien unter `deliverables/<change-id>/` nicht manuell; regeneriere sie mit `automation/Generate-Deliverables.ps1`.
- Bewahre bestehende `evidence.json` beim Regenerieren und erfinde keine Evidence-Referenzen.
- Behandle `Planning`, `BuildReady` und `ReleaseReady` als getrennte Gates.
- Speichere keine Secrets, Tenant-IDs, Tokens, personenbezogenen Daten oder echten Kundendaten.
- Ein OpenSpec-Change gilt erst als abgeschlossen, wenn `ReleaseReady` lokal besteht und Anforderungen, Implementierung, Tests, UAT, Schulung und Dokumentation rueckverfolgbar sind.
