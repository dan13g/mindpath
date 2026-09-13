{{ config(materialized='incremental') }}
WITH staged AS (
    SELECT
        hk_contract_service,
        hd_contract_service AS hashdiff,
        agreed_rate,
        session_limit,
        load_datetime,
        record_source
    FROM {{ ref('stg_contract_services') }}
),
deduped AS (
    SELECT * FROM staged
    QUALIFY ROW_NUMBER() OVER (PARTITION BY hk_contract_service, hashdiff ORDER BY load_datetime) = 1
)
SELECT d.* FROM deduped d
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_contract_service = d.hk_contract_service
      AND t.hashdiff = d.hashdiff
)
{% endif %}
