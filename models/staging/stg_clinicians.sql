WITH source AS (
    SELECT * FROM {{ source('mindpath_sqlserver', 'clinicians') }}
    WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
)

SELECT
    clinician_id,
    clinician_name,
    clinician_type,
    active_flag,
    region,
    primary_language,
    {{ hash_key(['clinician_id']) }} AS hk_clinician,
    {{ hashdiff(['clinician_name', 'clinician_type', 'active_flag', 'region', 'primary_language']) }} AS hd_clinician,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER.CLINICIANS' AS record_source
FROM source
