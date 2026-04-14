-- Create reusable view for forecast metrics (for QuickSight)
-- This view will be used by dashboard to show trends over time
CREATE OR REPLACE VIEW explo_capstone.v_forecast_metrics AS
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
  forecast_ma,
  surge_index,
  forecast_ma * (1 + surge_index) AS adjusted_demand
FROM calc;
