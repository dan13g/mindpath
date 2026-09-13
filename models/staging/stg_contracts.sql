WITH source AS (
    SELECT * FROM {{ source('mindpath_sqlserver', 'contracts') }}
    WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
)

SELECT
    contract_id,
    organisation_id,
    contract_name,
    start_date,
    end_date,
    status,
    billing_method,
    {{ hash_key(['contract_id']) }} AS hk_contract,
    {{ hash_key(['organisation_id']) }} AS hk_organisation,
    {{ hashdiff(['contract_name', 'start_date', 'end_date', 'status', 'billing_method']) }} AS hd_contract,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER.CONTRACTS' AS record_source
FROM source
