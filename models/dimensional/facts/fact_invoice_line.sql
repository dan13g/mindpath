{{ config(materialized='table') }}

WITH invoice_relationship AS (
    SELECT hk_invoice_line, MIN(hk_invoice) AS hk_invoice
    FROM {{ ref('lnk_invoice_invoice_line') }}
    GROUP BY hk_invoice_line
),
referral_relationship AS (
    SELECT hk_invoice_line, MIN(hk_referral) AS hk_referral
    FROM {{ ref('lnk_invoice_line_referral') }}
    GROUP BY hk_invoice_line
),
service_relationship AS (
    SELECT hk_invoice_line, MIN(hk_service) AS hk_service
    FROM {{ ref('lnk_invoice_line_service') }}
    GROUP BY hk_invoice_line
),
session_relationship AS (
    SELECT
        ls.hk_invoice_line,
        MIN(h.session_id) AS session_id
    FROM {{ ref('lnk_invoice_line_session') }} ls
    LEFT JOIN {{ ref('hub_session') }} h
      ON ls.hk_session = h.hk_session
    GROUP BY ls.hk_invoice_line
),
invoice_context AS (
    SELECT
        ir.hk_invoice_line,
        ir.hk_invoice,
        i.invoice_date,
        MIN(io.hk_organisation) AS hk_organisation,
        MIN(ic.hk_contract) AS hk_contract
    FROM invoice_relationship ir
    LEFT JOIN {{ ref('bv_invoice_current') }} i
      ON ir.hk_invoice = i.hk_invoice
    LEFT JOIN {{ ref('lnk_invoice_organisation') }} io
      ON ir.hk_invoice = io.hk_invoice
    LEFT JOIN {{ ref('lnk_invoice_contract') }} ic
      ON ir.hk_invoice = ic.hk_invoice
    GROUP BY ir.hk_invoice_line, ir.hk_invoice, i.invoice_date
)

SELECT
    l.hk_invoice_line AS invoice_line_key,
    l.invoice_line_id,

    di.invoice_key,
    dr.referral_key,
    ds.service_key,
    do.organisation_key,
    dc.contract_key,
    dd.date_key AS invoice_date_key,

    -- Session is an event/fact, so expose its business id as a degenerate
    -- dimension rather than pointing FACT_INVOICE_LINE at FACT_SESSION.
    sr.session_id,

    1 AS invoice_line_count,
    l.quantity,
    l.unit_price,
    l.line_amount

FROM {{ ref('bv_invoice_line_current') }} l

LEFT JOIN invoice_context ix
  ON l.hk_invoice_line = ix.hk_invoice_line
LEFT JOIN {{ ref('dim_invoice') }} di
  ON ix.hk_invoice = di.invoice_key

LEFT JOIN referral_relationship rr
  ON l.hk_invoice_line = rr.hk_invoice_line
LEFT JOIN {{ ref('dim_referral') }} dr
  ON rr.hk_referral = dr.referral_key

LEFT JOIN service_relationship svr
  ON l.hk_invoice_line = svr.hk_invoice_line
LEFT JOIN {{ ref('dim_service') }} ds
  ON svr.hk_service = ds.service_key

LEFT JOIN {{ ref('dim_organisation') }} do
  ON ix.hk_organisation = do.organisation_key
LEFT JOIN {{ ref('dim_contract') }} dc
  ON ix.hk_contract = dc.contract_key

LEFT JOIN {{ ref('dim_date') }} dd
  ON ix.invoice_date = dd.date_day

LEFT JOIN session_relationship sr
  ON l.hk_invoice_line = sr.hk_invoice_line
