SELECT
    *,
    SHA2_BINARY(
      CONCAT_WS('||'
        , COALESCE(NULLIF(UPPER(TRIM(CAST(assessment_id AS VARCHAR))), ''), '^^')
      ), 256
    ) AS hk_assessment,
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
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER' AS record_source
FROM MINDPATH_RAW.SQLSERVER.assessments
WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE