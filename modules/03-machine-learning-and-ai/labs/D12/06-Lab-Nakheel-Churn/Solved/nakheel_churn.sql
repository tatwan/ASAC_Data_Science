-- D12 · Lab 06 (optional) · Nakheel churn, and a leak · Solved (every query from the README, in order)
-- Self-guided: run one statement at a time.

-- Step 1 · Make the label
CREATE OR REPLACE VIEW ml.customer_churn AS
SELECT * EXCEPT (revenue_next_6m),
       IF(revenue_next_6m = 0, 'Yes', 'No') AS churned
FROM ml.customer_features;

SELECT churned, COUNT(*) AS customers
FROM ml.customer_churn
GROUP BY churned;

-- Step 2 · Train and judge
CREATE OR REPLACE MODEL ml.nakheel_churn
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['churned'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2) AS
SELECT segment, city, orders_before, revenue_before, avg_order_value,
       days_since_last, tenure_days, online_share, churned
FROM ml.customer_churn;

SELECT ROUND(accuracy, 3) AS accuracy, ROUND(recall, 3) AS recall, ROUND(roc_auc, 3) AS roc_auc
FROM ML.EVALUATE(MODEL ml.nakheel_churn);

-- Step 3 · A colleague's column, in a view so the join is written once
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
