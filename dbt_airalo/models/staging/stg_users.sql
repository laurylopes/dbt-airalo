select * from {{ source('dwh_bl', 'dim_users') }}
