{{ config(materialized='table') }}
WITH referral AS (
 SELECT hk_authorisation,MIN(hk_referral) referral_key FROM {{ ref('lnk_referral_authorisation') }} GROUP BY hk_authorisation
), contract AS (
 SELECT hk_authorisation,MIN(hk_contract) contract_key FROM {{ ref('lnk_authorisation_contract') }} GROUP BY hk_authorisation
)
SELECT a.hk_authorisation AS authorisation_key,a.authorisation_id,r.referral_key,c.contract_key,
       TO_NUMBER(TO_CHAR(a.authorisation_date,'YYYYMMDD')) authorisation_date_key,
       TO_NUMBER(TO_CHAR(a.expiry_date,'YYYYMMDD')) expiry_date_key,
       1 authorisation_count,a.authorised_sessions,a.authorised_amount,
       a.authorisation_status
FROM {{ ref('bv_authorisation_current') }} a
LEFT JOIN referral r ON a.hk_authorisation=r.hk_authorisation
LEFT JOIN contract c ON a.hk_authorisation=c.hk_authorisation
