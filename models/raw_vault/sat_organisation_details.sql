{{ config(materialized='incremental') }}
WITH staged AS (
    SELECT
        hk_organisation,
        hd_organisation AS hashdiff,
        organisation_name,
        organisation_type,
        status,
        load_datetime,
        record_source
    FROM {{ ref('stg_organisations') }}
),
deduped AS (
    SELECT *
    FROM staged
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_organisation, hashdiff
        ORDER BY load_datetime
    ) = 1
)
SELECT d.*
FROM deduped d
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_organisation = d.hk_organisation
      AND t.hashdiff = d.hashdiff
)
{% endif %}
