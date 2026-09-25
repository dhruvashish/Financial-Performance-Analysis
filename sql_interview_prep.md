# SQL Interview Preparation Guide
## Financial Performance Analysis — Query-by-Query Explanation

> Use this guide to confidently explain every query and concept in your SQL file during an interview.
> Author: Dhruv

---

## Core SQL Concepts Used in This Project

| Concept | Where Used | Interview Importance |
|---------|-----------|---------------------|
| `GROUP BY` | Every aggregation section | ⭐⭐⭐ Fundamental |
| `HAVING` | Loss-making filters | ⭐⭐⭐ |
| `ORDER BY` | All rankings | ⭐⭐⭐ |
| `CASE WHEN` | Customer/segment tiers | ⭐⭐⭐ |
| `RANK() OVER()` | Product/region rankings | ⭐⭐⭐ Advanced |
| `LAG()` | YoY growth calculation | ⭐⭐⭐ Advanced |
| `CTE (WITH ...)` | Cleaner multi-step queries | ⭐⭐ |
| Subqueries | Above-average comparison | ⭐⭐ |
| `ROW_NUMBER()` | Top product per region | ⭐⭐ Advanced |
| `NTILE()` | Profit quartile ranking | ⭐⭐ Advanced |
| `EXTRACT()` | Year/month from date | ⭐⭐ |
| `SUM() OVER()` | Running total | ⭐⭐ Advanced |

---

## Q&A: Explain Your Key Queries

---

### 1. Global Summary Query

```sql
SELECT
    ROUND(SUM(sales)::NUMERIC, 2)              AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2)             AS total_profit,
    COUNT(DISTINCT order_id)                   AS total_orders,
    ROUND((SUM(profit) / SUM(sales) * 100)::NUMERIC, 2) AS profit_margin_pct,
    ROUND((SUM(sales) / COUNT(DISTINCT order_id))::NUMERIC, 2) AS avg_order_value
FROM orders;
```

**Q: Why `COUNT(DISTINCT order_id)` instead of `COUNT(*)`?**
> Each row is an order LINE ITEM, not an order. One order can have 5 products = 5 rows. DISTINCT order_id gives us the real count of unique orders (5,112), not line items (10,196).

**Q: How did you calculate Profit Margin?**
> `Profit Margin = SUM(profit) / SUM(sales) × 100`. This gives the overall margin, not an average of per-row margins. If you averaged row-level margins, small orders would distort the result.

---

### 2. HAVING vs WHERE — Loss-Making Products

```sql
SELECT product_name, SUM(profit) AS total_profit
FROM orders
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;
```

**Q: Why use HAVING instead of WHERE here?**
> `WHERE` filters individual rows BEFORE aggregation. `HAVING` filters AFTER aggregation. Here, we need to first sum up all profits per product, then check if the total is negative — so HAVING is required.

**Q: What did this reveal?**
> 300 out of 1,850 products have negative total profit. The worst is Cubify CubeX 3D Printer at -$8,880 loss.

---

### 3. CASE WHEN — Customer Tiering

```sql
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
```

**Q: What is CASE WHEN used for?**
> It's SQL's equivalent of IF-ELSE. I used it to classify customers into business tiers based on their total spending — useful for targeted marketing strategies.

**Q: What were the thresholds based on?**
> Based on data distribution — Premium covers top ~5% of customers, Regular the next tier. These are business-defined thresholds I chose based on the data range ($0 to $25K).

---

### 4. Window Functions — RANK()

```sql
SELECT
    region,
    ROUND(SUM(sales)::NUMERIC, 2)  AS total_sales,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM orders
GROUP BY region
ORDER BY sales_rank;
```

**Q: What is a window function?**
> A window function performs a calculation across a set of rows related to the current row, WITHOUT collapsing rows like GROUP BY does. `RANK() OVER (ORDER BY ...)` assigns a rank to each row based on the specified ordering.

**Q: What's the difference between RANK() and ROW_NUMBER()?**
> `RANK()` skips numbers after ties (1, 2, 2, 4). `ROW_NUMBER()` always gives a unique number even for ties (1, 2, 3, 4). `DENSE_RANK()` doesn't skip after ties (1, 2, 2, 3).

---

### 5. YoY Growth with LAG()

```sql
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
```

**Q: What does LAG() do?**
> `LAG(column)` returns the value from the PREVIOUS row in the window. Here, it gets the previous year's sales so I can calculate how much growth occurred year-over-year.

