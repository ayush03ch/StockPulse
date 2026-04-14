-- Create reusable view for inventory metrics (for QuickSight)
-- This view will be used by dashboard to show stock level alerts
CREATE OR REPLACE VIEW explo_capstone.v_inventory_metrics AS
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
