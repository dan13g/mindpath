WITH source AS (
    SELECT * FROM {{ source('mindpath_sqlserver', 'organisations') }}
    WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
)

SELECT
    organisation_id,
    organisation_name,
    organisation_type,
    status,
    {{ hash_key(['organisation_id']) }} AS hk_organisation,
    {{ hashdiff(['organisation_name', 'organisation_type', 'status']) }} AS hd_organisation,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER.ORGANISATIONS' AS record_source
FROM source
