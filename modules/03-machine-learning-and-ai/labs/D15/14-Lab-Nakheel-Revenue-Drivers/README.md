# Lab 14 (optional, self-study) · What drove Nakheel's revenue up

In this optional self-guided lab, you will compare Nakheel's two years of completed orders with a contribution analysis model, read which cities, channels, customer segments and product categories explain the change, walk through each of the model's options, and check the model's answers with plain SQL.

**When:** after lab 13 or any time after class, about 50 minutes, at your own pace. Optional; not submitted. · **Data:** `nakheel.orders`, `nakheel.order_items`, `nakheel.products`, `nakheel.customers` (D04 activity 03) → the view `ml.revenue_lines` and the models `ml.revenue_drivers`, `ml.revenue_drivers_city_channel`, `ml.revenue_drivers_05`, `ml.revenue_drivers_top10`, `ml.revenue_drivers_pruned`, `ml.revenue_per_unit` and `ml.revenue_per_order` · **SQL:** `Unsolved/nakheel_revenue_drivers.sql` to run step by step, `Solved/nakheel_revenue_drivers.sql`

## The story

Nakheel's completed revenue grew by about a fifth from its first year of data (September 2024 to August 2025) to its second (September 2025 to August 2026). The managers want to know where the growth came from: a city, the online shop, the wholesale customers, one product category, or a mix of these? Lab 13 forecast the total; this lab takes the total apart. A contribution analysis model compares a **test** set of rows (the second year) with a **control** set (the first) and lists the slices of the data, called segments, whose change is largest or most surprising.

## What you will learn

- To put test and control rows in one table, with a BOOL column that says which is which.
- To train a `CONTRIBUTION_ANALYSIS` model, one option at a time, and to read `ML.GET_INSIGHTS`, `unexpected_difference` especially.
- To check the model's one-dimension segments with plain SQL.
- The three kinds of metric the model accepts: a sum, a ratio of two sums, and a sum per distinct value.

## Before you start

You need the four `nakheel` tables from D04. Check: `SELECT COUNT(*) FROM nakheel.order_items;` returns 7,516. If they are missing, upload the files in [`shared/datasets/nakheel`](../../../../../shared/datasets/nakheel/README.md) as its README describes.

Contribution analysis is not a prediction model: there is no label and nothing to forecast. `CREATE MODEL` with `MODEL_TYPE = 'CONTRIBUTION_ANALYSIS'` computes the segments, and the function `ML.GET_INSIGHTS` reads them. (There is no function called ML.CONTRIBUTION_ANALYSIS.) Google's pricing page lists "Contribution analysis model creation" in the same price row as linear regression and time series models. Whether it trains in a sandbox without a billing account has not been tested for this course. If `CREATE MODEL` stops with a billing error, read each step's expected output and run the plain-SQL steps (1, 2, 5, 6, 11 and 12): they give the same numbers for every single city, channel, segment and category.

Google's overview page also recommends a function, `AI.KEY_DRIVERS`, for cases like this one (fewer than 12 dimensions and a summed metric). This lab uses the model because the model has options to learn; `AI.KEY_DRIVERS` is not covered here.

Work like the other labs: read the step, run its SQL, compare with **What you should see**, and answer **Think** in one line. The plain-SQL values are exact. `ML.GET_INSIGHTS`'s values were computed outside BigQuery with the formulas on Google's page; BigQuery's own output has not been run for this course, so compare and expect the same numbers.

## Step 1 · Revenue by year, and what counts

```sql
SELECT IF(order_date >= DATE '2025-09-01', 'second year', 'first year') AS nakheel_year,
       COUNTIF(status = 'completed') AS completed_orders,
       ROUND(SUM(IF(status = 'completed', order_total, 0)), 2) AS completed_revenue,
       COUNTIF(status = 'pending') AS pending_orders
FROM nakheel.orders
GROUP BY nakheel_year
ORDER BY nakheel_year;
```

Revenue here is the same as in lab 13: the sum of `order_total` over **completed** orders (the Nakheel README: "Value of the goods on the order, in dinars, before shipping"). Cancelled orders never became revenue; pending ones have not yet.

