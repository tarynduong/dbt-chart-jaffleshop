# Jaffle Shop Analytics

A local analytics project for the classic **Jaffle Shop** dataset. It combines three layers:

- **dbt + DuckDB** — transforms raw seed CSVs into clean staging models in a local DuckDB database.
- **dbt Semantic Layer (MetricFlow)** — defines reusable semantic models and metrics (e.g. total sales, items sold).
- **dbt-charts (`dct`)** — renders an executive dashboard defined in YAML into a static HTML report.

Everything runs locally against a single DuckDB file (`jaffle_shop.duckdb`) — no cloud warehouse required.

## Project structure

```
dbt/
├── dbt_project.yml                  # dbt project config (profile: jaffle_shop_duckdb)
├── requirements.txt                 # Python dependencies
├── jaffle_shop.duckdb               # Local DuckDB database (generated)
├── seeds/                           # Raw source data (CSV)
│   ├── raw_customers.csv
│   ├── raw_items.csv
│   ├── raw_orders.csv
│   └── raw_products.csv
├── models/
│   ├── marts/                       # Staging models + time spine
│   │   ├── stg_customers.sql
│   │   ├── stg_orders.sql
│   │   ├── stg_order_items.sql
│   │   ├── stg_products.sql
│   │   ├── metricflow_time_spine.sql
│   │   └── _models.yml
│   └── semantic/
│       └── sales_semantic.yml       # Semantic models + metrics (MetricFlow)
├── charts/
│   └── store_dashboard.board.yml    # Dashboard definition (queries + charts + layout)
├── renders/
│   └── store_dashboard.board.html   # Rendered dashboard output
└── store_dashboard.html             # Rendered dashboard (HTML export)
```

## Data model

| Model | Source | Description |
|-------|--------|-------------|
| `stg_customers` | `raw_customers` | Customer id and name |
| `stg_orders` | `raw_orders` | Order id, customer, order date, order total |
| `stg_order_items` | `raw_items` | Line items linking orders to products |
| `stg_products` | `raw_products` | Product id, name, type, price |
| `metricflow_time_spine` | generated | Daily date spine required by the Semantic Layer |

**Metrics** (defined in `models/semantic/sales_semantic.yml`):

- `total_sales` — total sales revenue (sum of `order_total`)
- `total_items_sold` — total number of products sold

## Prerequisites

- Python 3.9+
- A DuckDB profile named `jaffle_shop_duckdb` in `~/.dbt/profiles.yml`:

  ```yaml
  jaffle_shop_duckdb:
    outputs:
      dev:
        type: duckdb
        path: jaffle_shop.duckdb
    target: dev
  ```

## Setup

From the project root:

```powershell
# Create and activate a virtual environment (optional but recommended)
python -m venv .env
.env\Scripts\Activate.bat

# Install dependencies
pip install -r requirements.txt
```

This installs `dbt-core`, `dbt-duckdb`, `dbt-metricflow`, and `dbt-charts` (which provides the `dct` CLI).

## Build the data

Load the seed CSVs and build the models into DuckDB:

```powershell
dbt seed        # Load raw CSVs into DuckDB
dbt run         # Build staging models
dbt build       # (alternative) seed + run + test in one step
```

## Explore metrics (Semantic Layer)

Query the defined metrics with MetricFlow:

```powershell
dbt sl query --metrics total_sales,total_items_sold --group-by metric_time__month
```

## Dashboard (`dct`)

The dashboard is defined in `charts/store_dashboard.board.yml`.

```powershell
# Validate the dashboard definition
dct validate

# Render the charts
dct render

# Export the dashboard to a standalone HTML file
dct render charts/store_dashboard.board.yml --format html > store_dashboard.html

# Serve the dashboard locally
dct serve
```

Open the served URL (or `store_dashboard.html`) in a browser to view the executive dashboard: revenue KPIs, monthly revenue trend, gross sales by product type, and a top-customers leaderboard.
