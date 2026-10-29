# Lab 08 (optional, self-study) · Nakheel: from raw tables to a model

In this optional self-guided lab, you will take Nakheel's raw order and customer tables, check them, clean them, join and summarise them into one row per customer in a view, train a spend model on it, and see how real company data behaves differently from the clean classroom files.

**When:** after labs 05–07, at your own pace. Optional; not submitted. · **Data:** `nakheel.orders`, `nakheel.customers` (D04 activity 03) · **SQL:** `Solved/nakheel_end_to_end.sql`

## Why this lab exists

In class every file was ready: one row per example, clean values, nothing to join. Company data is rarely like that. Most of the work in a real project happens **before** `CREATE MODEL`: deciding what one row should be, finding what is wrong in the tables, and building a table the model can learn from. This lab walks through that once, with SQL you already know (`GROUP BY`, `CASE`, joins, CTEs and views).

Work through it like labs 05–07: run each query, compare with **What you should see**, and answer **Think** in one line.

## The business question

Nakheel's finance team plans its marketing budget six months at a time. They ask: *how much will each customer spend in the next six months?* A customer who will spend a lot deserves a bigger budget than one who will spend nothing.

One row of the table we need is **one customer**. The label is what they spent in six months. The features describe what they did before that.

## Step 1 · Check the data

Before you build anything, find out what the tables really hold.

```sql
-- Orders: one row per order, three statuses.
SELECT status, COUNT(*) AS order_count, COUNT(DISTINCT customer_id) AS customer_count
FROM nakheel.orders
GROUP BY status
ORDER BY status;

-- Segments as they were typed.
SELECT segment, COUNT(*) AS customer_count
FROM nakheel.customers
GROUP BY segment
ORDER BY customer_count DESC;

-- Cities as they were typed.
SELECT city, COUNT(*) AS customer_count
FROM nakheel.customers
GROUP BY city
ORDER BY customer_count DESC;
```

**What you should see:**

- Orders: completed 2,771, cancelled 212, pending 17. Only completed orders are money a customer spent.
- Five spellings for two segments: `Retail` 408, `Wholesale` 61, `retail` 18, `RETAIL ` (with a space) 9, `wholesale` 4. To a model, five different groups.
- `Amman` and `amman`, `Zarqa` and `Al Zarqa`, and six customers with no city.

**Think:** what would one-hot encoding (lab 06) make of five spellings of two segments?

## Step 2 · Decide what one row is, and where the label comes from

The orders table has one row per **order**. The question is about **customers**. So many order rows must become one customer row.

The label must be something that happened **after** the features. We pick a **cutoff date, 1 March 2026**, and split each customer's completed orders there:

- Orders **before** 1 March become the features: how many, how much, how recently, how often online.
- Spend from **1 March to 31 August 2026** (six months) is the label, `revenue_next_6m`.

The rule for every feature: it may use only orders before the cutoff. A column that counts orders after it would contain part of the answer. That is a **leak**, and D12 shows what it does to a score.

## Step 3 · Build the customer view

A view saves a query under a name. Every time you read it, BigQuery runs the query again; it is not a copy of the data.

```sql
CREATE SCHEMA IF NOT EXISTS ml OPTIONS (location = 'US');

CREATE OR REPLACE VIEW ml.customer_features AS
WITH customers AS (
  -- One meaning, one spelling; a missing city stays visible as 'unknown'.
  SELECT customer_id,
         LOWER(TRIM(segment)) AS segment,
         CASE
           WHEN city IS NULL THEN 'unknown'
           WHEN LOWER(TRIM(city)) = 'al zarqa' THEN 'zarqa'
           ELSE LOWER(TRIM(city))
         END AS city,
         signup_date
  FROM nakheel.customers
),
before_cutoff AS (
  -- Features: completed orders before 1 March, one row per customer.
  SELECT customer_id,
         COUNT(*) AS orders_before,
         ROUND(SUM(order_total), 2) AS revenue_before,
         MAX(order_date) AS last_order_before,
         ROUND(AVG(IF(channel = 'online', 1, 0)), 3) AS online_share
  FROM nakheel.orders
  WHERE status = 'completed'
    AND order_date < DATE '2026-03-01'
  GROUP BY customer_id
),
after_cutoff AS (
  -- The label: completed spend from 1 March to 31 August. Never a feature.
  SELECT customer_id,
         ROUND(SUM(order_total), 2) AS revenue_next_6m
  FROM nakheel.orders
  WHERE status = 'completed'
    AND order_date >= DATE '2026-03-01'
    AND order_date <  DATE '2026-09-01'
  GROUP BY customer_id
)
SELECT c.customer_id,
       c.segment,
       c.city,
       b.orders_before,
       b.revenue_before,
       ROUND(b.revenue_before / b.orders_before, 2) AS avg_order_value,
       DATE_DIFF(DATE '2026-03-01', b.last_order_before, DAY) AS days_since_last,
       DATE_DIFF(DATE '2026-03-01', c.signup_date, DAY) AS tenure_days,
       b.online_share,
       COALESCE(a.revenue_next_6m, 0) AS revenue_next_6m
FROM customers AS c
INNER JOIN before_cutoff AS b ON c.customer_id = b.customer_id
LEFT JOIN after_cutoff AS a ON c.customer_id = a.customer_id;
```

