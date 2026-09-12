{{ config(materialized='incremental')}}

with incoming as (
    select distinct
        hk_referral,
        referral_id,
        load_datetime,
        record_source
    from {{ref('stg_referrals')}}
    where referral_id is not null
)

select
    i.*
from incoming i
{% if is_incremental()%}
where not exists(
        select 1 from {{this}} t
        where t.hk_referral = i.hk_referral
)
{% endif%}

