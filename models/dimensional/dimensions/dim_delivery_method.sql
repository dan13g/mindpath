{{ config(materialized='table') }}
SELECT DISTINCT MD5('DELIVERY_METHOD|' || UPPER(TRIM(delivery_method))) AS delivery_method_key,
       UPPER(TRIM(delivery_method)) AS delivery_method
FROM {{ ref('bv_session_current') }}
WHERE delivery_method IS NOT NULL
