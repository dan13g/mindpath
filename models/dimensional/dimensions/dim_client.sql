{{ config(materialized='table') }}
WITH ranked AS (
    SELECT
        hk_master_client,
        master_client_id,
        source_client_id,
        first_name,
        last_name,
        date_of_birth,
        nhs_number,
        email,
        mobile,
        postcode,
        source_system,
        ROW_NUMBER() OVER (
            PARTITION BY hk_master_client
            ORDER BY IFF(source_client_id = master_client_id, 0, 1), source_client_id
        ) AS rn,
        COUNT(*) OVER (PARTITION BY hk_master_client) AS source_record_count
    FROM {{ ref('bv_master_client') }}
)
SELECT
    hk_master_client AS client_key,
    master_client_id,
    first_name,
    last_name,
    TRIM(CONCAT(COALESCE(first_name,''), ' ', COALESCE(last_name,''))) AS client_name,
    date_of_birth,
    nhs_number,
    email,
    mobile,
    postcode,
    source_system,
    source_record_count,
    IFF(source_record_count > 1, TRUE, FALSE) AS is_mastered_from_duplicates
FROM ranked
WHERE rn = 1
