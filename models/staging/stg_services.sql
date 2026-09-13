WITH source AS (
    SELECT * FROM {{ source('mindpath_sqlserver', 'services') }}
    WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
)

SELECT
    service_id,
    service_name,
    service_category,
    {{ hash_key(['service_id']) }} AS hk_service,
    {{ hashdiff(['service_name', 'service_category']) }} AS hd_service,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER.SERVICES' AS record_source
FROM source
