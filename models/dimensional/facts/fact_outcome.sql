{{ config(materialized='table') }}

WITH referral_relationship AS (
    SELECT hk_outcome, MIN(hk_referral) AS hk_referral
    FROM {{ ref('lnk_referral_outcome') }}
    GROUP BY hk_outcome
),
client_relationship AS (
    SELECT
        co.hk_outcome,
        MIN(m.hk_master_client) AS hk_master_client
    FROM {{ ref('lnk_client_outcome') }} co
    LEFT JOIN {{ ref('bv_master_client') }} m
      ON co.hk_client = m.source_hk_client
    GROUP BY co.hk_outcome
),
session_relationship AS (
    SELECT
        so.hk_outcome,
        MIN(h.session_id) AS session_id
    FROM {{ ref('lnk_session_outcome') }} so
    LEFT JOIN {{ ref('hub_session') }} h
      ON so.hk_session = h.hk_session
    GROUP BY so.hk_outcome
)

SELECT
    o.hk_outcome AS outcome_key,
    o.outcome_id,
    dr.referral_key,
    dc.client_key,

    -- Session is another event/fact grain, so keep its business id as a
    -- degenerate dimension rather than creating a fact-to-fact FK.
    sr.session_id,

    dom.outcome_measure_key,
    dd.date_key AS measurement_date_key,
    1 AS outcome_count,
    o.score

FROM {{ ref('bv_outcome_current') }} o

LEFT JOIN referral_relationship rr
  ON o.hk_outcome = rr.hk_outcome
LEFT JOIN {{ ref('dim_referral') }} dr
  ON rr.hk_referral = dr.referral_key

LEFT JOIN client_relationship cr
  ON o.hk_outcome = cr.hk_outcome
LEFT JOIN {{ ref('dim_client') }} dc
  ON cr.hk_master_client = dc.client_key

LEFT JOIN session_relationship sr
  ON o.hk_outcome = sr.hk_outcome

LEFT JOIN {{ ref('dim_outcome_measure') }} dom
  ON UPPER(TRIM(o.measure_name)) = dom.measure_name

LEFT JOIN {{ ref('dim_date') }} dd
  ON o.measurement_date = dd.date_day
