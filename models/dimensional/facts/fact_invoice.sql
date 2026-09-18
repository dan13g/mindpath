{{ config(materialized='table') }}

WITH organisation_relationship AS (
    SELECT hk_invoice, MIN(hk_organisation) AS hk_organisation
    FROM {{ ref('lnk_invoice_organisation') }}
    GROUP BY hk_invoice
),
contract_relationship AS (
    SELECT hk_invoice, MIN(hk_contract) AS hk_contract
    FROM {{ ref('lnk_invoice_contract') }}
    GROUP BY hk_invoice
)

SELECT
    di.invoice_key,
    i.invoice_id,
    do.organisation_key,
    dc.contract_key,
    dd.date_key AS invoice_date_key,
    1 AS invoice_count,
    i.invoice_status,
    i.invoice_line_count,
    i.invoice_amount

FROM {{ ref('bv_invoice_summary') }} i

JOIN {{ ref('dim_invoice') }} di
  ON i.hk_invoice = di.invoice_key

LEFT JOIN organisation_relationship org_r
  ON i.hk_invoice = org_r.hk_invoice
LEFT JOIN {{ ref('dim_organisation') }} do
  ON org_r.hk_organisation = do.organisation_key

LEFT JOIN contract_relationship con_r
  ON i.hk_invoice = con_r.hk_invoice
LEFT JOIN {{ ref('dim_contract') }} dc
  ON con_r.hk_contract = dc.contract_key

LEFT JOIN {{ ref('dim_date') }} dd
  ON i.invoice_date = dd.date_day
