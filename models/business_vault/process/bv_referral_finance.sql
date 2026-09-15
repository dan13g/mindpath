{{ config(materialized='table') }}

WITH referral_lines AS (
    SELECT DISTINCT
        hk_referral,
        hk_invoice_line
    FROM {{ ref('lnk_invoice_line_referral') }}
),

invoice_for_line AS (
    SELECT
        hk_invoice_line,
        MIN(hk_invoice) AS hk_invoice
    FROM {{ ref('lnk_invoice_invoice_line') }}
    GROUP BY hk_invoice_line
),

line_values AS (
    SELECT
        hk_invoice_line,
        line_amount
    FROM {{ ref('bv_invoice_line_current') }}
),

combined AS (
    SELECT
        rl.hk_referral,
        rl.hk_invoice_line,
        ifl.hk_invoice,
        lv.line_amount
    FROM referral_lines rl
    LEFT JOIN invoice_for_line ifl
        ON rl.hk_invoice_line = ifl.hk_invoice_line
    LEFT JOIN line_values lv
        ON rl.hk_invoice_line = lv.hk_invoice_line
)

SELECT
    hk_referral,
    COUNT(DISTINCT hk_invoice) AS invoice_count,
    COUNT(DISTINCT hk_invoice_line) AS invoice_line_count,
    SUM(COALESCE(line_amount, 0)) AS total_billed
FROM combined
GROUP BY hk_referral
