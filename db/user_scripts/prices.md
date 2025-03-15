## Task

To calculate the price of token0 in terms of token1 at the end of each day 

### Approach

- Retreive the latest sqrtPriceX96 from swaps event for each pool at the end of each day. (We can find the Price either from sqrtPriceX96 or the current tick and here we are using sqrtPriceX96).
- Calculate price from sqrtPriceX96 : 

        Let x = token0
            y = token1
         P = price of x in terms of y = y/x

         sqrtPriceX96 = sqrt(P) * 2^96
      => P = (sqrtPriceX96/ 2^96) ^ 2

<!-- If using tick then price = ((1.001) ^ tick) where tick = current tick -->

### Assumption

- There are no gaps in the data as I have checked. So based on that, the query does not have any code for fillling gaps. But I am adding the snippet below for the same (in case there are gaps).

To fill gaps between the dates, we can interpolate the data as following : 
  ```sql

    with base as (
        select * from prices -- here prices is the prices.sql query
    )
    select 
        timestamp,
        pool_address,
        token_0_address,
        token_1_address,
        price
    from prices 
    order by 1 
    WITH FILL STEP toIntervalDay(1)
    INTERPOLATE (price as price)     

  ```  
