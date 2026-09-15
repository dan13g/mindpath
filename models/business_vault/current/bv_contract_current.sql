{{ config(materialized='view') }}
SELECT h.hk_contract, h.contract_id, s.contract_name, s.start_date, s.end_date,
       s.status AS contract_status, s.billing_method, s.load_datetime AS satellite_load_datetime, s.record_source
FROM {{ ref('hub_contract') }} h
LEFT JOIN {{ ref('sat_contract_details') }} s ON h.hk_contract=s.hk_contract
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.hk_contract ORDER BY s.load_datetime DESC)=1
