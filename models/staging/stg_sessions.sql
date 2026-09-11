SELECT
    *,
    {{ hash_key(['session_id']) }} AS hk_session,
    {{ hash_key(['referral_id']) }} AS hk_referral,
    {{ hash_key(['client_id']) }} AS hk_client,
    {{ hash_key(['clinician_id']) }} AS hk_clinician,
    {{ hash_key(['service_id']) }} AS hk_service,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER' AS record_source
FROM {{ source('mindpath_sqlserver', 'sessions') }}
WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
