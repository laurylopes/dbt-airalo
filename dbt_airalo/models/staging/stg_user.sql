with source as (

    select * from {{ source('raw', 'user') }}

),

renamed as (

    select
        cast(user_id as string) as user_id,
        created_at,
        platform,
        acquisition_channel,
        case ip_country 
            when null then 'UNKNOWN'
            else upper(ip_country)
        end as ip_country

    from source

)

select * from renamed