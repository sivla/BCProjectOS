# Design

Ein Record verbindet UAT-Exit, Cutover-Aufgaben, Mock-Lauf, Go/No-Go, Hypercare, Restart, Supportannahme und Handover über stabile IDs und Evidence. Der Durchstich bleibt lean: nur Informationen, die PM, Consultant, Process Owner und Support für Entscheidung, Ausführung und Übergabe benötigen.

Alle Entscheidungen sind synthetisch und nicht produktiv. Der Validator arbeitet read-only, prüft Reihenfolge, Referenzen, Evidence und blockiert Go-live oder Hypercare-Exit bei offenen P1/P2. Implementation und Support-only verwenden denselben Vertrag.

## SemVer

Der vollständige Betriebsdurchstich ist eine additive, rückwärtskompatible Produktfähigkeit gegen `0.13.0-alpha.1`. Nach der Releasepolicy begründet das den Minor-Schritt `0.14.0-alpha.1`. Alpha bleibt erforderlich, weil unabhängige Implementation-/Support-Piloten und RC-Evidence fehlen.
