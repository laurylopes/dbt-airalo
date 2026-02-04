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
    usd_amount,
    gbp_amount,
    orders.esim_package,
    orders.payment_method,
    card_country,
    orders.destination_country,
    orders.user_id,
    orders.completed_at,
    orders.refunded_at,
    orders.failed_at

from {{ ref('fct_order') }} orders