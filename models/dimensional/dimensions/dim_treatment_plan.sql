{{ config(materialized='table') }}
SELECT hk_treatment_plan AS treatment_plan_key, treatment_plan_id,
       recommended_sessions, treatment_plan_status
FROM {{ ref('bv_treatment_plan_current') }}
