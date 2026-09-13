{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        hk_contract,
        contract_id,
        load_datetime,
        record_source
    FROM {{ ref('stg_contracts') }}
    WHERE contract_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_contract = i.hk_contract
)
{% endif %}
