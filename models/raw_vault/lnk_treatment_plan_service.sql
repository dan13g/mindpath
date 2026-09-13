{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['treatment_plan_id', 'service_id']) }} AS hk_treatment_plan_service,
        hk_treatment_plan,
        hk_service,
        load_datetime,
        record_source
    FROM {{ ref('stg_treatment_plans') }}
    WHERE treatment_plan_id IS NOT NULL AND service_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_treatment_plan_service = i.hk_treatment_plan_service
)
{% endif %}
