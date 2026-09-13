{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        hk_specialism,
        specialism,
        load_datetime,
        record_source
    FROM {{ ref('stg_clinician_specialisms') }}
    WHERE specialism IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_specialism = i.hk_specialism
)
{% endif %}
