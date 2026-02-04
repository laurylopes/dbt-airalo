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
    user.*,
    metric.total_orders,
    metric.first_purchase_on,
    metric.last_purchase_on,
    metric.days_between_first_and_last,
    metric.is_new_user,
    metric.is_returned_user,
    metric.is_churned_user
from {{ ref('dim_user') }} user
left join {{ ref('_user_metrics_on_orders') }} metric
    using (user_id)

-- Incremental filter
{% if is_incremental() %}
where user.updated_at > (select max(user.updated_at) from {{ this }})
{% endif %}