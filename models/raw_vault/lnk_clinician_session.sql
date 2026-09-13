{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['clinician_id', 'session_id']) }} AS hk_clinician_session,
        hk_clinician,
        hk_session,
        load_datetime,
        record_source
    FROM {{ ref('stg_sessions') }}
    WHERE clinician_id IS NOT NULL AND session_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_clinician_session = i.hk_clinician_session
)
{% endif %}
