# Set up instructions

## Prerequisites

- Git
- Terminal/Command Line interface
- ~50GB free disk space

## Installation Steps

### 1. Setting up Clickhouse locally

Run the Clickhouse commands in the `db` folder

```bash
# Download and install Clickhouse
curl https://clickhouse.com/ | sh

# Start the Clickhouse server (keep this running in a separate terminal/tmux)
./clickhouse server
```

### Download the data

Run the following commands from the root of this repository.

Use the following command to download the data for the homework task.

Note this will take a monent, there is approx 50GB of data.

Download the files.

```
curl -o db/user_files/Factory_PoolCreated.tar.xz https://storage.googleapis.com/tt-blockchain-homework-eu/sql-january-2025-tar-uni-v3/uni_v3_Factory_PoolCreated.tar.xz
curl -o db/user_files/uni_v3_Pool_Burn.tar.xz https://storage.googleapis.com/tt-blockchain-homework-eu/sql-january-2025-tar-uni-v3/uni_v3_Pool_Burn.tar.xz
curl -o db/user_files/uni_v3_Pool_Mint.tar.xz https://storage.googleapis.com/tt-blockchain-homework-eu/sql-january-2025-tar-uni-v3/uni_v3_Pool_Mint.tar.xz
curl -o db/user_files/uni_v3_Pool_Swap.tar.xz https://storage.googleapis.com/tt-blockchain-homework-eu/sql-january-2025-tar-uni-v3/uni_v3_Pool_Swap.tar.xz
curl -o db/user_files/tokens.tar.xz https://storage.googleapis.com/tt-blockchain-homework-eu/sql-january-2025-tar/tokens.tar.xz
```

### Extract the data

Extract the data to the `db/user_files` folder.

```
tar -xvf db/user_files/uni_v3_Factory_PoolCreated.tar.xz -C db/user_files
tar -xvf db/user_files/uni_v3_Pool_Burn.tar.xz -C db/user_files
tar -xvf db/user_files/uni_v3_Pool_Mint.tar.xz -C db/user_files
tar -xvf db/user_files/uni_v3_Pool_Swap.tar.xz -C db/user_files
tar -xvf db/user_files/tokens.tar.xz -C db/user_files
```

### Import the data to clickhouse you just downloaded

Open clickhouse client in a new tab, in `db` folder.

```
./clickhouse client
```

Run the SQL commands in the `setup.sql` file. You can copy these from the file to the clickhouse client.

## Next Steps

- Review [ASSIGNMENT.md](./ASSIGNMENT.md) for the SQL assignment details
- Write your queries in the user_scripts directory

## Notes

- The complete dataset is approximately 50GB
- Keep the Clickhouse server running in a separate terminal/tmux session
- Make sure you have sufficient disk space before downloading
