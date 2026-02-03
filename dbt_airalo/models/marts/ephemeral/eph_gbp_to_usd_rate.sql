{{ config (
    materialized='ephemeral', 
    unique_key='currency'
) }}

select 
    currency,
    usd_rate as gbp_to_usd_rate
from {{ ref('stg_exchange_rate') }}
where currency = 'GBP'