-- ============================================================
--  FINANCIAL PERFORMANCE ANALYSIS
--  Author : Dhruv
--  Tool   : PostgreSQL
--  Dataset: US Superstore Retail Orders (2023-2026)
--  File   : sql_analysis.sql
-- ============================================================
-- Dataset: 10,196 order lines | 5,112 unique orders | 801 customers | 1,850 products
-- Global KPIs (pre-verified from dataset):
--   Total Sales   : $4,653,068.71
--   Total Profit  : $584,593.63
--   Profit Margin : 12.56%
--   Total Orders  : 5,112
--   Avg Order Val : $910.22
-- ============================================================

-- ============================================================
-- SECTION 0: TABLE SETUP & DATA VALIDATION
-- ============================================================

-- Create table (run once before importing CSV)
CREATE TABLE IF NOT EXISTS orders (
    row_id        INTEGER,
    order_id      VARCHAR(20),
    order_date    DATE,
    ship_date     DATE,
    ship_mode     VARCHAR(30),
    customer_id   VARCHAR(15),
    customer_name VARCHAR(60),
    segment       VARCHAR(20),
    country       VARCHAR(30),
    city          VARCHAR(50),
    state         VARCHAR(50),
    postal_code   VARCHAR(10),
    region        VARCHAR(20),
    product_id    VARCHAR(20),
    category      VARCHAR(30),
    sub_category  VARCHAR(30),
    product_name  VARCHAR(200),
    sales         NUMERIC(10,4),
    quantity      INTEGER,
    discount      NUMERIC(4,2),
    profit        NUMERIC(10,4)
);

-- Import CSV via psql:
-- \COPY orders FROM 'path/to/order_cleaned.csv' CSV HEADER;

-- Validate import
SELECT COUNT(*) AS total_rows FROM orders;                   -- Expected: 10,196
SELECT COUNT(DISTINCT order_id) AS total_orders FROM orders; -- Expected: 5,112
SELECT COUNT(DISTINCT customer_name) AS total_customers FROM orders; -- Expected: 801

-- Remove any null rows if present
DELETE FROM orders WHERE row_id IS NULL;

-- Quick data preview
SELECT * FROM orders LIMIT 5;


-- ============================================================
-- SECTION 1: GLOBAL SUMMARY METRICS
-- ============================================================
-- WHY: These are your headline KPI numbers for the dashboard and executive summary.

SELECT
    ROUND(SUM(sales)::NUMERIC, 2)              AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2)             AS total_profit,
    COUNT(DISTINCT order_id)                   AS total_orders,
    SUM(quantity)                              AS total_quantity,
    ROUND(AVG(discount)::NUMERIC * 100, 2)     AS avg_discount_pct,
    ROUND((SUM(profit) / SUM(sales) * 100)::NUMERIC, 2) AS profit_margin_pct,
    ROUND((SUM(sales) / COUNT(DISTINCT order_id))::NUMERIC, 2) AS avg_order_value,
    ROUND(AVG(sales)::NUMERIC, 2)              AS avg_sale_per_line,
    COUNT(DISTINCT customer_name)              AS total_customers,
    COUNT(DISTINCT product_name)               AS total_products
FROM orders;

-- Interview tip: Profit Margin = Total Profit / Total Sales × 100
--                Avg Order Value = Total Sales / Unique Orders


-- ============================================================
-- SECTION 2: SALES ANALYSIS
-- ============================================================

-- 2.1 Total Sales by Region
-- INSIGHT: West leads with highest sales; South is the weakest region.
SELECT
    region,
    ROUND(SUM(sales)::NUMERIC, 2)   AS total_sales,
    COUNT(DISTINCT order_id)         AS total_orders,
    ROUND(AVG(sales)::NUMERIC, 2)   AS avg_sale_per_line
FROM orders
WHERE region IS NOT NULL
GROUP BY region
ORDER BY total_sales DESC;

-- 2.2 Total Sales by State (Top 10)
-- INSIGHT: California ($457K) and New York ($310K) are the top revenue states.
SELECT
    state,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit
FROM orders
WHERE state IS NOT NULL
GROUP BY state
ORDER BY total_sales DESC
LIMIT 10;

