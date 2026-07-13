# Dokument- und Jira-Projektionsvertrag

Spectra projiziert validierte Workspacefakten in beliebig viele Dokumentationsräume. Die Projektion ist ein lokaler, portabler Vertrag und kein Live-Abbild von Confluence oder Jira.

`generated` bezeichnet reproduzierbare Ansichten mit vollständiger Snapshot- und Quellprovenienz. `authored` bezeichnet führende menschliche Dokumente. Renderer dürfen authored Inhalte weder erzeugen noch überschreiben. Support- und Knowledge-Workspaces dürfen Dokumentation ohne Projekt und ohne Tickets führen.

Jeder Space besitzt explizite Home-Referenzen. Nodes definieren Parent, Reihenfolge und initialen Aufklappzustand. Der Validator lehnt Zyklen, Waisen, doppelte Geschwisterreihenfolgen, unbekannte Dokumente, Cross-Customer-Referenzen und unsichere externe Origins ab. Jira-Tickets und Views sind ein getrennt validierbarer Teilvertrag.

Eine spätere Atlassian-Materialisierung darf nur einen validierten Snapshot konsumieren. Secrets, Sitezugänge und Tokens sind ausschließlich Laufzeitreferenzen und niemals Teil dieses Vertrags.
