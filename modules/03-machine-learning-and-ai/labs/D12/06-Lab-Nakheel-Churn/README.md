# Lab 06 (optional, self-study) · Nakheel churn, and a leak

In this optional self-guided lab, you will turn Nakheel's spend table into a yes-or-no label, train a classifier on it, judge it against the majority guess, and then watch a reasonable-looking column make the score almost perfect, and worthless.

**When:** after labs 03–05, at your own pace. Optional; not submitted. · **Data:** `ml.customer_features` (D11 lab 08, step 3), `nakheel.orders` (D04 activity 03) · **SQL:** `Solved/nakheel_churn.sql`

## Before you start

You need the view `ml.customer_features` from [D11 lab 08](../../D11/08-Lab-Nakheel-End-To-End/README.md), step 3. If you have not done it, run that step first: it needs only the `nakheel` tables from D04.

Work like the other labs: run each query, compare with **What you should see**, and answer **Think** in one line.

## Step 1 · Make the label

Nakheel's marketing team asks: *which customers will place no order in the six months after the 1 March cutoff?* That is churn, by our course definition. The view already has each customer's spend after the cutoff; zero spend means no completed order.

```sql
CREATE OR REPLACE VIEW ml.customer_churn AS
SELECT * EXCEPT (revenue_next_6m),
       IF(revenue_next_6m = 0, 'Yes', 'No') AS churned
FROM ml.customer_features;

SELECT churned, COUNT(*) AS customers
FROM ml.customer_churn
GROUP BY churned;
```

`SELECT * EXCEPT (…)` keeps every column but the one named. The spend after the cutoff must go: it **is** the answer.

**What you should see:** 183 Yes and 229 No. The majority guess, "No for everyone", is right for 229 ÷ 412 = 0.556.

## Step 2 · Train and judge

412 rows, so say how to split:

```sql
CREATE OR REPLACE MODEL ml.nakheel_churn
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['churned'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2) AS
SELECT segment, city, orders_before, revenue_before, avg_order_value,
       days_since_last, tenure_days, online_share, churned
FROM ml.customer_churn;

SELECT ROUND(accuracy, 3) AS accuracy, ROUND(recall, 3) AS recall, ROUND(roc_auc, 3) AS roc_auc
FROM ML.EVALUATE(MODEL ml.nakheel_churn);
```

**What you should see:** accuracy around 0.6 to 0.7 and ROC AUC around 0.65 to 0.75. Better than the majority guess, not by a lot. With only about 80 customers held aside, a different 80 could give quite a different score.

**Think:** compare with the Telco model in class (AUC ≈ 0.84 on 7,043 customers). Name two reasons Nakheel is harder.

## Step 3 · A colleague's column

A colleague offers help: "Our customer report has each customer's total number of completed orders. Loyal customers have more. Add it."

First, put the colleague's column next to ours in a view, so we only write the join once:

```sql
CREATE OR REPLACE VIEW ml.customer_churn_plus AS
WITH totals AS (
  SELECT customer_id, COUNT(*) AS orders_all_time
  FROM nakheel.orders
  WHERE status = 'completed'
  GROUP BY customer_id
)
SELECT ch.*, t.orders_all_time
FROM ml.customer_churn AS ch
INNER JOIN totals AS t
  ON ch.customer_id = t.customer_id;

SELECT customer_id, orders_before, orders_all_time, churned
FROM ml.customer_churn_plus
ORDER BY customer_id
LIMIT 10;
```

**What you should see:** where `orders_before` and `orders_all_time` are equal, `churned` is Yes; where they differ, No.

Train with it: the same model as step 2, plus one column.

```sql
CREATE OR REPLACE MODEL ml.nakheel_churn_leak
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['churned'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2) AS
SELECT segment, city, orders_before, revenue_before, avg_order_value,
       days_since_last, tenure_days, online_share,
       orders_all_time,
       churned
FROM ml.customer_churn_plus;

SELECT ROUND(accuracy, 3) AS accuracy, ROUND(roc_auc, 3) AS roc_auc
FROM ML.EVALUATE(MODEL ml.nakheel_churn_leak);
```

**What you should see:** accuracy and ROC AUC close to 1.

## Step 4 · Why it is worthless

`orders_all_time − orders_before` is the number of orders **after** the cutoff, and that is exactly zero when the customer churned. The column counts up to 31 August, past the cutoff, so the label is hidden inside it. This is a **leak**: information in the training data that would not exist when the model is used. On a real day, a column like this can only count the orders so far, which is `orders_before`.

The check is one question, asked of every feature: **does this column use any data from after the cutoff?** `orders_before`: no. `orders_all_time`: yes. Remove it.

**Think:** two more columns a report might offer: the date of each customer's latest order, and their total spend. Would either leak? How?

## What you saw

| Model | Accuracy | ROC AUC | Usable? |
|---|---:|---:|---|
| eight features | | | |
| eight features + `orders_all_time` | ≈ 1 | ≈ 1 | |

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../../../../shared/datasets/nakheel/README.md). Leakage: Kapoor and Narayanan, "Leakage and the reproducibility crisis in machine-learning-based science", *Patterns*, 2023.
