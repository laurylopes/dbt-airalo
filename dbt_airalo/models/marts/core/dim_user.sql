{{ config (
    materialized = 'table',
    unique_key = 'id'
) }}

select * from {{ ref('stg_user') }} 