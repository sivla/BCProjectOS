# Design

Ein kanonischer Record verbindet Setupentscheidungen, Rollenproben und Datenwellen ueber stabile IDs. Setup-Schritte bilden einen gerichteten azyklischen Abhaengigkeitsgraph. Parameter unterscheiden Standardwerte, Kundenparameter und bestaetigungspflichtige Lokalisierungs-/Steuerwerte. Rollen nennen nur generische Permission-Needs. Datenvorlagen enthalten Regeln und synthetische Kontrollsummen, niemals Kundeninhalt.

Der Validator arbeitet offline und read-only, prueft Schema, Reihenfolge, Referenzen, SoD, Proben, Summen und Marker fail-closed. Implementation und Support-only verwenden denselben Kern; das Profil aendert nur die operative Nutzungsperspektive.

## SemVer

Gegen `0.11.0-alpha.1` entsteht eine neue rueckwaertskompatible Produktfaehigkeit, daher Minor `0.12.0-alpha.1`. Alpha bleibt, da UAT/Training und Cutover/Betrieb noch fehlen.
