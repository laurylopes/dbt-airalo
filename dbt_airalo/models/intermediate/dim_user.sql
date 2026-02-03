{{ config (
    materialized = 'table',
    unique_key = 'user_id'
) }}

select * from {{ ref('snp_user') }} 