{{ config(materialized='table') }}
SELECT DISTINCT MD5('OUTCOME_MEASURE|' || UPPER(TRIM(measure_name))) AS outcome_measure_key,
       UPPER(TRIM(measure_name)) AS measure_name
FROM {{ ref('bv_outcome_current') }}
WHERE measure_name IS NOT NULL
