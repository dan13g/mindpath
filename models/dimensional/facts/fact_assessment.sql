{{ config(materialized='table') }}

WITH referral_relationship AS (
    SELECT hk_assessment, MIN(hk_referral) AS hk_referral
    FROM {{ ref('lnk_referral_assessment') }}
    GROUP BY hk_assessment
),
client_relationship AS (
    SELECT
        ca.hk_assessment,
        MIN(m.hk_master_client) AS hk_master_client
    FROM {{ ref('lnk_client_assessment') }} ca
    LEFT JOIN {{ ref('bv_master_client') }} m
      ON ca.hk_client = m.source_hk_client
    GROUP BY ca.hk_assessment
)

SELECT
    da.assessment_key,
    a.assessment_id,
    dr.referral_key,
    dc.client_key,
    dd.date_key AS assessment_date_key,
    1 AS assessment_count,
    IFF(UPPER(a.assessment_status) = 'COMPLETED', 1, 0) AS completed_assessment_count

FROM {{ ref('bv_assessment_current') }} a

JOIN {{ ref('dim_assessment') }} da
  ON a.hk_assessment = da.assessment_key

LEFT JOIN referral_relationship rr
  ON a.hk_assessment = rr.hk_assessment
LEFT JOIN {{ ref('dim_referral') }} dr
  ON rr.hk_referral = dr.referral_key

LEFT JOIN client_relationship cr
  ON a.hk_assessment = cr.hk_assessment
LEFT JOIN {{ ref('dim_client') }} dc
  ON cr.hk_master_client = dc.client_key

LEFT JOIN {{ ref('dim_date') }} dd
  ON a.assessment_date = dd.date_day
