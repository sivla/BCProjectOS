# Business-Central-Referenzbibliothek

Spectra registriert ausschließlich offizielle Microsoft-Quellen. Vendorinhalte liegen in einem gemeinsamen Runtime-Cache außerhalb von Produkt- und Kundenrepositories. Jeder verwendbare Knowledge-Snapshot bindet URL, Rolle, exakten Commit, Tree, Lizenzblob und Inhaltsdigest. Ein Branchname wie `main` ist niemals ausreichende Query-Provenienz.

Projektworkspaces speichern nur Knowledge-Pack-ID, Version und Digest sowie ihre tatsächliche BC-Version, Lokalisierung und installierten Apps. Der Objektkatalog trennt App, Country, Typ und Objekt-ID. Strukturelle Aussagen stammen deterministisch aus AL; fachliche Kurzbeschreibungen bleiben ohne offizielle oder kuratierte Provenienz `unknown`.

`status`, `build`, `search` und `show` sind offline. `plan-update` verändert nichts. Ein später explizit autorisiertes `update -Apply` darf ausschließlich Bare-Mirrors im sicheren Cache aktualisieren. Es gibt keinen stillen Onlinefallback. Cachepfade, Tokens, Tenant-, Session- oder Telemetriedaten gelangen weder in Produktpayload noch Index.
