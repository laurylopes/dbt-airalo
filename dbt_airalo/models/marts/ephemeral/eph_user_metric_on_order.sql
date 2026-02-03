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
        cast(min(updated_at) as date) as first_purchase_on,
        cast(max(updated_at) as date) as last_purchase_on
    from {{ ref('fct_order') }}
    where completed_at is not null
    group by user_id
), 

user_metrics as (
    select 
        user_id,
        total_orders,
        first_purchase_on,
        last_purchase_on,
        date_diff(last_purchase_on, first_purchase_on, DAY) as days_between_first_and_last,
        -- is_new_user: true if user has only 1 completed order
        case when total_orders = 1 then true else false end as is_new_user,
        -- is_returned_user: true if user has more than 1 completed order
        case when total_orders > 1 then true else false end as is_returned_user,
        -- is_churned_user: true if user has not made a purchase in the last 90 days
        case when date_diff(current_date, last_purchase_on, DAY) > 90 then true else false end as is_churned_user                    
    from user_orders
)

select 
    *
from user_metrics

