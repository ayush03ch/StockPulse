-- Create external table for curated daily sales data from S3 (CSV format)
-- Date is stored as string and will be cast to date in queries
CREATE EXTERNAL TABLE IF NOT EXISTS explo_capstone.sales_data (
  date string,
  product_id string,
  demand int,
  views int
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
LOCATION 's3://explo-capstone-ayush/curated/sales_data/'
TBLPROPERTIES ('skip.header.line.count'='1');