**What you should see:** 2 rows. First year: 1,235 completed orders, 142,273.50 dinars, no pending orders. Second year: 1,536 orders, 173,750.00 dinars, and 17 pending orders. The growth is 31,476.50 dinars, 22.1%. All 17 pending orders were placed from 27 to 31 August 2026, the last five days of the file (lab 13, step 1): they are not revenue yet, so the second year is slightly understated, by at most their 2,348 dinars.

## Step 2 · One row per order line, with its dimensions

```sql
CREATE OR REPLACE VIEW ml.revenue_lines AS
SELECT o.order_id,
       CASE
         WHEN c.customer_id IS NULL OR c.city IS NULL THEN 'unknown'
         WHEN LOWER(TRIM(c.city)) = 'al zarqa' THEN 'zarqa'
         ELSE LOWER(TRIM(c.city))
       END AS city,
       o.channel,
       IFNULL(LOWER(TRIM(c.segment)), 'unknown') AS segment,
       p.category,
       i.qty,
       i.qty * i.price AS item_revenue,
       o.order_date >= DATE '2025-09-01' AS is_test
FROM nakheel.orders AS o
JOIN nakheel.order_items AS i ON i.order_id = o.order_id
JOIN nakheel.products AS p ON p.product_id = i.product_id
LEFT JOIN nakheel.customers AS c ON c.customer_id = o.customer_id
WHERE o.status = 'completed';

SELECT is_test, COUNT(*) AS order_lines, ROUND(SUM(item_revenue), 2) AS line_revenue,
       COUNTIF(city = 'unknown') AS lines_city_unknown,
       COUNTIF(segment = 'unknown') AS lines_segment_unknown
FROM ml.revenue_lines
GROUP BY is_test
ORDER BY is_test;
```

A product category belongs to an order **line**, not to an order, so one row here is one line of a completed order: its city, channel, segment and category, and its value, `qty × price`. The lines of each completed order add up to its `order_total` (the course checked every order), so the totals match step 1.

Why each piece:

- `is_test` is TRUE for the second year (the test set) and FALSE for the first (the control set). The model's page: the column "must have a BOOL data type".
- The city and segment cleaning is D11 lab 08's: one spelling per city and segment, `al zarqa` as `zarqa`, and a missing city kept visible as `'unknown'`.
- The `LEFT JOIN` keeps one completed order (938 dinars, second year) whose customer is not in `nakheel.customers`; its city and segment become `'unknown'`. This matters because the page says "Any rows in the dimension columns that contain NULL values are removed": a NULL would drop that revenue from the analysis without a word.
- The name: `revenue_lines` is not the name of any of its columns.

**What you should see:** 2 rows. FALSE (first year): 3,171 lines, 142,273.50, 36 lines with an unknown city, 0 with an unknown segment. TRUE (second year): 3,780 lines, 173,750.00, 63 and 5. Google's page recommends "roughly equal numbers of test and control rows" for a summed metric; 3,171 against 3,780 is close enough here, but keep the advice in mind when one period is much longer than the other.

## Step 3 · The first model: a sum, four dimensions

```sql
CREATE OR REPLACE MODEL ml.revenue_drivers
OPTIONS (MODEL_TYPE = 'CONTRIBUTION_ANALYSIS',
         CONTRIBUTION_METRIC = 'SUM(item_revenue)',
         IS_TEST_COL = 'is_test',
         DIMENSION_ID_COLS = ['city', 'channel', 'segment', 'category']) AS
SELECT city, channel, segment, category, item_revenue, is_test
FROM ml.revenue_lines;
```

| Option | Here | Google's page |
|---|---|---|
| `MODEL_TYPE` | `'CONTRIBUTION_ANALYSIS'` | "This option is required." |
| `CONTRIBUTION_METRIC` | `'SUM(item_revenue)'`, a summable metric | a STRING with no default; the forms are `SUM(col)`, `SUM(a)/SUM(b)` (step 11) and `SUM(a)/COUNT(DISTINCT b)` (step 12); "You can't use any additional numerical computations" inside it, so do any arithmetic in the `SELECT` (here `qty * price` in the view) |
| `IS_TEST_COL` | `'is_test'` | the BOOL column that marks test rows; no default |
| `DIMENSION_ID_COLS` | the four columns to slice by | INT64, BOOL or STRING columns; step 7 leaves it out |

