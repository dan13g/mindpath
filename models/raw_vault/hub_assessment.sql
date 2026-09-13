{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        hk_assessment,
        assessment_id,
        load_datetime,
        record_source
    FROM {{ ref('stg_assessments') }}
    WHERE assessment_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_assessment = i.hk_assessment
)
{% endif %}
