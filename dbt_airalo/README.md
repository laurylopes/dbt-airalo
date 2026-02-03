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
├── models/
│   ├── staging/          # Raw data staging layer
│   │   ├── stg_user.sql
│   │   ├── stg_order.sql
│   │   └── stg_exchange_rate.sql
│   ├── intermediate/     # Business logic transformations
│   │   ├── dim_user.sql
│   │   ├── fct_order.sql (incremental)
│   │   └── fct_exchange_rate.sql
│   └── marts/            # Final analytics models
│       ├── entities/
│       │   ├── ent_order.sql
│       │   └── ent_user.sql
│       └── ephemeral/
│           ├── eph_gbp_to_usd_rate.sql
│           ├── eph_user_country.sql
│           └── eph_user_metric_on_orders.sql
├── macros/               # Custom macros
├── tests/                # Custom data tests
└── snapshots/            # Snapshot configurations
```

## 📊 Data Sources

### Raw Tables (BigQuery dataset: `raw`)
- **raw.user** - User profile and acquisition information
- **raw.order** - Order transactions and status updates
- **raw.exchange_rate** - Currency exchange rates to USD

## 🎯 Data Models

### Staging Layer (`staging` schema)
Views that perform basic cleaning and standardization of raw data:
- `stg_user` - Cleaned user data
- `stg_order` - Cleaned order data
- `stg_exchange_rate` - Cleaned exchange rate data

### Intermediate Layer (`dwh_core` schema)
Tables with business transformations:
- `dim_user` - User dimension with enriched attributes
- `fct_order` - Order facts with incremental updates (partitioned by `updated_at`)
- `fct_exchange_rate` - Exchange rate facts

### Marts Layer (`dwh_bl` schema)
Business-ready analytics tables:
- `ent_order` - Complete order entity with multi-currency amounts (USD, GBP)
- `ent_user` - Complete user entity with aggregated metrics

## 🚀 Getting Started

### Prerequisites
- dbt Core or dbt Cloud
- BigQuery access to `dbt-airalo` project
- Python 3.8+

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd dbt-airalo
```

2. Install dependencies:
```bash
cd dbt_airalo
dbt deps
```

3. Configure your profile in `~/.dbt/profiles.yml`:
```yaml
dbt_airalo:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: dbt-airalo
      dataset: dev
      location: US
      threads: 4
```

### Running the Project

```bash
# Run all models
dbt run

# Run specific models
dbt run --select staging
dbt run --select intermediate
dbt run --select marts

# Run with full refresh (rebuild incremental models)
dbt run --full-refresh

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

## 🔄 Incremental Models

The `fct_order` model is configured as incremental with:
- **Strategy**: `insert_overwrite`
- **Unique Key**: `order_id`
- **Partition**: Daily partitions on `updated_at` timestamp
- **Incremental Logic**: Captures only new/updated orders since last run

## 🧪 Data Quality Tests

Source data tests are defined in `models/staging/_sources.yml`:
- **Uniqueness** - Primary keys (user_id, order_id, currency)
- **Not Null** - Required fields
- **Accepted Values** - Platform values (ios, web, android)

## 📦 Dependencies

This project uses the following dbt packages:
- `dbt-labs/dbt_utils` - Utility macros
- `dbt-labs/codegen` - Code generation helpers

## 🛠️ Custom Macros

- `get_custom_schema` - Custom schema naming logic

## 📈 Key Metrics

The marts layer provides analytics for:
- Order completion rates
- Revenue by currency (with USD/GBP conversion)
- User acquisition channel performance
- Geographic distribution of orders
- Payment method analysis
- eSIM package popularity

## 📚 Resources

- [dbt Documentation](https://docs.getdbt.com/docs/introduction)
- [BigQuery Adapter Documentation](https://docs.getdbt.com/reference/warehouse-setups/bigquery-setup)
- [dbt Discourse](https://discourse.getdbt.com/)
- [dbt Slack Community](https://community.getdbt.com/)