The `SELECT` lists exactly six columns, because the page says the input "must contain exactly the columns that you reference in the CONTRIBUTION_METRIC, DIMENSION_ID_COLS, and IS_TEST_COL options". `order_id` and `qty` stay out until steps 11 and 12 need them. The page also says the metric's values "must be non-negative", unless `MIN_APRIORI_SUPPORT` is 0; every line value here is positive.

**What you should see:** the model trains, with no result table. The two options not written here take their defaults: `MIN_APRIORI_SUPPORT` 0.1 (step 8) and `PRUNING_METHOD` `'NO_PRUNING'` (step 10).

## Step 4 · ML.GET_INSIGHTS: read the segments

```sql
SELECT contributors, metric_test, metric_control, difference,
       ROUND(relative_difference, 3) AS relative_difference,
       ROUND(unexpected_difference, 2) AS unexpected_difference,
       ROUND(relative_unexpected_difference, 3) AS relative_unexpected_difference,
       ROUND(apriori_support, 3) AS apriori_support, contribution
FROM ML.GET_INSIGHTS(MODEL ml.revenue_drivers)
ORDER BY contribution DESC;
```

`ML.GET_INSIGHTS` takes only the model. One row is one segment: one value of one dimension (`channel=online`), or a combination of values from several (`online` and `retail` together). It also returns the four dimension columns. For a summed metric the page defines:

| Column | Read it as |
|---|---|
| `contributors` | the segment's dimension values (an ARRAY of STRING); `all` is the whole table |
| `metric_test`, `metric_control` | the segment's revenue in the second year and in the first |
| `difference` | `metric_test - metric_control`: the change in dinars |
| `relative_difference` | `difference / metric_control`: the change as a share |
| `unexpected_difference` | the change beyond what the rest of the data would predict for this segment (step 5 works it out) |
| `relative_unexpected_difference` | `unexpected_difference` as a share of the expected value |
| `apriori_support` | the segment's share of all revenue, in whichever year it is larger; segments below the threshold (0.1 by default) are left out |
| `contribution` | `ABS(difference)`; "Insights are automatically ordered by contribution in descending order" |

**What you should see:** about 36 rows: the `all` row and, computed outside BigQuery with the page's formulas, 35 segments with an `apriori_support` of at least 0.1. The first rows:

| `contributors` | `metric_test` | `metric_control` | `difference` | `relative_difference` | `unexpected_difference` | `apriori_support` |
|---|---:|---:|---:|---:|---:|---:|
| all | 173,750 | 142,273.5 | 31,476.5 | 0.221 | 31,476.5 | 1 |
| channel=online | 66,155 | 44,530.5 | 21,624.5 | 0.486 | 17,136.05 | 0.381 |
| segment=wholesale | 84,936.5 | 69,267.5 | 15,669 | 0.226 | 670.97 | 0.489 |
| segment=retail | 87,875.5 | 73,006 | 14,869.5 | 0.204 | -2,633.81 | 0.513 |
| online and retail | 34,480.5 | 24,132 | 10,348.5 | 0.429 | 6,032.82 | 0.198 |
| online and wholesale | 30,736.5 | 20,398.5 | 10,338 | 0.507 | 6,800 | 0.177 |
| city=irbid | 52,257.5 | 41,986.5 | 10,271 | 0.245 | 1,393.03 | 0.301 |

Two segments to find further down: `channel=store` (+9,852, but `unexpected_difference` -37,613.07) and `city=amman` (+4,801, 7.6%, `unexpected_difference` -16,412.67). Amman is the biggest city and grew least.

**Think:** wholesale and retail grew by almost the same amount. Which column tells you neither is the story?

## Step 5 · unexpected_difference, by hand

```sql
WITH by_channel AS (
  SELECT channel,
         SUM(IF(is_test, item_revenue, 0)) AS second_year,
         SUM(IF(NOT is_test, item_revenue, 0)) AS first_year
  FROM ml.revenue_lines
  GROUP BY channel
),
totals AS (
  SELECT SUM(second_year) AS all_second_year, SUM(first_year) AS all_first_year
  FROM by_channel
)
SELECT channel, second_year, first_year,
       ROUND(first_year * (all_second_year - second_year) / (all_first_year - first_year), 2) AS expected_second_year,
       ROUND(second_year - first_year * (all_second_year - second_year) / (all_first_year - first_year), 2) AS unexpected_difference,
       ROUND(GREATEST(second_year / all_second_year, first_year / all_first_year), 4) AS apriori_support
FROM by_channel
CROSS JOIN totals
ORDER BY channel;
```

