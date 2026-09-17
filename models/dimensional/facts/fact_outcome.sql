{{ config(materialized='table') }}
WITH referral AS (SELECT hk_outcome,MIN(hk_referral) referral_key FROM {{ ref('lnk_referral_outcome') }} GROUP BY hk_outcome),
client AS (
 SELECT co.hk_outcome,MIN(m.hk_master_client) client_key FROM {{ ref('lnk_client_outcome') }} co
 LEFT JOIN {{ ref('bv_master_client') }} m ON co.hk_client=m.source_hk_client GROUP BY co.hk_outcome
), session AS (SELECT hk_outcome,MIN(hk_session) session_key FROM {{ ref('lnk_session_outcome') }} GROUP BY hk_outcome)
SELECT o.hk_outcome AS outcome_key,o.outcome_id,r.referral_key,c.client_key,s.session_key,
       MD5('OUTCOME_MEASURE|' || UPPER(TRIM(o.measure_name))) outcome_measure_key,
       TO_NUMBER(TO_CHAR(o.measurement_date,'YYYYMMDD')) measurement_date_key,
       1 outcome_count,o.score
FROM {{ ref('bv_outcome_current') }} o
LEFT JOIN referral r ON o.hk_outcome=r.hk_outcome LEFT JOIN client c ON o.hk_outcome=c.hk_outcome LEFT JOIN session s ON o.hk_outcome=s.hk_outcome
