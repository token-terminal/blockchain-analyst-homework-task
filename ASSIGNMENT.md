# Senior Blockchain Data Analyst SQL Assignment

## Overview

This assignment evaluates your SQL expertise and understanding of DeFi fundamentals by having you analyze Uniswap V2 pairs on Ethereum to calculate token-denominated prices.

## Task Requirements

### Core Deliverables

1. Calculate daily token reserves for Uniswap V2 pairs on Ethereum:
   - Time period: Since December 1, 2024
   - Measurement: End-of-day (EOD) values
2. Calculate daily token-denominated prices:
   - Compute price of token0 in terms of token1
   - Time period: Since December 1, 2024
   - Measurement: End-of-day (EOD) values

### Expected Output Tables

1. `reserves.sql`:

   ```sql
   columns:
   - timestamp
   - chain
   - pool_address
   - token_0_address
   - token_1_address
   - reserve_0
   - reserve_1
   ```

2. `prices.sql`:
   ```sql
   columns:
   - timestamp
   - chain
   - pool_address
   - token_0_address
   - token_1_address
   - price
   ```

## Technical Considerations

### Performance Optimization

1. Implement incremental model updates
2. Propose query optimization strategies
3. Consider data indexing and partitioning approaches
4. Consider how inactive trading pairs affect your solution.

### Evaluation Criteria

You will be evaluated on:

- Query structure and organization
- Code readability and documentation
- Query performance optimization
- Logic explanation and technical communication
- Error handling and edge cases

## Tips

- Use [Etherscan Token Balance Analytics](https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2?a=0x0d4a11d5eeaac28ec3f61d100daf4d40471f1852#tokenAnalytics) to verify your reserves calculations

## Submission Guidelines

1. Provide SQL queries in separate files to the `./db/user_scripts` folder
2. Include documentation and comments explaining your approach
3. Detail any assumptions made during implementation
