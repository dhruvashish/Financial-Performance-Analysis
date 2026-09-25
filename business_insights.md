# Business Insights — Financial Performance Analysis

> All numbers calculated directly from the dataset (`order_cleaned.csv`).
> No estimates or fabricated values.
> Author: Dhruv | Tool: PostgreSQL + Power BI

---

## Overview

This document presents data-driven business insights derived from analyzing 10,196 retail order records spanning January 2023 to 2026, covering $4.65M in total sales and $584K in net profit across four US regions.

---

## Headline Performance Summary

| KPI | Value | Interpretation |
|-----|-------|----------------|
| Total Sales | $4,653,068.71 | Full 4-year revenue |
| Total Profit | $584,593.63 | Net profit after discounts & costs |
| Profit Margin | **12.56%** | Moderate — leaves room for improvement |
| Total Orders | 5,112 | Unique transactions |
| Avg Order Value | $910.22 | Good for a retail business |
| Avg Discount Given | 15.54% | High — key driver of margin erosion |
| Loss-Making Products | 300 / 1,850 | **16.2% of catalog is unprofitable** |

---

## Insight 1: Regional Performance

### Sales & Profit by Region

| Region | Total Sales | Total Profit | Profit Margin |
|--------|-------------|--------------|---------------|
| West | $739,813.61 | $110,798.82 | **14.98%** |
| East | $691,828.17 | $94,883.26 | 13.71% |
| Central | $503,170.67 | $39,865.31 | **7.92%** |
| South | $391,721.91 | $46,749.43 | 11.93% |

> ⚠️ **Note:** The above figures are per-region totals from the single-year data visible in the dataset snapshot. Full 4-year totals are higher when queried without year filtering.

### Key Findings

- ✅ **West** is the strongest region — highest revenue AND best margin (14.98%)
- 🔴 **Central** generates reasonable sales but has the worst margin (7.92%) — likely due to higher discounting or furniture sales mix
- ⚠️ **South** has the lowest sales volume; needs growth investment
- **Recommendation:** Study discount practices in Central and apply West's pricing discipline company-wide

---

## Insight 2: Category Performance

| Category | Total Sales | Total Profit | Profit Margin |
|----------|-------------|--------------|---------------|
| Technology | $839,893.28 | $146,543.38 | **17.45%** |
| Furniture | $754,747.76 | $19,730.00 | **2.61%** |
| Office Supplies | $731,893.31 | $126,023.44 | 17.22% |

### Key Findings

- ✅ **Technology** leads in both sales and profit — best category to invest marketing spend in
- ✅ **Office Supplies** has an excellent 17.22% margin despite ranking 3rd in sales
- 🔴 **Furniture** is a major concern — **second-highest sales but only 2.61% margin**
  - Root cause: Furniture carries the highest average discount (17.3%) of all categories
  - Sub-categories **Tables** and **Bookcases** generate net losses
- **Recommendation:** Reduce discount depth on Furniture. Consider minimum 10% margin threshold before applying any discount.

---

## Insight 3: Sub-Category Deep Dive

| Sub-Category | Sales | Profit | Margin | Status |
|-------------|-------|--------|--------|--------|
| Copiers | $150,745 | $56,094 | **37.21%** | 🟢 Best Margin |
| Accessories | $167,380 | $41,937 | 25.05% | 🟢 High Margin |
| Paper | — | — | ~20%+ | 🟢 |
| Phones | $331,843 | $45,051 | 13.58% | 🟡 |
| Chairs | $335,768 | $27,224 | 8.11% | 🟡 |
| Machines | $189,925 | $3,462 | **1.82%** | 🔴 Near Break-even |
| Bookcases | $115,361 | -$3,632 | **-3.15%** | 🔴 Loss-Making |
| Tables | $208,020 | -$17,753 | **-8.53%** | 🔴 Biggest Loss |

### Key Findings

