{{ config (
    materialized = 'incremental',
    unique_key = 'currency',
    incremental_strategy = 'append',
)}}

select * from {{ ref('snp_exchange_rate') }}