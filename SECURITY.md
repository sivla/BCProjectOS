# Sicherheit

Sicherheitsbefunde bitte nicht als öffentliches Issue mit Tokens, URLs oder Kundendaten melden. Verwende den privaten Security-Advisory-Kanal des kanonischen GitHub-Repositories. Entferne Secrets, Authzustände, Browserprofile, Tenant-, Umgebungs- und Kundenwerte aus Reproduktionen.

Spectra speichert keine Zugangsdaten. Runtime-Secrets werden ausschließlich über ausdrücklich dokumentierte `SPECTRA_*`-Umgebungsreferenzen oder einen autorisierten Secret-/Keychain-Adapter bereitgestellt. Live-Remote-Schreiben ist ohne separaten Plan, Revision Guard und Freigabe verboten.
