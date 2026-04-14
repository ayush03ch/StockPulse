-- View sample rows from curated sales data
SELECT date, product_id, demand, views
FROM explo_capstone.sales_data
ORDER BY date DESC, product_id
LIMIT 20;
