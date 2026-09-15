{{ config(materialized='view') }}
SELECT h.hk_invoice_line, h.invoice_line_id, s.quantity, s.unit_price, s.line_amount,
       s.load_datetime AS satellite_load_datetime, s.record_source
FROM {{ ref('hub_invoice_line') }} h
LEFT JOIN {{ ref('sat_invoice_line_details') }} s ON h.hk_invoice_line=s.hk_invoice_line
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.hk_invoice_line ORDER BY s.load_datetime DESC)=1
