CREATE OR REPLACE TABLE tokens (
  chain String,
  name String,
  symbol String,
  token_address String,
  decimals Int32,
  launch_timestamp DateTime
)
ENGINE = MergeTree()
ORDER BY (chain, name, symbol, token_address, decimals, launch_timestamp);

INSERT INTO tokens
SELECT
  chain,
  name,
  symbol,
  token_address,
  decimals,
  launch_timestamp
FROM file('tokens*.parquet', 'parquet');

CREATE OR REPLACE TABLE uni_v3_Pool_Burn_event (
    block_timestamp DateTime,
    block_number UInt64,
    transaction_hash String,
    log_index UInt64,
    address String,
    removed Boolean,
    in_tickLower Int256,
    in_tickUpper Int256,
    in_amount Int256,
    in_amount0 Int256,
    in_amount1 Int256,
  )
  ENGINE = MergeTree()
  ORDER BY (block_number, log_index, block_timestamp);

  INSERT INTO uni_v3_Pool_Burn_event SELECT
    block_timestamp,
    block_number,
    transaction_hash,
    log_index,
    address,
    removed,
    in_tickLower,
    in_tickUpper,
    in_amount,
    in_amount0,
    in_amount1,
  FROM file('uni_v3_Pool_Burn_event*.parquet', 'parquet');

CREATE OR REPLACE TABLE uni_v3_Pool_Mint_event (
  block_timestamp DateTime,
  block_number UInt64,
  transaction_hash String,
  log_index UInt64,
  address String,
  removed Boolean,
  in_sender String,
  in_owner String,
  in_tickLower Int256,
  in_tickUpper Int256,
  in_amount Int256,
  in_amount0 Int256,
  in_amount1 Int256,
)
ENGINE = MergeTree()
ORDER BY (block_number, log_index, block_timestamp);

INSERT INTO uni_v3_Pool_Mint_event SELECT
  block_timestamp,
  block_number,
  transaction_hash,
  log_index,
  address,
  removed,
  in_sender,
  in_owner,
  in_tickLower,
  in_tickUpper,
  in_amount,
  in_amount0,
  in_amount1,
FROM file('uni_v3_Pool_Mint_event*.parquet', 'parquet');

CREATE OR REPLACE TABLE uni_v3_Factory_PoolCreated_event (
  block_timestamp DateTime,
  block_number UInt64,
  transaction_hash String,
  log_index UInt64,
  address String,
  removed Boolean,
  in_token0 String,
  in_token1 String,
  in_fee Int256,
  in_tickSpacing Int256,
  in_pool String,
)
ENGINE = MergeTree()
ORDER BY (block_number, log_index, block_timestamp);

INSERT INTO uni_v3_Factory_PoolCreated_event SELECT
  block_timestamp,
  block_number,
  transaction_hash,
  log_index,
  address,
  removed,
  in_token0,
  in_token1,
  in_fee,
  in_tickSpacing,
  in_pool,
FROM file('uni_v3_Factory_PoolCreated_event*.parquet', 'parquet');

CREATE OR REPLACE TABLE uni_v3_Pool_Swap_event (
  block_timestamp DateTime,
  block_number Int64,
  transaction_hash String,
  log_index Int64,
  address String,
  removed Boolean,
  in_sender String,
  in_recipient String,
  in_amount0 Int256,
  in_amount1 Int256,
  in_sqrtPriceX96 Int256,
  in_liquidity Int256,
  in_tick Int256
)
ENGINE = MergeTree()
ORDER BY (block_timestamp, block_number, log_index);

INSERT INTO uni_v3_Pool_Swap_event
SELECT
  block_timestamp,
  block_number,
  transaction_hash,
  log_index,
  address,
  removed,
  in_sender,
  in_recipient,
  in_amount0,
  in_amount1,
  in_sqrtPriceX96,
  in_liquidity,
  in_tick
FROM file('uni_v3_Pool_Swap_event*.parquet', 'parquet');