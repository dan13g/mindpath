{{ config(materialized='table') }}
WITH sat AS (
 SELECT hk_contract_service,agreed_rate,session_limit
 FROM {{ ref('sat_contract_service_details') }}
 QUALIFY ROW_NUMBER() OVER(PARTITION BY hk_contract_service ORDER BY load_datetime DESC)=1
)
SELECT l.hk_contract AS contract_key,l.hk_service AS service_key,s.agreed_rate,s.session_limit
FROM {{ ref('lnk_contract_service') }} l LEFT JOIN sat s ON l.hk_contract_service=s.hk_contract_service
