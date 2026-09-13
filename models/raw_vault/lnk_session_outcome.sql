{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['session_id', 'outcome_id']) }} AS hk_session_outcome,
        hk_session,
        hk_outcome,
        load_datetime,
        record_source
    FROM {{ ref('stg_outcomes') }}
    WHERE session_id IS NOT NULL AND outcome_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_session_outcome = i.hk_session_outcome
)
{% endif %}
