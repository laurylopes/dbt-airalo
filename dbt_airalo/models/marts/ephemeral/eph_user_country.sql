{{ config (
    materialized = 'ephemeral',
    unique_key = 'user_id'
) }}

select 
    user_id,
    ip_country
from {{ ref('dim_user') }}