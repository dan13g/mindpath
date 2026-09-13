{{ config(materialized='incremental') }}
WITH staged AS (
    SELECT
        hk_treatment_plan,
        hd_treatment_plan AS hashdiff,
        recommended_sessions,
        plan_start_date,
        status,
        load_datetime,
        record_source
    FROM {{ ref('stg_treatment_plans') }}
),
deduped AS (
    SELECT *
    FROM staged
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_treatment_plan, hashdiff
        ORDER BY load_datetime
    ) = 1
)
SELECT d.*
FROM deduped d
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_treatment_plan = d.hk_treatment_plan
      AND t.hashdiff = d.hashdiff
)
{% endif %}
