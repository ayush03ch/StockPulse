-- Moving average forecast + surge index + adjusted demand
WITH base AS (
  SELECT
    dt,
    product_id,
    demand,
    views,
    AVG(demand) OVER (
      PARTITION BY product_id
      ORDER BY dt
      ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) AS forecast_ma,
    LAG(views) OVER (PARTITION BY product_id ORDER BY dt) AS views_prev
  FROM explo_capstone.sales_data
),
calc AS (
  SELECT
    dt,
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
  dt,
  product_id,
  demand,
  views,
  forecast_ma,
  surge_index,
  forecast_ma * (1 + surge_index) AS adjusted_demand
FROM calc;

-- Inventory metrics (example: fixed 7-day lead time, z=1.65)
WITH stats AS (
  SELECT
    product_id,
    AVG(demand) AS avg_daily_demand,
    STDDEV_POP(demand) AS sigma_demand
  FROM explo_capstone.sales_data
  GROUP BY product_id
)
SELECT
  product_id,
  avg_daily_demand,
  sigma_demand,
  1.65 * sigma_demand * SQRT(7) AS safety_stock,
  (avg_daily_demand * 7) + (1.65 * sigma_demand * SQRT(7)) AS reorder_point
FROM stats;
