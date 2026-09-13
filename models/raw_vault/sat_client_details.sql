{{ config(materialized='incremental') }}
WITH staged AS (
    SELECT
        hk_client,
        {{ hashdiff(['nhs_number','first_name','last_name','date_of_birth','email','mobile','postcode','source_system']) }} AS hashdiff,
        nhs_number,
        first_name,
        last_name,
        date_of_birth,
        email,
        mobile,
        postcode,
        source_system,
        load_datetime,
        record_source
    FROM {{ ref('stg_clients') }}
),
deduped AS (
    SELECT *
    FROM staged
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_client, hashdiff
        ORDER BY load_datetime
    ) = 1
)
SELECT d.*
FROM deduped d
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_client = d.hk_client
      AND t.hashdiff = d.hashdiff
)
{% endif %}
