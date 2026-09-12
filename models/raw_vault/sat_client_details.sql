{{ config(materialized='incremental')}}

with staged as (
    select
        hk_client,
        {{ hashdiff(['nhs_number','first_name','last_name','date_of_birth','email','mobile','postcode','source_system']) }} as hashdiff,
        nhs_number,
        first_name,
        last_name,
        date_of_birth,
        email,
        mobile,
        postcode,
        source_system,
        load_datetime,
        record_source
    from {{ref('stg_clients')}}
),
deduped as (
    select *
    from staged
    qualify row_number() over(
        partition by hk_client, hashdiff
        order by load_datetime
    ) = 1
)

select
    d.*
from deduped d
{% if is_incremental()%}
where not exists(
        select 1 from {{this}} t
        where t.hk_client = d.hk_client
            and t.hashdiff = d.hashdiff
)
{% endif%}

