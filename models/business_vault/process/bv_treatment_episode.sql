{{ config(materialized='table') }}
WITH plan AS (
 SELECT l.hk_referral, MIN(p.plan_start_date) plan_start_date, MAX(p.recommended_sessions) recommended_sessions
 FROM {{ ref('lnk_referral_treatment_plan') }} l JOIN {{ ref('bv_treatment_plan_current') }} p ON l.hk_treatment_plan=p.hk_treatment_plan GROUP BY l.hk_referral
), auth AS (
 SELECT hk_referral,authorised_sessions,authorised_amount,completed_sessions,remaining_sessions,utilisation_status FROM {{ ref('bv_authorisation_utilisation') }}
), outc AS (
 SELECT hk_referral,
        MAX(IFF(UPPER(measure_name)='PHQ9',baseline_score,NULL)) baseline_phq9,
        MAX(IFF(UPPER(measure_name)='PHQ9',latest_score,NULL)) latest_phq9,
        MAX(IFF(UPPER(measure_name)='PHQ9',score_improvement,NULL)) phq9_improvement,
        MAX(latest_date) latest_outcome_date
 FROM {{ ref('bv_outcome_summary') }} GROUP BY hk_referral
)
SELECT l.*,p.plan_start_date,p.recommended_sessions,a.authorised_sessions,a.authorised_amount,a.remaining_sessions,a.utilisation_status,
       o.baseline_phq9,o.latest_phq9,o.phq9_improvement,o.latest_outcome_date
FROM {{ ref('bv_referral_lifecycle') }} l LEFT JOIN plan p ON l.hk_referral=p.hk_referral
LEFT JOIN auth a ON l.hk_referral=a.hk_referral LEFT JOIN outc o ON l.hk_referral=o.hk_referral
