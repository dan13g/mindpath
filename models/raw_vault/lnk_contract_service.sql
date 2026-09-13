{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        hk_contract_service AS hk_contract_service,
        hk_contract,
        hk_service,
        load_datetime,
        record_source
    FROM {{ ref('stg_contract_services') }}
    WHERE contract_id IS NOT NULL AND service_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_contract_service = i.hk_contract_service
)
{% endif %}
