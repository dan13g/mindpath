WITH source AS (
    SELECT * FROM {{ source('mindpath_sqlserver', 'sessions') }}
    WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
)

SELECT
    session_id,
    referral_id,
    client_id,
    clinician_id,
    service_id,
    session_date,
    session_status,
    delivery_method,
    duration_minutes,
    {{ hash_key(['session_id']) }} AS hk_session,
    {{ hash_key(['referral_id']) }} AS hk_referral,
    {{ hash_key(['client_id']) }} AS hk_client,
    {{ hash_key(['clinician_id']) }} AS hk_clinician,
    {{ hash_key(['service_id']) }} AS hk_service,
    {{ hashdiff(['session_date', 'session_status', 'delivery_method', 'duration_minutes']) }} AS hd_session,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER.SESSIONS' AS record_source
FROM source
