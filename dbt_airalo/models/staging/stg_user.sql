with snapshot as (

    select * from {{ ref('snp_raw_user') }}

),

renamed as (

    select
	
        dbt_scd_id as id, 
        cast(user_id as string) as user_id,
        created_at,
        platform,
        acquisition_channel,
        case when ip_country is null then 'UNKNOWN' else upper(ip_country) end as ip_country, 
        dbt_updated_at as updated_at,
        dbt_valid_from as valid_from,
        dbt_valid_to as valid_to, 
        case when dbt_valid_to is null then true else false end as is_current

    from snapshot

)

select * from renamed