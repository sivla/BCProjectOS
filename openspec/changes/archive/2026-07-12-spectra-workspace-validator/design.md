# Design

`automation/Test-CustomerWorkspace.ps1` benötigt `-Path` und `-ProductRoot`, liest ausschließlich lokale Dateien und Git-Blobs und bricht bei unbekannten oder inkonsistenten Zuständen mit einem eindeutigen Fehler ab. Es validiert die kanonische Workspace-Identität, Profile, Pfade, genau einen OpenSpec-Root, Katalog-Hashes, BOUND-Releasebindung, Tag-Manifest-Digest-Ancestry sowie sensible Muster. Es schreibt keine Datei.

Die positive/negative Suite installiert ausschließlich in ein isoliertes Temp-Ziel und verändert danach nur absichtlich eine synthetische Katalogkopie.
