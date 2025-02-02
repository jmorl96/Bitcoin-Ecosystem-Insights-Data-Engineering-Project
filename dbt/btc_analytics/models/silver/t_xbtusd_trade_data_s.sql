{{
    config(
        materialized='incremental',
        unique_key='trade_id'
    )
}}

with XBTUSD_data_bronze as (
    select
        *, _FILE_NAME
    from
        {{ source('dv_kraken_data_bronze', 't_xbtusd_trade_data_b') }}
    {% if is_incremental() %}

    where 
    trade_id >= (select max(trade_id) from {{ this }})
    and
    array_reverse(split(_FILE_NAME, '/'))[SAFE_OFFSET(0)] not in (select distinct gcs_file_name from {{ this }})

    {% endif %}
),

final_data as (
    SELECT
        "XBTUSD" AS pair,
        CAST(price AS FLOAT64) AS price,
        CAST(volume AS FLOAT64) AS volume,
        time AS epoch_time,
        TIMESTAMP_SECONDS(CAST(time AS INT64)) AS timestamp_time,
        CASE
            WHEN buy_sell = "b" THEN "buy"
            WHEN buy_sell = "s" THEN "sell"
        END AS operation_type,
        CASE
            WHEN market_limit = "m" THEN "market"
            WHEN market_limit = "l" THEN "limit"
        END AS order_type,
        miscellanious,
        trade_id,
        array_reverse(split(_FILE_NAME, '/'))[SAFE_OFFSET(0)] AS gcs_file_name
    FROM
        XBTUSD_data_bronze
)

select
    *
from
    final_data