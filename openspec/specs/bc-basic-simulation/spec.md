# bc-basic-simulation Specification

## Purpose
TBD - created by archiving change spectra-bc-basic-simulation. Update Purpose after archive.
## Requirements
### Requirement: Synthetic BC-Basic simulation
The fixture SHALL remain synthetic, non-installable and local-only while exposing the generic four-area process chain.

#### Scenario: Valid simulation
- **WHEN** all four BC areas and the ten-step process chain are present
- **THEN** the read-only validator succeeds

#### Scenario: Manipulated process chain
- **WHEN** a required process step is removed or a record status is unknown
- **THEN** validation fails closed with a stable error code

#### Scenario: Simulated execution gates
- **WHEN** customer/domain approval, UAT sign-off, cutover GO, go-live rehearsal, hypercare acceptance, restart and handover are represented as synthetic gates
- **THEN** each gate validates as `simulated_pass` with `synthetic: true` and `external_activity: false`

