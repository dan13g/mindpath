{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        hk_organisation,
        organisation_id,
        load_datetime,
        record_source
    FROM {{ ref('stg_organisations') }}
    WHERE organisation_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_organisation = i.hk_organisation
)
{% endif %}
