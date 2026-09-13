{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        hk_client,
        client_id,
        load_datetime,
        record_source
    FROM {{ ref('stg_clients') }}
    WHERE client_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_client = i.hk_client
)
{% endif %}
