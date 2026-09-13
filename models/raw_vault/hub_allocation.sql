{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        hk_allocation,
        allocation_id,
        load_datetime,
        record_source
    FROM {{ ref('stg_clinician_allocations') }}
    WHERE allocation_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_allocation = i.hk_allocation
)
{% endif %}
