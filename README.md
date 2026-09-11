# Mindpath Stage 3 — Snowflake + dbt Data Vault

This stage uses the **same business data** as Mindpath Stages 1 and 2.

The SQL Server source remains unchanged. The Snowflake raw layer is a simulated Fivetran landing:

`MINDPATH_SOURCE (SQL Server) -> simulated Fivetran -> MINDPATH_RAW.SQLSERVER -> dbt -> MINDPATH_ENT_DW.RAW_VAULT`

There is **no second simulated load** in this stage.

## Run order

1. Run `01_snowflake_setup.sql` in Snowflake.
2. Run `02_create_raw_tables.sql`.
3. Run `03_load_raw_initial.sql`.
4. Run `04_raw_reconciliation.sql` and compare with SQL Server if you want.
5. Create a new dbt Cloud project/repository and copy in `starter_dbt_project`.
6. Work through `05_stage3_exercises.md`.
7. Use `reference_solution` only after attempting the exercises.

The goal is not to memorise Data Vault SQL. It is to understand grain, business keys, hubs, links, satellites, metadata and how dbt builds them.
