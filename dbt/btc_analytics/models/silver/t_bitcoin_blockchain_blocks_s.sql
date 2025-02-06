{{
    config(
        materialized='incremental',
        unique_key='hash',
        partition_by={
            "field": "timestamp",
            "data_type": "timestamp",
            "granularity": "day"
        }
    )
}}

with blocks_data_raw as (
    select
        *
    from
        {{ source('bigquery-public-data', 'blocks') }}
    where timestamp_month >= "2024-01-01"
    {% if is_incremental() %} 
    and timestamp_month >= (select max(timestamp_month) from {{ this }})

    {% endif %}
),

final_data as (
    SELECT
        *
    FROM
        blocks_data_raw
)

select
    *
from
    final_data