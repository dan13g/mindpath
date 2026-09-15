{{ config(materialized='table') }}
-- Training PIT: one row per client pointing at the latest client satellite version as of this build.
SELECT h.hk_client, h.client_id,
       MAX(s.load_datetime) AS sat_client_details_load_datetime,
       CURRENT_TIMESTAMP() AS pit_created_datetime
FROM {{ ref('hub_client') }} h
LEFT JOIN {{ ref('sat_client_details') }} s ON h.hk_client=s.hk_client
GROUP BY h.hk_client,h.client_id
