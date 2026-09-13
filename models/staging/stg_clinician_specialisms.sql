WITH source AS (
    SELECT * FROM {{ source('mindpath_sqlserver', 'clinician_specialisms') }}
    WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
)

SELECT
    clinician_id,
    specialism,
    {{ hash_key(['clinician_id']) }} AS hk_clinician,
    {{ hash_key(['specialism']) }} AS hk_specialism,
    {{ hash_key(['clinician_id', 'specialism']) }} AS hk_clinician_specialism,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER.CLINICIAN_SPECIALISMS' AS record_source
FROM source