-- 2.3 Total Sales by Category
-- INSIGHT: Technology has highest sales ($840K); Office Supplies is close behind.
SELECT
    category,
    ROUND(SUM(sales)::NUMERIC, 2)      AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2)     AS total_profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct
FROM orders
WHERE category IS NOT NULL
GROUP BY category
ORDER BY total_sales DESC;

-- 2.4 Total Sales by Sub-Category (All)
-- INSIGHT: Chairs and Phones are the top sub-categories by revenue.
SELECT
    sub_category,
    ROUND(SUM(sales)::NUMERIC, 2)      AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2)     AS total_profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct
FROM orders
WHERE sub_category IS NOT NULL
GROUP BY sub_category
ORDER BY total_sales DESC;

-- 2.5 Top 10 Products by Sales
SELECT
    product_name,
    category,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit
FROM orders
GROUP BY product_name, category
ORDER BY total_sales DESC
LIMIT 10;


-- ============================================================
-- SECTION 3: PROFIT ANALYSIS
-- ============================================================

-- 3.1 Profit by Region (with margin)
-- INSIGHT: West has best profit ($110K); Central has lowest margin (7.92%).
SELECT
    region,
    ROUND(SUM(profit)::NUMERIC, 2)             AS total_profit,
    ROUND(SUM(sales)::NUMERIC, 2)              AS total_sales,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct
FROM orders
WHERE region IS NOT NULL
GROUP BY region
ORDER BY total_profit DESC;

-- 3.2 Profit by Category (with margin)
-- INSIGHT: Furniture has only 2.61% margin despite being 2nd in sales — discount-heavy.
SELECT
    category,
    ROUND(SUM(profit)::NUMERIC, 2)             AS total_profit,
    ROUND(SUM(sales)::NUMERIC, 2)              AS total_sales,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct
FROM orders
WHERE category IS NOT NULL
GROUP BY category
ORDER BY total_profit DESC;

-- 3.3 Profit by Sub-Category
-- INSIGHT: Tables (-8.53% margin) and Bookcases (-3.15%) are net loss-making sub-categories.
SELECT
    sub_category,
    ROUND(SUM(profit)::NUMERIC, 2)             AS total_profit,
    ROUND(SUM(sales)::NUMERIC, 2)              AS total_sales,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct
FROM orders
WHERE sub_category IS NOT NULL
GROUP BY sub_category
ORDER BY total_profit DESC;

-- 3.4 Top 10 Most Profitable Products
SELECT
    product_name,
    category,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales
FROM orders
GROUP BY product_name, category
ORDER BY total_profit DESC
LIMIT 10;

-- 3.5 Loss-Making Products (All)
-- INSIGHT: 300 products are net loss-makers; top loss is Cubify CubeX 3D Printer (-$8,880).
SELECT
    product_name,
    sub_category,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales,
    ROUND(AVG(discount)::NUMERIC * 100, 2) AS avg_discount_pct
FROM orders
GROUP BY product_name, sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

-- 3.6 Profit Margin Classification by Sub-Category
-- INSIGHT: CASE WHEN to bucket sub-categories — useful for targeted decision-making.
SELECT
    sub_category,
    ROUND(SUM(profit)::NUMERIC, 2)             AS total_profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct,
    CASE
        WHEN SUM(profit)/SUM(sales) >= 0.20 THEN 'High Margin (≥20%)'
        WHEN SUM(profit)/SUM(sales) >= 0.10 THEN 'Medium Margin (10-20%)'
        WHEN SUM(profit)/SUM(sales) >= 0    THEN 'Low Margin (0-10%)'
        ELSE 'Loss-Making'
    END AS margin_tier
FROM orders
WHERE sub_category IS NOT NULL
GROUP BY sub_category
ORDER BY profit_margin_pct DESC;


-- ============================================================
-- SECTION 4: YEAR-OVER-YEAR (YoY) TREND ANALYSIS
-- ============================================================
-- NEW — Not in the reference project.
-- WHY: YoY comparison is a core business intelligence metric for any analyst role.

