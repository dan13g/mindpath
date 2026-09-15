{{ config(materialized='view') }}
SELECT h.hk_treatment_plan, h.treatment_plan_id, s.recommended_sessions, s.plan_start_date,
       s.status AS treatment_plan_status, s.load_datetime AS satellite_load_datetime, s.record_source
FROM {{ ref('hub_treatment_plan') }} h
LEFT JOIN {{ ref('sat_treatment_plan_details') }} s ON h.hk_treatment_plan=s.hk_treatment_plan
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.hk_treatment_plan ORDER BY s.load_datetime DESC)=1
