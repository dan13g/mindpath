{{ config(materialized='table') }}
WITH referral AS (SELECT hk_session,MIN(hk_referral) referral_key FROM {{ ref('lnk_referral_session') }} GROUP BY hk_session),
client AS (
 SELECT cs.hk_session,MIN(m.hk_master_client) client_key FROM {{ ref('lnk_client_session') }} cs
 LEFT JOIN {{ ref('bv_master_client') }} m ON cs.hk_client=m.source_hk_client GROUP BY cs.hk_session
), clinician AS (SELECT hk_session,MIN(hk_clinician) clinician_key FROM {{ ref('lnk_clinician_session') }} GROUP BY hk_session),
service AS (SELECT hk_session,MIN(hk_service) service_key FROM {{ ref('lnk_session_service') }} GROUP BY hk_session)
SELECT s.hk_session AS session_key,s.session_id,r.referral_key,c.client_key,cl.clinician_key,sv.service_key,
       TO_NUMBER(TO_CHAR(s.session_date,'YYYYMMDD')) session_date_key,
       MD5('SESSION_STATUS|' || UPPER(TRIM(s.session_status))) session_status_key,
       IFF(s.delivery_method IS NULL,NULL,MD5('DELIVERY_METHOD|' || UPPER(TRIM(s.delivery_method)))) delivery_method_key,
       1 session_count,IFF(UPPER(s.session_status)='COMPLETED',1,0) completed_session_count,
       IFF(UPPER(s.session_status) IN ('DNA','DID_NOT_ATTEND'),1,0) dna_session_count,
       s.duration_minutes
FROM {{ ref('bv_session_current') }} s
LEFT JOIN referral r ON s.hk_session=r.hk_session LEFT JOIN client c ON s.hk_session=c.hk_session
LEFT JOIN clinician cl ON s.hk_session=cl.hk_session LEFT JOIN service sv ON s.hk_session=sv.hk_session
