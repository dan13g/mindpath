{{ config(materialized='incremental') }}
WITH staged AS (
    SELECT
        hk_invoice,
        hd_invoice AS hashdiff,
        invoice_date,
        invoice_status,
        load_datetime,
        record_source
    FROM {{ ref('stg_invoices') }}
), deduped AS (
    SELECT * FROM staged
    QUALIFY ROW_NUMBER() OVER (PARTITION BY hk_invoice, hashdiff ORDER BY load_datetime) = 1
)
SELECT d.* FROM deduped d
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_invoice = d.hk_invoice
      AND t.hashdiff = d.hashdiff
)
{% endif %}
