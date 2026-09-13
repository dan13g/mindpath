{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['referral_id', 'allocation_id']) }} AS hk_referral_allocation,
        hk_referral,
        hk_allocation,
        load_datetime,
        record_source
    FROM {{ ref('stg_clinician_allocations') }}
    WHERE referral_id IS NOT NULL AND allocation_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_referral_allocation = i.hk_referral_allocation
)
{% endif %}
