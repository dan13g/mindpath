# Mindpath SQL Training Project

Mindpath is the fictitious mental-health provider used throughout this practice project.

## Naming convention

Operational SQL Server database:
`MINDPATH_SOURCE`

Snowflake raw landing database:
`MINDPATH_RAW`

Snowflake Enterprise DW / Data Vault:
`MINDPATH_ENT_DW`

Snowflake Dimensional DW:
`MINDPATH_DIM_DW`

Reporting:
Power BI

## Stage 1 setup

1. Run `00_create_mindpath_source_database.sql`.
2. Run `01_create_schema.sql`.
3. Run `02_load_training_data.sql`.
4. Work through `03_stage1_exercises.md`.
5. Only use `04_stage1_answers.sql` after attempting each ticket.

The operational tables are deliberately messy. Foreign keys are not enforced because some of the exercises require you to discover:
- orphan records
- duplicate clients
- inconsistent email/mobile formatting
- missing values
- invalid contract relationships
- suspicious session dates
- duplicate-looking sessions
- row multiplication during joins

## Future stages

Stage 2 — harder operational SQL and reconciliation  
Stage 3 — `MINDPATH_RAW` and `MINDPATH_ENT_DW.RAW_VAULT`  
Stage 4 — `MINDPATH_ENT_DW.BUSINESS_VAULT`, MDM, PIT and bridges  
Stage 5 — `MINDPATH_DIM_DW` facts and dimensions  
Stage 6 — Power BI semantic/report reconciliation


# Mindpath SQL Training — Stage 2

Uses your existing SQL Server database:

`MINDPATH_SOURCE`

No reload required.

Stage 2 focuses on realistic investigation and reconciliation work:
- row multiplication
- incorrect joins
- NULL handling
- source vs report reconciliation
- latest-record logic
- waiting-time metrics
- duplicate detection / MDM
- lifecycle tracing
- invoice/session reconciliation
- root-cause investigation

Workflow:
1. Read the ticket.
2. Investigate with your own SQL.
3. Check table grain before every join.
4. Reconcile counts at each step.
5. Only then compare with the answers file.




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




# Mindpath Stage 4 — Business Vault

Prerequisite: Stage 3 V5 Raw Vault is built and passing.

This stage converts source-faithful Raw Vault structures into reusable business logic. It deliberately stops before dimensional facts/dimensions (Stage 5).

## What you build
- Current-state views for the major business entities
- Deterministic client matching and master-client mapping
- Client and referral PIT tables
- Referral lifecycle
- Outcome baseline/latest summary
- Authorisation utilisation
- Treatment episode
- Invoice summary and referral finance
- Full client journey (one row per referral)
- Master-client-to-referral bridge

## Install
Copy `dbt_project/models/business_vault` into the existing Mindpath dbt project from Stage 3. Merge the `business_vault` block from this pack's `dbt_project.yml` into your existing `dbt_project.yml` if necessary.

Then run:

    dbt build --select business_vault

For learning, do the exercises first and use `reference_answers` only after attempting them.

## Core rule
Raw Vault asks: what did the source say?
Business Vault asks: what business meaning/rules do we derive from it?

`BV_CLIENT_JOURNEY` has one row per referral. Sessions, outcomes and invoice lines are aggregated before they reach it to prevent fanout.
