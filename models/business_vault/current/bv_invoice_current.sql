{{ config(materialized='view') }}
SELECT h.hk_invoice, h.invoice_id, s.invoice_date, s.invoice_status,
       s.load_datetime AS satellite_load_datetime, s.record_source
FROM {{ ref('hub_invoice') }} h
LEFT JOIN {{ ref('sat_invoice_details') }} s ON h.hk_invoice=s.hk_invoice
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.hk_invoice ORDER BY s.load_datetime DESC)=1
