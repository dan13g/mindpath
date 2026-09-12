{{ config(materialized='incremental')}}

with incoming as (
    select distinct
        {{ hash_key(['client_id', 'referral_id']) }} as hk_client_referral,
        hk_client,
        hk_referral,
        load_datetime,
        record_source
    from {{ref('stg_referrals')}}
    where referral_id is not null and client_id is not null
)

select
    i.*
from incoming i
{% if is_incremental()%}
where not exists(
        select 1 from {{this}} t
        where t.hk_client_referral = i.hk_client_referral
)
{% endif%}

