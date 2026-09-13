WITH source AS (
    SELECT * FROM {{ source('mindpath_sqlserver', 'clients') }}
    WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
)

SELECT
    client_id,
    nhs_number,
    first_name,
    last_name,
    date_of_birth,
    email,
    mobile,
    postcode,
    created_date,
    source_system,
    {{ hash_key(['client_id']) }} AS hk_client,
    {{ hashdiff(['nhs_number', 'first_name', 'last_name', 'date_of_birth', 'email', 'mobile', 'postcode', 'created_date', 'source_system']) }} AS hd_client,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER.CLIENTS' AS record_source
FROM source