-- 4.1 Annual Sales, Profit & Margin
-- INSIGHT: Sales grew from $494K (2023) to $745K (2026); profit margin improved 2023→2025.
SELECT
    EXTRACT(YEAR FROM order_date)              AS year,
    ROUND(SUM(sales)::NUMERIC, 2)             AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2)            AS total_profit,
    COUNT(DISTINCT order_id)                  AS total_orders,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct,
    ROUND((SUM(sales)/COUNT(DISTINCT order_id))::NUMERIC, 2) AS avg_order_value
FROM orders
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

-- 4.2 Year-over-Year Sales Growth %
-- HOW: Uses LAG() window function to compare each year to the previous year.
WITH yearly_sales AS (
    SELECT
        EXTRACT(YEAR FROM order_date) AS year,
        ROUND(SUM(sales)::NUMERIC, 2) AS total_sales
    FROM orders
    GROUP BY EXTRACT(YEAR FROM order_date)
)
SELECT
    year,
    total_sales,
    LAG(total_sales) OVER (ORDER BY year) AS prev_year_sales,
    ROUND(
        ((total_sales - LAG(total_sales) OVER (ORDER BY year))
        / LAG(total_sales) OVER (ORDER BY year) * 100)::NUMERIC, 2
    ) AS yoy_growth_pct
FROM yearly_sales
ORDER BY year;

-- 4.3 YoY Profit Growth %
WITH yearly_profit AS (
    SELECT
        EXTRACT(YEAR FROM order_date) AS year,
        ROUND(SUM(profit)::NUMERIC, 2) AS total_profit
    FROM orders
    GROUP BY EXTRACT(YEAR FROM order_date)
)
SELECT
    year,
    total_profit,
    LAG(total_profit) OVER (ORDER BY year) AS prev_year_profit,
    ROUND(
        ((total_profit - LAG(total_profit) OVER (ORDER BY year))
        / LAG(total_profit) OVER (ORDER BY year) * 100)::NUMERIC, 2
    ) AS yoy_profit_growth_pct
FROM yearly_profit
ORDER BY year;

-- 4.4 Monthly Sales Trend (across all years)
-- INSIGHT: Reveals seasonality — which months consistently perform best.
SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS year_month,
    ROUND(SUM(sales)::NUMERIC, 2)  AS monthly_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS monthly_profit,
    COUNT(DISTINCT order_id)        AS monthly_orders
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY year_month;

-- 4.5 Month-wise Average (seasonality pattern)
SELECT
    TO_CHAR(order_date, 'Month') AS month_name,
    EXTRACT(MONTH FROM order_date) AS month_num,
    ROUND(AVG(sales)::NUMERIC, 2)   AS avg_monthly_sales,
    ROUND(SUM(sales)::NUMERIC, 2)   AS total_sales
FROM orders
GROUP BY TO_CHAR(order_date, 'Month'), EXTRACT(MONTH FROM order_date)
ORDER BY month_num;


-- ============================================================
-- SECTION 5: CUSTOMER SEGMENT ANALYSIS
-- ============================================================

-- 5.1 Basic Segment Performance
-- INSIGHT: Consumer is largest (50%+ revenue share) but Home Office has best margin (14%).
SELECT
    segment,
    ROUND(SUM(sales)::NUMERIC, 2)              AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2)             AS total_profit,
    COUNT(DISTINCT order_id)                   AS total_orders,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct,
    ROUND((SUM(sales)/COUNT(DISTINCT order_id))::NUMERIC, 2) AS avg_order_value
FROM orders
WHERE segment IS NOT NULL
GROUP BY segment
ORDER BY total_sales DESC;

-- 5.2 Segment Classification by Total Sales
SELECT
    segment,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    CASE
        WHEN SUM(sales) >= 1000000 THEN 'Tier 1 - High'
        WHEN SUM(sales) >= 600000  THEN 'Tier 2 - Medium'
        ELSE 'Tier 3 - Low'
    END AS segment_tier
FROM orders
GROUP BY segment
ORDER BY total_sales DESC;

-- 5.3 Segment Ranking by Total Sales (Window Function)
SELECT
    segment,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM orders
GROUP BY segment
ORDER BY sales_rank;

