{{
    config(
        materialized='incremental',
        unique_key='date'
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
  count(trade_id) AS n_trades,
  sum( IF(operation_type = "buy",1,0)) AS n_buy_operations,
  sum( IF(operation_type = "sell",1,0)) AS n_sell_operations,
  sum( IF(order_type = "market",1,0)) as n_orders_market_type,
  sum( IF(order_type = "limit",1,0)) as n_orders_limit_type,
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