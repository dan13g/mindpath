{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['client_id', 'session_id']) }} AS hk_client_session,
        hk_client,
        hk_session,
        load_datetime,
        record_source
    FROM {{ ref('stg_sessions') }}
    WHERE client_id IS NOT NULL AND session_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_client_session = i.hk_client_session
)
{% endif %}
