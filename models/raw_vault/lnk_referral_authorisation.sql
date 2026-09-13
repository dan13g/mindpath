{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['referral_id', 'authorisation_id']) }} AS hk_referral_authorisation,
        hk_referral,
        hk_authorisation,
        load_datetime,
        record_source
    FROM {{ ref('stg_authorisations') }}
    WHERE referral_id IS NOT NULL AND authorisation_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_referral_authorisation = i.hk_referral_authorisation
)
{% endif %}
