{{ config(materialized='table') }}

WITH referral_relationship AS (
    SELECT hk_session, MIN(hk_referral) AS hk_referral
    FROM {{ ref('lnk_referral_session') }}
    GROUP BY hk_session
),
client_relationship AS (
    SELECT
        cs.hk_session,
        MIN(m.hk_master_client) AS hk_master_client
    FROM {{ ref('lnk_client_session') }} cs
    LEFT JOIN {{ ref('bv_master_client') }} m
      ON cs.hk_client = m.source_hk_client
    GROUP BY cs.hk_session
),
clinician_relationship AS (
    SELECT hk_session, MIN(hk_clinician) AS hk_clinician
    FROM {{ ref('lnk_clinician_session') }}
    GROUP BY hk_session
),
service_relationship AS (
    SELECT hk_session, MIN(hk_service) AS hk_service
    FROM {{ ref('lnk_session_service') }}
    GROUP BY hk_session
)

SELECT
    s.hk_session AS session_key,
    s.session_id,

    dr.referral_key,
    dc.client_key,
    dcl.clinician_key,
    dsv.service_key,
    dd.date_key AS session_date_key,
    dss.session_status_key,
    ddm.delivery_method_key,

    1 AS session_count,
    IFF(UPPER(s.session_status) = 'COMPLETED', 1, 0) AS completed_session_count,
    IFF(UPPER(s.session_status) IN ('DNA','DID_NOT_ATTEND'), 1, 0) AS dna_session_count,
    s.duration_minutes

FROM {{ ref('bv_session_current') }} s

LEFT JOIN referral_relationship rr
  ON s.hk_session = rr.hk_session
LEFT JOIN {{ ref('dim_referral') }} dr
  ON rr.hk_referral = dr.referral_key

LEFT JOIN client_relationship cr
  ON s.hk_session = cr.hk_session
LEFT JOIN {{ ref('dim_client') }} dc
  ON cr.hk_master_client = dc.client_key

LEFT JOIN clinician_relationship clr
  ON s.hk_session = clr.hk_session
LEFT JOIN {{ ref('dim_clinician') }} dcl
  ON clr.hk_clinician = dcl.clinician_key

LEFT JOIN service_relationship sr
  ON s.hk_session = sr.hk_session
LEFT JOIN {{ ref('dim_service') }} dsv
  ON sr.hk_service = dsv.service_key

LEFT JOIN {{ ref('dim_date') }} dd
  ON s.session_date = dd.date_day

LEFT JOIN {{ ref('dim_session_status') }} dss
  ON UPPER(TRIM(s.session_status)) = dss.session_status

LEFT JOIN {{ ref('dim_delivery_method') }} ddm
  ON UPPER(TRIM(s.delivery_method)) = ddm.delivery_method
