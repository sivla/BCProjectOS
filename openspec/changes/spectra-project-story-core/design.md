# Design

The core is file-based and deterministic. Every ticket transition is timestamped; Done/Closed requires acceptance criteria, evidence references and a closing comment. Pages use stable IDs and parent references. Timeline events connect offers, pages, tickets, tests and evidence without external writes. The proposed `0.3.0-alpha.1` remains below 1.0 because full intake, backup/restore and pilot evidence are absent.
