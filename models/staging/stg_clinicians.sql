SELECT
    *,
    {{ hash_key(['clinician_id']) }} AS hk_clinician,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER' AS record_source
FROM {{ source('mindpath_sqlserver', 'clinicians') }}
WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
