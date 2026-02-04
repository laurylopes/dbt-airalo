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
    -- If no exchange rate is found for the order date then use the initial exchange rate for that currency
    orders.amount / coalesce(exchange_rate.rate_from_usd, oldest_exchange_rate.rate_from_usd) as usd_amount,
    orders.amount / coalesce(exchange_rate.rate_from_gbp, oldest_exchange_rate.rate_from_gbp) as gbp_amount,

    esim_package,
    payment_method,

    -- Assuming that the card country is same as IP country as a fallback
    coalesce(orders.card_country, user.ip_country) as card_country,
    destination_country,
    latest_status,
    completed_at,
    refunded_at,
    failed_at

from {{ ref('fct_order') }}  orders
left join {{ ref('fct_exchange_rate') }} exchange_rate
    on orders.currency = exchange_rate.currency
    and orders.created_at between exchange_rate.valid_from and exchange_rate.valid_to
left join {{ ref('fct_exchange_rate') }} oldest_exchange_rate
    on orders.currency = oldest_exchange_rate.currency
    and oldest_exchange_rate.is_initial
left join {{ ref('dim_user') }} user
    on orders.user_id = user.user_id

-- Incremental filter
{% if is_incremental() %}
where orders.updated_at > (select max(orders.updated_at) from {{ this }})
{% endif %}

-- Keep only the latest status per order
qualify row_number() over (partition by order_id order by orders.updated_at desc) = 1