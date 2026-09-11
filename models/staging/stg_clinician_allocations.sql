SELECT
    *,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER' AS record_source
FROM {{ source('mindpath_sqlserver', 'clinician_allocations') }}
WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
