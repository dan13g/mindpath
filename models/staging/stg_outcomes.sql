WITH source AS (
    SELECT * FROM {{ source('mindpath_sqlserver', 'outcomes') }}
    WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
)

SELECT
    outcome_id,
    referral_id,
    client_id,
    session_id,
    measure_name,
    measurement_date,
    score,
    {{ hash_key(['outcome_id']) }} AS hk_outcome,
    {{ hash_key(['referral_id']) }} AS hk_referral,
    {{ hash_key(['client_id']) }} AS hk_client,
    {{ hash_key(['session_id']) }} AS hk_session,
    {{ hashdiff(['measure_name', 'measurement_date', 'score']) }} AS hd_outcome,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER.OUTCOMES' AS record_source
FROM source
