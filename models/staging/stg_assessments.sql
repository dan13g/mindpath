WITH source AS (
    SELECT * FROM {{ source('mindpath_sqlserver', 'assessments') }}
    WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
)

SELECT
    assessment_id,
    referral_id,
    client_id,
    assessment_date,
    assessment_type,
    presenting_condition,
    risk_level,
    recommended_treatment,
    assessment_status,
    {{ hash_key(['assessment_id']) }} AS hk_assessment,
    {{ hash_key(['referral_id']) }} AS hk_referral,
    {{ hash_key(['client_id']) }} AS hk_client,
    {{ hashdiff(['assessment_date', 'assessment_type', 'presenting_condition', 'risk_level', 'recommended_treatment', 'assessment_status']) }} AS hd_assessment,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER.ASSESSMENTS' AS record_source
FROM source
