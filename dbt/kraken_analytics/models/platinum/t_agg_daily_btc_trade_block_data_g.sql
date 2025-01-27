{{
    config(
        materialized='incremental',
        unique_key='date'
    )
}}

with btc_agg_daily_blocks_data_gold as (
    select
        *
    from
        {{ ref('t_agg_daily_bitcoin_blockchain_blocks_g') }}
    {% if is_incremental() %}

    where 
    date >= (select max(date) from {{ this }})

    {% endif %}
),

btc_agg_daily_trade_data_gold as (
    select
        *
    from
        {{ ref('t_agg_daily_xbtusd_trade_data_g') }}
    {% if is_incremental() %}

    where 
    date >= (select max(date) from {{ this }})

    {% endif %}
),

final_data AS (
SELECT
  pair,
  COALESCE(trade.date, blockchain.date) AS date,
  avg_trade_price,
  min_trade_price,
  max_trade_price,
  trade_volume,
  n_trades,
  n_buy_operations,
  n_sell_operations,
  n_orders_market_type,
  n_orders_limit_type,
  min_block_size,
  max_block_size,
  avg_block_size,
  block_difficulty,
  min_block_transaction_count,
  max_block_transaction_count,
  avg_block_transaction_count,
  trades,
  blocks
FROM
  btc_agg_daily_trade_data_gold AS trade

FULL OUTER JOIN
  btc_agg_daily_blocks_data_gold AS blockchain

ON trade.date = blockchain.date

)

SELECT 
    *
FROM final_data

ORDER BY date ASC