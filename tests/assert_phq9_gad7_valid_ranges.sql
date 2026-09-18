select f.*, m.measure_name
from {{ ref('fact_outcome') }} f
join {{ ref('dim_outcome_measure') }} m
  on f.outcome_measure_key = m.outcome_measure_key
where (upper(m.measure_name) like 'PHQ%9%' and (f.score < 0 or f.score > 27))
   or (upper(m.measure_name) like 'GAD%7%' and (f.score < 0 or f.score > 21))
