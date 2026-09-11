SELECT
    *,
    {{ hash_key(['organisation_id']) }} AS hk_organisation,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER' AS record_source
FROM {{ source('mindpath_sqlserver', 'organisations') }}
WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
