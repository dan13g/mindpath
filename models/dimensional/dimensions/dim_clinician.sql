{{ config(materialized='table') }}
SELECT hk_clinician AS clinician_key, clinician_id, clinician_name, clinician_type,
       active_flag, region, primary_language
FROM {{ ref('bv_clinician_current') }}
