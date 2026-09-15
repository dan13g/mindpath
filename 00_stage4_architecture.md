# Stage 4 architecture

MINDPATH_ENT_DW.RAW_VAULT
  -> current-state views
  -> MDM/master client
  -> PITs
  -> process aggregates (referral lifecycle, outcomes, authorisation, treatment episode, finance)
  -> BV_CLIENT_JOURNEY
  -> bridge

The dimensional DW is intentionally not built here.

## Important grains
- BV_MASTER_CLIENT: one row per source client mapped to a master client
- BV_REFERRAL_LIFECYCLE: one row per referral
- BV_OUTCOME_SUMMARY: one row per referral + measure
- BV_TREATMENT_EPISODE: one row per referral
- BV_INVOICE_SUMMARY: one row per invoice
- BV_REFERRAL_FINANCE: one row per referral
- BV_CLIENT_JOURNEY: one row per referral
