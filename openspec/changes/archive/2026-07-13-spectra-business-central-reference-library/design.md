# Design: Business-Central-Referenzbibliothek

`SPECTRA_KNOWLEDGE_ROOT` zeigt auf einen gemeinsamen Runtime-Root außerhalb der Repositorys. `sources/*.git` sind Bare-Mirrors. Jeder Snapshot besitzt ein Lock mit exakten Commit-/Tree-/Lizenz-/Inhaltsdigests und einen deterministischen Index. Projektworkspaces referenzieren später ausschließlich Knowledge-Pack-ID, Version und Digest.

Objektschlüssel kombinieren App-ID, Country, Objekttyp und Objekt-ID. Damit überschreiben W1, DE oder mehrere Apps einander nicht. Strukturelle Metadaten werden deterministisch aus AL gelesen; eine fachliche Kurzbeschreibung ist nur mit offizieller oder kuratierter Provenienz zulässig, sonst bleibt sie ausdrücklich unbekannt.

Der V1-Parser priorisiert Table, TableExtension, Page und PageExtension und hält das Schema für weitere Objektarten offen. Ein exakter 28.2/DE/App-Snapshot ist zulässig; ein floating BCApps-Branch ist nie Query-Provenienz.
