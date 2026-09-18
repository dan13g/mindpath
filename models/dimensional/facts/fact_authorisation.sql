{{ config(materialized='table') }}

WITH referral_relationship AS (
    SELECT hk_authorisation, MIN(hk_referral) AS hk_referral
    FROM {{ ref('lnk_referral_authorisation') }}
    GROUP BY hk_authorisation
),
contract_relationship AS (
    SELECT hk_authorisation, MIN(hk_contract) AS hk_contract
    FROM {{ ref('lnk_authorisation_contract') }}
    GROUP BY hk_authorisation
)

SELECT
    a.hk_authorisation AS authorisation_key,
    a.authorisation_id,
    dr.referral_key,
    dc.contract_key,
    dauth.date_key AS authorisation_date_key,
    dexp.date_key AS expiry_date_key,
    1 AS authorisation_count,
    a.authorised_sessions,
    a.authorised_amount,
    a.authorisation_status

FROM {{ ref('bv_authorisation_current') }} a

LEFT JOIN referral_relationship rr
  ON a.hk_authorisation = rr.hk_authorisation
LEFT JOIN {{ ref('dim_referral') }} dr
  ON rr.hk_referral = dr.referral_key

LEFT JOIN contract_relationship cr
  ON a.hk_authorisation = cr.hk_authorisation
LEFT JOIN {{ ref('dim_contract') }} dc
  ON cr.hk_contract = dc.contract_key

LEFT JOIN {{ ref('dim_date') }} dauth
  ON a.authorisation_date = dauth.date_day
LEFT JOIN {{ ref('dim_date') }} dexp
  ON a.expiry_date = dexp.date_day
