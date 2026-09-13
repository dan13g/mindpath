{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        hk_outcome,
        outcome_id,
        load_datetime,
        record_source
    FROM {{ ref('stg_outcomes') }}
    WHERE outcome_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_outcome = i.hk_outcome
)
{% endif %}
