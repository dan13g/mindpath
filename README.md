# Mindpath Stage 3 — Complete Raw Vault

This is the canonical Stage 3 package. It keeps the same Mindpath business data from Stages 1–2, lands it in `MINDPATH_RAW.SQLSERVER` with Fivetran-style metadata, and builds a complete training Raw Vault in dbt.

## Run order
1. `01_snowflake_setup.sql`
2. `02_create_raw_tables.sql`
3. `03_load_raw_initial.sql`
4. `04_raw_reconciliation.sql`
5. Configure the `dbt_project` folder in dbt Cloud
6. `dbt build`
7. Work through `05_stage3_exercises.md`

## Modelling rule used
- Durable business key / business object -> Hub
- Meaningful business relationship -> Link
- Descriptive attributes that can change -> Satellite

A source table does **not** automatically require its own satellite. Pure relationship tables with no descriptive payload may become only a Link. In this model, `CLINICIAN_SPECIALISMS` is such an example. `CONTRACT_SERVICES` has descriptive payload (`agreed_rate`, `session_limit`), so its Link has a Link Satellite.

Stage 3 stops at the Raw Vault. MDM, PIT/bridges and business rules belong to Stage 4 Business Vault.
