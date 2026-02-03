{{ config (
    materialized = 'incremental',
    unique_key = 'order_id',
    incremental_strategy = 'insert_overwrite',
    partition_by = {
        'field': 'updated_at',
        'data_type': 'timestamp',
        'granularity': 'day'
    }
)}}

select 
    order_id,
    user_id,
    created_at,
    updated_at,
    amount,
    currency,
    esim_package,
    payment_method,
    card_country,
    destination_country,
    status as latest_status,
    min(case when status = 'completed' then updated_at end) over (partition by order_id) as completed_at,
    min(case when status = 'refunded' then updated_at end) over (partition by order_id) as refunded_at,
    min(case when status = 'failed' then updated_at end) over (partition by order_id) as failed_at

from {{ ref('stg_order') }}

-- Incremental filter
{% if is_incremental() %}
where updated_at > (select max(updated_at) from {{ this }})
{% endif %}

-- Keep only the latest status per order
qualify row_number() over (partition by order_id order by updated_at desc) = 1