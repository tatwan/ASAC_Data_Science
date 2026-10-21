# Lab 03 · Thresholds: from a probability to a decision

In this self-guided lab, you will see how the threshold turns the model's probabilities into decisions, read the ROC curve, let the costs of an offer choose the threshold, and compare two models on how well they rank customers.

**When:** after class, at your own pace. Not submitted. · **Data:** `ml.telco`, and the models `ml.churn_tenure` (activity 01) and `ml.churn_model` (activity 02) · **SQL:** `Solved/thresholds_and_curves.sql`

## The one idea

The model never says "leaves" or "stays". It gives each customer a **probability** of leaving. The **threshold** is the cut we choose: above it, the customer gets a retention offer. The model is the same at every threshold; only our decision changes. Which threshold is right depends on what an offer costs, and that is a business question.

## How to work through this lab

Run each query, compare with **What you should see**, and answer **Think** in one line. If a model is missing, run activity 01 block 3 and activity 02 block 1 first.

`Churn` is BOOLEAN in your table: TRUE means the customer left.

## Step 1 · Same probabilities, different decisions

Ten customers, their probability of leaving, and the model's answer at threshold 0.3:

```sql
SELECT customerID,
       ROUND(p.prob, 2) AS prob_leave,
       predicted_Churn
FROM ML.PREDICT(MODEL ml.churn_model,
       (SELECT * FROM ml.telco ORDER BY customerID LIMIT 10),
       STRUCT(0.3 AS threshold)),
     UNNEST(predicted_Churn_probs) AS p
WHERE p.label = TRUE;
```

`STRUCT(0.3 AS threshold)` is a setting for `ML.PREDICT`: say TRUE (leaves) when the probability is above 0.3. The `UNNEST` line is the one from activity 01: it keeps the probability of TRUE.

Now change `0.3` to `0.7` and run it again.

**What you should see:** `prob_leave` is the same in both runs. Only `predicted_Churn` changes: at 0.3 more customers are TRUE, at 0.7 fewer.

**Think:** a customer has `prob_leave` 0.45. At which of the two thresholds do they get an offer?

## Step 2 · The ROC curve: every threshold at once

```sql
SELECT ROUND(false_positive_rate, 3) AS false_positive_rate,
       ROUND(recall, 3) AS recall
FROM ML.ROC_CURVE(MODEL ml.churn_model)
ORDER BY false_positive_rate;
```

Each row is one threshold, scored on the 20% of customers the model did not train on. Two columns:

- `recall`: of the customers who left, the share we flagged. We want this high.
- `false_positive_rate`: of the customers who stayed, the share we flagged by mistake. We want this low.

To see the curve, open the **Chart** tab under the results (if your console shows one), choose a line chart, and put `false_positive_rate` on the x axis and `recall` on the y axis.

**What you should see:** both columns rise together. Flag more customers and you catch more leavers, but you also bother more customers who were staying. The curve bends up towards the top-left corner.

**Think:** why is the top-left corner the best place to be? (Hint: what are recall and the false positive rate there?)

## Step 3 · Let the costs choose the threshold

The costs from class (invented, said to be invented):

- an offer costs **50**;
- a customer who leaves costs **500**;
- an offer keeps **1 in 3** of the leavers who get it.

So each leaver we catch is worth about 500 ÷ 3 − 50 ≈ **117**, and each offer sent to someone who was staying anyway costs **50**. Price every threshold:

```sql
SELECT ROUND(threshold, 2) AS threshold,
       true_positives + false_positives AS offers,
       true_positives * 117 - false_positives * 50 AS campaign_value
FROM ML.ROC_CURVE(MODEL ml.churn_model)
ORDER BY campaign_value DESC
LIMIT 5;
```

`true_positives` are the leavers we caught; `false_positives` are the offers wasted on customers who were staying.

**What you should see:** the five best thresholds sit close to 0.3.

Now make the offer cost **100**. A caught leaver is then worth 500 ÷ 3 − 100 ≈ 67, and a wasted offer costs 100. Change the line to:

```sql
       true_positives * 67 - false_positives * 100 AS campaign_value
```

**What you should see:** the best thresholds move up, to around 0.6. When offers cost more, send them only to customers who are more likely to leave.

Why 0.3 and 0.6? An offer pays when the chance of leaving × 500 ÷ 3 is more than its cost: 50 ÷ 167 ≈ 0.3, and 100 ÷ 167 ≈ 0.6.

That rule takes the model's probabilities at their word. They are estimates, so the best rows land near 0.3 and 0.6, not exactly on them. One more honest note: we picked the threshold on the same held-aside customers we scored it on. That is fine for learning. In a real project, you pick it on one group of customers and check it once on another, as D14 does.

**Think:** who should supply these costs, the analyst or the business?

## Step 4 · Which model ranks customers better?

ROC AUC is the area under step 2's curve, one number for every threshold at once. It answers: pick one leaver and one stayer at random; how often does the model give the leaver the higher probability? 0.5 is guessing, 1 is perfect.

```sql
SELECT 'tenure only' AS model, ROUND(roc_auc, 3) AS roc_auc
FROM ML.EVALUATE(MODEL ml.churn_tenure)
UNION ALL
SELECT 'eight features', ROUND(roc_auc, 3)
FROM ML.EVALUATE(MODEL ml.churn_model);
```

**What you should see:** about 0.74 for tenure only and about 0.84 for eight features. Each model held aside its own 20%, so small differences could be luck; a gap of about 0.1 is not.

**Think:** did the extra seven features help the model tell leavers from stayers?

## What you saw

| Step | What it showed |
|---|---|
| 1 · threshold in `ML.PREDICT` | |
| 2 · `ML.ROC_CURVE` | |
| 3 · campaign value | |
| 4 · `roc_auc`, one feature against eight | |

## Bonus · Precision against recall

Not required. Precision is "of the customers we flagged, the share who really left". This query shows how it falls as recall rises:

```sql
SELECT ROUND(threshold, 2) AS threshold,
       ROUND(recall, 2) AS recall,
       ROUND(true_positives / (true_positives + false_positives), 2) AS precision
FROM ML.ROC_CURVE(MODEL ml.churn_model)
WHERE threshold BETWEEN 0.1 AND 0.75
ORDER BY recall;
```

As recall climbs, precision falls. At threshold 0.1 the model finds about 19 in 20 leavers, but only about 4 in 10 of the customers it flags really leave. Flag everyone and precision would fall to about 0.27, the share who left. The area under this curve is called PR AUC; BigQuery does not print it.

## References

Telco Customer Churn, IBM sample data; course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md). The retention costs are invented for class. BigQuery ML: [ML.PREDICT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-predict), [ML.ROC_CURVE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-roc), [ML.EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate), Google Cloud.
