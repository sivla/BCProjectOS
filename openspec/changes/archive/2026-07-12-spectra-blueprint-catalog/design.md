# Design

Der Katalog unter `contract/blueprints/catalog.json` beschreibt Pakete und deren Artefakte. Jede Vorlage besitzt Zweck, führenden Ablageort, Pflicht-/Optionalfelder, erlaubte Referenzen, Sichtbarkeit und Inhaltsgrenze. Quelldateien liegen unter `contract/blueprints/templates/` und sind mit `spectra_template: true` sowie `content_status: blank` gekennzeichnet.

`spectra init` gibt profilabhängige Empfehlungen aus, kopiert aber nur explizit ausgewählte Pakete. Dadurch entstehen keine unnötigen Seiten. Unterseiten werden nur als eigenständige Blankovorlagen bereitgestellt und nicht automatisch unter jedem Wurzelbereich vervielfacht.
