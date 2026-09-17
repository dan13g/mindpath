{{ config(materialized='table') }}
WITH referral AS (
 SELECT hk_treatment_plan,MIN(hk_referral) referral_key FROM {{ ref('lnk_referral_treatment_plan') }} GROUP BY hk_treatment_plan
), assessment AS (
 SELECT hk_treatment_plan,MIN(hk_assessment) assessment_key FROM {{ ref('lnk_assessment_treatment_plan') }} GROUP BY hk_treatment_plan
), service AS (
 SELECT hk_treatment_plan,MIN(hk_service) service_key FROM {{ ref('lnk_treatment_plan_service') }} GROUP BY hk_treatment_plan
)
SELECT p.hk_treatment_plan AS treatment_plan_key,p.treatment_plan_id,r.referral_key,a.assessment_key,s.service_key,
       TO_NUMBER(TO_CHAR(p.plan_start_date,'YYYYMMDD')) plan_start_date_key,
       1 treatment_plan_count,p.recommended_sessions
FROM {{ ref('bv_treatment_plan_current') }} p
LEFT JOIN referral r ON p.hk_treatment_plan=r.hk_treatment_plan
LEFT JOIN assessment a ON p.hk_treatment_plan=a.hk_treatment_plan
LEFT JOIN service s ON p.hk_treatment_plan=s.hk_treatment_plan
