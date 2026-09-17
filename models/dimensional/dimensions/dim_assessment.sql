{{ config(materialized='table') }}
SELECT hk_assessment AS assessment_key, assessment_id, assessment_type,
       presenting_condition, risk_level, recommended_treatment, assessment_status
FROM {{ ref('bv_assessment_current') }}