-- 5.4 Above-Average Sales Segments (Subquery)
SELECT segment, ROUND(SUM(sales)::NUMERIC, 2) AS total_sales
FROM orders
GROUP BY segment
HAVING SUM(sales) > (
    SELECT AVG(seg_total)
    FROM (
        SELECT segment, SUM(sales) AS seg_total
        FROM orders
        GROUP BY segment
    ) sub
)
ORDER BY total_sales DESC;


-- ============================================================
-- SECTION 6: REGIONAL ANALYSIS
-- ============================================================

-- 6.1 Full Regional Breakdown
-- INSIGHT: West leads in sales & profit. Central has lowest margin (7.92%).
SELECT
    region,
    ROUND(SUM(sales)::NUMERIC, 2)              AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2)             AS total_profit,
    COUNT(DISTINCT order_id)                   AS total_orders,
    SUM(quantity)                              AS total_quantity,
    ROUND(AVG(discount)::NUMERIC * 100, 2)     AS avg_discount_pct,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct
FROM orders
WHERE region IS NOT NULL
GROUP BY region
ORDER BY total_sales DESC;

-- 6.2 Regional Classification
SELECT
    region,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    CASE
        WHEN SUM(sales) >= 700000 THEN 'High Performing'
        WHEN SUM(sales) >= 500000 THEN 'Medium Performing'
        ELSE 'Low Performing'
    END AS performance_tier
FROM orders
GROUP BY region
ORDER BY total_sales DESC;

-- 6.3 Rank Regions by Total Sales
SELECT
    region,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM orders
GROUP BY region
ORDER BY sales_rank;

-- 6.4 Regions Above Average Sales (CTE)
WITH region_totals AS (
    SELECT region, SUM(sales) AS total_sales
    FROM orders
    GROUP BY region
)
SELECT region, ROUND(total_sales::NUMERIC, 2) AS total_sales
FROM region_totals
WHERE total_sales > (SELECT AVG(total_sales) FROM region_totals)
ORDER BY total_sales DESC;

-- 6.5 Top 5 States by Sales
SELECT
    state,
    region,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit
FROM orders
WHERE state IS NOT NULL
GROUP BY state, region
ORDER BY total_sales DESC
LIMIT 5;

-- 6.6 Bottom 5 States by Profit (States with Losses)
-- INSIGHT: Texas (-$25.7K) and Pennsylvania (-$15.5K) are major loss-draining states.
SELECT
    state,
    region,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales
FROM orders
WHERE state IS NOT NULL
GROUP BY state, region
ORDER BY total_profit ASC
LIMIT 5;


-- ============================================================
-- SECTION 7: CATEGORY & SUB-CATEGORY ANALYSIS
-- ============================================================

-- 7.1 Category Performance
SELECT
    category,
    ROUND(SUM(sales)::NUMERIC, 2)              AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2)             AS total_profit,
    COUNT(DISTINCT order_id)                   AS total_orders,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct,
    ROUND(AVG(discount)::NUMERIC * 100, 2)     AS avg_discount_pct
FROM orders
WHERE category IS NOT NULL
GROUP BY category
ORDER BY total_sales DESC;

-- 7.2 Classify Categories by Profit Margin
SELECT
    category,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct,
    CASE
        WHEN SUM(profit)/SUM(sales) >= 0.15 THEN 'High Margin'
        WHEN SUM(profit)/SUM(sales) >= 0.05 THEN 'Medium Margin'
        ELSE 'Low / Loss Margin'
    END AS margin_category
FROM orders
GROUP BY category
ORDER BY profit_margin_pct DESC;

-- 7.3 Category Profit Ranking (Window Function)
SELECT
    category,
    ROUND(SUM(profit)::NUMERIC, 2)  AS total_profit,
    RANK() OVER (ORDER BY SUM(profit) DESC) AS profit_rank
FROM orders
GROUP BY category
ORDER BY profit_rank;

-- 7.4 All Sub-Categories with Margin (Ranked)
SELECT
    sub_category,
    category,
    ROUND(SUM(sales)::NUMERIC, 2)              AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2)             AS total_profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct,
    RANK() OVER (ORDER BY SUM(profit) DESC)    AS profit_rank
FROM orders
WHERE sub_category IS NOT NULL
GROUP BY sub_category, category
ORDER BY profit_rank;

