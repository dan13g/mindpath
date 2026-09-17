{{ config(materialized='table') }}
SELECT DISTINCT MD5('SESSION_STATUS|' || UPPER(TRIM(session_status))) AS session_status_key,
       UPPER(TRIM(session_status)) AS session_status
FROM {{ ref('bv_session_current') }}
WHERE session_status IS NOT NULL
