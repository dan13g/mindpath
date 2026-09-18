{{ config(materialized='table') }}

SELECT
    hk_invoice AS invoice_key,
    invoice_id,
    invoice_date,
    invoice_status
FROM {{ ref('bv_invoice_current') }}
