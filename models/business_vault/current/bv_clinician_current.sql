{{ config(materialized='view') }}
SELECT h.hk_clinician, h.clinician_id, s.clinician_name, s.clinician_type,
       s.active_flag, s.region, s.primary_language, s.load_datetime AS satellite_load_datetime, s.record_source
FROM {{ ref('hub_clinician') }} h
LEFT JOIN {{ ref('sat_clinician_details') }} s ON h.hk_clinician=s.hk_clinician
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.hk_clinician ORDER BY s.load_datetime DESC)=1
