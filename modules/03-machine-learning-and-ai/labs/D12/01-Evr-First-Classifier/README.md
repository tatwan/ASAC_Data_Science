# A first classifier: will this customer leave?

In this activity, you will upload 7,043 telecom customers, find a number column that arrived as text, see who leaves, train a model on one feature, and read the probability it gives five customers.

**Data:** [`telco_churn.csv`](../../../../../shared/datasets/ml_classics/telco_churn.csv) → `ml.telco` · **Starter:** `Unsolved/first_classifier.sql`

## The story

A telecom company loses about a quarter of its customers in a month. Its retention team can offer a discount to customers about to leave, but not to everyone: an offer costs money, and most customers would have stayed anyway. The question: *which customers will leave this month, and who should get an offer?*

Yesterday the label was a number (a salary, medical charges). Today it is a category: `Churn` is Yes or No. A model that predicts a category is a **classifier**. In BigQuery the simplest one is logistic regression, `LOGISTIC_REG`, and it gives a probability as well as a Yes or No.

## What you will learn

- To check every column's type before you train.
- To train `LOGISTIC_REG` and read its probabilities.
- That a probability is not yet a decision.

## Before you start

You need the dataset `ml` from D11 (if it is missing: `CREATE SCHEMA IF NOT EXISTS ml OPTIONS (location = 'US');`). Download [`telco_churn.csv`](../../../../../shared/datasets/ml_classics/telco_churn.csv) and upload it as the table `telco` in `ml` (**⋮** → **Create table**, Upload, CSV, **Auto detect**).

## Steps

1. **Check the types (block 1).** Open the table's **Schema** tab. `tenure` (months as a customer) and `MonthlyCharges` are numbers, but `TotalCharges` is STRING. Block 1 finds why: 11 rows have a blank there. All 11 have `tenure` 0: they joined this month and have not been charged yet. We leave `TotalCharges` out today; it is roughly tenure × monthly charges anyway.

    Now look at `Churn`. The file says Yes or No, but **Auto detect** read it as BOOLEAN: TRUE means the customer left, FALSE means they stayed. That is why today's queries write `Churn = TRUE`, not `Churn = 'Yes'`.

2. **Who leaves? (block 2).** The share of customers who left, for each contract type. `COUNTIF(Churn = TRUE)` counts the customers who left. Month-to-month: 0.427. One year: 0.113. Two year: 0.028. Overall 1,869 of 7,043 left: 26.5%, so 73.5% stayed. Keep 73.5% in mind.

3. **Train on one feature (block 3).**

    - `model_type = 'LOGISTIC_REG'`: a classifier. The label `Churn` is TRUE or FALSE; BigQuery learns to predict which.
    - One feature: `tenure`.
    - `data_split_method = 'RANDOM'`, `data_split_eval_fraction = 0.2`: 20% held aside, as yesterday.

4. **Ask it about five customers (block 4).** `ML.PREDICT` adds `predicted_Churn` (TRUE or FALSE) and `predicted_Churn_probs`, a small list with two probabilities: one for TRUE (leaves), one for FALSE (stays). `UNNEST` turns that list into rows, and `WHERE p.label = TRUE` keeps the probability of leaving. `LIMIT 5` takes any five customers, so yours may not be your neighbour's.

    A customer with tenure 1 gets about 0.50; tenure 34 about 0.22; tenure 45 about 0.15. The longer a customer has stayed, the less likely they are to leave.

5. **Read the model (block 5).** `ML.WEIGHTS`: the weight of `tenure` is about −0.039. Negative: more tenure, lower chance of leaving. The size is on a log-odds scale, so read the sign, not the number.

6. **The question for the next hour.** The model says 0.49 for one customer and 0.22 for another. Who gets the offer? A probability is not a decision: someone has to choose where to cut.

## Check yourself

| Block | Rows returned | One value to check |
|---|---:|---|
| 1 | 11 | every row has tenure 0 and a blank `TotalCharges` |
| 2 | 3 | month-to-month 0.427 · one year 0.113 · two year 0.028 |
| 4 | 5 | the shorter the tenure, the higher the probability (tenure 1 ≈ 0.50) |
| 5 | 2 | `tenure` ≈ −0.039 |

## If something goes wrong

- **`Churn` shows as STRING in the schema:** you uploaded without Auto detect. Write `Churn = 'Yes'` for `Churn = TRUE`, and `p.label = 'Yes'` in block 4.
- **`Unrecognized name: predicted_Churn_probs`:** the name follows the label: `predicted_` + `Churn` + `_probs`, with the same capital C.
- **Block 4 returns 10 rows:** the `WHERE p.label = TRUE` line is missing; each customer has a row for TRUE and a row for FALSE.

## References

Telco Customer Churn, IBM sample data (7,043 customers), from IBM's public repository `IBM/telco-customer-churn-on-icp4d`; course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md), taken 18 October 2026. BigQuery ML: [CREATE MODEL for logistic regression](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm), [ML.PREDICT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-predict), Google Cloud.
