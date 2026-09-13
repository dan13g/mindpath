{{ config(materialized='incremental') }}
WITH staged AS (
    SELECT
        hk_contract,
        hd_contract AS hashdiff,
        contract_name,
        start_date,
        end_date,
        status,
        billing_method,
        load_datetime,
        record_source
    FROM {{ ref('stg_contracts') }}
),
deduped AS (
    SELECT *
    FROM staged
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_contract, hashdiff
        ORDER BY load_datetime
    ) = 1
)
SELECT d.*
FROM deduped d
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_contract = d.hk_contract
      AND t.hashdiff = d.hashdiff
)
{% endif %}
