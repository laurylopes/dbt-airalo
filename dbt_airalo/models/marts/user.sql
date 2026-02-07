{{ config (
    materialized = 'incremental',
    unique_key = 'user_id',
    incremental_strategy = 'insert_overwrite',
    partition_by = {
        'field': 'updated_at',
        'data_type': 'timestamp',
        'granularity': 'day'
    }
)}}


select 
    user.user_id,
    user.created_at,
    metric.first_purchase_on,
    metric.last_purchase_on,
    user.platform,
    user.acquisition_channel,
    user.ip_country as country,
    coalesce(metric.total_orders, 0) as total_orders,
    coalesce(metric.total_usd_amount_spent, 0) as total_usd_amount_spent,
    coalesce(metric.total_gbp_amount_spent, 0) as total_gbp_amount_spent,
    coalesce(metric.usd_amount_spent_new, 0) as usd_amount_spent_new,
    coalesce(metric.gbp_amount_spent_new, 0) as gbp_amount_spent_new,
    coalesce(metric.usd_amount_spent_returned, 0) as usd_amount_spent_returned,
    coalesce(metric.gbp_amount_spent_returned, 0) as gbp_amount_spent_returned,
    metric.days_between_first_and_last_purchase,
    metric.distinct_products_purchased,
    coalesce(metric.is_new, 0) as is_new,
    coalesce(metric.has_returned, 0) as has_returned,
    user.updated_at
from {{ ref('dim_user') }} user
left join {{ ref('_user_metrics_on_orders') }} metric
    using (user_id)
-- Taking the latest record for each user, eg. latest country, platform 
where user.valid_to is null
 
-- Incremental filter
{% if is_incremental() %}
    and user.updated_at > (select max(updated_at) from {{ this }})
{% endif %}