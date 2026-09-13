WITH source AS (
    SELECT * FROM {{ source('mindpath_sqlserver', 'authorisations') }}
    WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
)

SELECT
    authorisation_id,
    referral_id,
    contract_id,
    authorisation_date,
    authorised_sessions,
    authorised_amount,
    expiry_date,
    status,
    {{ hash_key(['authorisation_id']) }} AS hk_authorisation,
    {{ hash_key(['referral_id']) }} AS hk_referral,
    {{ hash_key(['contract_id']) }} AS hk_contract,
    {{ hashdiff(['authorisation_date', 'authorised_sessions', 'authorised_amount', 'expiry_date', 'status']) }} AS hd_authorisation,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER.AUTHORISATIONS' AS record_source
FROM source
