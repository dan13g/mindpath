{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        hk_session,
        session_id,
        load_datetime,
        record_source
    FROM {{ ref('stg_sessions') }}
    WHERE session_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_session = i.hk_session
)
{% endif %}
