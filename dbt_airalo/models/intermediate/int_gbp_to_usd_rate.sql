{{ config (
    materialized='view', 
    unique_key='currency'
) }}

select 
    currency,
    usd_rate as gbp_to_usd_rate, 
    valid_from,
    valid_to
from {{ ref('stg_exchange_rate') }}
where currency = 'GBP'