{{ config(materialized='table') }}
WITH ass AS (
 SELECT l.hk_referral, MIN(a.assessment_date) first_assessment_date
 FROM {{ ref('lnk_referral_assessment') }} l JOIN {{ ref('bv_assessment_current') }} a ON l.hk_assessment=a.hk_assessment GROUP BY l.hk_referral
), alloc AS (
 SELECT l.hk_referral, MIN(a.allocation_date) first_allocation_date
 FROM {{ ref('lnk_referral_allocation') }} l JOIN {{ ref('bv_allocation_current') }} a ON l.hk_allocation=a.hk_allocation GROUP BY l.hk_referral
), sess AS (
 SELECT l.hk_referral, MIN(s.session_date) first_session_date, MAX(s.session_date) last_session_date,
        COUNT(*) total_sessions, COUNT_IF(s.session_status='COMPLETED') completed_sessions,
        COUNT_IF(s.session_status IN ('DNA','DID_NOT_ATTEND')) dna_sessions
 FROM {{ ref('lnk_referral_session') }} l JOIN {{ ref('bv_session_current') }} s ON l.hk_session=s.hk_session GROUP BY l.hk_referral
), org AS (
 SELECT l.hk_referral,o.organisation_id,o.organisation_name FROM {{ ref('lnk_referral_organisation') }} l JOIN {{ ref('bv_organisation_current') }} o ON l.hk_organisation=o.hk_organisation
), con AS (
 SELECT l.hk_referral,c.contract_id,c.contract_name,c.billing_method FROM {{ ref('lnk_referral_contract') }} l JOIN {{ ref('bv_contract_current') }} c ON l.hk_contract=c.hk_contract
)
SELECT r.hk_referral,r.referral_id,r.referral_date,r.referral_status,r.priority,r.funding_type,
       o.organisation_id,o.organisation_name,c.contract_id,c.contract_name,c.billing_method,
       a.first_assessment_date,al.first_allocation_date,s.first_session_date,s.last_session_date,
       COALESCE(s.total_sessions,0) total_sessions,COALESCE(s.completed_sessions,0) completed_sessions,COALESCE(s.dna_sessions,0) dna_sessions,
       DATEDIFF('day',r.referral_date,a.first_assessment_date) days_to_assessment,
       DATEDIFF('day',r.referral_date,al.first_allocation_date) days_to_allocation,
       DATEDIFF('day',r.referral_date,s.first_session_date) days_to_first_session
FROM {{ ref('bv_referral_current') }} r
LEFT JOIN ass a ON r.hk_referral=a.hk_referral LEFT JOIN alloc al ON r.hk_referral=al.hk_referral
LEFT JOIN sess s ON r.hk_referral=s.hk_referral LEFT JOIN org o ON r.hk_referral=o.hk_referral LEFT JOIN con c ON r.hk_referral=c.hk_referral
