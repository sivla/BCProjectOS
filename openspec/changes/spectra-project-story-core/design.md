# Design

The core is file-based and deterministic. Every ticket transition is timestamped; Done/Closed requires acceptance criteria, evidence references and a closing comment. Pages use stable IDs and parent references. Timeline events connect offers, pages, tickets, tests and evidence without external writes.
