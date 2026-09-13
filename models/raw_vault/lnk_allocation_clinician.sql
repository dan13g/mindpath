{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['allocation_id', 'clinician_id']) }} AS hk_allocation_clinician,
        hk_allocation,
        hk_clinician,
        load_datetime,
        record_source
    FROM {{ ref('stg_clinician_allocations') }}
    WHERE allocation_id IS NOT NULL AND clinician_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_allocation_clinician = i.hk_allocation_clinician
)
{% endif %}
