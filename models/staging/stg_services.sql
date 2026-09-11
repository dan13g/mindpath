SELECT
    *,
    {{ hash_key(['service_id']) }} AS hk_service,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER' AS record_source
FROM {{ source('mindpath_sqlserver', 'services') }}
WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
