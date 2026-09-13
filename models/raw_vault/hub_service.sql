{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        hk_service,
        service_id,
        load_datetime,
        record_source
    FROM {{ ref('stg_services') }}
    WHERE service_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_service = i.hk_service
)
{% endif %}
