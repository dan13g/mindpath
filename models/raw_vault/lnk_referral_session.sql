{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['referral_id','session_id']) }} AS hk_referral_session,
        hk_referral,
        hk_session,
        load_datetime,
        record_source
    FROM {{ ref('stg_sessions') }}
    WHERE referral_id IS NOT NULL AND session_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_referral_session = i.hk_referral_session
)
{% endif %}