-- 7.5 Sub-Categories with Negative Profit (Loss Sub-Categories)
SELECT
    sub_category,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales,
    ROUND(AVG(discount)::NUMERIC * 100, 2) AS avg_discount_pct
FROM orders
GROUP BY sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

-- 7.6 Sub-Categories with Sales > $200,000 (CTE)
WITH sub_cat_sales AS (
    SELECT
        sub_category,
        SUM(sales)  AS total_sales,
        SUM(profit) AS total_profit
    FROM orders
    GROUP BY sub_category
)
SELECT
    sub_category,
    ROUND(total_sales::NUMERIC, 2)  AS total_sales,
    ROUND(total_profit::NUMERIC, 2) AS total_profit
FROM sub_cat_sales
WHERE total_sales > 200000
ORDER BY total_sales DESC;


-- ============================================================
-- SECTION 8: CUSTOMER ANALYSIS
-- ============================================================

-- 8.1 Top 10 Customers by Sales
-- INSIGHT: Sean Miller is top by sales ($25K) but has NEGATIVE profit (-$1,981) — review discounts.
SELECT
    customer_name,
    segment,
    region,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    COUNT(DISTINCT order_id)        AS total_orders
FROM orders
GROUP BY customer_name, segment, region
ORDER BY total_sales DESC
LIMIT 10;

-- 8.2 Top 10 Customers by Profit
SELECT
    customer_name,
    segment,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales
FROM orders
GROUP BY customer_name, segment
ORDER BY total_profit DESC
LIMIT 10;

-- 8.3 Customer Tiering (CASE WHEN Classification)
SELECT
    customer_name,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    CASE
        WHEN SUM(sales) >= 15000 THEN 'Premium'
        WHEN SUM(sales) >= 8000  THEN 'Regular'
        ELSE 'Standard'
    END AS customer_tier
FROM orders
GROUP BY customer_name
ORDER BY total_sales DESC;

-- 8.4 Customer Ranking by Sales (Window Function)
SELECT
    customer_name,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS customer_rank
FROM orders
GROUP BY customer_name
ORDER BY customer_rank
LIMIT 20;

-- 8.5 Customers with High Sales but Negative Profit (At-Risk Customers)
-- INSIGHT: Identifies customers where heavy discounts are eroding profit.
SELECT
    customer_name,
    segment,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND(AVG(discount)::NUMERIC * 100, 2) AS avg_discount_pct
FROM orders
GROUP BY customer_name, segment
HAVING SUM(sales) > 5000 AND SUM(profit) < 0
ORDER BY total_profit ASC;


-- ============================================================
-- SECTION 9: DISCOUNT IMPACT ANALYSIS
-- ============================================================
-- NEW — Not in the reference project.
-- WHY: Discount is the #1 driver of profit erosion in retail; always asked in interviews.

-- 9.1 Discount Impact by Category
-- INSIGHT: Furniture avg discount 17.3% — highest category, lowest margin.
SELECT
    category,
    ROUND(AVG(discount)::NUMERIC * 100, 2)     AS avg_discount_pct,
    ROUND(SUM(sales)::NUMERIC, 2)              AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2)             AS total_profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct
FROM orders
WHERE category IS NOT NULL
GROUP BY category
ORDER BY avg_discount_pct DESC;

-- 9.2 Discount Bands — How discount level affects profit
-- INSIGHT: Orders with >30% discount consistently generate losses.
SELECT
    CASE
        WHEN discount = 0          THEN '0% (No Discount)'
        WHEN discount <= 0.10      THEN '1-10%'
        WHEN discount <= 0.20      THEN '11-20%'
        WHEN discount <= 0.30      THEN '21-30%'
        WHEN discount <= 0.50      THEN '31-50%'
        ELSE '> 50%'
    END AS discount_band,
    COUNT(*)                               AS order_lines,
    ROUND(SUM(sales)::NUMERIC, 2)         AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2)        AS total_profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct
FROM orders
GROUP BY
    CASE
        WHEN discount = 0          THEN '0% (No Discount)'
        WHEN discount <= 0.10      THEN '1-10%'
        WHEN discount <= 0.20      THEN '11-20%'
        WHEN discount <= 0.30      THEN '21-30%'
        WHEN discount <= 0.50      THEN '31-50%'
        ELSE '> 50%'
    END