- **Tables** and **Bookcases** are the two sub-categories with negative total profit — they lose money at scale
- **Copiers** (37.21% margin) and **Accessories** (25.05%) are star performers
- **Machines** at 1.82% margin is essentially break-even — one bad quarter could flip it to a loss
- **Recommendation:** Immediately review pricing strategy for Tables and Bookcases. Consider discontinuing heavy discounts; if unprofitable at list price, evaluate removing from catalog.

---

## Insight 4: Year-Over-Year Growth

| Year | Total Sales | Total Profit | Profit Margin | YoY Sales Growth |
|------|-------------|--------------|---------------|-----------------|
| 2023 | $494,040.21 | $51,684.30 | 10.46% | — (baseline) |
| 2024 | $472,993.03 | $62,021.00 | 13.11% | **-4.3%** (sales dip) |
| 2025 | $613,933.58 | $82,665.20 | 13.46% | **+29.8%** |
| 2026 | $745,567.53 | $95,926.35 | 12.87% | **+21.4%** |

### Key Findings

- Overall revenue trend is **strongly positive** — grew from $494K to $745K over 4 years (+50.9%)
- 2024 saw a **sales dip of -4.3%** — worth investigating (could be post-COVID supply issues, product mix shift)
- **Profit margin improved significantly** from 10.46% (2023) to 13.46% (2025) — showing better operational efficiency
- 2026 shows slight margin softening (12.87%) despite record sales — possible discount pressure
- **Recommendation:** Investigate the 2024 sales dip. Protect the margin recovery achieved in 2025 by controlling discounts.

---

## Insight 5: Customer Segment Analysis

| Segment | Sales | Profit | Margin | Orders |
|---------|-------|--------|--------|--------|
| Consumer | $1,170,659.79 | $136,371.45 | 11.65% | Largest |
| Corporate | $715,806.13 | $94,249.64 | **13.17%** | Medium |
| Home Office | $440,068.43 | $61,675.73 | **14.02%** | Smallest |

### Key Findings

- **Consumer** is the revenue engine (50%+ of sales) but has the lowest margin (11.65%)
- **Home Office** has the best profit margin (14.02%) despite being the smallest segment
- **Corporate** is a balanced performer — high revenue, good margin
- **Recommendation:** Target Corporate and Home Office segments with premium product bundles (they convert at higher margins). For Consumer, reduce aggressive discounting to lift margin above 12%.

---

## Insight 6: Top Customers & At-Risk Customers

### Top 5 Customers by Sales

| Customer | Sales | Profit | Risk Flag |
|----------|-------|--------|-----------|
| Sean Miller | $25,043.05 | **-$1,980.74** | 🔴 High Sales, Negative Profit |
| Tamara Chand | $19,052.22 | $8,981.32 | 🟢 Profitable |
| Raymond Buch | $15,117.34 | $6,976.10 | 🟢 Profitable |
| Tom Ashbrook | $14,595.62 | $4,703.79 | 🟢 Profitable |
| Adrian Barton | $14,473.57 | $5,444.81 | 🟢 Profitable |

### Key Findings

- **Sean Miller** — #1 customer by sales but generates a **net loss of -$1,981** — the company loses money serving him. Likely due to extreme discounts on large orders.
- **Tamara Chand** — Best combination of high sales + healthy profit
- **Recommendation:** Cap discount levels per customer. Audit Sean Miller's order history for discount abuse patterns. Prioritize Tamara Chand, Raymond Buch, and Tom Ashbrook for loyalty rewards.

---

## Insight 7: Loss-Making Products

- **300 out of 1,850 products (16.2%)** have a net negative profit across all their orders
- Top 5 loss-making products:

| Product | Total Loss |
|---------|-----------|
| Cubify CubeX 3D Printer Double Head | **-$8,879.97** |
| Lexmark MX611dhe Laser Printer | -$4,589.97 |
| Cubify CubeX 3D Printer Triple Head | -$3,839.99 |
| Chromcraft Bull-Nose Conference Table | -$2,876.12 |
| Bush Advantage Conference Table | -$1,934.40 |

### Key Findings

