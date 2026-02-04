{{ config (
    materialized='ephemeral', 
    unique_key='user_id'
) }}

/* This model calculates user metrics based on orders such as total orders, 
first and last purchase dates, and user status flags */

with user_orders as (
    select 
        user_id,
        count(distinct order_id) as total_orders,
        sum(usd_amount) as usd_total_amount,
        sum(gbp_amount) as gbp_total_amount,
        cast(min(updated_at) as date) as first_purchase_on,
        cast(max(updated_at) as date) as last_purchase_on, 
        string_agg(distinct esim_package, ', ' order by esim_package) as distinct_products_purchased,
        count(distinct esim_package) as distinct_products_count
    from {{ ref('order') }}
    -- Only consider completed orders for user metrics
    where completed_at is not null
    group by user_id
)

select 
    user_id,
    total_orders,
    round(usd_total_amount, 2) as total_usd_amount_spent,
    round(gbp_total_amount, 2) as total_gbp_amount_spent,
    first_purchase_on,
    last_purchase_on,
    date_diff(last_purchase_on, first_purchase_on, DAY) as days_between_first_and_last,
    distinct_products_purchased,
    distinct_products_count > 1 as has_purchased_different_products,
    -- is_new_user: true if user has only 1 completed order
    case when total_orders = 1 then true else false end as is_new,
    -- is_returned_user: true if user has more than 1 completed order
    case when total_orders > 1 then true else false end as has_returned,
    -- is_churned_user: true if user has not made a purchase in the last 90 days
    case when date_diff(current_date, last_purchase_on, DAY) > 90 then true else false end as has_churned                    
from user_orders


