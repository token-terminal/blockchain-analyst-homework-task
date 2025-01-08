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

CREATE OR REPLACE TABLE Pair_Burn_event (
  block_timestamp DateTime,
    block_number UInt64,
    transaction_hash String,
    log_index UInt64,
    address String,
    removed Boolean,
    in_sender String,
    in_amount0 Int256,
    in_amount1 Int256,
    in_to String,
  )
  ENGINE = MergeTree()
  ORDER BY (block_number, log_index, block_timestamp);

  INSERT INTO Pair_Burn_event SELECT
    block_timestamp,
    block_number,
    transaction_hash,
    log_index,
    address,
    removed,
    in_sender,
    in_amount0,
    in_amount1,
    in_to,
  FROM file('Pair_Burn_event*.parquet', 'parquet');

CREATE OR REPLACE TABLE Pair_Mint_event (
  block_timestamp DateTime,
  block_number UInt64,
  transaction_hash String,
  log_index UInt64,
  address String,
  removed Boolean,
  in_sender String,
  in_amount0 Int256,
  in_amount1 Int256,
)
ENGINE = MergeTree()
ORDER BY (block_number, log_index, block_timestamp);

INSERT INTO Pair_Mint_event SELECT
  block_timestamp,
  block_number,
  transaction_hash,
  log_index,
  address,
  removed,
  in_sender,
  in_amount0,
  in_amount1,
FROM file('Pair_Mint_event*.parquet', 'parquet');

CREATE OR REPLACE TABLE Factory_PairCreated_event (
  block_timestamp DateTime,
  block_number UInt64,
  transaction_hash String,
  log_index UInt64,
  address String,
  removed Boolean,
  in_token0 String,
  in_token1 String,
  in_pair String,
  in_anon3 String,
)
ENGINE = MergeTree()
ORDER BY (block_number, log_index, block_timestamp);

INSERT INTO Factory_PairCreated_event SELECT
  block_timestamp,
  block_number,
  transaction_hash,
  log_index,
  address,
  removed,
  in_token0,
  in_token1,
  in_pair,
  in_anon3,
  FROM file('Factory_PairCreated_event*.parquet', 'parquet');

CREATE OR REPLACE TABLE Pair_Swap_event (
  block_timestamp DateTime,
  block_number Int64,
  transaction_hash String,
  log_index Int64,
  address String,
  removed Boolean,
  in_sender String,
  in_amount0In Int256,
  in_amount1In Int256,
  in_amount0Out Int256,
  in_amount1Out Int256,
  in_to String
)
ENGINE = MergeTree()
ORDER BY (block_timestamp, block_number, log_index);

INSERT INTO Pair_Swap_event
SELECT
  block_timestamp,
  block_number,
  transaction_hash,
  log_index,
  address,
  removed,
  in_sender,
  in_amount0In,
  in_amount1In,
  in_amount0Out,
  in_amount1Out,
  in_to
  FROM file('Pair_Swap_event*.parquet', 'parquet');


CREATE OR REPLACE TABLE Pair_Sync_event (
  block_timestamp DateTime,
  block_number Int64,
  transaction_hash String,
  log_index Int64,
  address String,
  removed Boolean,
  in_reserve0 Int256,
  in_reserve1 Int256,
)

ENGINE = MergeTree()
ORDER BY (block_timestamp, block_number, log_index);

INSERT INTO Pair_Sync_event
SELECT
  block_timestamp,
  block_number,
  transaction_hash,
  log_index,
  address,
  removed,
  in_reserve0,
  in_reserve1
FROM file('Pair_Sync_event*.parquet', 'parquet');