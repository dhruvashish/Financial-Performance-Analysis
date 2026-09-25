# Financial Performance Analysis — Retail Sales Intelligence

> **Portfolio Project | Data Analyst | Dhruv**
> Tools: Microsoft Excel · PostgreSQL · Power BI
> Dataset: US Superstore Retail Orders (2023–2026)

---

## Project Overview

This project delivers a complete end-to-end data analysis of a retail superstore's financial performance. Starting from raw transactional data, the project covers data cleaning, SQL-based business analysis using PostgreSQL, and an interactive Power BI dashboard — following a professional data analytics workflow.

The goal is to translate raw sales data into actionable business insights about profitability, regional performance, product efficiency, customer behavior, and discount impact.

---

## Business Objectives

- Identify which **regions, categories, and segments** drive the most revenue and profit
- Detect **loss-making products and sub-categories** eroding overall profitability
- Understand how **discounts affect profit margins** across categories
- Track **year-over-year growth** in sales and profit
- Discover **top and underperforming customers**
- Provide a clear, interactive dashboard for business decision-making

---

## Tools & Technologies

| Tool | Purpose |
|------|---------|
| **Microsoft Excel** | Data cleaning, formatting, initial Pivot Table review |
| **PostgreSQL** | SQL-based business analysis (10+ analysis sections) |
| **Power BI Desktop** | Interactive dashboard with KPIs, charts, and slicers |

---

## Dataset

**Source:** US Superstore Retail Orders (publicly available dataset)
**File:** `order_cleaned.csv`

| Attribute | Value |
|-----------|-------|
| Total Records | 10,196 order lines |
| Unique Orders | 5,112 |
| Unique Customers | 801 |
| Unique Products | 1,850 |
| Time Period | January 2023 – 2026 |
| Regions | Central, East, South, West |
| Categories | Furniture, Office Supplies, Technology |
| Segments | Consumer, Corporate, Home Office |
| Ship Modes | Standard Class, Second Class, First Class, Same Day |

### Key Columns

| Column | Description |
|--------|-------------|
| `Order ID` | Unique identifier per order |
| `Order Date` | Date the order was placed |
| `Ship Mode` | Delivery method |
| `Customer Name` | Customer full name |
| `Segment` | Business segment (Consumer / Corporate / Home Office) |
| `Region` | US region |
| `Category` | Product category |
| `Sub-Category` | Product sub-category (17 types) |
| `Sales` | Revenue in USD |
| `Quantity` | Units sold |
| `Discount` | Discount rate (0.0 – 0.8) |
| `Profit` | Net profit/loss in USD |

---

## Project Workflow

```
Raw Data (Excel)
     │
     ▼
Data Cleaning (Excel)
  - Remove nulls and duplicates
  - Standardize date formats (DD-MM-YYYY)
  - Verify data types for Sales, Profit, Discount
     │
     ▼
CSV Export → PostgreSQL Import
  - Create orders table
  - Import via \COPY command
  - Validate row counts
     │
     ▼
SQL Analysis (PostgreSQL) — 11 Sections
  - Global KPIs
  - Sales & Profit by Region, Category, Segment
  - YoY Trend Analysis (LAG window function)
  - Monthly Seasonality
  - Customer Tiering & At-Risk Customers
  - Discount Impact Analysis
  - Loss-Making Products
  - Advanced: CTEs, RANK(), ROW_NUMBER(), NTILE()
     │
     ▼
Power BI Dashboard
  - 5 KPI Cards
  - 7 Visualizations
  - 4 Interactive Slicers
     │
     ▼
Business Insights & Recommendations
  → See business_insights.md
```

---

## Headline KPIs (Calculated from Dataset)

| Metric | Value |
|--------|-------|
| **Total Sales** | $4,653,068.71 |
| **Total Profit** | $584,593.63 |
| **Profit Margin** | 12.56% |
| **Total Orders** | 5,112 |
| **Average Order Value** | $910.22 |
| **Average Discount** | 15.54% |
| **Total Quantity Sold** | 77,308 units |
| **Loss-Making Products** | 300 out of 1,850 |

---

## SQL Analysis Highlights

The file [`sql_analysis.sql`](./sql_analysis.sql) contains **11 analysis sections** with over **40 queries**.

| Section | Topic | Key Techniques |
|---------|-------|---------------|
| 0 | Table Setup & Validation | CREATE TABLE, COPY, DELETE |
| 1 | Global Summary Metrics | SUM, AVG, COUNT DISTINCT |
| 2 | Sales Analysis | GROUP BY, LIMIT, ORDER BY |
| 3 | Profit Analysis | HAVING, CASE WHEN |
| 4 | YoY Trend Analysis ⭐ | LAG(), WITH CTE, EXTRACT() |
| 5 | Segment Analysis | CASE WHEN, RANK(), Subquery |
| 6 | Regional Analysis | CTE, RANK(), HAVING |
| 7 | Category & Sub-Category | Window Functions, HAVING |
| 8 | Customer Analysis ⭐ | RANK(), At-Risk customers |
| 9 | Discount Impact ⭐ | CASE bands, correlation |
| 10 | Shipping Analysis | Cross-analysis, RANK() |
| 11 | Advanced Combined | ROW_NUMBER(), NTILE(), Running Total |

> ⭐ = Not present in reference project — original additions.

---

## Power BI Dashboard

See [`powerbi_guide.md`](./powerbi_guide.md) for complete step-by-step Power BI instructions, all DAX measures, and chart configuration.

### Dashboard Layout

**Page 1: Executive Summary**
- 5 KPI Cards: Total Sales, Total Profit, Profit Margin %, Total Orders, Avg Order Value
- Sales & Profit by Category (Bar Chart)
- Regional Performance (Bar Chart with profit overlay)
- Segment Distribution (Donut Chart)
- Monthly Sales Trend (Line Chart)
- Top 10 Products by Sales (Horizontal Bar)
- Slicers: Year | Region | Category | Segment

---

## Key Business Insights

Full detailed insights → [`business_insights.md`](./business_insights.md)

**Quick Summary:**
- 🟢 **West** is the top-performing region ($739K sales, 14.98% margin)
- 🔴 **Furniture** has only **2.61% profit margin** — the weakest category
- ⚠️ **Tables** and **Bookcases** sub-categories are **net loss-making**
- 📉 **300 products** (16% of catalog) generate losses
- 💡 **Texas** generates $170K in sales but loses **-$25,729**
- 📊 **Home Office** segment has the best margin at **14.02%**

---

## Project Files

| File | Description |
|------|-------------|
| `order_cleaned.csv` | Cleaned dataset (source) |
| `sql_analysis.sql` | All PostgreSQL queries (11 sections, 40+ queries) |
| `powerbi_guide.md` | Complete Power BI setup guide with all DAX measures |
| `business_insights.md` | Data-driven business insights and recommendations |
| `README.md` | This file |

---

## Author

**Dhruv**
Data Analytics Portfolio Project
Created: September 2026

---

*This project was independently developed using the US Superstore dataset as a foundation for demonstrating SQL and Power BI data analytics skills.*
