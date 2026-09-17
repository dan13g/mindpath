{{ config(materialized='table') }}
SELECT hk_specialism AS specialism_key, specialism
FROM {{ ref('hub_specialism') }}