The page's recipe for `unexpected_difference`: take everything **except** the segment (its complement), see how much that grew (complement second year ÷ complement first year), grow the segment's first year by the same rate to get its expected second year, and subtract. For online, the rest of the business is the stores, which grew from 97,743 to 107,595, a factor of about 1.10. Online at that rate would have reached 49,018.95; it reached 66,155.

**What you should see:** 2 rows. Online: expected 49,018.95, unexpected **+17,136.05**, support 0.3807. Store: expected 145,208.07, unexpected **-37,613.07**, support 0.687. With two channels, each one's complement is the other, so the store's large negative number says the same thing from the other side: online grew 48.6%, the stores 10.1%. The model's rows in step 4 should show these values.

## Step 6 · Check with plain SQL: the change by city, channel, segment and category

```sql
SELECT 'city' AS dimension, city AS dimension_value,
       ROUND(SUM(IF(NOT is_test, item_revenue, 0)), 2) AS first_year,
       ROUND(SUM(IF(is_test, item_revenue, 0)), 2) AS second_year,
       ROUND(SUM(IF(is_test, item_revenue, -item_revenue)), 2) AS change_in_revenue
FROM ml.revenue_lines GROUP BY city
UNION ALL
SELECT 'channel', channel,
       ROUND(SUM(IF(NOT is_test, item_revenue, 0)), 2), ROUND(SUM(IF(is_test, item_revenue, 0)), 2),
       ROUND(SUM(IF(is_test, item_revenue, -item_revenue)), 2)
FROM ml.revenue_lines GROUP BY channel
UNION ALL
SELECT 'segment', segment,
       ROUND(SUM(IF(NOT is_test, item_revenue, 0)), 2), ROUND(SUM(IF(is_test, item_revenue, 0)), 2),
       ROUND(SUM(IF(is_test, item_revenue, -item_revenue)), 2)
FROM ml.revenue_lines GROUP BY segment
UNION ALL
SELECT 'category', category,
       ROUND(SUM(IF(NOT is_test, item_revenue, 0)), 2), ROUND(SUM(IF(is_test, item_revenue, 0)), 2),
       ROUND(SUM(IF(is_test, item_revenue, -item_revenue)), 2)
FROM ml.revenue_lines GROUP BY category
ORDER BY dimension, change_in_revenue DESC;
```

The model's one-dimension rows are these sums: `metric_control` is `first_year`, `metric_test` is `second_year`, `difference` is `change_in_revenue`. A plain `GROUP BY` gives every value, whatever its size; the model shows only segments above its support threshold, and adds the combinations.

**What you should see:** 20 rows (9 cities, 2 channels, 3 segments, 6 categories).

| Dimension | Change, second year minus first (dinars) |
|---|---|
| city | irbid +10,271 · zarqa +7,787 · amman +4,801 · aqaba +3,232 · karak +2,212 · salt +2,109 · unknown +1,758 · madaba +750.50 · mafraq -1,444 |
| channel | online +21,624.50 (44,530.50 → 66,155) · store +9,852 (97,743 → 107,595) |
| segment | wholesale +15,669 · retail +14,869.50 · unknown +938 |
| category | Shoes +9,797.50 · Bottoms +6,189 · Accessories +4,468 · Outerwear +4,001 · Tops +3,922 · Sportswear +3,099 |

Zarqa has the second-largest city change, yet step 4 did not list it. Step 8 shows why.

**Think:** online is about a third of revenue and brought about two thirds of the growth. What would you ask the managers before calling online "the reason"?

## Step 7 · DIMENSION_ID_COLS: fewer dimensions, or left out

