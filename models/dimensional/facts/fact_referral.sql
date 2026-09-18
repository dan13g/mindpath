{{ config(materialized='table') }}

WITH client_relationship AS (
    SELECT
        b.hk_referral,
        MIN(b.hk_master_client) AS hk_master_client
    FROM {{ ref('bridge_master_client_referral') }} b
    GROUP BY b.hk_referral
),
organisation_relationship AS (
    SELECT
        hk_referral,
        MIN(hk_organisation) AS hk_organisation
    FROM {{ ref('lnk_referral_organisation') }}
    GROUP BY hk_referral
),
contract_relationship AS (
    SELECT
        hk_referral,
        MIN(hk_contract) AS hk_contract
    FROM {{ ref('lnk_referral_contract') }}
    GROUP BY hk_referral
),
service_relationship AS (
    SELECT
        rt.hk_referral,
        MIN(ts.hk_service) AS hk_service
    FROM {{ ref('lnk_referral_treatment_plan') }} rt
    JOIN {{ ref('lnk_treatment_plan_service') }} ts
      ON rt.hk_treatment_plan = ts.hk_treatment_plan
    GROUP BY rt.hk_referral
)

SELECT
    dr.referral_key,
    j.referral_id,
    dc.client_key,
    do.organisation_key,
    dco.contract_key,
    ds.service_key,
    d_ref.date_key AS referral_date_key,
    d_ass.date_key AS first_assessment_date_key,
    d_sess.date_key AS first_session_date_key,

    1 AS referral_count,
    IFF(j.first_assessment_date IS NOT NULL, 1, 0) AS assessed_referral_count,
    IFF(j.first_session_date IS NOT NULL, 1, 0) AS started_treatment_count,

    j.total_sessions,
    j.completed_sessions,
    j.dna_sessions,
    j.days_to_assessment,
    j.days_to_allocation,
    j.days_to_first_session,
    j.authorised_sessions,
    j.remaining_sessions,
    j.total_billed

FROM {{ ref('bv_client_journey') }} j

-- Resolve the referral itself through DIM_REFERRAL.
JOIN {{ ref('dim_referral') }} dr
  ON j.hk_referral = dr.referral_key

-- Raw/BV structures establish relationships; dimensions provide fact FKs.
LEFT JOIN client_relationship cr
  ON j.hk_referral = cr.hk_referral
LEFT JOIN {{ ref('dim_client') }} dc
  ON cr.hk_master_client = dc.client_key

LEFT JOIN organisation_relationship org_r
  ON j.hk_referral = org_r.hk_referral
LEFT JOIN {{ ref('dim_organisation') }} do
  ON org_r.hk_organisation = do.organisation_key

LEFT JOIN contract_relationship con_r
  ON j.hk_referral = con_r.hk_referral
LEFT JOIN {{ ref('dim_contract') }} dco
  ON con_r.hk_contract = dco.contract_key

LEFT JOIN service_relationship svc_r
  ON j.hk_referral = svc_r.hk_referral
LEFT JOIN {{ ref('dim_service') }} ds
  ON svc_r.hk_service = ds.service_key

LEFT JOIN {{ ref('dim_date') }} d_ref
  ON j.referral_date = d_ref.date_day
LEFT JOIN {{ ref('dim_date') }} d_ass
  ON j.first_assessment_date = d_ass.date_day
LEFT JOIN {{ ref('dim_date') }} d_sess
  ON j.first_session_date = d_sess.date_day
