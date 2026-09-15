{{ config(materialized='view') }}
SELECT h.hk_service, h.service_id, s.service_name, s.service_category,
       s.load_datetime AS satellite_load_datetime, s.record_source
FROM {{ ref('hub_service') }} h
LEFT JOIN {{ ref('sat_service_details') }} s ON h.hk_service=s.hk_service
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.hk_service ORDER BY s.load_datetime DESC)=1
