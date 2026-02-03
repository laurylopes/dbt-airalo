{{config (
    materialized = 'table',
    unique_key = 'order_id'
)}}


select 
    orders.order_id,
    orders.created_at,
    orders.updated_at,
    orders.latest_status,
    orders.amount,
    orders.currency,
    round(orders.amount / exchange_rates.usd_rate, 2) as usd_amount,
    round(orders.amount / exchange_rates.usd_rate * gbp_rate.gbp_to_usd_rate, 2) as gbp_amount,
    orders.esim_package,
    orders.payment_method,
    coalesce(orders.card_country, users.ip_country) as card_country,
    orders.destination_country,
    orders.user_id,
    orders.completed_at,
    orders.refunded_at,
    orders.failed_at

from {{ ref('fct_order') }} orders
left join {{ ref('fct_exchange_rate') }} exchange_rates
    on orders.currency = exchange_rates.currency
left join {{ ref('eph_gbp_to_usd_rate') }} gbp_rate
    on true
left join {{ ref('eph_user_country') }} users
    on orders.user_id = users.user_id