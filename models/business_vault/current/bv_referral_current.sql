{{ config(materialized='view') }}

WITH latest AS (
    SELECT
        hk_referral,
        referral_date,
        referral_source,
        presenting_problem,
        priority,
        funding_type,
        load_datetime,
        record_source
    FROM {{ ref('sat_referral_details') }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_referral
        ORDER BY load_datetime DESC
    ) = 1
)

SELECT
    h.hk_referral,
    h.referral_id,
    s.referral_date,
    s.referral_source,
    s.presenting_problem,
    s.priority,
    CAST(NULL AS VARCHAR) AS referral_status,
    s.funding_type,
    s.load_datetime AS satellite_load_datetime,
    COALESCE(s.record_source, h.record_source) AS record_source
FROM {{ ref('hub_referral') }} h
LEFT JOIN latest s
    ON h.hk_referral = s.hk_referral
