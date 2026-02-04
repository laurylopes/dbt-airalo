{{ config (
    materialized = 'incremental',
    unique_key = 'id',
    incremental_strategy = 'insert_overwrite',
    partition_by = {
        'field': 'updated_at',
        'data_type': 'timestamp',
        'granularity': 'day'
    }
)}}

-- tout est update en meme temps a chaque fois
with gbp_rate as (
    select 
        usd_rate as rate_from_usd_to_gbp,
        valid_from
    from {{ ref('stg_exchange_rate') }}
    where currency = 'GBP'
)

select 
    id,
    currency,
    usd_rate as rate_from_usd,
    usd_rate / rate_from_usd_to_gbp  as rate_from_gbp,
    valid_from, 
    valid_to,
    min(valid_from) over (partition by currency) = valid_from as is_initial
from {{ ref('stg_exchange_rate') }}
left join gbp_rate 
    -- To get the correct GBP rate for the valid_from date
    using(valid_from)
