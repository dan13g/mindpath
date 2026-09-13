WITH source AS (
    SELECT * FROM {{ source('mindpath_sqlserver', 'treatment_plans') }}
    WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
)

SELECT
    treatment_plan_id,
    referral_id,
    assessment_id,
    service_id,
    recommended_sessions,
    plan_start_date,
    status,
    {{ hash_key(['treatment_plan_id']) }} AS hk_treatment_plan,
    {{ hash_key(['referral_id']) }} AS hk_referral,
    {{ hash_key(['assessment_id']) }} AS hk_assessment,
    {{ hash_key(['service_id']) }} AS hk_service,
    {{ hashdiff(['recommended_sessions', 'plan_start_date', 'status']) }} AS hd_treatment_plan,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER.TREATMENT_PLANS' AS record_source
FROM source
