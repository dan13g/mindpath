{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['referral_id', 'treatment_plan_id']) }} AS hk_referral_treatment_plan,
        hk_referral,
        hk_treatment_plan,
        load_datetime,
        record_source
    FROM {{ ref('stg_treatment_plans') }}
    WHERE referral_id IS NOT NULL AND treatment_plan_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_referral_treatment_plan = i.hk_referral_treatment_plan
)
{% endif %}
