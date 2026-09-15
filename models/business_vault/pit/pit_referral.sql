{{ config(materialized='table') }}
SELECT h.hk_referral, h.referral_id,
       MAX(s.load_datetime) AS sat_referral_details_load_datetime,
       CURRENT_TIMESTAMP() AS pit_created_datetime
FROM {{ ref('hub_referral') }} h
LEFT JOIN {{ ref('sat_referral_details') }} s ON h.hk_referral=s.hk_referral
GROUP BY h.hk_referral,h.referral_id
