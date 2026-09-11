SELECT
    *,
    {{ hash_key(['client_id']) }} AS hk_client,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER' AS record_source
FROM {{ source('mindpath_sqlserver', 'clients') }}
WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
