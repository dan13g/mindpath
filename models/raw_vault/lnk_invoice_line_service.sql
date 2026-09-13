{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['invoice_line_id','service_id']) }} AS hk_invoice_line_service,
        hk_invoice_line, hk_service, load_datetime, record_source
    FROM {{ ref('stg_invoice_lines') }}
    WHERE invoice_line_id IS NOT NULL AND service_id IS NOT NULL
)
SELECT i.* FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (SELECT 1 FROM {{ this }} t WHERE t.hk_invoice_line_service = i.hk_invoice_line_service)
{% endif %}