Why each part is there:

| Part | Why it is here |
|---|---|
| `customers` CTE | cleans the spellings found in step 1, so each segment and city is one category |
| `before_cutoff` | turns many orders into one row per customer, using only orders before 1 March: the features |
| `after_cutoff` | the six months after the cutoff: the label. The upper date stops a September order slipping in |
| `INNER JOIN before_cutoff` | the model is for existing buyers: a customer with no order before 1 March has no features |
| `LEFT JOIN after_cutoff` + `COALESCE(…, 0)` | a customer who bought nothing afterwards stays in, with a label of 0: a real answer |
| `AVG(IF(channel = 'online', 1, 0))` | the average of 1s and 0s is the share of orders placed online |

Check it:

```sql
SELECT COUNT(*) AS customer_count,
       COUNTIF(revenue_next_6m = 0) AS bought_nothing_after,
       ROUND(AVG(revenue_next_6m), 2) AS avg_next_6m
FROM ml.customer_features;
```

**What you should see:** 412 customers; 183 bought nothing after the cutoff; an average of 220.51.

**Think:** 500 customers signed up. Where did the other 88 go, and is that right for this question?

## Step 4 · Train, with the split chosen on purpose

412 rows is fewer than 500, so `AUTO_SPLIT` would hold nothing aside (lab 05). Say what you want:

```sql
CREATE OR REPLACE MODEL ml.spend_model
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['revenue_next_6m'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2) AS
SELECT segment, city, orders_before, revenue_before, avg_order_value,
       days_since_last, tenure_days, online_share,
       revenue_next_6m
FROM ml.customer_features;
```

`customer_id` is left out: an identifier says nothing about spending.

## Step 5 · Score it, and compare it with a guess

```sql
SELECT ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.spend_model);

SELECT ROUND(AVG(ABS(revenue_next_6m - 220.51)), 2) AS mae_of_the_average_guess
FROM ml.customer_features;
```

**What you should see:** the average guess misses by about 287 dinars. The model's MAE is usually lower, around 160, but your R² can be almost anywhere between about −0.3 and 0.9. Compare with your classmates.

Why so unstable? A few wholesale customers spend thousands while most spend little or nothing. Whether those few land in the 82 evaluation customers changes the score a lot. That is lab 05's lesson, on real data.

## Step 6 · Look at what it does wrong

```sql
SELECT customer_id, segment, revenue_before, revenue_next_6m,
       ROUND(predicted_revenue_next_6m, 2) AS predicted
FROM ML.PREDICT(MODEL ml.spend_model, (SELECT * FROM ml.customer_features))
ORDER BY predicted
LIMIT 10;
```

**What you should see:** several predictions **below zero**. Spending cannot be negative, but a straight line does not know that. About 55 of the 412 customers get a negative prediction.

**Think:** the insurance model in class worked well. Name two things about Nakheel's data that make it harder: think about the label's shape and the size of the table.

## What you saw

| Step | What you found |
|---|---|
| Check the data | |
| One row per customer | |
| The model against the guess | |
| What goes wrong | |

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../../../../shared/datasets/nakheel/README.md). BigQuery ML: [CREATE MODEL for linear regression](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm), Google Cloud.
