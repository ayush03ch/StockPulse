-- Test forecast metrics view
SELECT * FROM explo_capstone.v_forecast_metrics
ORDER BY date DESC, product_id
LIMIT 20;
