{{ config(materialized='table') }}
SELECT hk_service AS service_key, service_id, service_name, service_category
FROM {{ ref('bv_service_current') }}
