WITH source AS (
    SELECT * FROM {{ source('mindpath_sqlserver', 'clinician_allocations') }}
    WHERE COALESCE(_FIVETRAN_DELETED, FALSE) = FALSE
)

SELECT
    allocation_id,
    referral_id,
    clinician_id,
    allocation_date,
    allocation_status,
    {{ hash_key(['allocation_id']) }} AS hk_allocation,
    {{ hash_key(['referral_id']) }} AS hk_referral,
    {{ hash_key(['clinician_id']) }} AS hk_clinician,
    {{ hashdiff(['allocation_date', 'allocation_status']) }} AS hd_clinician_allocation,
    _FIVETRAN_SYNCED AS load_datetime,
    'MINDPATH_SQLSERVER.CLINICIAN_ALLOCATIONS' AS record_source
FROM source
