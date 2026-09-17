{{ config(materialized='table') }}
WITH org AS (
    SELECT l.hk_contract, MIN(o.hk_organisation) AS organisation_key
    FROM {{ ref('lnk_contract_organisation') }} l
    LEFT JOIN {{ ref('bv_organisation_current') }} o ON l.hk_organisation=o.hk_organisation
    GROUP BY l.hk_contract
)
SELECT c.hk_contract AS contract_key, c.contract_id, o.organisation_key,
       c.contract_name, c.start_date, c.end_date, c.contract_status, c.billing_method
FROM {{ ref('bv_contract_current') }} c
LEFT JOIN org o ON c.hk_contract=o.hk_contract
