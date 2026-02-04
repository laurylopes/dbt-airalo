with snapshot as (

    select * from {{ ref('snp_raw_exchange_rate') }}

),

renamed as (

    select
        dbt_scd_id as id, 
        currency,
        usd_rate,
        dbt_updated_at as updated_at,
        dbt_valid_from as valid_from,
        dbt_valid_to as valid_to

from snapshot

)

select * from renamed