ORDER BY discount_band;

-- 9.3 Avg Discount vs Profit by Sub-Category
SELECT
    sub_category,
    ROUND(AVG(discount)::NUMERIC * 100, 2)     AS avg_discount_pct,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct
FROM orders
WHERE sub_category IS NOT NULL
GROUP BY sub_category
ORDER BY avg_discount_pct DESC;


-- ============================================================
-- SECTION 10: SHIPPING MODE ANALYSIS
-- ============================================================

-- 10.1 Ship Mode Performance
-- INSIGHT: Standard Class is most used (60% of orders) but First Class has best margin (13.93%).
SELECT
    ship_mode,
    ROUND(SUM(sales)::NUMERIC, 2)              AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2)             AS total_profit,
    COUNT(*)                                   AS order_lines,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct,
    ROUND(AVG(sales)::NUMERIC, 2)              AS avg_sale_per_line
FROM orders
WHERE ship_mode IS NOT NULL
GROUP BY ship_mode
ORDER BY total_sales DESC;

-- 10.2 Ship Mode Ranking by Average Sale
SELECT
    ship_mode,
    ROUND(AVG(sales)::NUMERIC, 2)  AS avg_sales,
    RANK() OVER (ORDER BY AVG(sales) DESC) AS ship_mode_rank
FROM orders
GROUP BY ship_mode
ORDER BY ship_mode_rank;

-- 10.3 Ship Mode × Segment Cross Analysis
SELECT
    segment,
    ship_mode,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit
FROM orders
WHERE segment IS NOT NULL AND ship_mode IS NOT NULL
GROUP BY segment, ship_mode
ORDER BY segment, total_sales DESC;


-- ============================================================
-- SECTION 11: ADVANCED COMBINED ANALYSIS
-- ============================================================

-- 11.1 Region × Category Matrix (Sales & Profit)
-- INSIGHT: Technology in West is the strongest region-category combination.
SELECT
    region,
    category,
    ROUND(SUM(sales)::NUMERIC, 2)              AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2)             AS total_profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct
FROM orders
WHERE region IS NOT NULL AND category IS NOT NULL
GROUP BY region, category
ORDER BY region, total_sales DESC;

-- 11.2 Running Total Sales by Month (Cumulative)
-- HOW: SUM() OVER with ORDER BY gives a running total — useful for growth tracking.
WITH monthly AS (
    SELECT
        TO_CHAR(order_date, 'YYYY-MM') AS year_month,
        SUM(sales) AS monthly_sales
    FROM orders
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT
    year_month,
    ROUND(monthly_sales::NUMERIC, 2)   AS monthly_sales,
    ROUND(SUM(monthly_sales) OVER (ORDER BY year_month)::NUMERIC, 2) AS cumulative_sales
FROM monthly
ORDER BY year_month;

-- 11.3 Top Product per Region (Window Function — ROW_NUMBER)
-- HOW: Partitions ranking within each region to find the best product per region.
WITH product_region AS (
    SELECT
        region,
        product_name,
        SUM(sales) AS total_sales,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sales) DESC) AS rn
    FROM orders
    WHERE region IS NOT NULL
    GROUP BY region, product_name
)
SELECT region, product_name, ROUND(total_sales::NUMERIC, 2) AS total_sales
FROM product_region
WHERE rn = 1
ORDER BY total_sales DESC;

-- 11.4 Profitability Percentile (NTILE)
-- HOW: Divides all products into 4 quartiles based on profit — Q4 = top 25%.
SELECT
    product_name,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    NTILE(4) OVER (ORDER BY SUM(profit)) AS profit_quartile
FROM orders
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 20;

-- 11.5 Customer Lifetime Summary (with order frequency)
SELECT
    customer_name,
    segment,
    COUNT(DISTINCT order_id)        AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND((SUM(sales)/COUNT(DISTINCT order_id))::NUMERIC, 2) AS avg_order_value,
    MIN(order_date)                AS first_order_date,
    MAX(order_date)                AS last_order_date
FROM orders
GROUP BY customer_name, segment
ORDER BY total_sales DESC
LIMIT 20;

-- ============================================================
-- END OF ANALYSIS
-- ============================================================
