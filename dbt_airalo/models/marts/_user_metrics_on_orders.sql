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
    date_diff(last_purchase_on, first_purchase_on, DAY) as days_between_first_and_last_purchase,
    date_diff(current_date, last_purchase_on, DAY) as days_since_last_purchase,
    distinct_products_purchased,
    case when distinct_products_count > 1 then 1 else 0 end as has_purchased_different_products,
    -- is_new_user: true if user has only 1 completed order
    case when total_orders = 1 then 1 else 0 end as is_new,
    -- is_frequent_user: true if user has made a purchase in the last 90 days
    case when date_diff(current_date, last_purchase_on, DAY) <= 90 then 1 else 0 end as is_frequent,                    
    -- is_occasional_user: true if user has made a purchase between 90 and 180 days ago
    case when date_diff(current_date, last_purchase_on, DAY) > 90 and date_diff(current_date, last_purchase_on, DAY) <= 180 then 1 else 0 end as is_occasional,                        
    -- is_rare_user: true if user made a purchase more than 180 days ago
    case when date_diff(current_date, last_purchase_on, DAY) > 180 then 1 else 0 end as is_rare                   
from user_orders


