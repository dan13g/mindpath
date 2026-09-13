{% snapshot snap_clinicians %}

{{
    config(
        target_database='MINDPATH_ENT_DW',
        target_schema='SNAPSHOTS',
        unique_key='clinician_id',
        strategy='check',
        check_cols=[
            'clinician_name',
            'clinician_type',
            'active_flag',
            'region',
            'primary_language'
        ]
    )
}}

select
    clinician_id,
    clinician_name,
    clinician_type,
    active_flag,
    region,
    primary_language,
    _fivetran_synced,
    _fivetran_deleted
from {{ source('mindpath_sqlserver', 'clinicians') }}
where coalesce(_fivetran_deleted, false) = false

{% endsnapshot %}
