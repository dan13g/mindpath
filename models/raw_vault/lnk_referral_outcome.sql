{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['referral_id', 'outcome_id']) }} AS hk_referral_outcome,
        hk_referral,
        hk_outcome,
        load_datetime,
        record_source
    FROM {{ ref('stg_outcomes') }}
    WHERE referral_id IS NOT NULL AND outcome_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_referral_outcome = i.hk_referral_outcome
)
{% endif %}
