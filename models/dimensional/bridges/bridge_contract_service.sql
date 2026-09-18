{{ config(materialized='table') }}

WITH latest_sat AS (
    SELECT
        hk_contract_service,
        agreed_rate,
        session_limit
    FROM {{ ref('sat_contract_service_details') }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_contract_service
        ORDER BY load_datetime DESC
    ) = 1
)

SELECT
    dc.contract_key,
    ds.service_key,
    s.agreed_rate,
    s.session_limit
FROM {{ ref('lnk_contract_service') }} l
JOIN {{ ref('dim_contract') }} dc
  ON l.hk_contract = dc.contract_key
JOIN {{ ref('dim_service') }} ds
  ON l.hk_service = ds.service_key
LEFT JOIN latest_sat s
  ON l.hk_contract_service = s.hk_contract_service
