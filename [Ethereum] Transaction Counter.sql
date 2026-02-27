WITH time_filter AS (
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

all_events AS (
  SELECT DATE_TRUNC('day', block_time) AS day, 1 AS tx, 0 AS internal, 0 AS erc20, 0 AS erc721, 0 AS erc1155
  FROM ethereum.transactions
  CROSS JOIN address 
  CROSS JOIN time_filter 
  WHERE ("from" = addr OR "to" = addr) AND block_time >= start_date
  
  UNION ALL
  
  SELECT DATE_TRUNC('day', block_time), 0, 1, 0, 0, 0
  FROM ethereum.traces
  CROSS JOIN address 
  CROSS JOIN time_filter 
  WHERE ("from" = addr OR "to" = addr) AND block_time >= start_date
  
  UNION ALL
  
  SELECT DATE_TRUNC('day', evt_block_time), 0, 0, 1, 0, 0
  FROM erc20_ethereum.evt_Transfer
  CROSS JOIN address 
  CROSS JOIN time_filter 
  WHERE ("from" = addr OR "to" = addr) AND evt_block_time >= start_date
  
  UNION ALL
  
  SELECT DATE_TRUNC('day', evt_block_time), 0, 0, 0, 1, 0
  FROM erc721_ethereum.evt_Transfer
  CROSS JOIN address 
  CROSS JOIN time_filter 
  WHERE ("from" = addr OR "to" = addr) AND evt_block_time >= start_date
  
  UNION ALL
  
  SELECT DATE_TRUNC('day', evt_block_time), 0, 0, 0, 0, 1
  FROM erc1155_ethereum.evt_TransferSingle
  CROSS JOIN address 
  CROSS JOIN time_filter 
  WHERE ("from" = addr OR "to" = addr) AND evt_block_time >= start_date
  
  UNION ALL
  
  SELECT DATE_TRUNC('day', evt_block_time), 0, 0, 0, 0, 1
  FROM erc1155_ethereum.evt_TransferBatch
  CROSS JOIN address 
  CROSS JOIN time_filter 
  WHERE ("from" = addr OR "to" = addr) AND evt_block_time >= start_date
),

daily_stats AS (
  SELECT 
    day,
    SUM(tx) AS tx_count,
    SUM(internal) AS internal_count,
    SUM(erc20) AS erc20_transfer_count,
    SUM(erc721) AS erc721_transfer_count,
    SUM(erc1155) AS erc1155_transfer_count
  FROM all_events
  GROUP BY 1
)

SELECT
  day,
  tx_count,
  internal_count,
  erc20_transfer_count,
  erc721_transfer_count,
  erc1155_transfer_count,
  -- Cumulative calculations
  SUM(tx_count) OVER (ORDER BY day) AS cum_tx,
  SUM(internal_count) OVER (ORDER BY day) AS cum_internal,
  SUM(erc20_transfer_count) OVER (ORDER BY day) AS cum_erc20,
  SUM(erc721_transfer_count) OVER (ORDER BY day) AS cum_erc721,
  SUM(erc1155_transfer_count) OVER (ORDER BY day) AS cum_erc1155,
  -- Daily and Cumulative Totals
  (tx_count + internal_count + erc20_transfer_count + erc721_transfer_count + erc1155_transfer_count) AS total_transaction_count,
  SUM(tx_count + internal_count + erc20_transfer_count + erc721_transfer_count + erc1155_transfer_count) OVER (ORDER BY day) AS cum_total_transaction_count
FROM daily_stats
ORDER BY day;
