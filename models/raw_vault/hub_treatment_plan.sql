{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        hk_treatment_plan,
        treatment_plan_id,
        load_datetime,
        record_source
    FROM {{ ref('stg_treatment_plans') }}
    WHERE treatment_plan_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_treatment_plan = i.hk_treatment_plan
)
{% endif %}
