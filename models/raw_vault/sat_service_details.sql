{{ config(materialized='incremental') }}
WITH staged AS (
    SELECT
        hk_service,
        hd_service AS hashdiff,
        service_name,
        service_category,
        load_datetime,
        record_source
    FROM {{ ref('stg_services') }}
),
deduped AS (
    SELECT *
    FROM staged
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_service, hashdiff
        ORDER BY load_datetime
    ) = 1
)
SELECT d.*
FROM deduped d
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_service = d.hk_service
      AND t.hashdiff = d.hashdiff
)
{% endif %}
