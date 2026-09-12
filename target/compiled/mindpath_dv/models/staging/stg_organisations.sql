SELECT
    *,
    SHA2_BINARY(
      CONCAT_WS('||'
        , COALESCE(NULLIF(UPPER(TRIM(CAST(organisation_id AS VARCHAR))), ''), '^^')
      ), 256
    ) AS hk_organisation,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER' AS record_source
FROM MINDPATH_RAW.SQLSERVER.organisations
WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE