{{config (
    materialized = 'table',
    unique_key = 'user_id'
)}}

select 
    user.*,
    metric.total_orders,
    metric.first_purchase_on,
    metric.last_purchase_on,
    metric.days_between_first_and_last,
    metric.is_new_user,
    metric.is_returned_user,
    metric.is_churned_user
from {{ ref('dim_user') }} user
left join {{ ref('agg_user_on_order') }} metric
    using (user_id)