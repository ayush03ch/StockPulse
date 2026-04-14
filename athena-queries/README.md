# Athena Queries - Inventory Demand Intelligence

This folder contains all SQL queries for the project organized by category.

## Folder Structure

- `01-SETUP-*.sql` - Database and table creation queries (run first, once)
- `04-PROOF-*.sql` - Data validation queries (prove ingestion is working)
- `10-PROCESSING-*.sql` - Analytics and business logic queries
- `query-outputs/` - Output data and screenshots folder

## Step-by-Step Execution

Run queries in this exact order in AWS Athena Query Editor.

### Phase 1: Setup (One-time)
1. `01-SETUP-CreateDatabase.sql` - Create the database
2. `02-SETUP-CreateClickstreamTable.sql` - Create clickstream raw table
3. `03-SETUP-CreateSalesDataTable.sql` - Create curated sales table

### Phase 2: Ingestion Proof (Show Data is Flowing)
4. `04-PROOF-ShowTables.sql` - Verify tables exist
5. `05-PROOF-ClickstreamRowCount.sql` - Count total events
6. `06-PROOF-LatestClickstreamEvents.sql` - View recent events
7. `07-PROOF-ClickstreamByS3File.sql` - Show delivery breakdown
8. `08-PROOF-SalesDataRowCount.sql` - Count sales records
9. `09-PROOF-SalesDataSample.sql` - View sales sample

### Phase 3: Analytics (Business Logic)
10. `10-PROCESSING-ForecastAndSurge.sql` - Demand forecast + surge index
11. `11-PROCESSING-SafetyStockAndROP.sql` - Inventory metrics

### Phase 4: Reusable Views (For Dashboard)
12. `12-PROCESSING-CreateForecastMetricsView.sql` - Forecast view
13. `13-PROCESSING-CreateInventoryMetricsView.sql` - Inventory view
14. `14-TEST-QueryForecastMetricsView.sql` - Test forecast view
15. `15-TEST-QueryInventoryMetricsView.sql` - Test inventory view

## Where to Save Screenshots

After running each query, take a screenshot of the Athena result and save it to `query-outputs/screenshots/` with a name like:

- `01-CreateDatabase.png`
- `02-CreateClickstreamTable.png`
- ...
- `06-LatestClickstreamEvents.png`
- ...
- `11-SafetyStockAndROP.png`

This creates a visual proof document for evaluation.

## Key Business Metrics Explained

1. **Forecast MA** - 4-day moving average of demand
2. **Surge Index** - % change in views from previous day
3. **Adjusted Demand** - Forecast increased/decreased by surge
4. **Safety Stock** - Buffer inventory to prevent stockouts
5. **Reorder Point** - When to order more stock

## Demo Narrative

"We have a complete pipeline from event ingestion through AWS to business intelligence. Proof queries show 1000+ events delivered continuously. Processing queries demonstrate demand forecasting, surge detection, and supply chain optimization metrics that prevent stockouts."
