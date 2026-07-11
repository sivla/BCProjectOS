# Kundenworkspace-Architektur

Status: Accepted for MVP 0

```text
<customer-workspace>/
|-- AGENTS.md
|-- README.md
|-- workspace.yaml
|-- governance/{catalogs,policies,decisions}/
|-- company/
|-- knowledge/{items,processes,business-rules,bc,application-landscape}/
|-- projects/<PRJ-ID>/
|-- support/{cases,board}/
|-- meetings/<MTG-ID>/
|-- work/tickets/
|-- external-files/{inbox,review,quarantine,register,originals,derived,processing-log}/
|-- openspec/{config.yaml,schemas,specs,changes}/
|-- evidence/<EVD-ID>/
|-- generated/<CHG-ID>/
|-- automation/
|-- schemas/
|-- migrations/
|-- backup/manifests/
`-- .gitignore
```

`workspace.yaml` ist die kanonische Identitaet des Kundenworkspace. Projekte, Supportfaelle und Meetings duerfen Quellen referenzieren, aber nicht duplizieren. Archivierung ist ein Lifecycle-Status und kein globaler Verschiebeordner.

## Datenklassen

1. **Originale:** unveraenderte externe Bytes unter `external-files/originals/sha256/<hash-prefix>/<sha256>`; Metadaten unter `external-files/register/`.
2. **Kuratiertes Wissen:** menschlich akzeptierte bzw. freigegebene Aussagen unter `company/` und `knowledge/`.
3. **Evidence:** explizite Nachweisdatensaetze unter `evidence/`; binaere Nachweise referenzieren ein `FILE-*`-Original.
4. **Generierte Dateien:** reproduzierbare, klar markierte Outputs unter `generated/`; niemals eigenstaendige Source of Truth oder Freigabenachweis.
5. **Arbeitsobjekte:** Projekte, Supportfaelle, Meetings und lokale Tickets mit eigenem Lifecycle.

Ein relativer Pfad ist Ablage, nicht Identitaet. Kein Pfad darf einen anderen Kundenworkspace verlassen.
