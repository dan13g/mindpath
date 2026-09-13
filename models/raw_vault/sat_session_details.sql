{{ config(materialized='incremental') }}
WITH staged AS (
    SELECT
        hk_session,
        hd_session AS hashdiff,
        session_date,
        session_status,
        delivery_method,
        duration_minutes,
        load_datetime,
        record_source
    FROM {{ ref('stg_sessions') }}
),
deduped AS (
    SELECT *
    FROM staged
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_session, hashdiff
        ORDER BY load_datetime
    ) = 1
)
SELECT d.*
FROM deduped d
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_session = d.hk_session
      AND t.hashdiff = d.hashdiff
)
{% endif %}
