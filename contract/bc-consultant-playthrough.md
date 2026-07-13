# BC-Wissensbasis und Consultant-Playthrough

Der Wissenspack ist versions- und lokalisierungsgebunden. Aussagen unterscheiden offizielle Dokumentation, abgeleitete Standardmetadaten, getestete generische Verfahrenskenntnis und offene Annahmen. Er fuehrt keine eigene Source-Registry: `reference_snapshot` bindet exakt einen bereits validierten BC-Reference-Library-Lock und -Index. `knowledge_pack_id` muss mit dieser Bindung uebereinstimmen und jede `object_refs`-Referenz muss einen exakten `object_key` des validierten Index bezeichnen. Ohne gueltigen Snapshot-, Lock-, Objekt- und Indexdigest ist ein Pack nicht queryfaehig.

Playthroughs sind ausschliesslich Plaene. Sie beschreiben Preconditions, Schritte, erwartete Wirkung, Readback, Fehlerbehandlung und Stop-Codes. Sie buchen, importieren, erzeugen oder veraendern weder Business Central noch Kundenartefakte.

CRONUS ist eine Microsoft-Demo-Baseline. Kopieren oder Umbenennen beweist keine kundenspezifische Konfiguration. Baseline, Soll und Readback bleiben getrennt.
