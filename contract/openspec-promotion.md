# OpenSpec-Promotion

Status: Accepted for MVP 0

Ein Supportfall, Meeting oder lokales Ticket wird nur zu einem `CHG-*`, wenn mindestens eine kontrollierte Aenderung an BC-Verhalten, AL-Code, fachlich wirksamer Konfiguration, Integration, Migration, Berechtigung, pruefbarer Requirement/UAT-Verpflichtung oder Release-/Rollback-/Delivery-Verpflichtung erforderlich ist.

Keine Promotion erfolgt fuer reine Fragen, Statusabstimmungen, Meetings ohne bestaetigte Aenderungsentscheidung, Bedienhilfe ohne Systemaenderung, Dokumentenablage, abgeschlossene Diagnose oder ein Duplikat eines aktiven Changes.

Vor Promotion muessen Triggerquelle akzeptiert, Scope und Nicht-Ziele ausreichend klar, der verantwortliche Kontext bekannt und aktive Changes auf Ueberschneidung geprueft sein. Der Change referenziert seine Quellen ueber IDs und kopiert sie nicht. Ein Trigger darf hoechstens einen aktiven Ziel-Change fuer denselben fachlichen Scope besitzen.

Der Kundenworkspace behaelt genau einen OpenSpec-Root. Requirements bleiben im Change; ein lesbarer Change-Slug ersetzt die stabile `CHG-*`-ID nicht.
