{{ config(materialized='view') }}
SELECT h.hk_session, h.session_id, s.session_date, s.session_status, s.delivery_method,
       s.duration_minutes, s.load_datetime AS satellite_load_datetime, s.record_source
FROM {{ ref('hub_session') }} h
LEFT JOIN {{ ref('sat_session_details') }} s ON h.hk_session=s.hk_session
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.hk_session ORDER BY s.load_datetime DESC)=1
