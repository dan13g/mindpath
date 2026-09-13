{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['referral_id', 'contract_id']) }} AS hk_referral_contract,
        hk_referral,
        hk_contract,
        load_datetime,
        record_source
    FROM {{ ref('stg_referrals') }}
    WHERE referral_id IS NOT NULL AND contract_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_referral_contract = i.hk_referral_contract
)
{% endif %}
