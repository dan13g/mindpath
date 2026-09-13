{{ config(materialized='incremental') }}
WITH staged AS (
    SELECT
        hk_authorisation,
        hd_authorisation AS hashdiff,
        authorisation_date,
        authorised_sessions,
        authorised_amount,
        expiry_date,
        status,
        load_datetime,
        record_source
    FROM {{ ref('stg_authorisations') }}
),
deduped AS (
    SELECT *
    FROM staged
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_authorisation, hashdiff
        ORDER BY load_datetime
    ) = 1
)
SELECT d.*
FROM deduped d
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_authorisation = d.hk_authorisation
      AND t.hashdiff = d.hashdiff
)
{% endif %}
