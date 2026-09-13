{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['referral_id', 'assessment_id']) }} AS hk_referral_assessment,
        hk_referral,
        hk_assessment,
        load_datetime,
        record_source
    FROM {{ ref('stg_assessments') }}
    WHERE referral_id IS NOT NULL AND assessment_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_referral_assessment = i.hk_referral_assessment
)
{% endif %}
