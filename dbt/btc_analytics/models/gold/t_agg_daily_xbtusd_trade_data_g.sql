{{
    config(
        materialized='incremental',
        unique_key='date',
        partition_by={
            "field": "date",
            "data_type": "date",
            "granularity": "day"
        }
    )
}}

with XBTUSD_data_silver as (
    select
        *
    from
        {{ ref('t_xbtusd_trade_data_s') }}
    {% if is_incremental() %}

    where 
    extract(DATE FROM timestamp_time) >= (select max(date) from {{ this }})

    {% endif %}
),

final_data AS (
SELECT
  pair,
  extract(DATE FROM timestamp_time) AS date,
  AVG(price) AS avg_trade_price,
  MIN(price) AS min_trade_price,
  MAX(price) AS max_trade_price,
  sum(volume) AS trade_volume,
  count(trade_id) AS trades_count,
  sum( IF(operation_type = "buy",1,0)) AS buy_operations_count,
  sum( IF(operation_type = "sell",1,0)) AS sell_operations_count,
  sum( IF(order_type = "market",1,0)) as market_type_orders_count,
  sum( IF(order_type = "limit",1,0)) as limit_type_orders_count,
  ARRAY_AGG(
    STRUCT(
      trade_id, 
      price, 
      volume, 
      epoch_time, 
      timestamp_time, 
      operation_type, 
      order_type, 
      miscellanious
    )
  ) AS trades

FROM
    XBTUSD_data_silver
GROUP BY 1,2
)

SELECT 
    *
FROM final_data