```sql
CREATE OR REPLACE MODEL ml.revenue_drivers_city_channel
OPTIONS (MODEL_TYPE = 'CONTRIBUTION_ANALYSIS',
         CONTRIBUTION_METRIC = 'SUM(item_revenue)',
         IS_TEST_COL = 'is_test') AS
SELECT city, channel, item_revenue, is_test
FROM ml.revenue_lines;

SELECT contributors, difference, ROUND(unexpected_difference, 2) AS unexpected_difference,
       ROUND(apriori_support, 3) AS apriori_support
FROM ML.GET_INSIGHTS(MODEL ml.revenue_drivers_city_channel)
ORDER BY contribution DESC;
```

No `DIMENSION_ID_COLS` this time. The page: "If you omit the dimension_id_cols option, then all columns in the query statement that are not specified in the contribution_metric or is_test_col options are used as dimension_id_cols." The `SELECT` has only `city` and `channel` besides the metric and the test column, so those two are the dimensions. The page's limits: up to 50 dimensions when `MIN_APRIORI_SUPPORT` is above 0, and 13 when it is 0; and "Using fewer dimensions helps reduce the model creation runtime."

**What you should see:** about 9 rows (computed outside BigQuery): `all`, then `channel=online` (+21,624.5), `city=irbid` (+10,271), `channel=store` (+9,852), Amman's online orders (+6,626), Irbid's store orders (+6,029.5) and `city=amman` (+4,801). The same numbers as step 4 for the same segments: a segment's sums do not depend on which other dimensions the model has.

## Step 8 · MIN_APRIORI_SUPPORT: how small a segment may be

```sql
CREATE OR REPLACE MODEL ml.revenue_drivers_05
OPTIONS (MODEL_TYPE = 'CONTRIBUTION_ANALYSIS',
         CONTRIBUTION_METRIC = 'SUM(item_revenue)',
         IS_TEST_COL = 'is_test',
         DIMENSION_ID_COLS = ['city', 'channel', 'segment', 'category'],
         MIN_APRIORI_SUPPORT = 0.05) AS
SELECT city, channel, segment, category, item_revenue, is_test
FROM ml.revenue_lines;

SELECT contributors, difference, ROUND(apriori_support, 4) AS apriori_support
FROM ML.GET_INSIGHTS(MODEL ml.revenue_drivers_05)
WHERE apriori_support < 0.1
ORDER BY contribution DESC
LIMIT 5;
```

`MIN_APRIORI_SUPPORT` (FLOAT64 from 0 to 1, default 0.1): "All segments whose apriori_support value is less than the MIN_APRIORI_SUPPORT value that you specify are excluded." Support is a segment's share of the revenue, in whichever year the share is larger. Zarqa had 6.5% of the first year's revenue and 9.8% of the second's: support 0.0982, just under the default 0.1.

**What you should see:** about 84 rows in the model (computed outside BigQuery: `all` and 83 segments); the query returns the 5 largest changes among the segments the default left out. `city=zarqa` comes first (+7,787, support 0.0982), then online Outerwear (+7,505.5) and online Shoes (+5,927.5). A lower threshold finds smaller segments and makes a longer list to read.

## Step 9 · TOP_K_INSIGHTS_BY_APRIORI_SUPPORT: keep the k largest segments

```sql
CREATE OR REPLACE MODEL ml.revenue_drivers_top10
OPTIONS (MODEL_TYPE = 'CONTRIBUTION_ANALYSIS',
         CONTRIBUTION_METRIC = 'SUM(item_revenue)',
         IS_TEST_COL = 'is_test',
         DIMENSION_ID_COLS = ['city', 'channel', 'segment', 'category'],
         TOP_K_INSIGHTS_BY_APRIORI_SUPPORT = 10) AS
SELECT city, channel, segment, category, item_revenue, is_test
FROM ml.revenue_lines;

SELECT contributors, difference, ROUND(apriori_support, 3) AS apriori_support
FROM ML.GET_INSIGHTS(MODEL ml.revenue_drivers_top10)
ORDER BY apriori_support DESC;
```

Instead of a threshold, a count: "the maximum number of insights to output with the highest apriori support value", an INT64 from 1 to 1,000,000 with no default. It "can't be used together with MIN_APRIORI_SUPPORT", so this model has no threshold.

