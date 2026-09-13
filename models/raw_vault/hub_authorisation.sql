{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        hk_authorisation,
        authorisation_id,
        load_datetime,
        record_source
    FROM {{ ref('stg_authorisations') }}
    WHERE authorisation_id IS NOT NULL
)
SELECT i.*
FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_authorisation = i.hk_authorisation
)
{% endif %}
