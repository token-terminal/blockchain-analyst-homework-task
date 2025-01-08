#
#
#bq extract \
#  --destination_format=PARQUET \
#  --project_id=project_id \
#  dataset.table \
#  gs://your_bucket_name/your_table.parquet
#
#
#tt-contracts.uniswap_v2_ethereum.Factory_PairCreated_event
#tt-contracts.uniswap_v2_ethereum.Pair_Burn_event
#tt-contracts.uniswap_v2_ethereum.Pair_Mint_event
#tt-contracts.uniswap_v2_ethereum.Pair_Swap_event
#tt-contracts.uniswap_v2_ethereum.Pair_Sync_event
#tt-contracts.uniswap_v2_ethereum.Pair_Transfer_event
#tt-shared-infra.states_tokens.tokens
#gs://tt-blockchain-homework-eu/sql-january-2025-tar/Factory_PairCreated.tar.xz
#
#Write a bash script that extracts the tables and writes them to a gss bucket tt-blockchain-homework-eu/sql-january-2025/ in parquet format.
#
#
tables=(
  "tt-contracts.uniswap_v2_ethereum.Factory_PairCreated_event"
  "tt-contracts.uniswap_v2_ethereum.Pair_Burn_event"
  "tt-contracts.uniswap_v2_ethereum.Pair_Mint_event"
  "tt-contracts.uniswap_v2_ethereum.Pair_Swap_event" -- pending
  "tt-contracts.uniswap_v2_ethereum.Pair_Sync_event" -- pending
  "tt-contracts.uniswap_v2_ethereum.Pair_Transfer_event"
  "tt-shared-infra.states_tokens.tokens"
)

for table in "${tables[@]}"
do
  #split the table name into project_id, dataset, table and use the table..
  project=$(echo $table | cut -d. -f1)
  ds=$(echo $table | cut -d. -f2)
  name=$(echo $table | cut -d. -f3)
  echo $name
  bq extract \
    --destination_format=PARQUET \
    --project_id=$project \
    "$ds.$name" \
    "gs://tt-blockchain-homework-eu/sql-january-2025/${name}_*.parquet"
done
