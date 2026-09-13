{{ config(materialized='incremental') }}
WITH staged AS (
    SELECT
        hk_invoice_line,
        hd_invoice_line AS hashdiff,
        quantity,
        unit_price,
        line_amount,
        load_datetime,
        record_source
    FROM {{ ref('stg_invoice_lines') }}
), deduped AS (
    SELECT * FROM staged
    QUALIFY ROW_NUMBER() OVER (PARTITION BY hk_invoice_line, hashdiff ORDER BY load_datetime) = 1
)
SELECT d.* FROM deduped d
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_invoice_line = d.hk_invoice_line
      AND t.hashdiff = d.hashdiff
)
{% endif %}
