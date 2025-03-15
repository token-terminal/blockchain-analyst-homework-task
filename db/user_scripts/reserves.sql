with pool_info as (
    select  
          in_pool as pool_address
        , in_token0 as token_0_address
        , in_token1 as token_1_address   
    from uni_v3_Factory_PoolCreated_event
 --  where lower(in_pool) = lower('0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640')
)
, token_metadata as (
    select 
          token_address
        , decimals
    from tokens
   where chain = 'ethereum'
)
, mint_events as (
    select
          block_timestamp as timestamp
        , address as pool_address
        , in_tickLower as tick_lower
        , in_tickUpper as tick_upper
        , in_amount as liquidity_delta
        , in_amount0 as amount0
        , in_amount1 as amount1
    from uni_v3_Pool_Mint_event  -- Add Liquidity (Mint is emitted when a user is providing liquidity to the pool)
)
, burn_events as (
    select
        block_timestamp as timestamp,
        address as pool_address,
        in_tickLower as tick_lower,
        in_tickUpper as tick_upper,
        -in_amount as liquidity_delta, -- Negative for burns
        -in_amount0 as amount0,        
        -in_amount1 as amount1         
    from uni_v3_Pool_Burn_event -- Remove Liquidity (Burn is emitted when a user is removing liquidity from the pool)
)
, liquidity_events as (
    select * from mint_events
    union all
    select * from burn_events
)
, swaps as (
    select
          block_timestamp as timestamp
        , log_index  
        , address as pool_address
        , in_tick as tick
        , in_sqrtPriceX96 as sqrt_price_x96
        , in_liquidity as pool_liquidity
    from uni_v3_Pool_Swap_event  -- Swap (Swap is emitted when a user is trading in the pool)
)
/* we are calculating the most recent sqrtPriceX96 for all liquidity events at the end of each day 
   -- can be done for each liquidity event but query was taking too long so chose this approach  
*/
, daily_last_swap as (
    select
          date_trunc('day', timestamp) as event_date
        , pool_address
        , argMax(tick, (timestamp,log_index)) as current_tick
        , argMax(sqrt_price_x96, (timestamp,log_index)) as current_sqrt_price_X96
        , argMax(pool_liquidity, (timestamp,log_index)) as active_liquidity
    from swaps
    group by 1,2
)
-- Calculate cumulative liquidity for each tick range by day
, daily_positions as (
    select
          date_trunc('day', timestamp) as event_date
        , pool_address
        , tick_lower
        , tick_upper
        , sum(liquidity_delta) as liquidity
    from liquidity_events
    group by 1,2,3,4
)
-- Join positions with daily prices to determine active liquidity
, active_positions as (
    select
          p.event_date as event_date
        , p.pool_address as pool_address
        , p.tick_lower as tick_lower
        , p.tick_upper as tick_upper
        , p.liquidity as liquidity
        , s.current_tick as current_tick
        , s.current_sqrt_price_X96 / pow(2, 96) as current_sqrt_price
        , multiIf((s.current_tick >= p.tick_lower) and (s.current_tick < p.tick_upper), p.liquidity, 0) as active_liquidity --liquidity is only active if the current tick is in range of lower and upper tick
        , sqrt(pow(1.0001, toInt64(p.tick_lower))) as sqrt_ratio_lower --clickhouse only takes (U)Int8/16/32/64
        , sqrt(pow(1.0001, toInt64(p.tick_upper))) as sqrt_ratio_upper
    from daily_positions as p
    inner join daily_last_swap as s 
       on p.event_date = s.event_date
      and p.pool_address = s.pool_address
    where p.liquidity > 0
)
, tradable_reserves as (
    select
          event_date
        , pool_address
        , sum(active_liquidity) as total_active_liquidity
        -- Calculate token0 reserves using Uniswap V3 math
        , sum(
                multiIf(
                        current_sqrt_price <= sqrt_ratio_lower, 
                           toFloat64(liquidity) * ((sqrt_ratio_upper - sqrt_ratio_lower) / (sqrt_ratio_lower * sqrt_ratio_upper)), 
                        current_sqrt_price >= sqrt_ratio_upper, 
                           0, 
                        toFloat64(liquidity) * ((sqrt_ratio_upper - current_sqrt_price) / (current_sqrt_price * sqrt_ratio_upper))
                )
            ) as token0_reserves
        -- Calculate token1 reserves using Uniswap V3 math
        , sum(
                multiIf(
                        current_sqrt_price <= sqrt_ratio_lower, 
                           0, 
                        current_sqrt_price >= sqrt_ratio_upper, 
                           toFloat64(liquidity) * (sqrt_ratio_upper - sqrt_ratio_lower), 
                        toFloat64(liquidity) * (current_sqrt_price - sqrt_ratio_lower)
                )
            ) as token1_reserves
    from active_positions
    group by 1,2
)
select 
      r.event_date as timestamp
    , 'ethereum' as chain
    , r.pool_address as pool_address
    , p.token_0_address
    , p.token_1_address
    , r.token0_reserves / pow(10, t0.decimals) as reserve_0 -- decimal normalization
    , r.token1_reserves / pow(10, t1.decimals) as reserve_1
from tradable_reserves as r
inner join pool_info as p
   on lower(r.pool_address) = lower(p.pool_address)
left join token_metadata as t0 
  on lower(t0.token_address) = lower(p.token_0_address)
left join token_metadata as t1 
  on lower(t1.token_address) = lower(p.token_1_address)
order by 1 desc
