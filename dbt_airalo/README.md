# dbt-airalo

A dbt project for transforming and modeling Airalo's eSIM order and user data in BigQuery.

## 📋 Project Overview

This dbt project transforms raw Airalo data into analytics-ready models for reporting and analysis. It processes:
- **User data** - Platform usage, acquisition channels, and geographic information
- **Order data** - eSIM purchases, payments, and order lifecycle tracking
- **Exchange rate data** - Multi-currency conversion for financial analysis

## 🏗️ Project Structure

```
dbt_airalo/
├── macros/               # Custom macros
├── models/
│   ├── staging/          # Raw data staging layer
│   │   ├── stg_user.sql
│   │   ├── stg_order.sql
│   │   └── stg_exchange_rate.sql
│   ├── intermediate/     # Business logic transformations
│   │   ├── dim_user.sql (incremental)
│   │   ├── fct_order.sql (incremental)
│   │   └── fct_exchange_rate.sql (incremental)
│   └── marts/            # Final analytics models
│       ├── order.sql (incremental)
│       ├── user.sql (incremental)
│       ├── _user_metrics_on_orders.sql (ephemeral)
│       └── metrics/
├── snapshots/            # Snapshot configurations
├── docs/                 # Project documentation
├── logs/                 # dbt logs
└── target/               # dbt artifacts (compiled, manifest, catalog, etc.)
```

## 📊 Data Sources

### Raw Tables (BigQuery dataset: `raw`)
- **raw.user** - User profile and acquisition information
- **raw.order** - Order transactions and status updates
- **raw.exchange_rate** - Currency exchange rates to USD

## 🎯 Data Models

### Staging Layer (`staging` schema)
Views that perform basic cleaning and standardization of raw data:
- `stg_user` - Cleaned user data - from snapshot to have historical data on user profile (eg. country change)
- `stg_order` - Cleaned order data 
- `stg_exchange_rate` - Cleaned exchange rate data - from snapshot to have historical data on rates to calculate order amounts with the according date rate.

### Intermediate Layer (`intermediate` schema)
Tables with business transformations:
- `dim_user` - User dimension - SCD2 to have hostorical data on user - Defined as incremental to minimise costs 
- `fct_order` - Order facts - Accumulating Fact Snapshot transformation - Defined as incremental to minimise costs 
- `fct_exchange_rate` - Exchange rate facts - Periodic snapshot fact table and rate transformation and usd_mount and gpb_amoun added - Defined as incremental to minimise costs 

### Marts Layer (`mart` schema)
Business-ready analytics tables:
- `order` - Final order entity with multi-currency amounts (USD, GBP) - Defined as incremental to minimise costs 
- `user` - Final user entity with aggregated metrics - Defined as incremental to minimise costs - Takes the latest version of the user profile
- `_user_metrics_on_orders` - Ephemeral supporting metrics logic for user-order analysis (the idea is to use one ephemeral per entity calculations by user, another one would be eg. _user_metrics_on_events)


## 📈 Key Metrics

The marts layer provides analytics for core user and order performance. Key metrics include:
- Total users and total orders
- Total spend in USD and GBP
- Average order value in USD and GBP
- First vs. last purchase recency (days between first/last purchase, days since last purchase)
- User cohorts by engagement (new, frequent, occasional, rare)
- Breakdowns by platform, country, and acquisition channel
