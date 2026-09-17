{{ config(materialized='table') }}
WITH org AS (SELECT hk_invoice,MIN(hk_organisation) organisation_key FROM {{ ref('lnk_invoice_organisation') }} GROUP BY hk_invoice),
contract AS (SELECT hk_invoice,MIN(hk_contract) contract_key FROM {{ ref('lnk_invoice_contract') }} GROUP BY hk_invoice)
SELECT i.hk_invoice AS invoice_key,i.invoice_id,o.organisation_key,c.contract_key,
       TO_NUMBER(TO_CHAR(i.invoice_date,'YYYYMMDD')) invoice_date_key,
       1 invoice_count,i.invoice_status,i.invoice_line_count,i.invoice_amount
FROM {{ ref('bv_invoice_summary') }} i
LEFT JOIN org o ON i.hk_invoice=o.hk_invoice LEFT JOIN contract c ON i.hk_invoice=c.hk_invoice
