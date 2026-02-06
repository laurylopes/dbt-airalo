{{ config (
    materialized = 'incremental',
    unique_key = 'id',
    incremental_strategy = 'insert_overwrite',
    partition_by = {
        'field': 'updated_at',
        'data_type': 'timestamp',
        'granularity': 'day'
    }
)}}

select 
    id,
    user_id,
    created_at,
    platform,
    acquisition_channel,
    ip_country,
    updated_at,
    valid_from,
    valid_to
from {{ ref('stg_user') }} 

-- Incremental filter
{% if is_incremental() %}
where updated_at > (select max(updated_at) from {{ this }})
{% endif %}