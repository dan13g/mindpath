{{ config(materialized='view') }}

WITH latest AS (
    SELECT
        hk_client,
        nhs_number,
        first_name,
        last_name,
        date_of_birth,
        email,
        mobile,
        postcode,
        source_system,
        load_datetime,
        record_source
    FROM {{ ref('sat_client_details') }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_client
        ORDER BY load_datetime DESC
    ) = 1
)

SELECT
    h.hk_client,
    h.client_id,
    s.nhs_number,
    s.first_name,
    s.last_name,
    s.date_of_birth,
    s.email,
    s.mobile,
    s.postcode,
    s.source_system,
    s.load_datetime AS satellite_load_datetime,
    COALESCE(s.record_source, h.record_source) AS record_source
FROM {{ ref('hub_client') }} h
LEFT JOIN latest s
    ON h.hk_client = s.hk_client
