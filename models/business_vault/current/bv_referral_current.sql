{{ config(materialized='view') }}
SELECT h.hk_referral, h.referral_id,
       s.referral_date, s.referral_source, s.presenting_problem, s.priority,
       s.referral_status, s.funding_type, s.load_datetime AS satellite_load_datetime, s.record_source
FROM {{ ref('hub_referral') }} h
LEFT JOIN {{ ref('sat_referral_details') }} s ON h.hk_referral=s.hk_referral
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.hk_referral ORDER BY s.load_datetime DESC)=1
