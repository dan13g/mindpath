{{ config(materialized='incremental')}}

with incoming as (
    select distinct
        hk_client,
        client_id,
        load_datetime,
        record_source
    from {{ref('stg_clients')}}
    where client_id is not null
)

select
    i.*
from incoming i
{% if is_incremental()%}
where not exists(
        select 1 from {{this}} t
        where t.hk_client = i.hk_client
)
{% endif%}

