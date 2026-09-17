{{ config(materialized='table') }}
WITH client_map AS (
    SELECT hk_referral, MIN(hk_master_client) AS client_key
    FROM {{ ref('bridge_master_client_referral') }} GROUP BY hk_referral
), service_map AS (
    SELECT rt.hk_referral, MIN(ts.hk_service) AS service_key
    FROM {{ ref('lnk_referral_treatment_plan') }} rt
    JOIN {{ ref('lnk_treatment_plan_service') }} ts ON rt.hk_treatment_plan=ts.hk_treatment_plan
    GROUP BY rt.hk_referral
)
SELECT
    j.hk_referral AS referral_key,
    j.referral_id,
    cm.client_key,
    ro.hk_organisation AS organisation_key,
    rc.hk_contract AS contract_key,
    sm.service_key,
    TO_NUMBER(TO_CHAR(j.referral_date,'YYYYMMDD')) AS referral_date_key,
    TO_NUMBER(TO_CHAR(j.first_assessment_date,'YYYYMMDD')) AS first_assessment_date_key,
    TO_NUMBER(TO_CHAR(j.first_session_date,'YYYYMMDD')) AS first_session_date_key,
    1 AS referral_count,
    IFF(j.first_assessment_date IS NOT NULL,1,0) AS assessed_referral_count,
    IFF(j.first_session_date IS NOT NULL,1,0) AS started_treatment_count,
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
LEFT JOIN client_map cm ON j.hk_referral=cm.hk_referral
LEFT JOIN {{ ref('lnk_referral_organisation') }} ro ON j.hk_referral=ro.hk_referral
LEFT JOIN {{ ref('lnk_referral_contract') }} rc ON j.hk_referral=rc.hk_referral
LEFT JOIN service_map sm ON j.hk_referral=sm.hk_referral
