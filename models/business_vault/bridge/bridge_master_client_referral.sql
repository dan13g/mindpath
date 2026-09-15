{{ config(materialized='table') }}
SELECT m.hk_master_client,m.master_client_id,m.source_hk_client,m.source_client_id,l.hk_referral,r.referral_id
FROM {{ ref('bv_master_client') }} m JOIN {{ ref('lnk_client_referral') }} l ON m.source_hk_client=l.hk_client
JOIN {{ ref('hub_referral') }} r ON l.hk_referral=r.hk_referral
