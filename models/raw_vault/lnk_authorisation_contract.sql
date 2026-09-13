{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['authorisation_id', 'contract_id']) }} AS hk_authorisation_contract,
        hk_authorisation,
        hk_contract,
        load_datetime,
        record_source
    FROM {{ ref('stg_authorisations') }}
    WHERE authorisation_id IS NOT NULL AND contract_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_authorisation_contract = i.hk_authorisation_contract
)
{% endif %}
