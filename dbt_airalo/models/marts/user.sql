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
    user.updated_at,
    user.platform,
    user.acquisition_channel,
    user.ip_country as country,
    metric.total_orders,
    metric.total_usd_amount_spent as usd_total_amount,
    metric.total_gbp_amount_spent as gbp_total_amount,
    metric.first_purchase_on,
    metric.last_purchase_on,
    metric.days_between_first_and_last_purchase,
    metric.days_since_last_purchase,
    metric.distinct_products_purchased,
    metric.is_new,
    metric.is_frequent,
    metric.is_occasional,
    metric.is_rare
from {{ ref('dim_user') }} user
left join {{ ref('_user_metrics_on_orders') }} metric
    using (user_id)
-- Taking the latest record for each user, eg. latest country, platform 
where user.valid_to is null
 
-- Incremental filter
{% if is_incremental() %}
    and user.updated_at > (select max(updated_at) from {{ this }})
{% endif %}