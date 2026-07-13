# Vertrag

- Freiheit: mittel; lokale Initialisierung nur nach explizitem `Apply`.
- Zulässige Writes: neues, explizites Workspaceziel; keine Vendor-, Produkt- oder Fremdrepositoryänderung.
- Pflichtbindung: customer, environment, company, profile, project/support scope und Source-Revision.
- Bestehende Inhalte: nie still überschreiben; Konflikte als Plan melden.
- Evidence: Dry-run-Ergebnis, erzeugte Pfade, Validatorstatus und Produktbindung.
- Blueprint-Autoritaet: `blueprint-catalog-v2` und dessen Proposal-only-Vorschau; `BPC-*`-Pakete sind ausschließlich der kompatible Blanko-Materializer bestehender Init-Eingaben.
- Stop-Codes: `INIT_TARGET_UNSAFE`, `INIT_CONFLICT`, `INIT_SOURCE_UNBOUND`, `INIT_CUSTOMER_FACT_UNKNOWN`.
- Reset/Rollback: unfertiges Staging entfernen; bestehendes Ziel unverändert lassen.
