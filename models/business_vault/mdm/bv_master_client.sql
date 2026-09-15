{{ config(materialized='table') }}
-- Training implementation: deterministic identity token, then a stable master id.
WITH c AS (
  SELECT *,
    NULLIF(REGEXP_REPLACE(UPPER(TRIM(nhs_number)), '[^0-9A-Z]', ''), '') AS norm_nhs,
    NULLIF(LOWER(TRIM(email)), '') AS norm_email,
    NULLIF(REGEXP_REPLACE(mobile, '[^0-9]', ''), '') AS norm_mobile
  FROM {{ ref('bv_client_current') }}
), keyed AS (
  SELECT *,
    CASE
      WHEN norm_nhs IS NOT NULL THEN 'NHS|' || norm_nhs
      WHEN date_of_birth IS NOT NULL AND norm_mobile IS NOT NULL THEN 'DOBMOB|' || TO_VARCHAR(date_of_birth) || '|' || norm_mobile
      WHEN date_of_birth IS NOT NULL AND norm_email IS NOT NULL THEN 'DOBEMAIL|' || TO_VARCHAR(date_of_birth) || '|' || norm_email
      ELSE 'SOURCE|' || TO_VARCHAR(client_id)
    END AS identity_token
  FROM c
), mastered AS (
  SELECT *, MIN(client_id) OVER (PARTITION BY identity_token) AS master_client_id
  FROM keyed
)
SELECT
  MD5('MASTER_CLIENT|' || TO_VARCHAR(master_client_id)) AS hk_master_client,
  master_client_id,
  hk_client AS source_hk_client,
  client_id AS source_client_id,
  identity_token,
  CASE WHEN client_id=master_client_id THEN TRUE ELSE FALSE END AS is_survivor,
  first_name,last_name,date_of_birth,nhs_number,email,mobile,postcode,source_system
FROM mastered
