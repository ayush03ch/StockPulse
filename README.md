# StockPulse

Smart inventory demand intelligence for retail planning.

The project simulates clickstream events, stores them in AWS, and turns the data into practical inventory metrics like forecast, surge-adjusted demand, safety stock, and reorder point.

## What this project does

- Generates synthetic clickstream activity for products
- Pushes events to Amazon Kinesis
- Delivers stream data to Amazon S3 through Firehose
- Queries data in Athena
- Computes demand and inventory metrics
- Prepares output for QuickSight dashboarding



## Tech stack

- Python
- boto3, pandas, numpy
- AWS Kinesis Data Streams
- AWS Kinesis Data Firehose
- Amazon S3
- AWS Athena + Glue Data Catalog
- Amazon QuickSight (pending dashboard finalization)

## Project structure

- src/generator/clickstream_producer.py: sends clickstream records to Kinesis
- src/processing/generate_sample_data.py: creates sample sales and views data
- src/processing/forecast_inventory.py: computes forecasting and inventory metrics
- sql/athena_glue_setup.sql: Athena database and table setup
- sql/athena_metrics.sql: analytics queries (forecast, surge, safety stock, ROP)
- athena-queries/: clean step-by-step SQL files used in Athena GUI
- dashboard/kpi_spec.md: dashboard visual requirements
- status-report/: detailed project status document

## Local run

1. Install dependencies

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

2. Generate sample data

```powershell
python src/processing/generate_sample_data.py
```

3. Run metric pipeline

```powershell
python src/processing/forecast_inventory.py --input data/sales_data.csv --output data/inventory_metrics.csv --kpi data/kpi_snapshot.csv
```

4. Check outputs

- data/sales_data.csv
- data/inventory_metrics.csv
- data/kpi_snapshot.csv

## AWS run

1. Create a .env file from .env.example
2. Fill in AWS region and stream details
3. Start producer:

```powershell
python src/generator/clickstream_producer.py
```

4. In Athena, run the SQL files from athena-queries in numeric order
5. Save query outputs/screenshots in athena-queries/query-outputs/screenshots

## Core formulas

- Forecast (moving average): average demand over recent 4 periods
- Surge Index: (views_today - views_yesterday) / views_yesterday
- Adjusted Demand: forecast_ma * (1 + surge_index)
- Safety Stock: z * sigma_demand * sqrt(lead_time_days)
- Reorder Point: (avg_daily_demand * lead_time_days) + safety_stock

## Notes

- This is an MVP focused on pipeline stability and useful business logic.
- Advanced ML (returns/stockout probability) is planned for later.
- Frontend complexity was intentionally kept low during initial build.


