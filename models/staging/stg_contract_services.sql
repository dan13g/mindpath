WITH source AS (
    SELECT * FROM {{ source('mindpath_sqlserver', 'contract_services') }}
    WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
)

SELECT
    contract_id,
    service_id,
    agreed_rate,
    session_limit,
    {{ hash_key(['contract_id']) }} AS hk_contract,
    {{ hash_key(['service_id']) }} AS hk_service,
    {{ hash_key(['contract_id', 'service_id']) }} AS hk_contract_service,
    {{ hashdiff(['agreed_rate', 'session_limit']) }} AS hd_contract_service,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER.CONTRACT_SERVICES' AS record_source
FROM source
