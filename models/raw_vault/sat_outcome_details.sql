{{ config(materialized='incremental') }}
WITH staged AS (
    SELECT
        hk_outcome,
        hd_outcome AS hashdiff,
        measure_name,
        measurement_date,
        score,
        load_datetime,
        record_source
    FROM {{ ref('stg_outcomes') }}
),
deduped AS (
    SELECT *
    FROM staged
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_outcome, hashdiff
        ORDER BY load_datetime
    ) = 1
)
SELECT d.*
FROM deduped d
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t
    WHERE t.hk_outcome = d.hk_outcome
      AND t.hashdiff = d.hashdiff
)
{% endif %}
