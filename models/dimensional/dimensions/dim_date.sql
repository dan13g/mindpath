{{ config(materialized='table') }}
WITH bounds AS (
    SELECT
        LEAST(
            COALESCE(MIN(referral_date), CURRENT_DATE()),
            COALESCE(MIN(first_session_date), CURRENT_DATE()),
            COALESCE(MIN(first_assessment_date), CURRENT_DATE())
        ) AS min_date,
        GREATEST(
            COALESCE(MAX(referral_date), CURRENT_DATE()),
            COALESCE(MAX(last_session_date), CURRENT_DATE()),
            CURRENT_DATE()
        ) AS max_date
    FROM {{ ref('bv_client_journey') }}
), dates AS (
    SELECT DATEADD(day, SEQ4(), b.min_date)::DATE AS date_day
    FROM bounds b, TABLE(GENERATOR(ROWCOUNT => 10000))
    QUALIFY date_day <= DATEADD(year, 2, b.max_date)
)
SELECT
    TO_NUMBER(TO_CHAR(date_day, 'YYYYMMDD')) AS date_key,
    date_day,
    DAY(date_day) AS day_of_month,
    DAYOFWEEKISO(date_day) AS day_of_week_number,
    DAYNAME(date_day) AS day_name,
    WEEKISO(date_day) AS week_of_year,
    MONTH(date_day) AS month_number,
    MONTHNAME(date_day) AS month_name,
    QUARTER(date_day) AS quarter_number,
    YEAR(date_day) AS year_number,
    DATE_TRUNC('month', date_day)::DATE AS month_start_date,
    DATE_TRUNC('quarter', date_day)::DATE AS quarter_start_date,
    IFF(DAYOFWEEKISO(date_day) IN (6,7), TRUE, FALSE) AS is_weekend
FROM dates
