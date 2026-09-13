WITH source AS (
    SELECT * FROM {{ source('mindpath_sqlserver', 'referrals') }}
    WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
)

SELECT
    referral_id,
    client_id,
    organisation_id,
    contract_id,
    referral_date,
    referral_source,
    presenting_problem,
    priority,
    referral_status,
    funding_type,
    {{ hash_key(['referral_id']) }} AS hk_referral,
    {{ hash_key(['client_id']) }} AS hk_client,
    {{ hash_key(['organisation_id']) }} AS hk_organisation,
    {{ hash_key(['contract_id']) }} AS hk_contract,
    {{ hashdiff(['referral_date', 'referral_source', 'presenting_problem', 'priority', 'referral_status', 'funding_type']) }} AS hd_referral,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER.REFERRALS' AS record_source
FROM source
