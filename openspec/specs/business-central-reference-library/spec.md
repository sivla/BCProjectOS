# Business-Central-Referenzbibliothek

## Requirements

### Requirement: Quellen sind positivgelistet und unveränderlich gebunden
Spectra MUST jede Quelle an kanonische URL, Rolle, exakten Commit, Tree, Lizenzblob und Inhaltsdigest binden.

### Requirement: Cache bleibt außerhalb aller Projektworkspaces
Spectra MUST Bare-Mirrors ausschließlich unter einem sicheren `SPECTRA_KNOWLEDGE_ROOT` lesen oder explizit aktualisieren.

### Requirement: Objektkatalog ist versions- und lokalisierungsbezogen
Spectra MUST Objektkeys aus App, Country, Typ und ID bilden und BC-Version, installierte Appversion, Quelle und Provenienz erhalten.

### Requirement: Fachliche Beschreibung wird nicht erfunden
Spectra MUST unbelegte Zwecke als `unknown` kennzeichnen und belegte Texte an offizielle oder kuratierte Provenienz binden.

### Requirement: Build und Query bleiben deterministisch offline
Spectra MUST aus einem validierten Lock byteidentische Indexe erzeugen und Query ohne validierten Snapshot ablehnen.
