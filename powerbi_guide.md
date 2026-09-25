# Power BI Dashboard Guide
## Financial Performance Analysis — Step-by-Step Setup

> Author: Dhruv
> Tool: Power BI Desktop (free download: https://powerbi.microsoft.com/desktop)
> Data Source: order_cleaned.csv
> This guide tells you exactly what to build, click-by-click.

---

## STEP 1: Load Data into Power BI

1. Open **Power BI Desktop**
2. Click **Home → Get Data → Text/CSV**
3. Browse to `order_cleaned.csv` and click **Open**
4. In the preview window, click **Transform Data** (opens Power Query Editor)

### In Power Query Editor:
- Verify column `Order Date` is detected as **Date** type
- Verify `Sales`, `Profit`, `Discount` are **Decimal Number** type
- Verify `Quantity` is **Whole Number**
- Click **Close & Apply**

---

## STEP 2: Create a Date Table (for time intelligence)

In Power BI, go to **Modeling → New Table** and enter:

```dax
DateTable = 
CALENDAR(
    MIN(orders[Order Date]),
    MAX(orders[Order Date])
)
```

Then add these columns to the DateTable:

```dax
Year = YEAR(DateTable[Date])
Month Number = MONTH(DateTable[Date])
Month Name = FORMAT(DateTable[Date], "MMMM")
Quarter = "Q" & QUARTER(DateTable[Date])
Year-Month = FORMAT(DateTable[Date], "YYYY-MM")
```

Then go to **Model View** and draw a relationship:
- `DateTable[Date]` → `orders[Order Date]` (Many-to-One)

---

## STEP 3: Create All DAX Measures

Go to **Home → New Measure** for each of the following.
Create them in a dedicated table: right-click on your data pane → **New Table** → name it `_Measures`.

### Core KPI Measures

```dax
Total Sales = SUM(orders[Sales])
```

```dax
Total Profit = SUM(orders[Profit])
```

```dax
Total Orders = DISTINCTCOUNT(orders[Order ID])
```

```dax
Total Quantity = SUM(orders[Quantity])
```

```dax
Profit Margin % = 
DIVIDE([Total Profit], [Total Sales], 0) * 100
```

```dax
Avg Order Value = 
DIVIDE([Total Sales], [Total Orders], 0)
```

```dax
Avg Discount % = 
AVERAGE(orders[Discount]) * 100
```

### Year-over-Year Measures

```dax
Sales LY = 
CALCULATE(
    [Total Sales],
    SAMEPERIODLASTYEAR(DateTable[Date])
)
```

```dax
YoY Sales Growth % = 
DIVIDE([Total Sales] - [Sales LY], [Sales LY], 0) * 100
```

```dax
Profit LY = 
CALCULATE(
    [Total Profit],
    SAMEPERIODLASTYEAR(DateTable[Date])
)
```

```dax
YoY Profit Growth % = 
DIVIDE([Total Profit] - [Profit LY], [Profit LY], 0) * 100
```

### Supporting Measures

```dax
Total Customers = DISTINCTCOUNT(orders[Customer Name])
```

```dax
Total Products = DISTINCTCOUNT(orders[Product Name])
```

```dax
Loss-Making Products = 
CALCULATE(
    DISTINCTCOUNT(orders[Product Name]),
    FILTER(
        VALUES(orders[Product Name]),
        CALCULATE(SUM(orders[Profit])) < 0
    )
)
```

---

## STEP 4: Dashboard Layout

### Recommended Canvas Size
Go to **View → Page View → Actual Size**
Set canvas to **1280 × 720** pixels (16:9, standard widescreen)

---

## STEP 5: Build Each Visual

### 5.1 — KPI Cards (Top Row, 5 cards)

For each KPI Card:
1. Click **Visualizations → Card**
2. Drag the measure into the **Fields** well

| Card # | Measure | Label |
|--------|---------|-------|
| 1 | `Total Sales` | Total Sales |
| 2 | `Total Profit` | Total Profit |
| 3 | `Profit Margin %` | Profit Margin % |
| 4 | `Total Orders` | Total Orders |
| 5 | `Avg Order Value` | Avg Order Value |

**Format each card:**
- Font: Segoe UI, Bold
- Value font size: 28
- Label font size: 11
- Border: On (rounded corners)
- Background: Light gray (#F5F5F5) or match your theme

---

### 5.2 — Sales & Profit by Category (Bar Chart)

1. Visual type: **Clustered Bar Chart**
2. Y-axis: `Category`
3. X-axis: `Total Sales`
4. Add `Total Profit` as a second bar (clustered)
5. Format:
   - Title: "Sales & Profit by Category"
   - Data labels: On
   - Colors: Blue for Sales, Green for Profit

---

### 5.3 — Regional Sales & Profit (Bar Chart)

1. Visual type: **Clustered Bar Chart**
2. Y-axis: `Region`
3. X-axis: `Total Sales`
4. Tooltip: Add `Profit Margin %`
5. Title: "Performance by Region"
6. Sort by: Total Sales descending

---

### 5.4 — Monthly Sales Trend (Line Chart)

1. Visual type: **Line Chart**
2. X-axis: `DateTable[Year-Month]` (or `Month Name`)
3. Y-axis: `Total Sales`
4. Secondary Y-axis: `Total Profit`
5. Title: "Monthly Sales & Profit Trend"
6. Format: Smooth line, markers on

---

### 5.5 — Sales Distribution by Segment (Donut Chart)

1. Visual type: **Donut Chart**
2. Legend: `Segment`
3. Values: `Total Sales`
4. Title: "Sales by Customer Segment"
5. Format: Show percentage labels

---

### 5.6 — Top 10 Products by Sales (Horizontal Bar)

1. Visual type: **Bar Chart** (horizontal)
2. Y-axis: `Product Name`
3. X-axis: `Total Sales`
4. Apply a **Top N filter**:
   - Click the visual → Filters pane → Product Name → Filter type: Top N → Show items: Top 10 → By value: `Total Sales`
5. Title: "Top 10 Products by Sales"

---

### 5.7 — Sub-Category Profit Matrix (Bar Chart)

1. Visual type: **Bar Chart** (horizontal)
2. Y-axis: `Sub-Category`
3. X-axis: `Total Profit`
4. Conditional formatting: 
   - Color bars Red if profit < 0, Green if profit > 0
   - Go to Format → Data Colors → Conditional formatting → Based on field: `Total Profit`
5. Title: "Profit by Sub-Category (Losses Highlighted)"

---

### 5.8 — YoY Growth (KPI Visual or Card)

1. Visual type: **KPI** visual (or a Card)
2. Value: `YoY Sales Growth %`
3. Title: "Year-over-Year Sales Growth"
4. Trend axis: `DateTable[Year]`

---

## STEP 6: Add Slicers (Filters)

Place 4 slicers on the right side or top of the dashboard:

| Slicer | Field | Style |
|--------|-------|-------|
| Year | `DateTable[Year]` | Dropdown or List |
| Region | `orders[Region]` | List (checkboxes) |
| Category | `orders[Category]` | List (checkboxes) |
| Segment | `orders[Segment]` | List (checkboxes) |

**How to add a slicer:**
1. Click **Visualizations → Slicer**
2. Drag the field into the **Field** well
3. Format → Slicer Settings → Style: Tile or List

---

## STEP 7: Apply Formatting & Theme

### Color Theme
- Primary: `#2563EB` (Professional Blue)
- Profit/Positive: `#16A34A` (Green)
- Loss/Negative: `#DC2626` (Red)
- Background: `#F8FAFC` (Light gray-white)
- Cards background: `#FFFFFF` with subtle border

### Typography
- Titles: Segoe UI Bold, 14pt
- Values: Segoe UI Bold, 28pt
- Labels: Segoe UI, 10pt

### Dashboard Title
Add a **Text Box** at the top:
- Line 1: `Financial Performance Analysis` (Bold, 22pt)
- Line 2: `Retail Sales Intelligence Dashboard | 2023–2026` (Regular, 12pt)

---

## STEP 8: Add a Second Page (Optional — Deep Dive)

Add a second page called **"Deep Dive"** with:
- Discount Band analysis (clustered bar: Discount Band vs. Profit Margin %)
- State-level map visual (if Bing Maps is enabled): Bubble map with Sales by State
- Customer Tier table: Customer Name, Tier (Premium/Regular/Standard), Sales, Profit
- Loss-Making Products table: Product Name, Sub-Category, Total Loss

---

## STEP 9: Final Checks Before Export

- [ ] All 5 KPI cards show correct values
- [ ] Slicers work — test Year 2023 and verify numbers change
- [ ] Monthly trend shows data for all months
- [ ] Top 10 Products chart uses TopN filter
- [ ] Sub-Category chart highlights losses in red
- [ ] Dashboard title is correct
- [ ] Page is named "Executive Summary"

### Export Dashboard Image
**File → Export → Export to PDF** (for documentation)
Or: **File → Export → Publish to web** (for sharing)
Or: Take a screenshot using Windows + Shift + S

---

## DAX Reference (All Measures Summary)

```dax
-- Core KPIs
Total Sales        = SUM(orders[Sales])
Total Profit       = SUM(orders[Profit])
Total Orders       = DISTINCTCOUNT(orders[Order ID])
Total Quantity     = SUM(orders[Quantity])
Total Customers    = DISTINCTCOUNT(orders[Customer Name])
Total Products     = DISTINCTCOUNT(orders[Product Name])

-- Derived KPIs
Profit Margin %    = DIVIDE([Total Profit], [Total Sales], 0) * 100
Avg Order Value    = DIVIDE([Total Sales], [Total Orders], 0)
Avg Discount %     = AVERAGE(orders[Discount]) * 100

-- Time Intelligence
Sales LY           = CALCULATE([Total Sales], SAMEPERIODLASTYEAR(DateTable[Date]))
YoY Sales Growth % = DIVIDE([Total Sales] - [Sales LY], [Sales LY], 0) * 100
Profit LY          = CALCULATE([Total Profit], SAMEPERIODLASTYEAR(DateTable[Date]))
YoY Profit Growth %= DIVIDE([Total Profit] - [Profit LY], [Profit LY], 0) * 100

-- Advanced
Loss-Making Products = 
    CALCULATE(
        DISTINCTCOUNT(orders[Product Name]),
        FILTER(VALUES(orders[Product Name]),
        CALCULATE(SUM(orders[Profit])) < 0)
    )
```

---

## Interview Q&A for Power BI Measures

**Q: What is Profit Margin % and how did you calculate it?**
A: Profit Margin = Total Profit ÷ Total Sales × 100. In DAX: `DIVIDE([Total Profit], [Total Sales], 0) * 100`. The DIVIDE function handles divide-by-zero safely.

**Q: What is Average Order Value?**
A: Total Sales divided by the count of distinct orders. `DIVIDE([Total Sales], DISTINCTCOUNT(orders[Order ID]), 0)`. It tells us how much revenue each order generates on average — here it's $910.22.

**Q: How does YoY Growth work?**
A: I used `SAMEPERIODLASTYEAR()` — a DAX time intelligence function that shifts the filter context back by one year. Then I subtract last year's value from the current and divide by last year's to get a percentage change.

**Q: Why use DISTINCTCOUNT for orders instead of COUNT?**
A: The dataset has multiple order lines per order (one row per product). COUNT would give 10,196 (line items), but DISTINCTCOUNT gives 5,112 (actual unique orders) — which is the business-meaningful number.

---

*This guide covers everything needed to recreate and improve the dashboard in Power BI Desktop.*
*All DAX formulas are tested and compatible with Power BI Desktop (latest version).*
