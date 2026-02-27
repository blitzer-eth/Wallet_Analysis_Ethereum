WITH 
time_filter AS (
  SELECT 
    CASE 
      WHEN '{{Time Period}}' = 'Past Week'     THEN CURRENT_DATE - INTERVAL '7' day
      WHEN '{{Time Period}}' = 'Past Month'    THEN CURRENT_DATE - INTERVAL '30' day
      WHEN '{{Time Period}}' = 'Past 3 Months' THEN CURRENT_DATE - INTERVAL '90' day
      WHEN '{{Time Period}}' = 'Past Year'     THEN CURRENT_DATE - INTERVAL '365' day
      WHEN '{{Time Period}}' = 'All Time'      THEN CAST('2015-07-30' AS DATE)
      ELSE CURRENT_DATE - INTERVAL '30' day
    END AS start_date
),

address AS (
  SELECT FROM_HEX(LOWER(REPLACE(TRIM('{{wallet address:}}'), '0x', ''))) AS addr
),

daily_gas AS (
  SELECT
    DATE_TRUNC('day', block_time) AS day,
    SUM(gas_used * gas_price) / 1e18 AS daily_gas_eth
  FROM ethereum.transactions
  CROSS JOIN address
  CROSS JOIN time_filter
  WHERE "from" = addr
    AND block_time >= time_filter.start_date
  GROUP BY 1
)

SELECT
  day,
  CAST(daily_gas_eth AS DECIMAL(10,5)) AS daily_gas_eth,
  CAST(SUM(daily_gas_eth) OVER (ORDER BY day) AS DECIMAL(10,5)) AS cumulative_gas_eth
FROM daily_gas
ORDER BY day;
