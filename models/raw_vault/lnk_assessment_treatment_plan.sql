{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['assessment_id', 'treatment_plan_id']) }} AS hk_assessment_treatment_plan,
        hk_assessment,
        hk_treatment_plan,
        load_datetime,
        record_source
    FROM {{ ref('stg_treatment_plans') }}
    WHERE assessment_id IS NOT NULL AND treatment_plan_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_assessment_treatment_plan = i.hk_assessment_treatment_plan
)
{% endif %}
