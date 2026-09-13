{{ config(materialized='incremental') }}
WITH staged AS (
    SELECT
        hk_allocation,
        hd_clinician_allocation AS hashdiff,
        allocation_date,
        allocation_status,
        load_datetime,
        record_source
    FROM {{ ref('stg_clinician_allocations') }}
),
deduped AS (
    SELECT *
    FROM staged
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_allocation, hashdiff
        ORDER BY load_datetime
    ) = 1
)
SELECT d.*
FROM deduped d
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_allocation = d.hk_allocation
      AND t.hashdiff = d.hashdiff
)
{% endif %}
