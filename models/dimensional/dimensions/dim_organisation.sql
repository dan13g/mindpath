{{ config(materialized='table') }}
SELECT hk_organisation AS organisation_key, organisation_id, organisation_name,
       organisation_type, organisation_status
FROM {{ ref('bv_organisation_current') }}
