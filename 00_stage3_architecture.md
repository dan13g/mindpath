# Stage 3 architecture

```text
MINDPATH_SOURCE (SQL Server)
        ↓ simulated Fivetran
MINDPATH_RAW.SQLSERVER
        ↓ dbt staging
MINDPATH_ENT_DW.STAGING
        ↓ dbt
MINDPATH_ENT_DW.RAW_VAULT
```

## Raw Vault coverage
Hubs are created for clients, organisations, services, contracts, referrals, assessments, treatment plans, authorisations, clinicians, specialisms, allocations, sessions, outcomes, invoices and invoice lines.

Links represent all meaningful source relationships used in the training schema. See `09_raw_vault_model_inventory.md`.
