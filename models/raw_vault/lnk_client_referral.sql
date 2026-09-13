{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['client_id', 'referral_id']) }} AS hk_client_referral,
        hk_client,
        hk_referral,
        load_datetime,
        record_source
    FROM {{ ref('stg_referrals') }}
    WHERE client_id IS NOT NULL AND referral_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_client_referral = i.hk_client_referral
)
{% endif %}
