{{ config(materialized='view') }}
SELECT h.hk_allocation, h.allocation_id, s.allocation_date, s.allocation_status,
       s.load_datetime AS satellite_load_datetime, s.record_source
FROM {{ ref('hub_allocation') }} h
LEFT JOIN {{ ref('sat_allocation_details') }} s ON h.hk_allocation=s.hk_allocation
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.hk_allocation ORDER BY s.load_datetime DESC)=1
