{{ config(materialized='view') }}
SELECT h.hk_organisation, h.organisation_id, s.organisation_name, s.organisation_type,
       s.status AS organisation_status, s.load_datetime AS satellite_load_datetime, s.record_source
FROM {{ ref('hub_organisation') }} h
LEFT JOIN {{ ref('sat_organisation_details') }} s ON h.hk_organisation=s.hk_organisation
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.hk_organisation ORDER BY s.load_datetime DESC)=1
