{{ config(materialized='view') }}
SELECT
    h.hk_client, h.client_id,
    s.nhs_number, s.first_name, s.last_name, s.date_of_birth,
    s.email, s.mobile, s.postcode, s.created_date, s.source_system,
    s.load_datetime AS satellite_load_datetime, s.record_source
FROM {{ ref('hub_client') }} h
LEFT JOIN {{ ref('sat_client_details') }} s ON h.hk_client = s.hk_client
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.hk_client ORDER BY s.load_datetime DESC) = 1