**What you should see:** about 10 rows, the largest segments, not the biggest changes. By the page's formula the ten largest are: `channel=store` (0.687), retail (0.513), wholesale (0.489), Amman (0.443), online (0.381), store with retail and store with wholesale (0.344 each), Irbid (0.301), Amman's store orders (0.299) and Outerwear (0.255). Whether the `all` row counts as one of the ten, the page does not say. Shoes (+9,797.5) is not among them: the largest segments are not always the ones that changed most.

## Step 10 · PRUNING_METHOD: drop rows that repeat another row

```sql
CREATE OR REPLACE MODEL ml.revenue_drivers_pruned
OPTIONS (MODEL_TYPE = 'CONTRIBUTION_ANALYSIS',
         CONTRIBUTION_METRIC = 'SUM(item_revenue)',
         IS_TEST_COL = 'is_test',
         DIMENSION_ID_COLS = ['city', 'channel', 'segment', 'category'],
         PRUNING_METHOD = 'PRUNE_REDUNDANT_INSIGHTS') AS
SELECT city, channel, segment, category, item_revenue, is_test
FROM ml.revenue_lines;

SELECT 'no pruning' AS pruning, COUNT(*) AS insights FROM ML.GET_INSIGHTS(MODEL ml.revenue_drivers)
UNION ALL
SELECT 'prune redundant', COUNT(*) FROM ML.GET_INSIGHTS(MODEL ml.revenue_drivers_pruned);
```

`PRUNING_METHOD` is `'NO_PRUNING'` (the default: every segment above the threshold) or `'PRUNE_REDUNDANT_INSIGHTS'`. Two rows are redundant when "Their metric values are equal" and one row's dimension values are part of the other's; then "the row with more dimension IDs (the more descriptive row) is kept", and "The all insight row is never pruned." Example: if every Mafraq order were a store order, `city=mafraq` and "Mafraq and store" would have the same sums, and only the second would stay.

**What you should see:** 2 rows with the same count, about 36. Computed outside BigQuery, no two of the 35 segments have equal sums in both years, so nothing is pruned on this data. On data where whole groups sit inside one value of another dimension, the option shortens the list.

## Step 11 · CONTRIBUTION_METRIC as a ratio: revenue per unit sold

```sql
CREATE OR REPLACE MODEL ml.revenue_per_unit
OPTIONS (MODEL_TYPE = 'CONTRIBUTION_ANALYSIS',
         CONTRIBUTION_METRIC = 'SUM(item_revenue)/SUM(qty)',
         IS_TEST_COL = 'is_test',
         DIMENSION_ID_COLS = ['city', 'channel', 'segment', 'category']) AS
SELECT city, channel, segment, category, item_revenue, qty, is_test
FROM ml.revenue_lines;

SELECT contributors, ROUND(metric_test, 2) AS metric_test, ROUND(metric_control, 2) AS metric_control,
       ROUND(metric_test_over_metric_control, 3) AS metric_test_over_metric_control,
       ROUND(aumann_shapley_attribution, 3) AS aumann_shapley_attribution,
       ROUND(apriori_support, 3) AS apriori_support
FROM ML.GET_INSIGHTS(MODEL ml.revenue_per_unit)
ORDER BY contribution DESC
LIMIT 10;

SELECT is_test, SUM(qty) AS units_sold, ROUND(SUM(item_revenue) / SUM(qty), 2) AS revenue_per_unit
FROM ml.revenue_lines
GROUP BY is_test
ORDER BY is_test;
```

A summable ratio metric is `SUM(numerator)/SUM(denominator)`, here dinars per unit sold. The output columns change: `metric_test` and `metric_control` are the ratio in each year, `metric_test_over_metric_control` divides them, `metric_test_over_complement` and `metric_control_over_complement` compare the segment with the rest, and `aumann_shapley_attribution` "measures the contribution of the segment ratio relative to the population ratio". `contribution` is its absolute value, and the rows are sorted by it.

**What you should see:** the plain query gives 2 rows: first year 8,106 units at 17.55 dinars each, second year 10,002 units at 17.37. The price per unit hardly moved (it fell a little), so the revenue growth came from selling more units, not dearer ones. In the model's output, the `all` row should show 17.37 against 17.55.

## Step 12 · CONTRIBUTION_METRIC per category: revenue per order

