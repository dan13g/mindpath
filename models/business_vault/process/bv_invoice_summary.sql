{{ config(materialized='table') }}
WITH lines AS (
 SELECT il.hk_invoice,COUNT(DISTINCT il.hk_invoice_line) invoice_line_count,
        SUM(COALESCE(d.line_amount,0)) invoice_amount
 FROM {{ ref('lnk_invoice_invoice_line') }} il
 JOIN {{ ref('bv_invoice_line_current') }} d ON il.hk_invoice_line=d.hk_invoice_line GROUP BY il.hk_invoice
), org AS (
 SELECT l.hk_invoice,o.organisation_id,o.organisation_name FROM {{ ref('lnk_invoice_organisation') }} l JOIN {{ ref('bv_organisation_current') }} o ON l.hk_organisation=o.hk_organisation
), con AS (
 SELECT l.hk_invoice,c.contract_id,c.contract_name FROM {{ ref('lnk_invoice_contract') }} l JOIN {{ ref('bv_contract_current') }} c ON l.hk_contract=c.hk_contract
)
SELECT i.hk_invoice,i.invoice_id,i.invoice_date,i.invoice_status,o.organisation_id,o.organisation_name,c.contract_id,c.contract_name,
       COALESCE(l.invoice_line_count,0) invoice_line_count,COALESCE(l.invoice_amount,0) invoice_amount
FROM {{ ref('bv_invoice_current') }} i LEFT JOIN lines l ON i.hk_invoice=l.hk_invoice LEFT JOIN org o ON i.hk_invoice=o.hk_invoice LEFT JOIN con c ON i.hk_invoice=c.hk_invoice
