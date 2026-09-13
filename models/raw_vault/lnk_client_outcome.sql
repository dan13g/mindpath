{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['client_id', 'outcome_id']) }} AS hk_client_outcome,
        hk_client,
        hk_outcome,
        load_datetime,
        record_source
    FROM {{ ref('stg_outcomes') }}
    WHERE client_id IS NOT NULL AND outcome_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_client_outcome = i.hk_client_outcome
)
{% endif %}