**Q: What is a CTE (WITH clause)?**
> CTE stands for Common Table Expression. It's a temporary named result set defined using the `WITH` keyword. It makes complex queries more readable by breaking them into steps. Here, I first calculate yearly totals in the CTE, then apply LAG() in the main query.

**Q: What were the results?**
> Sales grew from $494K (2023) to $745K (2026). 2024 had a -4.3% dip, then recovered strongly — +29.8% in 2025 and +21.4% in 2026.

---

### 6. ROW_NUMBER with PARTITION BY — Top Product per Region

```sql
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
```

**Q: What does PARTITION BY do?**
> It divides the result set into groups (partitions) before applying the window function. Here, `PARTITION BY region` means ROW_NUMBER restarts at 1 for each region. So we get rank #1 (the top product) within EACH region separately.

**Q: Why `WHERE rn = 1` in the outer query?**
> We want only the top-ranked product per region. The CTE calculates the ranking; the outer query filters to only the first-ranked row per region.

---

### 7. Subquery — Above-Average Segments

```sql
SELECT segment, ROUND(SUM(sales)::NUMERIC, 2) AS total_sales
FROM orders
GROUP BY segment
HAVING SUM(sales) > (
    SELECT AVG(total_sales)
    FROM (
        SELECT segment, SUM(sales) AS total_sales
        FROM orders
        GROUP BY segment
    ) sub
)
ORDER BY total_sales DESC;
```

**Q: Explain the nested subquery logic.**
> The innermost query calculates total sales per segment. The middle subquery is needed because you can't use AVG() directly on an aggregated GROUP BY result. The outer HAVING clause then compares each segment's total against the computed average.

**Q: Could you rewrite this as a CTE?**
> Yes! CTEs make this cleaner:
> ```sql
> WITH seg_totals AS (SELECT segment, SUM(sales) AS total_sales FROM orders GROUP BY segment)
> SELECT * FROM seg_totals WHERE total_sales > (SELECT AVG(total_sales) FROM seg_totals);
> ```

---

### 8. Discount Impact Analysis — CASE Banding

```sql
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
```

**Q: What business question does this answer?**
> It shows how discounting behavior directly impacts profitability. The analysis reveals that orders with >30% discount are consistently loss-making — a key finding for pricing strategy.

**Q: Why repeat the CASE WHEN in both SELECT and GROUP BY?**
> In standard SQL (and PostgreSQL), you must repeat the expression in GROUP BY or use a subquery/CTE. PostgreSQL doesn't allow column aliases in GROUP BY directly in the same query level.

---

### 9. At-Risk Customer Query

```sql
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
```

**Q: What is an "at-risk" customer in this context?**
> A customer who buys a lot (>$5K) but generates negative profit for the business — typically because they receive excessive discounts. Sean Miller is the key example: $25K in sales but -$1,981 in profit.

**Q: What would you recommend based on this?**
> Flag these customers for account review. Cap their discount levels or assign them a minimum margin threshold before order approval.

---

## 5 Most Likely SQL Interview Questions for This Project

**Q1: What is the difference between WHERE and HAVING?**
> WHERE filters rows BEFORE aggregation (cannot use aggregate functions). HAVING filters AFTER aggregation (used with GROUP BY). Example: `WHERE sales > 100` vs `HAVING SUM(sales) > 100`.

**Q2: What are window functions and when do you use them?**
> Window functions (RANK, ROW_NUMBER, LAG, SUM OVER, etc.) perform calculations across related rows without collapsing the result like GROUP BY. Use them when you need ranking, running totals, or comparisons to adjacent rows.

**Q3: What is a CTE and why is it better than a subquery?**
> A CTE (Common Table Expression) is a named temporary result set defined with `WITH`. It's more readable, can be referenced multiple times, and can be recursive. Subqueries are harder to read when nested deeply.

**Q4: How do you find duplicates in a dataset using SQL?**
> `SELECT column, COUNT(*) FROM table GROUP BY column HAVING COUNT(*) > 1;`

**Q5: If you had to optimize a slow query, where would you start?**
> (1) Check if indexes exist on JOIN and WHERE columns. (2) Avoid `SELECT *`, select only needed columns. (3) Avoid functions on indexed columns in WHERE clauses. (4) Use CTEs/subqueries to pre-filter data before joining. (5) Use EXPLAIN ANALYZE to see the query plan.

---

*This guide prepares you to explain every query in `sql_analysis.sql` confidently in an interview.*
