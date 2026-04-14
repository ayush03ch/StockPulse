-- Create external table for raw clickstream data from S3 (JSON format)
-- This table reads compressed JSON objects from S3 delivered by Kinesis Firehose
CREATE EXTERNAL TABLE IF NOT EXISTS explo_capstone.clickstream_raw (
  product_id string,
  event string,
  timestamp string,
  user_id string
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
LOCATION 's3://explo-capstone-ayush/clickstream/'
TBLPROPERTIES ('has_encrypted_data'='false');
