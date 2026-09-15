{{ config(materialized='view') }}
SELECT h.hk_outcome, h.outcome_id, s.measure_name, s.measurement_date, s.score,
       s.load_datetime AS satellite_load_datetime, s.record_source
FROM {{ ref('hub_outcome') }} h
LEFT JOIN {{ ref('sat_outcome_details') }} s ON h.hk_outcome=s.hk_outcome
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.hk_outcome ORDER BY s.load_datetime DESC)=1
