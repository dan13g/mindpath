{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['referral_id','organisation_id']) }} AS hk_referral_organisation,
        hk_referral,
        hk_organisation,
        load_datetime,
        record_source
    FROM {{ ref('stg_referrals') }}
    WHERE referral_id IS NOT NULL AND organisation_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_referral_organisation = i.hk_referral_organisation
)
{% endif %}
