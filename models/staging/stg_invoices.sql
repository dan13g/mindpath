SELECT
    *,
    {{ hash_key(['invoice_id']) }} AS hk_invoice,
    {{ hash_key(['organisation_id']) }} AS hk_organisation,
    {{ hash_key(['contract_id']) }} AS hk_contract,
    {{ hashdiff(['invoice_date','invoice_status']) }} AS hd_invoice,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER' AS record_source
FROM {{ source('mindpath_sqlserver', 'invoices') }}
WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
