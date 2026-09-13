{{ config(materialized='incremental') }}
WITH staged AS (
    SELECT
        hk_assessment,
        hd_assessment AS hashdiff,
        assessment_date,
        assessment_type,
        presenting_condition,
        risk_level,
        recommended_treatment,
        assessment_status,
        load_datetime,
        record_source
    FROM {{ ref('stg_assessments') }}
),
deduped AS (
    SELECT *
    FROM staged
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_assessment, hashdiff
        ORDER BY load_datetime
    ) = 1
)
SELECT d.*
FROM deduped d
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_assessment = d.hk_assessment
      AND t.hashdiff = d.hashdiff
)
{% endif %}
