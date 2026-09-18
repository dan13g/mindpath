{{ config(materialized='table') }}

WITH referral_relationship AS (
    SELECT hk_treatment_plan, MIN(hk_referral) AS hk_referral
    FROM {{ ref('lnk_referral_treatment_plan') }}
    GROUP BY hk_treatment_plan
),
assessment_relationship AS (
    SELECT hk_treatment_plan, MIN(hk_assessment) AS hk_assessment
    FROM {{ ref('lnk_assessment_treatment_plan') }}
    GROUP BY hk_treatment_plan
),
service_relationship AS (
    SELECT hk_treatment_plan, MIN(hk_service) AS hk_service
    FROM {{ ref('lnk_treatment_plan_service') }}
    GROUP BY hk_treatment_plan
)

SELECT
    dtp.treatment_plan_key,
    p.treatment_plan_id,
    dr.referral_key,
    da.assessment_key,
    ds.service_key,
    dd.date_key AS plan_start_date_key,
    1 AS treatment_plan_count,
    p.recommended_sessions

FROM {{ ref('bv_treatment_plan_current') }} p

JOIN {{ ref('dim_treatment_plan') }} dtp
  ON p.hk_treatment_plan = dtp.treatment_plan_key

LEFT JOIN referral_relationship rr
  ON p.hk_treatment_plan = rr.hk_treatment_plan
LEFT JOIN {{ ref('dim_referral') }} dr
  ON rr.hk_referral = dr.referral_key

LEFT JOIN assessment_relationship ar
  ON p.hk_treatment_plan = ar.hk_treatment_plan
LEFT JOIN {{ ref('dim_assessment') }} da
  ON ar.hk_assessment = da.assessment_key

LEFT JOIN service_relationship sr
  ON p.hk_treatment_plan = sr.hk_treatment_plan
LEFT JOIN {{ ref('dim_service') }} ds
  ON sr.hk_service = ds.service_key

LEFT JOIN {{ ref('dim_date') }} dd
  ON p.plan_start_date = dd.date_day
