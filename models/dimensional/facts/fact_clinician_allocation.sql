{{ config(materialized='table') }}

WITH referral_relationship AS (
    SELECT hk_allocation, MIN(hk_referral) AS hk_referral
    FROM {{ ref('lnk_referral_allocation') }}
    GROUP BY hk_allocation
),
clinician_relationship AS (
    SELECT hk_allocation, MIN(hk_clinician) AS hk_clinician
    FROM {{ ref('lnk_allocation_clinician') }}
    GROUP BY hk_allocation
)

SELECT
    a.hk_allocation AS allocation_key,
    a.allocation_id,
    dr.referral_key,
    dc.clinician_key,
    dd.date_key AS allocation_date_key,
    1 AS allocation_count,
    a.allocation_status

FROM {{ ref('bv_allocation_current') }} a

LEFT JOIN referral_relationship rr
  ON a.hk_allocation = rr.hk_allocation
LEFT JOIN {{ ref('dim_referral') }} dr
  ON rr.hk_referral = dr.referral_key

LEFT JOIN clinician_relationship cr
  ON a.hk_allocation = cr.hk_allocation
LEFT JOIN {{ ref('dim_clinician') }} dc
  ON cr.hk_clinician = dc.clinician_key

LEFT JOIN {{ ref('dim_date') }} dd
  ON a.allocation_date = dd.date_day
