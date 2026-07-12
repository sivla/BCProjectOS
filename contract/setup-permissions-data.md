# Setup, Berechtigungen und Daten

Dieser Vertrag fuehrt eine BC-Basic-Standardentscheidung bis zu pruefbarem Setup, Rollenproben und kontrollierter Datenuebernahme. Er speichert keine Kundenwerte und fuehrt keine BC-Schreiboperation aus.

## Setupreihenfolge

Die kanonischen Bereiche sind: Gesellschaft/GL, Konten und Buchungsgruppen, VAT, Dimensionen, Nummernserien, Zahlungsbedingungen/-methoden, Mahnwesen, Bankabstimmung, Einkauf, Verkauf, Lager, Perioden und Standardreporting. Jeder Schritt besitzt Entry-/Exit-Kriterien, Abhaengigkeiten, Wirkung und einen pruefbaren Sollzustand.

## Parameter und Wahrheitsgrenze

`standard` ist wiederverwendbares Produktwissen. `customer_parameter` muss die Kundeninstanz liefern. `localization_or_tax_confirmation` benoetigt vor Nutzung eine fachliche Bestaetigung; Spectra trifft keine Steuer- oder Rechtsentscheidung.

## Rollen und SoD

Rollen beschreiben Aufgaben und generische Permission-Needs. Reale Permission Sets werden in der Kundeninstanz ermittelt. Verbotene Kombinationen und positive sowie verweigerte/eskalierte Proben muessen vor Freigabe belegt sein.

## Daten

Acht Vorlagentypen (`gl_account`, `dimension`, `customer`, `vendor`, `item`, `bank_account`, `opening_balance`, `open_document`) laufen in drei Wellen (`foundation`, `master_data`, `opening_and_open_items`). Dry-run, Pflicht-/Format-/Referenzregeln, Kontrollsummen, Fehlerklassifikation, Korrektur und Retest sind verpflichtend.

## Offizielle Produktreferenzen

- Microsoft Learn: https://learn.microsoft.com/dynamics365/business-central/finance-posting-groups
- Microsoft Learn: https://learn.microsoft.com/dynamics365/business-central/finance-setup-vat
- Microsoft Learn: https://learn.microsoft.com/dynamics365/business-central/ui-security-groups
- Microsoft Learn: https://learn.microsoft.com/dynamics365/business-central/dev-itpro/administration/set-up-standard-company-configuration-packages

Die Quellen beschreiben allgemeines Produktverhalten. Konkrete Lokalisierungs-, Steuer-, Rollen- und Datenentscheidungen bleiben bestaetigungspflichtig.
