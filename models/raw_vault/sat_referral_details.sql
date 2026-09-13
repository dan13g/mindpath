{{ config(materialized='incremental') }}
WITH staged AS (
    SELECT
        hk_referral,
        hd_referral AS hashdiff,
        referral_date,
        referral_source,
        presenting_problem,
        priority,
        referral_status,
        funding_type,
        load_datetime,
        record_source
    FROM {{ ref('stg_referrals') }}
),
deduped AS (
    SELECT *
    FROM staged
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_referral, hashdiff
        ORDER BY load_datetime
    ) = 1
)
SELECT d.*
FROM deduped d
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_referral = d.hk_referral
      AND t.hashdiff = d.hashdiff
)
{% endif %}
