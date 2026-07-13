# Design: P0-Skillkatalog

Jede Skillfamilie liegt unter `skills/<name>/` und enthält ausschließlich `SKILL.md`, `agents/openai.yaml` sowie benötigte direkte Referenzen. Der Trigger steht vollständig in der Frontmatter-Beschreibung. Varianten und Prozessdetails gehören in Referenzen, wiederholte deterministische Prüfungen später in `scripts/`.

Ein zentraler maschinenlesbarer Katalog beschreibt Risiko, Mutationsklasse und Pflichtreferenzen. Mutierende Skills sind standardmäßig low-freedom, benötigen explizite Zielbindung und dürfen nie implizit aus Intake, Statuspflege oder Recherche triggern. Der erste Block liefert Vertrag und belastbare Skillhüllen; tiefe Prozessreferenzen und produktive Adapter folgen in weiteren eigenständigen Skill-Releases.
