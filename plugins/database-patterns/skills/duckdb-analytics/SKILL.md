---
name: duckdb-analytics
description: DuckDB columnar OLAP patterns — reading from Parquet/CSV/S3, GROUP BY ALL, COPY TO for export, OLAP vs OLTP distinction, ETL/ELT/Reverse-ETL concepts, and when columnar databases are the right choice. Use when running analytics, building dashboards, exploring large datasets, or evaluating whether an OLAP database is needed.
---

# DuckDB and columnar analytics

DuckDB is an embedded columnar (OLAP) database — like SQLite but designed for analytical workloads. It operates directly on files (Parquet, CSV, JSON) with no server process required.

## OLAP vs OLTP

- **OLTP** (PostgreSQL, MongoDB): "Give me user #47's profile" — row-oriented, optimized for single-record lookups and transactions
- **OLAP** (DuckDB, ClickHouse, Snowflake): "What's the average age across 10 million users?" — column-oriented, optimized for aggregations across large datasets

**Never use a columnar DB as your app's primary transactional store.** It's for analytics alongside your OLTP database.

### Why columnar is faster for analytics
Row databases store entire rows together on disk. To compute "average of column X across 10M rows," Postgres reads every full row. Columnar databases store each column separately — so DuckDB reads only the X column, skipping everything else. Much less I/O for aggregate queries.

The tradeoff: reconstructing a single complete row requires reaching into every column's storage.

## Getting started

```bash
# Install (macOS)
brew install duckdb
# or download from https://duckdb.org/install/

# Open a database file
duckdb my-duck.db

# Or use the browser UI
duckdb -ui my-duck.db
```

## Query remote data directly

```sql
-- Read from S3 (no download needed)
SELECT * FROM read_parquet(
  's3://bucket/path/to/data.parquet'
) LIMIT 10;

-- Load into a local table
CREATE TABLE netflix AS SELECT * FROM read_parquet('s3://bucket/netflix.parquet');

-- Quick look at the data
FROM netflix LIMIT 5;           -- shortcut for SELECT * FROM
DESCRIBE netflix;               -- column names and types
SELECT DISTINCT title FROM netflix LIMIT 25;
```

DuckDB can read Parquet, CSV, JSON, and other formats directly — even from remote URLs and S3.

## Analytical queries

```sql
-- COVID lockdown binge watching
SELECT Title, Type, MAX("Days In Top 10") as peak_days
FROM netflix
WHERE "As of" BETWEEN '2020-03-15' AND '2020-06-30'
GROUP BY ALL
ORDER BY peak_days DESC
LIMIT 10;

-- Netflix exclusive performance
SELECT
  Title, Type,
  MAX("Days In Top 10") as total_days,
  ROUND(AVG("Viewership Score"), 1) as avg_score
FROM netflix
WHERE "Netflix Exclusive" = 'Yes'
GROUP BY ALL
ORDER BY total_days DESC
LIMIT 10;
```

### GROUP BY ALL
DuckDB's quality-of-life feature: automatically groups by all non-aggregate columns in SELECT. No need to manually list every column in GROUP BY (a pain in Postgres when you're iterating on queries with many columns).

## Export results

```sql
COPY (
  SELECT Title, Type, MAX("Days In Top 10") as peak_days
  FROM netflix
  GROUP BY ALL
  ORDER BY peak_days DESC
) TO 'top_titles.csv' (HEADER);
```

Export to CSV, Parquet, JSON, and other formats. Core to OLAP workflows — get results out for sharing, dashboards, or further processing.

## ETL / ELT concepts

How does data get into an OLAP database?

- **ETL** (Extract, Transform, Load): Pull data from your OLTP DB, transform it into analytical schema, load into OLAP. Transform happens before load — slower to set up but queries are clean.
- **ELT** (Extract, Load, Transform): Dump raw data in, transform at query time. Faster to set up, data is closer to real-time, but queries are more complex.
- **Reverse-ETL**: Run analytics in OLAP, push insights back to your OLTP DB for use in the product (e.g., "users who bought X also bought Y" recommendations).

DuckDB's file-based approach makes ELT simple: have your app dump CSV/Parquet to S3, then DuckDB reads it directly.

## Data formats

- **Parquet**: The standard for columnar data. Efficient, compressed, widely supported.
- **Apache Iceberg**: Adds ACID, schema evolution, and time travel on top of Parquet. Industry standard for lakehouses.
- **Delta Lake**: Databricks' alternative to Iceberg (converging with Iceberg v3).

DuckDB reads Parquet natively. It has growing support for Iceberg and Delta Lake.

## Golden rules

- ✅ Use DuckDB for analytics, reporting, and data exploration.
- ✅ Use `GROUP BY ALL` to save time on iterative queries.
- ✅ Read directly from Parquet/S3 — no need to import first.
- ✅ Use `COPY TO` to export results for sharing.
- ✅ Keep your OLTP and OLAP databases separate — different tools for different jobs.
- ❌ Don't use DuckDB as your app's primary database.
- ❌ Don't try to serve real-time user requests from a columnar DB.
- ❌ Don't reinvent ETL — use DuckDB's native file reading for simple pipelines.

## Related skills

- `database-selection` — when OLAP vs OLTP
- `postgresql-querying` — SQL fundamentals (DuckDB uses similar SQL syntax)
