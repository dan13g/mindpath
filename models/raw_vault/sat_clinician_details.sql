{{ config(materialized='incremental') }}
WITH staged AS (
    SELECT
        hk_clinician,
        hd_clinician AS hashdiff,
        clinician_name,
        clinician_type,
        active_flag,
        region,
        primary_language,
        load_datetime,
        record_source
    FROM {{ ref('stg_clinicians') }}
),
deduped AS (
    SELECT *
    FROM staged
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_clinician, hashdiff
        ORDER BY load_datetime
    ) = 1
)
SELECT d.*
FROM deduped d
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_clinician = d.hk_clinician
      AND t.hashdiff = d.hashdiff
)
{% endif %}
