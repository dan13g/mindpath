SELECT
    *,
    {{ hash_key(['assessment_id']) }} AS hk_assessment,
    {{ hash_key(['referral_id']) }} AS hk_referral,
    {{ hash_key(['client_id']) }} AS hk_client,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER' AS record_source
FROM {{ source('mindpath_sqlserver', 'assessments') }}
WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
