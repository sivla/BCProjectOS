# Design

Die Piloten konsumieren ausschließlich einen unveränderlichen Spectra-Release und laufen in getrennten synthetischen Repositories. Sie beweisen Bedienbarkeit und Produktkohärenz, nicht Kunden- oder Produktivaktivität.

Implementation führt Engagement, Setup/Daten, UAT/Training/Defects sowie Cutover/Hypercare/Handover aus. Support-only beginnt mit einer kontrollierten Supportannahme und beweist Ticket-/Evidence-, Recovery- und Handoverpfade ohne künstliche Implementierungsphasen.

Ein RC-GO ist nur zulässig, wenn beide Piloten, Upgrade, Backup/Restore, Manipulationsmatrix, deutsche Dokumentation und Fresh-Clone-Reproduzierbarkeit grün sind und keine offenen P1/P2-Produktdefects bestehen.

Der Upgradevergleich folgt vollständiger SemVer-Prerelease-Reihenfolge. Dadurch sind veröffentlichte Alpha-/Beta-Stände kontrolliert auf `1.0.0-rc.1`, spätere RCs und schließlich `1.0.0` planbar; Downgrades bleiben fail-closed.
