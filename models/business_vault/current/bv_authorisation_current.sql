{{ config(materialized='view') }}
SELECT h.hk_authorisation, h.authorisation_id, s.authorisation_date, s.authorised_sessions,
       s.authorised_amount, s.expiry_date, s.status AS authorisation_status,
       s.load_datetime AS satellite_load_datetime, s.record_source
FROM {{ ref('hub_authorisation') }} h
LEFT JOIN {{ ref('sat_authorisation_details') }} s ON h.hk_authorisation=s.hk_authorisation
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.hk_authorisation ORDER BY s.load_datetime DESC)=1
