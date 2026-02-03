with source as (

    select * from {{ source('raw', 'order') }}

),

renamed as (

    select
        order_id,
        created_at,
        updated_at,
        lower(status) as status,
        amount,
        upper(currency) as currency,
        esim_package,
        payment_method,
        upper(card_country) as card_country,
        upper(destination_country) as destination_country,
        cast(user_id as string) as user_id

    from source

)

select * from renamed