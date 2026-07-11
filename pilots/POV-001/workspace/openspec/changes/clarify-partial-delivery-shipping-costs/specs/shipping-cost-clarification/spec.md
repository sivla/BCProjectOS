## ADDED Requirements

### Requirement: REQ-01J0000000000000000000010D - Freigegebene Versandkostenregel pruefbar anwenden

Business Central SHALL eine fachlich freigegebene Versandkostenregel bei Teil- und Nachlieferungen konsistent anwenden. Der konkrete Regelinhalt bleibt bis zur Freigabe von `BR-01J0000000000000000000010A` blockiert.

#### Scenario: Regel ist nicht freigegeben

- **WHEN** keine freigegebene Geschaeftsregel vorliegt
- **THEN** MUST Implementierung und Aktivierung blockiert bleiben
- **AND** es darf keine Berechnungslogik erfunden werden

#### Scenario: Regel ist spaeter freigegeben

- **WHEN** eine nachgewiesen freigegebene Regel vorliegt
- **THEN** SHALL das Verhalten auf Auftrag und Lieferungen rueckverfolgbar sein
