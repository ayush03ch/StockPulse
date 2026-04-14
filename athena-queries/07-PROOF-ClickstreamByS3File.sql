-- Show how many events came from each S3 file
-- Proves Firehose is continuously delivering compressed objects to S3
SELECT "$path" AS s3_file_path, count(*) AS rows_in_file
FROM explo_capstone.clickstream_raw
GROUP BY 1
ORDER BY 1 DESC
LIMIT 20;
