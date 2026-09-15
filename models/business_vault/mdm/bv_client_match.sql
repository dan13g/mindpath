{{ config(materialized='table') }}
WITH c AS (
  SELECT *,
    NULLIF(REGEXP_REPLACE(UPPER(TRIM(nhs_number)), '[^0-9A-Z]', ''), '') AS norm_nhs,
    NULLIF(LOWER(TRIM(email)), '') AS norm_email,
    NULLIF(REGEXP_REPLACE(mobile, '[^0-9]', ''), '') AS norm_mobile
  FROM {{ ref('bv_client_current') }}
), pairs AS (
  SELECT a.hk_client AS hk_client_a, b.hk_client AS hk_client_b,
         a.client_id AS client_id_a, b.client_id AS client_id_b,
         CASE
           WHEN a.norm_nhs IS NOT NULL AND a.norm_nhs=b.norm_nhs THEN 'NHS_EXACT'
           WHEN a.date_of_birth=b.date_of_birth AND a.norm_mobile IS NOT NULL AND a.norm_mobile=b.norm_mobile THEN 'DOB_MOBILE'
           WHEN a.date_of_birth=b.date_of_birth AND a.norm_email IS NOT NULL AND a.norm_email=b.norm_email THEN 'DOB_EMAIL'
         END AS match_rule
  FROM c a JOIN c b ON a.client_id < b.client_id
  WHERE (a.norm_nhs IS NOT NULL AND a.norm_nhs=b.norm_nhs)
     OR (a.date_of_birth=b.date_of_birth AND a.norm_mobile IS NOT NULL AND a.norm_mobile=b.norm_mobile)
     OR (a.date_of_birth=b.date_of_birth AND a.norm_email IS NOT NULL AND a.norm_email=b.norm_email)
)
SELECT * FROM pairs
