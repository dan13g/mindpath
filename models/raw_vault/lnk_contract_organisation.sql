{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['contract_id', 'organisation_id']) }} AS hk_contract_organisation,
        hk_contract,
        hk_organisation,
        load_datetime,
        record_source
    FROM {{ ref('stg_contracts') }}
    WHERE contract_id IS NOT NULL AND organisation_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_contract_organisation = i.hk_contract_organisation
)
{% endif %}
