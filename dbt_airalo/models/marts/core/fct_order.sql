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
    orders.user_id,
    orders.created_at,
    orders.updated_at,
    orders.amount,
    orders.currency,

    -- Creating USD and GBP amount fields
    round(orders.amount / exchange_rate.usd_rate, 2) as usd_amount,
    round(orders.amount / exchange_rate.usd_rate * gbp_rate.gbp_to_usd_rate, 2) as gbp_amount,
    esim_package,
    payment_method,

    -- Assuming that the card country is same as IP country as a fallback
    coalesce(orders.card_country, user.ip_country) as card_country,
    destination_country,
    status as latest_status,

    -- Creating status timestamp fields for completed, refunded, and failed
    min(case when status = 'completed' then orders.updated_at end) over (partition by order_id) as completed_at,
    min(case when status = 'refunded' then orders.updated_at end) over (partition by order_id) as refunded_at,
    min(case when status = 'failed' then orders.updated_at end) over (partition by order_id) as failed_at

from {{ ref('stg_order') }}  orders
left join {{ ref('fct_exchange_rate') }} exchange_rate
    on orders.currency = exchange_rate.currency
left join {{ ref('int_gbp_to_usd_rate') }} gbp_rate
    on true
left join {{ ref('stg_user') }} user
    on orders.user_id = user.user_id

-- Incremental filter
{% if is_incremental() %}
where orders.updated_at > (select max(orders.updated_at) from {{ this }})
{% endif %}

-- Keep only the latest status per order
qualify row_number() over (partition by order_id order by orders.updated_at desc) = 1