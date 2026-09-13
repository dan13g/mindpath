{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['invoice_line_id', 'session_id']) }} AS hk_invoice_line_session,
        hk_invoice_line,
        hk_session,
        load_datetime,
        record_source
    FROM {{ ref('stg_invoice_lines') }}
    WHERE invoice_line_id IS NOT NULL AND session_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_invoice_line_session = i.hk_invoice_line_session
)
{% endif %}
