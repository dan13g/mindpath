{{ config(materialized='table') }}
SELECT hk_clinician AS clinician_key, hk_specialism AS specialism_key
FROM {{ ref('lnk_clinician_specialism') }}
