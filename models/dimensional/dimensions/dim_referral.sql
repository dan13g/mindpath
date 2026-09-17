{{ config(materialized='table') }}
SELECT hk_referral AS referral_key, referral_id, referral_source, presenting_problem,
       priority, referral_status, funding_type
FROM {{ ref('bv_referral_current') }}
