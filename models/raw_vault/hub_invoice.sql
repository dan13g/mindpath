{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT hk_invoice, invoice_id, load_datetime, record_source
    FROM {{ ref('stg_invoices') }}
    WHERE invoice_id IS NOT NULL
)
SELECT i.* FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (SELECT 1 FROM {{ this }} t WHERE t.hk_invoice = i.hk_invoice)
{% endif %}
