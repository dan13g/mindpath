{{ config(materialized='table') }}
WITH referral AS (
    SELECT hk_assessment, MIN(hk_referral) AS referral_key FROM {{ ref('lnk_referral_assessment') }} GROUP BY hk_assessment
), client AS (
    SELECT ca.hk_assessment, MIN(m.hk_master_client) AS client_key
    FROM {{ ref('lnk_client_assessment') }} ca
    LEFT JOIN {{ ref('bv_master_client') }} m ON ca.hk_client=m.source_hk_client
    GROUP BY ca.hk_assessment
)
SELECT a.hk_assessment AS assessment_key, a.assessment_id, r.referral_key, c.client_key,
       TO_NUMBER(TO_CHAR(a.assessment_date,'YYYYMMDD')) AS assessment_date_key,
       1 AS assessment_count,
       IFF(UPPER(a.assessment_status)='COMPLETED',1,0) AS completed_assessment_count
FROM {{ ref('bv_assessment_current') }} a
LEFT JOIN referral r ON a.hk_assessment=r.hk_assessment
LEFT JOIN client c ON a.hk_assessment=c.hk_assessment
