-- Check total rows received from live clickstream ingestion
SELECT COUNT(*) AS total_clickstream_rows
FROM explo_capstone.clickstream_raw;
