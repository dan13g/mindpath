{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        hk_clinician_specialism AS hk_clinician_specialism,
        hk_clinician,
        hk_specialism,
        load_datetime,
        record_source
    FROM {{ ref('stg_clinician_specialisms') }}
    WHERE clinician_id IS NOT NULL AND specialism IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_clinician_specialism = i.hk_clinician_specialism
)
{% endif %}
