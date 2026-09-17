{{ config(materialized='table') }}
WITH invoice AS (SELECT hk_invoice_line,MIN(hk_invoice) invoice_key FROM {{ ref('lnk_invoice_invoice_line') }} GROUP BY hk_invoice_line),
referral AS (SELECT hk_invoice_line,MIN(hk_referral) referral_key FROM {{ ref('lnk_invoice_line_referral') }} GROUP BY hk_invoice_line),
session AS (SELECT hk_invoice_line,MIN(hk_session) session_key FROM {{ ref('lnk_invoice_line_session') }} GROUP BY hk_invoice_line),
service AS (SELECT hk_invoice_line,MIN(hk_service) service_key FROM {{ ref('lnk_invoice_line_service') }} GROUP BY hk_invoice_line)
SELECT l.hk_invoice_line AS invoice_line_key,l.invoice_line_id,i.invoice_key,r.referral_key,s.session_key,sv.service_key,
       1 invoice_line_count,l.quantity,l.unit_price,l.line_amount
FROM {{ ref('bv_invoice_line_current') }} l
LEFT JOIN invoice i ON l.hk_invoice_line=i.hk_invoice_line LEFT JOIN referral r ON l.hk_invoice_line=r.hk_invoice_line
LEFT JOIN session s ON l.hk_invoice_line=s.hk_invoice_line LEFT JOIN service sv ON l.hk_invoice_line=sv.hk_invoice_line
