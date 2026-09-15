{{ config(materialized='view') }}
SELECT h.hk_assessment, h.assessment_id, s.assessment_date, s.assessment_type,
       s.presenting_condition, s.risk_level, s.recommended_treatment, s.assessment_status,
       s.load_datetime AS satellite_load_datetime, s.record_source
FROM {{ ref('hub_assessment') }} h
LEFT JOIN {{ ref('sat_assessment_details') }} s ON h.hk_assessment=s.hk_assessment
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.hk_assessment ORDER BY s.load_datetime DESC)=1
