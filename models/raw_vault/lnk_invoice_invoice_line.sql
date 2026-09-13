{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['invoice_id','invoice_line_id']) }} AS hk_invoice_invoice_line,
        hk_invoice, hk_invoice_line, load_datetime, record_source
    FROM {{ ref('stg_invoice_lines') }}
    WHERE invoice_id IS NOT NULL AND invoice_line_id IS NOT NULL
)
SELECT i.* FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (SELECT 1 FROM {{ this }} t WHERE t.hk_invoice_invoice_line = i.hk_invoice_invoice_line)
{% endif %}
