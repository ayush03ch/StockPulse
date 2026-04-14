-- Create database for clickstream analytics
CREATE DATABASE IF NOT EXISTS explo_capstone;

-- Raw clickstream table on S3 JSON data
CREATE EXTERNAL TABLE IF NOT EXISTS explo_capstone.clickstream_raw (
  product_id string,
  event string,
  timestamp string,
  user_id string
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
LOCATION 's3://explo-capstone-ayush/clickstream/'
TBLPROPERTIES ('has_encrypted_data'='false');

-- Curated sales table on S3 CSV data
CREATE EXTERNAL TABLE IF NOT EXISTS explo_capstone.sales_data (
  date string,
  product_id string,
  demand int,
  views int
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '"',
  'escapeChar' = '\\'
)
LOCATION 's3://explo-capstone-ayush/curated/sales_data/'
TBLPROPERTIES ('skip.header.line.count'='1');
