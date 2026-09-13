{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['session_id','service_id']) }} AS hk_session_service,
        hk_session,
        hk_service,
        load_datetime,
        record_source
    FROM {{ ref('stg_sessions') }}
    WHERE session_id IS NOT NULL AND service_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_session_service = i.hk_session_service
)
{% endif %}
