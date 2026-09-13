{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['client_id', 'assessment_id']) }} AS hk_client_assessment,
        hk_client,
        hk_assessment,
        load_datetime,
        record_source
    FROM {{ ref('stg_assessments') }}
    WHERE client_id IS NOT NULL AND assessment_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_client_assessment = i.hk_client_assessment
)
{% endif %}
