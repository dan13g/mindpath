{{ config(materialized='table') }}
WITH auth AS (
 SELECT ra.hk_referral, MAX(a.authorised_sessions) AS authorised_sessions, MAX(a.authorised_amount) AS authorised_amount
 FROM {{ ref('lnk_referral_authorisation') }} ra
 JOIN {{ ref('bv_authorisation_current') }} a ON ra.hk_authorisation=a.hk_authorisation
 GROUP BY ra.hk_referral
), sess AS (
 SELECT rs.hk_referral, COUNT_IF(s.session_status='COMPLETED') AS completed_sessions
 FROM {{ ref('lnk_referral_session') }} rs
 JOIN {{ ref('bv_session_current') }} s ON rs.hk_session=s.hk_session
 GROUP BY rs.hk_referral
)
SELECT COALESCE(a.hk_referral,s.hk_referral) hk_referral,a.authorised_sessions,a.authorised_amount,
       COALESCE(s.completed_sessions,0) completed_sessions,
       a.authorised_sessions-COALESCE(s.completed_sessions,0) remaining_sessions,
       CASE WHEN a.authorised_sessions IS NULL THEN 'NO_AUTHORISATION'
            WHEN COALESCE(s.completed_sessions,0)>a.authorised_sessions THEN 'OVER_USED'
            WHEN COALESCE(s.completed_sessions,0)=a.authorised_sessions THEN 'FULLY_USED'
            WHEN COALESCE(s.completed_sessions,0)=0 THEN 'NOT_USED' ELSE 'PART_USED' END utilisation_status
FROM auth a FULL OUTER JOIN sess s ON a.hk_referral=s.hk_referral
