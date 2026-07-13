# Blueprint-Katalog v2

Der Katalog ist ein kundenunabhaengiger Strukturvertrag. Er beschreibt Zweck, fuehrenden Ablageort, Pflicht-/optionale Felder, Rollen und erlaubte Referenzen. Blankovorlagen bleiben leer und sind keine Kundenwahrheit.

`New-BlueprintPreview.ps1` erzeugt nur einen lokalen Preview-/Proposal-Satz. Der Generator schreibt keine Jira-, Confluence- oder Kundenartefakte. Ein spaeterer Connector darf nur nach einem eigenen Change und einer expliziten Freigabe handeln.

Die drei Starttypen sind `implementation`, `support-only` und `bc-basic`. Jira-Hierarchien bleiben variabel; nur `task` darf abrechenbar sein. Bestehende Zielstrukturen werden ueber ID, Blueprintrevision und Digest verglichen; Konflikte blockieren fail-closed.
