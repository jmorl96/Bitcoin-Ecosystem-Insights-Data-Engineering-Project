{{
    config(
        materialized='incremental',
        unique_key='date'
    )
}}

with btc_blocks_data_silver as (
    select
        *
    from
        {{ ref('t_bitcoin_blockchain_blocks_s') }}
    {% if is_incremental() %}

    where 
    extract(DATE FROM timestamp) >= (select max(date) from {{ this }})

    {% endif %}
),

final_data AS (
SELECT
  extract(DATE FROM timestamp) AS date,
  MIN(size) AS min_block_size,
  MAX(size) AS max_block_size,
  AVG(size) AS avg_block_size,
  -- Convert the bits field to a difficulty value. Bitcoin difficulty is a measure of how hard it is to mine a block, adjusted to keep block intervals around 10 minutes. The higher the difficulty, the more computational power is required to mine a block.
  ANY_VALUE(
    4.294967296E+76 / 
    (
      CAST(CONCAT('0x', SUBSTR(bits, 3)) AS FLOAT64) * 
      POW(2, 8 * (CAST(CONCAT('0x', SUBSTR(bits, 1, 2)) AS INT64) - 3))
    )
  ) AS block_difficulty,
  MIN(transaction_count) AS min_block_transaction_count,
  MAX(transaction_count) AS max_block_transaction_count,
  AVG(transaction_count) AS avg_block_transaction_count,
  ARRAY_AGG(
    STRUCT(
      `hash`, 
      size, 
      stripped_size, 
      weight, 
      number, 
      version, 
      merkle_root, 
      timestamp, 
      timestamp_month, 
      nonce, 
      bits, 
      coinbase_param, 
      transaction_count
    )
  ) AS blocks
FROM
    btc_blocks_data_silver
GROUP BY 1
)

SELECT 
    *
FROM final_data