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

select * from {{ ref('stg_exchange_rate') }}