-- View latest 20 clickstream events (most recent first)
-- Proves ingestion is working end-to-end from local producer -> Kinesis -> S3
SELECT product_id, event, timestamp, user_id
FROM explo_capstone.clickstream_raw
ORDER BY timestamp DESC
LIMIT 20;
