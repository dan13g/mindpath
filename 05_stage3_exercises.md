# Mindpath Stage 3 exercises — Snowflake + dbt Raw Vault

## 1. Validate the simulated Fivetran landing
Run the reconciliation script. Confirm the raw table counts and check `_FIVETRAN_SYNCED` / `_FIVETRAN_DELETED`. Confirm the Stage 1 anomalies were not cleaned away.

## 2. Create the dbt Cloud project
Connect dbt Cloud to Snowflake using `MINDPATH_DBT_WH`, `MINDPATH_DBT_ROLE`, database `MINDPATH_ENT_DW`, then connect a Git repo containing `starter_dbt_project`. Run `dbt debug` and `dbt parse`.

## 3. Inspect sources and staging
Run `dbt build --select staging`. Check the generated `MINDPATH_ENT_DW` staging schema. Explain why `_FIVETRAN_DELETED = FALSE` belongs in staging rather than modifying raw.

## 4. Build HUB_CLIENT
Grain: one unique source client business key (`client_id`). Columns: `hk_client`, `client_id`, `load_datetime`, `record_source`. Incremental and append-only. Add unique/not-null tests on `hk_client`.

## 5. Build the remaining core hubs
Create HUB_REFERRAL, HUB_ORGANISATION, HUB_CONTRACT, HUB_CLINICIAN, HUB_SERVICE, HUB_SESSION and HUB_ASSESSMENT. Use the source business key, not descriptive attributes, in each hub hash key.

## 6. Build LNK_CLIENT_REFERRAL
One unique client-referral relationship. Create a link hash from the participating hub keys/business keys. Include load datetime and record source. Test the link hash unique/not-null.

## 7. Build the remaining links
Build:
- LNK_REFERRAL_ORGANISATION
- LNK_REFERRAL_CONTRACT
- LNK_REFERRAL_ASSESSMENT
- LNK_CLIENT_SESSION
- LNK_REFERRAL_SESSION
- LNK_CLINICIAN_SESSION
- LNK_SESSION_SERVICE

Decide what to do when a relationship key is NULL. Do not invent a real clinician for the deliberately missing-clinician session.

## 8. Build SAT_CLIENT_DETAILS
Parent: HUB_CLIENT. Descriptive columns: NHS number, names, DOB, email, mobile, postcode, source_system. Add `hashdiff`, `load_datetime`, `record_source`.

## 9. Build SAT_REFERRAL_DETAILS and SAT_REFERRAL_STATUS
Separate relatively descriptive referral attributes from status. Explain why status deserves its own satellite.

## 10. Build SAT_SESSION_DETAILS
Store session date, status, delivery method and duration. Do not place clinician/service business keys in this satellite; those relationships belong in links.

## 11. Add dbt tests
At minimum test all hub/link hash keys for not_null + unique. Add relationship tests from satellite parent hash keys to hubs. Keep in mind the raw source deliberately contains bad referential data.

## 12. Reconcile Raw Vault to raw landing
For each hub compare distinct source business keys to hub rows. For each link compare distinct valid relationships to link rows. Investigate any mismatch.

## 13. Prove the orphan is preserved
Trace referral `20099` from `MINDPATH_RAW.SQLSERVER.REFERRALS` into HUB_REFERRAL and its links. Explain why a Raw Vault should preserve the referral even though client `99999` does not exist in the client source table.

## 14. Prove grain/fanout is still understood
Using only Raw Vault objects, calculate completed sessions. Then join session-related data to referral outcomes in a deliberately unsafe way and reproduce row multiplication. Fix it.

## 15. Document lineage
Use dbt docs / lineage to trace:
`MINDPATH_RAW.SQLSERVER.SESSIONS -> STG_SESSIONS -> HUB_SESSION/LNK_REFERRAL_SESSION/LNK_CLINICIAN_SESSION/SAT_SESSION_DETAILS`.

## Stage 3 completion criteria
You are done when:
- dbt build succeeds
- core hubs/links/satellites exist
- tests pass except any deliberately chosen tests that expose known source-quality problems
- counts reconcile
- you can explain the grain of every Raw Vault object
- you can trace one referral through the Raw Vault without guessing
