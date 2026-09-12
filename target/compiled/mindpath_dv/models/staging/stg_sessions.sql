SELECT
    *,
    SHA2_BINARY(
      CONCAT_WS('||'
        , COALESCE(NULLIF(UPPER(TRIM(CAST(session_id AS VARCHAR))), ''), '^^')
      ), 256
    ) AS hk_session,
    SHA2_BINARY(
      CONCAT_WS('||'
        , COALESCE(NULLIF(UPPER(TRIM(CAST(referral_id AS VARCHAR))), ''), '^^')
      ), 256
    ) AS hk_referral,
    SHA2_BINARY(
      CONCAT_WS('||'
        , COALESCE(NULLIF(UPPER(TRIM(CAST(client_id AS VARCHAR))), ''), '^^')
      ), 256
    ) AS hk_client,
    SHA2_BINARY(
      CONCAT_WS('||'
        , COALESCE(NULLIF(UPPER(TRIM(CAST(clinician_id AS VARCHAR))), ''), '^^')
      ), 256
    ) AS hk_clinician,
    SHA2_BINARY(
      CONCAT_WS('||'
        , COALESCE(NULLIF(UPPER(TRIM(CAST(service_id AS VARCHAR))), ''), '^^')
      ), 256
    ) AS hk_service,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER' AS record_source
FROM MINDPATH_RAW.SQLSERVER.sessions
WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE