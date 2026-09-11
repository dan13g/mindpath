SELECT
    *,
    {{ hash_key(['referral_id']) }} AS hk_referral,
    {{ hash_key(['client_id']) }} AS hk_client,
    {{ hash_key(['organisation_id']) }} AS hk_organisation,
    {{ hash_key(['contract_id']) }} AS hk_contract,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER' AS record_source
FROM {{ source('mindpath_sqlserver', 'referrals') }}
WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