```sql
CREATE OR REPLACE MODEL ml.revenue_per_order
OPTIONS (MODEL_TYPE = 'CONTRIBUTION_ANALYSIS',
         CONTRIBUTION_METRIC = 'SUM(item_revenue)/COUNT(DISTINCT order_id)',
         IS_TEST_COL = 'is_test',
         DIMENSION_ID_COLS = ['city', 'channel', 'segment', 'category']) AS
SELECT city, channel, segment, category, item_revenue, order_id, is_test
FROM ml.revenue_lines;

SELECT contributors, ROUND(metric_test, 2) AS metric_test, ROUND(metric_control, 2) AS metric_control,
       ROUND(difference, 2) AS difference, ROUND(relative_difference, 3) AS relative_difference,
       ROUND(apriori_support, 3) AS apriori_support
FROM ML.GET_INSIGHTS(MODEL ml.revenue_per_order)
ORDER BY contribution DESC
LIMIT 10;

SELECT is_test, COUNT(DISTINCT order_id) AS orders_completed,
       ROUND(SUM(item_revenue) / COUNT(DISTINCT order_id), 2) AS revenue_per_order
FROM ml.revenue_lines
GROUP BY is_test
ORDER BY is_test;
```

A summable by category metric is `SUM(a)/COUNT(DISTINCT b)`, where `b` may be BOOL, DATE, DATETIME, TIME, TIMESTAMP, STRING or INT64. With `order_id` it is the average order value. Its output has `metric_test_over_population` and `metric_control_over_population` in place of the unexpected-difference columns. Read a category's row with care: one order can hold lines from several categories, so `category=Shoes` is shoe revenue per order that had shoes in it.

**What you should see:** the plain query gives 2 rows: 1,235 orders at 115.20 dinars in the first year, 1,536 orders at 113.12 in the second. Orders grew by about a quarter while the average order shrank a little. With steps 6 and 11: more orders, mostly online, at the same prices.

## More practice (not checked, not submitted)

- Make the test set the online orders and the control set the store orders (`channel = 'online' AS is_test`, and drop `channel` from the dimensions). Which cities and categories lean online?
- Add a dimension for the month of the year, `FORMAT_DATE('%m', order_date)`, to the view and to the model. Does any month explain the growth?
- Compare two months instead of two years, for example August 2026 against August 2025. Remember the 17 pending orders at the end of August 2026.

## What you saw

| Model | Metric | What it said about the growth |
|---|---|---|
| `ml.revenue_drivers` | revenue | |
| `ml.revenue_drivers_05` | revenue, smaller segments | |
| `ml.revenue_per_unit` | revenue per unit | |
| `ml.revenue_per_order` | revenue per order | |

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 2 | first year **1,235** orders, **142,273.5** · second year **1,536**, **173,750** · pending **17** |
| 2 | 2 | **3,171** lines, **142,273.5** · **3,780** lines, **173,750** · unknown city **36** and **63** |
| 5 | 2 | online expected **49,018.95**, unexpected **17,136.05** · store unexpected **-37,613.07** |
| 6 | 20 | irbid **10,271** · zarqa **7,787** · amman **4,801** · mafraq **-1,444** · online **21,624.5** · store **9,852** · wholesale **15,669** · retail **14,869.5** · Shoes **9,797.5** · Sportswear **3,099** |
| 11 | 2 | **8,106** units at **17.55** · **10,002** units at **17.37** |
| 12 | 2 | **1,235** orders at **115.20** · **1,536** orders at **113.12** |

## Hint

If a segment you expect is missing from `ML.GET_INSIGHTS`, check its `apriori_support` in plain SQL: its share of revenue in each year. Below the threshold, the model leaves it out, however large its change.

## Bonus

Mafraq is the only city whose revenue fell. Is it big enough to appear in any of the models above? (Its share was 2.0% of the first year's revenue: below even step 8's 0.05.)

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026; see [the dataset README](../../../../../shared/datasets/nakheel/README.md) for `status`, `order_total` and the order lines. BigQuery ML: [CREATE MODEL for contribution analysis](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-contribution-analysis), [ML.GET_INSIGHTS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-get-insights), [contribution analysis overview](https://docs.cloud.google.com/bigquery/docs/contribution-analysis), [BigQuery ML pricing](https://cloud.google.com/bigquery/pricing#bqml), Google Cloud. All pages read 19 October 2026.