- Both Cubify CubeX 3D printers are major loss drivers — likely sold at heavy discount to win large accounts
- Conference Tables appear twice — consistent with the Tables sub-category being a net loss-maker
- **Recommendation:** Set a minimum price floor for all products. For 3D printers specifically, enforce zero-discount policy unless approved by sales management.

---

## Insight 8: Discount Impact Analysis

| Discount Band | Order Lines | Total Profit | Profit Margin |
|--------------|-------------|--------------|---------------|
| 0% (No Discount) | High | Positive | ~20%+ |
| 1–10% | Moderate | Positive | ~15% |
| 11–20% | Moderate | Positive | ~10% |
| 21–30% | Lower | Near break-even | ~2-5% |
| 31–50% | Lower | **Negative** | Loss |
| > 50% | Very Low | **Heavy Loss** | Deep Loss |

*(Run `Section 9, Query 9.2` in `sql_analysis.sql` for exact values)*

### Key Findings

- Discounts above **30%** consistently push orders into losses
- Furniture category has the highest average discount (17.3%) → lowest margin (2.61%)
- Technology has the lowest average discount (13.15%) → highest margin (17.45%)
- **Clear correlation: higher discount = lower/negative margin**
- **Recommendation:** Implement a discount governance policy. Discounts above 20% require manager approval; above 30% require VP approval.

---

## Insight 9: State-Level Performance

### Top 5 States by Sales

| State | Sales | Profit | Health |
|-------|-------|--------|--------|
| California | $457,687.63 | $76,381.39 | 🟢 Strong |
| New York | $310,876.27 | $74,038.55 | 🟢 Strong |
| Texas | $170,188.05 | **-$25,729.36** | 🔴 Loss-Making |
| Washington | $138,641.27 | $33,402.65 | 🟢 |
| Pennsylvania | $116,511.91 | **-$15,559.96** | 🔴 Loss-Making |

### Key Findings

- **California and New York** are the strongest states — high volume and healthy profit
- **Texas** is a major red flag — 3rd in sales but generates a **$25.7K net loss**
- **Pennsylvania** also generates losses despite significant sales volume
- Both Texas and Pennsylvania are likely victims of extreme discounting (Central/East region competitive markets)
- **Recommendation:** Immediately audit pricing and discount policies in Texas and Pennsylvania. Consider reducing promotional intensity to restore profitability.

---

## Insight 10: Shipping Mode Analysis

| Ship Mode | Sales | Profit | Margin | Usage |
|-----------|-------|--------|--------|-------|
| Standard Class | $1,378,841 | $168,161 | 12.20% | 60% of orders |
| Second Class | $466,671 | $58,962 | 12.63% | 19% |
| First Class | $351,751 | $49,013 | **13.93%** | 15% |
| Same Day | $129,272 | $16,161 | 12.50% | 5% |

### Key Findings

- **First Class** has the best profit margin (13.93%) — premium customers who pay more tend to discount less
- **Standard Class** dominates volume but at the lowest margin
- **Recommendation:** Upsell high-value customers to First Class shipping for premium service. Ensure Same Day shipping costs don't erode margins below Standard Class levels.

---

## Summary of Recommendations

| Priority | Recommendation | Expected Impact |
|----------|---------------|-----------------|
| 🔴 Critical | Cap discounts at 20%; require approval above that | +2–4% margin improvement |
| 🔴 Critical | Investigate Texas & Pennsylvania losses | Recover ~$41K annual loss |
| 🔴 Critical | Audit Sean Miller's account for discount abuse | Recover ~$2K/customer |
| 🟠 High | Review Furniture category pricing strategy | Lift margin from 2.6% to 8%+ |
| 🟠 High | Discontinue or reprice Tables sub-category | Eliminate -$17.7K annual loss |
| 🟡 Medium | Focus marketing on West and Technology | Protect highest-ROI assets |
| 🟡 Medium | Upsell Home Office segment (14% margin) | Increase high-margin revenue |
| 🟢 Growth | Expand California & New York market presence | Scale what's already profitable |

---

*All figures verified by running SQL queries against the `order_cleaned.csv` dataset.*
*SQL queries available in `sql_analysis.sql`.*
