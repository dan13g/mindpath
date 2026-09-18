select
    fs.session_id,
    sd.date_day as session_date,
    fr.referral_id,
    rd.date_day as referral_date
from {{ ref('fact_session') }} fs
join {{ ref('fact_referral') }} fr
  on fs.referral_key = fr.referral_key
join {{ ref('dim_date') }} sd
  on fs.session_date_key = sd.date_key
join {{ ref('dim_date') }} rd
  on fr.referral_date_key = rd.date_key
where sd.date_day < rd.date_day
