# Design

Spectra trennt die kanonische Bedeutung von der technischen Projektkonfiguration. `ticket_structure.issue_types` bildet jeden Quelltyp auf genau eine Spectra-Kategorie ab; `status_mappings` bildet Projektstatus auf stabile Spectra-Status ab. Quellwerte bleiben unverändert als Projektmetadaten erhalten.

`spectra-standard` ist ein auswählbares Startprofil. `project-mapping` und `imported-readonly` erlauben eigene Strukturen. Beim Onboarding muss jeder beobachtete Vorgangstyp genau einmal abgebildet sein. Doppelte und unbekannte Abbildungen werden abgelehnt.
