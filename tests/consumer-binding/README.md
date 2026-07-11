# Consumer-Binding-Fixtures

Diese Dateien sind ausschliesslich deterministische Vertragsfixtures. Sie enthalten keine Kunden-, Tenant-, Universaarl- oder Release-Evidence.

`pending-valid.json` ist der einzig positive Fixturefall im aktuellen Repository: Ohne annotierten Tag, finalen Manifeststand und passenden Digest ist `PENDING_BCPROJECTOS_RELEASE` die einzige zulaessige Bindung. `bound-unverified.json` ist absichtlich kein Releasebeweis und muss gegen dieses Repository fail-closed abgewiesen werden.
