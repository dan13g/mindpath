{{ config(materialized='table') }}
-- Grain: one row per referral. Child collections are aggregated before joining to avoid fanout.
WITH client_map AS (
 SELECT cr.hk_referral,m.hk_master_client,m.master_client_id,m.source_client_id,m.first_name,m.last_name,m.date_of_birth,m.nhs_number,m.email,m.mobile
 FROM {{ ref('lnk_client_referral') }} cr JOIN {{ ref('bv_master_client') }} m ON cr.hk_client=m.source_hk_client
), clinician AS (
 SELECT ra.hk_referral,MIN(a.allocation_date) first_allocation_date,
        MIN_BY(c.clinician_id,a.allocation_date) clinician_id,MIN_BY(c.clinician_name,a.allocation_date) clinician_name
 FROM {{ ref('lnk_referral_allocation') }} ra
 JOIN {{ ref('bv_allocation_current') }} a ON ra.hk_allocation=a.hk_allocation
 LEFT JOIN {{ ref('lnk_allocation_clinician') }} ac ON a.hk_allocation=ac.hk_allocation
 LEFT JOIN {{ ref('bv_clinician_current') }} c ON ac.hk_clinician=c.hk_clinician GROUP BY ra.hk_referral
), service AS (
 SELECT rt.hk_referral,MIN(s.service_id) service_id,MIN(s.service_name) service_name
 FROM {{ ref('lnk_referral_treatment_plan') }} rt
 JOIN {{ ref('lnk_treatment_plan_service') }} ts ON rt.hk_treatment_plan=ts.hk_treatment_plan
 JOIN {{ ref('bv_service_current') }} s ON ts.hk_service=s.hk_service GROUP BY rt.hk_referral
)
SELECT c.hk_master_client,c.master_client_id,c.source_client_id,c.first_name,c.last_name,c.date_of_birth,c.nhs_number,c.email,c.mobile,
       e.hk_referral,e.referral_id,e.referral_date,e.referral_status,e.priority,e.funding_type,
       e.organisation_id,e.organisation_name,e.contract_id,e.contract_name,e.billing_method,
       sv.service_id,sv.service_name,e.first_assessment_date,cl.first_allocation_date,cl.clinician_id,cl.clinician_name,
       e.first_session_date,e.last_session_date,e.total_sessions,e.completed_sessions,e.dna_sessions,
       e.recommended_sessions,e.authorised_sessions,e.remaining_sessions,e.utilisation_status,
       e.baseline_phq9,e.latest_phq9,e.phq9_improvement,e.latest_outcome_date,
       COALESCE(f.invoice_count,0) invoice_count,COALESCE(f.invoice_line_count,0) invoice_line_count,COALESCE(f.total_billed,0) total_billed,
       e.days_to_assessment,e.days_to_allocation,e.days_to_first_session
FROM {{ ref('bv_treatment_episode') }} e
LEFT JOIN client_map c ON e.hk_referral=c.hk_referral LEFT JOIN clinician cl ON e.hk_referral=cl.hk_referral
LEFT JOIN service sv ON e.hk_referral=sv.hk_referral LEFT JOIN {{ ref('bv_referral_finance') }} f ON e.hk_referral=f.hk_referral
