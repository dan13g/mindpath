{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        hk_invoice_line,
        invoice_line_id,
        load_datetime,
        record_source
    FROM {{ ref('stg_invoice_lines') }}
    WHERE invoice_line_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_invoice_line = i.hk_invoice_line
)
{% endif %}
