{{ config(materialized='table') }}

SELECT
    dc.clinician_key,
    ds.specialism_key
FROM {{ ref('lnk_clinician_specialism') }} l
JOIN {{ ref('dim_clinician') }} dc
  ON l.hk_clinician = dc.clinician_key
JOIN {{ ref('dim_specialism') }} ds
  ON l.hk_specialism = ds.specialism_key
