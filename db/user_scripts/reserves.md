## Task

To calculate token reserves for Uniswap V3 pools at the end of each day.

### Approach

- Took `Mint`, `Burn` and `Swap` events as all of them affect liquidity in a pool.
 `Mint` is emitted when an LP provides liquidity to a pool whereas `Burn` is emitted when LP removes liquidity from a pool. Both have the liquidity delta i.e. the amount being added or removed and `tickLower` & `tickUpper` which define the price range in which the liquidity is being provided or removed.

- Further, the `Swap` event logs the current `tick` and `sqrtPriceX96` which tells us the current tick of the pool i.e. this defines the current price range of the pool. 
For active liquidity, the current tick needs to be between the `tickLower` and `tickUpper` of the liquidity events - Mint and Burn. Thus, to deteremine active liquidity, I retrieved the end of the day tick and sqrtPriceX96 for each pool. 
The position is in range if:
    - The current tick is greater than or equal to your tickLower
    - The current tick is strictly less than your tickUpper
        tickLower <= current_tick < tickUpper
​
<!-- Ideally it should be calculated before each Mint and Burn event but the query was taking too long for even 1 pool so I resolved to this approach of eod values -->
- After retrieving the current tick and current sqrtPriceX96 (eod values), I calculated activeLiquidity, sqrt_ratio_lower and sqrt_ratio_upper
        sqrt_ratio_lower = sqrt(1.0001 ^ tickLower)
        sqrt_ratio_upper = sqrt(1.0001 ^ tickUpper)

- Then tradable reserves, reserve_0 and reserve_1 are calculated using Uniswap V3 Maths. There are two different methods to calculate the amount of tokens held in a position:
    - when a position is in range
    - when a position is out of range
When a position is in range then :
     token0 = liquidity * ((sqrtRatioU - sqrtPrice) / (sqrtPrice * sqrtRatioU)) <!-- sqrtPrice = sqrtPriceX96/2^96 -->
     token1 = liquidity * (sqrtPrice - sqrtRatioL)
When a position is out range then :
    If sqrtPrice <= sqrtRatioL then
       token0 = liquidity * ((sqrtRatioU - sqrtRatioL) / (sqrtRatioL * sqrtRatioU)) <!-- sqrtPrice = sqrtPriceX96/2^96 -->
       token1 = 0
    If sqrtRatioU <= sqrtPrice 
       token0 = 0
       token1 = liquidity * (sqrtRatioU - sqrtRatioL)
Reference : [Here](https://blog.uniswap.org/uniswap-v3-math-primer-2)


### Assumptions

- The latest sqrtPriceX96 and tick should be calculated after each swap and before each Mint/ Burn event. But I calculated at the end of the each day to make query execute faster. Example : [dune spellbook liquidity by me](https://github.com/duneanalytics/spellbook/blob/main/dbt_subprojects/dex/macros/models/_project/uniswap_compatible_liquidity.sql)
- It has been mentioned to study fee structure however, according to docs, in Uniswap V3 the swap fees is stored and not added back to the pool. Hence, it does not directly affect the tradable reserves of the pool. The LP's can collect their fees without removing the liquidity from pool so reserves are not being affected. However, fee tiers (uniswap v3 pools have different fee tiers - 0.05%, 0.3%, 1% etc) might affect the price ranges in which liquidity can be provided but this is already catered in the code and the ticks are logged in the liquidity events accordingly. 

### Additional Notes 

- To implement incremental strategy, we can use `dbt` and create models where the configuration will be set as follows : 
    ```
    {{ config(
          schema = '...'
        , materialized = 'incremental'
        , incremental_strategy = 'merge'
      )   
    }}
    ```
- For optimisation, we can create MV's in clickhouse for Swaps, which can be used for both `reserves.sql` and `prices.sql`
  ```sql

    CREATE MATERIALIZED VIEW daily_last_swap mv
        ENGINE = ReplacingMergeTree
        PARTITION BY toYYYYMMDD(timestamp)
        ORDER BY (pool_address, timestamp) -- works like index in Oracle for faster lookup
        POPULATE AS
            SELECT 
                pool_address,
                toStartOfDay(block_timestamp) AS timestamp, -- Group by day
                argMax(in_sqrtPriceX96, (block_timestamp,log_index)) AS sqrtPriceX96,
                argMax(in_tick, (block_timestamp,log_index)) AS tick,
                max(block_timestamp) AS latest_timestamp
            FROM uni_v3_Pool_Swap_event
            GROUP BY pool_address,day ;  
              
    ```    