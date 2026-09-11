# Stage 3 architecture

```text
MINDPATH_SOURCE
SQL Server operational database
        |
        | simulated Fivetran initial sync
        v
MINDPATH_RAW.SQLSERVER
        |
        | dbt Cloud
        v
MINDPATH_ENT_DW.RAW_VAULT
        |
        +-- HUB_CLIENT
        +-- HUB_REFERRAL
        +-- HUB_ORGANISATION
        +-- HUB_CONTRACT
        +-- HUB_CLINICIAN
        +-- HUB_SERVICE
        +-- HUB_SESSION
        +-- HUB_ASSESSMENT
        |
        +-- LNK_CLIENT_REFERRAL
        +-- LNK_REFERRAL_ORGANISATION
        +-- LNK_REFERRAL_CONTRACT
        +-- LNK_REFERRAL_ASSESSMENT
        +-- LNK_CLIENT_SESSION
        +-- LNK_REFERRAL_SESSION
        +-- LNK_CLINICIAN_SESSION
        +-- LNK_SESSION_SERVICE
        |
        +-- SAT_CLIENT_DETAILS
        +-- SAT_REFERRAL_DETAILS
        +-- SAT_REFERRAL_STATUS
        +-- SAT_SESSION_DETAILS
```

## Raw layer rule

Do not clean away source problems in `MINDPATH_RAW`. Raw should preserve what arrived from the source, including the deliberately bad records from Stage 1.

## Fivetran simulation

All landed tables have `_FIVETRAN_SYNCED` and `_FIVETRAN_DELETED`. Tables that had no source primary key also include `_FIVETRAN_ID` and `_FIVETRAN_INDEX`.

## Stage 3 boundary

Stage 3 stops at the Raw Vault. Client mastering, deterministic cross-source identity, PIT tables and Business Vault lifecycle logic are reserved for Stage 4.
