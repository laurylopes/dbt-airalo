with source as (

    select * from {{ source('raw', 'exchange_rate') }}

),

renamed as (

    select
        currency,
        usd_rate

    from source

)

select * from renamed