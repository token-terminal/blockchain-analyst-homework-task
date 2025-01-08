#!/bin/bash

# Download the public db/user_files
mkdir -p db/user_files


curl -o db/user_files/tokens.parquet https://storage.googleapis.com/tt-blockchain-homework-eu/sql-january-2025/tokens.parquet
curl -o db/user_files/Factory_PairCreated_event.parquet https://storage.googleapis.com/tt-blockchain-homework-eu/sql-january-2025/Factory_PairCreated_event.parquet
curl -o db/user_files/Pair_Burn_event.parquet https://storage.googleapis.com/tt-blockchain-homework-eu/sql-january-2025/Pair_Burn_event.parquet
curl -o db/user_files/Pair_Mint_event.parquet https://storage.googleapis.com/tt-blockchain-homework-eu/sql-january-2025/Pair_Mint_event.parquet
curl -o db/user_files/Pair_Swap_event.parquet https://storage.googleapis.com/tt-blockchain-homework-eu/sql-january-2025/Pair_Swap_event.parquet
curl -o db/user_files/Pair_Sync_event.parquet https://storage.googleapis.com/tt-blockchain-homework-eu/sql-january-2025/Pair_Sync_event.parquet
curl -o db/user_files/Pair_Transfer_event.parquet https://storage.googleapis.com/tt-blockchain-homework-eu/sql-january-2025/Pair_Transfer_event.parquet

