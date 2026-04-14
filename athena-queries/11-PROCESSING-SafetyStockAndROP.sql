-- Safety Stock and Reorder Point (ROP) Calculation
-- This query computes inventory control metrics:
-- 1. Average daily demand per product
-- 2. Demand standard deviation (variability)
-- 3. Safety stock = z-score * sigma * sqrt(lead_time_days)
--    (z=1.65 for 95% service level, lead_time=7 days)
-- 4. Reorder point = (avg_daily_demand * lead_time) + safety_stock
-- Proves supply chain optimization logic
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
  ROUND(avg_daily_demand, 2) AS avg_daily_demand,
  ROUND(sigma_demand, 2) AS sigma_demand,
  ROUND(1.65 * sigma_demand * SQRT(7), 2) AS safety_stock,
  ROUND((avg_daily_demand * 7) + (1.65 * sigma_demand * SQRT(7)), 2) AS reorder_point
FROM stats
ORDER BY product_id;
