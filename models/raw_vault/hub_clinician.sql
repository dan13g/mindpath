{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        hk_clinician,
        clinician_id,
        load_datetime,
        record_source
    FROM {{ ref('stg_clinicians') }}
    WHERE clinician_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_clinician = i.hk_clinician
)
{% endif %}
