{{ config(materialized='table') }}
WITH referral AS (
 SELECT hk_allocation,MIN(hk_referral) referral_key FROM {{ ref('lnk_referral_allocation') }} GROUP BY hk_allocation
), clinician AS (
 SELECT hk_allocation,MIN(hk_clinician) clinician_key FROM {{ ref('lnk_allocation_clinician') }} GROUP BY hk_allocation
)
SELECT a.hk_allocation AS allocation_key,a.allocation_id,r.referral_key,c.clinician_key,
       TO_NUMBER(TO_CHAR(a.allocation_date,'YYYYMMDD')) allocation_date_key,
       1 allocation_count,a.allocation_status
FROM {{ ref('bv_allocation_current') }} a
LEFT JOIN referral r ON a.hk_allocation=r.hk_allocation
LEFT JOIN clinician c ON a.hk_allocation=c.hk_allocation
