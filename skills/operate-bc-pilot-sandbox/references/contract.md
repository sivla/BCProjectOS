# Vertrag

- Freiheit: niedrig bei Import, Posting, Delete und Reset; mittel bei read-only Analyse.
- Zulässige Writes: ausschließlich gebundene Pilotsandbox und freigegebener fachlicher Schritt.
- Verboten: Produktion, unbekannte Company, externe Bank-/Steuer-/Mailübermittlung, persistierte Authstates.
- Preconditions: Environment, Company, Version, Locale, Role, Work Date, Reset und Expected State.
- Evidence: Vorzustand, Aktion, sichtbares Resultat, Ledgerkontrolle, WritesPerformed und Retest.
- Stop-Codes: `BC_TARGET_NOT_SANDBOX`, `BC_COMPANY_UNBOUND`, `BC_RESET_UNAVAILABLE`, `BC_EXTERNAL_TRANSMISSION_FORBIDDEN`.
- Reset/Rollback: vor jedem Write konkret belegen; bei Unsicherheit keine Mutation.
