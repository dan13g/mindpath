{{ config(materialized='table') }}
WITH x AS (
 SELECT r.hk_referral, il.hk_invoice_line, ii.hk_invoice, d.line_amount
 FROM {{ ref('lnk_invoice_line_referral') }} r
 JOIN {{ ref('bv_invoice_line_current') }} d ON r.hk_invoice_line=d.hk_invoice_line
 LEFT JOIN {{ ref('lnk_invoice_invoice_line') }} ii ON r.hk_invoice_line=ii.hk_invoice_line
)
SELECT hk_referral,COUNT(DISTINCT hk_invoice) invoice_count,COUNT(DISTINCT hk_invoice_line) invoice_line_count,
       SUM(COALESCE(line_amount,0)) total_billed
FROM x GROUP BY hk_referral
