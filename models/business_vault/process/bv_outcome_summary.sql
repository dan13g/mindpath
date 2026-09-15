{{ config(materialized='table') }}
WITH x AS (
 SELECT l.hk_referral,o.measure_name,o.measurement_date,o.score,
        ROW_NUMBER() OVER(PARTITION BY l.hk_referral,o.measure_name ORDER BY o.measurement_date,o.outcome_id) AS rn_first,
        ROW_NUMBER() OVER(PARTITION BY l.hk_referral,o.measure_name ORDER BY o.measurement_date DESC,o.outcome_id DESC) AS rn_last
 FROM {{ ref('lnk_referral_outcome') }} l
 JOIN {{ ref('bv_outcome_current') }} o ON l.hk_outcome=o.hk_outcome
)
SELECT hk_referral,measure_name,
       MAX(IFF(rn_first=1,measurement_date,NULL)) AS baseline_date,
       MAX(IFF(rn_first=1,score,NULL)) AS baseline_score,
       MAX(IFF(rn_last=1,measurement_date,NULL)) AS latest_date,
       MAX(IFF(rn_last=1,score,NULL)) AS latest_score,
       MAX(IFF(rn_first=1,score,NULL))-MAX(IFF(rn_last=1,score,NULL)) AS score_improvement
FROM x GROUP BY hk_referral,measure_name
