-- Finding last sqrtPriceX96 for each Uniswap V3 pool at the end of each day from Swaps.
with eod_swaps as (
    select
          date_trunc('day', block_timestamp) as timestamp
        , address as pool_address
        , argMax(in_sqrtPriceX96, (timestamp, log_index)) as eod_sqrt_price_x96
    from uni_v3_Pool_Swap_event
   group by 1,2
)
, pool_info as (
    select  
          in_pool as pool_address
        , in_token0 as token_0_address
        , in_token1 as token_1_address   
    from uni_v3_Factory_PoolCreated_event
)
, token_metadata as (
    select 
          token_address
        , decimals
     from tokens    
    where chain = 'ethereum' -- as 'tokens' has data for all the chains
)
, price as (
    select
        s.timestamp
        , s.pool_address
        , p.token_0_address
        , p.token_1_address
        , pow((toFloat64(s.eod_sqrt_price_x96) / pow(2, 96)), 2) as price    -- price of token0 in terms of token1 = (sqrtPriceX96/2^96)^2
    from eod_swaps s
    join pool_info p 
    on lower(s.pool_address) = lower(p.pool_address)
)
select 
      p.timestamp
    , p.pool_address
    , p.token_0_address
    , p.token_1_address
    , p.price * (pow(10,t0.decimals)/pow(10,t1.decimals)) as price   -- decimal normalized price
from price p    
join token_metadata t0
  on t0.token_address = p.token_0_address
join token_metadata t1
  on t1.token_address = p.token_1_address    
