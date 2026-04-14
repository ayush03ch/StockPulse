-- Forecast + Surge Index + Adjusted Demand
-- This query computes:
-- 1. Moving average demand (4-day window)
-- 2. View surge index (% change from previous day)
-- 3. Adjusted demand = forecast * (1 + surge_index)
-- Proves demand forecasting and surge detection logic
WITH base AS (
  SELECT
    CAST(date AS date) AS date,
    product_id,
    demand,
    views,
    AVG(demand) OVER (
      PARTITION BY product_id
      ORDER BY CAST(date AS date)
      ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) AS forecast_ma,
    LAG(views) OVER (PARTITION BY product_id ORDER BY CAST(date AS date)) AS views_prev
  FROM explo_capstone.sales_data
),
calc AS (
  SELECT
    date,
    product_id,
    demand,
    views,
    forecast_ma,
    CASE
      WHEN COALESCE(views_prev, 0) = 0 THEN 0
      ELSE (views - views_prev) * 1.0 / views_prev
    END AS surge_index
  FROM base
)
SELECT
  date,
  product_id,
  demand,
  views,
  ROUND(forecast_ma, 2) AS forecast_ma,
  ROUND(surge_index, 4) AS surge_index,
  ROUND(forecast_ma * (1 + surge_index), 2) AS adjusted_demand
FROM calc
ORDER BY date DESC, product_id;
