# Design: Generische Dokumentprojektion

Die Quelldatei `projection.json` bleibt der normalisierte, validierte Projektionsvertrag. Der Renderer schreibt ausschließlich in ein neues explizites Ziel. `generated` Dokumente werden aus belegten Snapshotfakten reproduziert; `authored` Dokumente werden als führende menschliche Inhalte referenziert und niemals überschrieben.

IDs sind domänenweit stabil. Nodes bilden einen azyklischen Baum innerhalb eines Space. Home-Node und Home-Dokument müssen zusammenpassen. Referenzen sind typisiert und müssen gültige Endpunkte besitzen. Jira ist separat und darf leer sein. Externe Atlassian-Metadaten sind rein informativ, HTTPS-beschränkt und credentialfrei.

Der spätere Materialisierungsblock konsumiert ausschließlich diesen validierten Vertrag. Er ergänzt Revision Guard und Create/Update/Skip/Conflict, gehört aber nicht in diesen Change.
