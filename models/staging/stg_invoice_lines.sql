SELECT
    *,
    {{ hash_key(['invoice_line_id']) }} AS hk_invoice_line,
    {{ hash_key(['invoice_id']) }} AS hk_invoice,
    {{ hash_key(['referral_id']) }} AS hk_referral,
    {{ hash_key(['session_id']) }} AS hk_session,
    {{ hash_key(['service_id']) }} AS hk_service,
    {{ hashdiff(['quantity','unit_price','line_amount']) }} AS hd_invoice_line,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER' AS record_source
FROM {{ source('mindpath_sqlserver', 'invoice_lines') }}
WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
