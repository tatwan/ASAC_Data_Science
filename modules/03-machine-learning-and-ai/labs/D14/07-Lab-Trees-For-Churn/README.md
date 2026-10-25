# Lab 07 · Trees for a category: Telco churn, fairly compared

In this lab, you will put D12's logistic regression, a boosted-trees classifier and a random-forest classifier on the same Telco customers, choose one on validation, test one engineered feature, and test your choice once.

**When:** after class, about 50 minutes, at your own pace. Not submitted. · **Data:** `ml.telco` (D12) → the view `ml.telco_groups` · **SQL:** `Solved/trees_for_churn.sql`

## The story

On D12 the retention team got a logistic regression that ranks customers by their chance of leaving (ROC AUC about 0.84). In class today, trees beat a straight line on the insurance data. The retention team asks the obvious question: *would trees find more of our leavers?* You will answer it the way you answered the pricing team: same rows for every model, choose on validation, test once.

## What you will learn

- To train `BOOSTED_TREE_CLASSIFIER` and `RANDOM_FOREST_CLASSIFIER` with the same features as a `LOGISTIC_REG`.
- To compare classifiers fairly on ROC AUC, accuracy and log loss, against the majority guess.
- To judge a small gain from one new feature, and to check it on a second deal of the rows.

## Before you start

You need the table `ml.telco` from [D12 activity 01](../../D12/01-Evr-First-Classifier/README.md): 7,043 rows, `Churn` TRUE (left) or FALSE (stayed), as on D12. If it is missing, download [`telco_churn.csv`](../../../../../shared/datasets/ml_classics/telco_churn.csv) and upload it as `telco` in `ml` with **Auto detect**. Auto detect reads the file's Yes/No as BOOLEAN. If `Churn` shows as STRING instead, write `'Yes'` for `TRUE` and `'No'` for `FALSE` in the queries below.

Work like the other labs: run each query, compare with **What you should see**, and answer **Think** in one line. The values were computed outside BigQuery with BigQuery's default settings; tree models may differ a little from yours. If the tree models will not train in your sandbox (a message about billing or Vertex AI), use the fallback file in step 3.

## Checkpoints

- **C1:** a boosted-trees or forest classifier compared with D12's logistic regression on the same validation customers, and a choice in one sentence (steps 1 to 4).
- **C2:** one engineered feature and its effect on validation, checked on a second deal (steps 5 and 6).
- **C3:** the chosen model tested once, with a one-paragraph recommendation for the retention team (step 7).

## Step 1 · The same customers for every model

```sql
CREATE OR REPLACE VIEW ml.telco_groups AS
SELECT *,
       CASE MOD(ROW_NUMBER() OVER (ORDER BY customerID), 5)
         WHEN 3 THEN 'validation'
         WHEN 4 THEN 'test'
         ELSE 'train'
       END AS split
FROM ml.telco;

SELECT split, COUNT(*) AS customers, ROUND(COUNTIF(Churn = TRUE) / COUNT(*), 3) AS churn_rate
FROM ml.telco_groups
GROUP BY split
ORDER BY customers DESC;
```

The same deal as in class, ordered by `customerID` because Telco has an identifier.

**What you should see:** training 4,226 customers (churn rate 0.262), validation 1,409 (0.252), test 1,408 (0.288).

## Step 2 · Three classifiers, one set of features

```sql
CREATE OR REPLACE MODEL ml.telco_logistic
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['Churn'], data_split_method = 'NO_SPLIT') AS
SELECT tenure, MonthlyCharges, Contract, InternetService, PaymentMethod,
       SeniorCitizen, PaperlessBilling, TechSupport, Churn
FROM ml.telco_groups
WHERE split = 'train';

CREATE OR REPLACE MODEL ml.telco_boosted
OPTIONS (model_type = 'BOOSTED_TREE_CLASSIFIER', input_label_cols = ['Churn'], data_split_method = 'NO_SPLIT') AS
SELECT tenure, MonthlyCharges, Contract, InternetService, PaymentMethod,
       SeniorCitizen, PaperlessBilling, TechSupport, Churn
FROM ml.telco_groups
WHERE split = 'train';

CREATE OR REPLACE MODEL ml.telco_forest
OPTIONS (model_type = 'RANDOM_FOREST_CLASSIFIER', input_label_cols = ['Churn'], data_split_method = 'NO_SPLIT') AS
SELECT tenure, MonthlyCharges, Contract, InternetService, PaymentMethod,
       SeniorCitizen, PaperlessBilling, TechSupport, Churn
FROM ml.telco_groups
WHERE split = 'train';
```

D12's eight features, for all three. A classic single classification tree works like the regression tree from class, with a leaf holding the **share of leavers** among its training customers, and each question chosen to make the groups less mixed (Gini impurity, on today's slides). BigQuery's trees are built with XGBoost: each question is chosen to lower the log loss from D12, and the leaves of all the trees add up to one score that becomes the probability. The idea is the same: questions that separate leavers from stayers.

## Step 3 · Score all three on the same validation customers

```sql
SELECT 'logistic' AS model, ROUND(roc_auc, 3) AS roc_auc, ROUND(accuracy, 3) AS accuracy,
       ROUND(precision, 3) AS precision, ROUND(recall, 3) AS recall, ROUND(log_loss, 3) AS log_loss
FROM ML.EVALUATE(MODEL ml.telco_logistic, (SELECT * FROM ml.telco_groups WHERE split = 'validation'))
UNION ALL
SELECT 'boosted trees', ROUND(roc_auc, 3), ROUND(accuracy, 3), ROUND(precision, 3), ROUND(recall, 3), ROUND(log_loss, 3)
FROM ML.EVALUATE(MODEL ml.telco_boosted, (SELECT * FROM ml.telco_groups WHERE split = 'validation'))
UNION ALL
SELECT 'random forest', ROUND(roc_auc, 3), ROUND(accuracy, 3), ROUND(precision, 3), ROUND(recall, 3), ROUND(log_loss, 3)
FROM ML.EVALUATE(MODEL ml.telco_forest, (SELECT * FROM ml.telco_groups WHERE split = 'validation'));

SELECT ROUND(COUNTIF(Churn = FALSE) / COUNT(*), 3) AS majority_guess_accuracy
FROM ml.telco_groups
WHERE split = 'validation';
```

`log_loss` is new: it punishes a confident wrong probability more than an unsure one; lower is better.

**What you should see:**

| Model | ROC AUC | Accuracy | Precision | Recall | Log loss |
|---|---:|---:|---:|---:|---:|
| logistic | 0.830 | 0.797 | 0.616 | 0.515 | 0.425 |
| boosted trees | ≈ 0.827 | ≈ 0.789 | ≈ 0.59 | ≈ 0.51 | ≈ 0.43 |
| random forest | ≈ 0.829 | ≈ 0.79 | ≈ 0.61 | ≈ 0.51 | ≈ 0.45 |

The majority guess ("No" for everyone) is right for 0.748 of the validation customers. All three models land within about 0.004 of each other on ROC AUC.

**If the tree models will not train:** upload [`d14_telco_probabilities.csv`](../Resources/fallback/d14_telco_probabilities.csv) as `ml.d14_telco` and compute accuracy at 0.5 for each column in plain SQL, for example `ROUND(AVG(IF((prob_boosted >= 0.5) = Churn, 1, 0)), 3)` on `WHERE split = 'validation'`.

**Think:** the trees' training ROC AUC is about 0.90 (boosted) and 0.91 (forest), against 0.84 for logistic. What does that gap tell you?

## Step 4 · What the boosted trees leaned on

```sql
SELECT feature, importance_weight,
       ROUND(importance_weight * importance_gain
             / SUM(importance_weight * importance_gain) OVER (), 3) AS share_of_gain
FROM ML.FEATURE_IMPORTANCE(MODEL ml.telco_boosted)
ORDER BY share_of_gain DESC;
```

`importance_gain` is the average gain per question, so the query multiplies it by the number of questions to get each column's total, then its share.

**What you should see:** `Contract` first with about 0.4 of the total gain from only about 30 questions; `MonthlyCharges` and `tenure` about 0.22 each, from about 315 and 210 questions. The same story as D12's logistic weights: month-to-month contracts leave.

**C1:** which model would you give the retention team, and why, in one sentence? (A fair answer: logistic regression. It scores as well as the trees on unseen customers, overfits less, and D12 already showed how to read its weights.)

## Step 5 · One engineered feature

Leaving is most common in the first months; after that, each extra month matters less. A logarithm says exactly that (D13): `LN(1 + tenure)` rises fast at first, then slowly.

```sql
CREATE OR REPLACE MODEL ml.telco_logistic_log
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['Churn'], data_split_method = 'NO_SPLIT') AS
SELECT tenure, LN(1 + tenure) AS log_tenure, MonthlyCharges, Contract, InternetService, PaymentMethod,
       SeniorCitizen, PaperlessBilling, TechSupport, Churn
FROM ml.telco_groups
WHERE split = 'train';

SELECT ROUND(roc_auc, 3) AS roc_auc, ROUND(accuracy, 3) AS accuracy
FROM ML.EVALUATE(MODEL ml.telco_logistic_log,
  (SELECT *, LN(1 + tenure) AS log_tenure FROM ml.telco_groups WHERE split = 'validation'));
```

**What you should see:** ROC AUC about 0.839 (from 0.830), accuracy about 0.808 (from 0.797).

**Think:** a gain of 0.009 on 1,409 customers. Real, or luck of this deal? Step 6 checks.

## Step 6 · A second deal

Deal the cards differently: the customers in the old remainder 0 become validation, and the old validation customers join training. The test customers stay where they are.

```sql
CREATE OR REPLACE VIEW ml.telco_groups_deal2 AS
SELECT *,
       CASE MOD(ROW_NUMBER() OVER (ORDER BY customerID), 5)
         WHEN 0 THEN 'validation'
         WHEN 4 THEN 'test'
         ELSE 'train'
       END AS split
FROM ml.telco;
```

Train both logistic models again on the new deal, under new names, and score both on its validation rows:

```sql
CREATE OR REPLACE MODEL ml.telco_logistic_d2
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['Churn'], data_split_method = 'NO_SPLIT') AS
SELECT tenure, MonthlyCharges, Contract, InternetService, PaymentMethod,
       SeniorCitizen, PaperlessBilling, TechSupport, Churn
FROM ml.telco_groups_deal2
WHERE split = 'train';

CREATE OR REPLACE MODEL ml.telco_logistic_log_d2
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['Churn'], data_split_method = 'NO_SPLIT') AS
SELECT tenure, LN(1 + tenure) AS log_tenure, MonthlyCharges, Contract, InternetService, PaymentMethod,
       SeniorCitizen, PaperlessBilling, TechSupport, Churn
FROM ml.telco_groups_deal2
WHERE split = 'train';

SELECT 'without log_tenure' AS model, ROUND(roc_auc, 3) AS roc_auc
FROM ML.EVALUATE(MODEL ml.telco_logistic_d2,
  (SELECT * FROM ml.telco_groups_deal2 WHERE split = 'validation'))
UNION ALL
SELECT 'with log_tenure', ROUND(roc_auc, 3)
FROM ML.EVALUATE(MODEL ml.telco_logistic_log_d2,
  (SELECT *, LN(1 + tenure) AS log_tenure FROM ml.telco_groups_deal2 WHERE split = 'validation'));
```

**What you should see:** about 0.823 without and 0.831 with `log_tenure`. On four deals computed outside BigQuery, the feature helped every time, by 0.005 to 0.009. Small, but steady.

**C2:** keep the feature or not? One sentence. (Either answer can be right; say what the four deals tell you.)

## Step 7 · The test, once

Score the model you chose, once, on the test customers. For the logistic regression with `log_tenure`:

```sql
SELECT ROUND(roc_auc, 3) AS roc_auc, ROUND(accuracy, 3) AS accuracy,
       ROUND(precision, 3) AS precision, ROUND(recall, 3) AS recall
FROM ML.EVALUATE(MODEL ml.telco_logistic_log,
  (SELECT *, LN(1 + tenure) AS log_tenure FROM ml.telco_groups WHERE split = 'test'));

SELECT ROUND(COUNTIF(Churn = FALSE) / COUNT(*), 3) AS majority_guess_accuracy
FROM ml.telco_groups
WHERE split = 'test';
```

**What you should see:** ROC AUC about 0.844, accuracy about 0.788, precision about 0.68 and recall about 0.50, against 0.712 for the majority guess. (For comparison only, not to choose again: without `log_tenure` the test ROC AUC is about 0.839.)

**C3:** a paragraph for the retention team: which model, how well it ranks leavers on customers it never saw, what it gets wrong (recall about 0.5 at threshold 0.5), and what you would try next (D12: move the threshold to the cost of a missed leaver).

## More practice (not checked, not submitted)

- **Class weights on trees.** Add `auto_class_weights = TRUE` to `ml.telco_boosted`. Computed outside BigQuery: recall rises from about 0.51 to about 0.73, precision falls from about 0.59 to about 0.50, ROC AUC stays about 0.83. The same trade as D12 lab 04: more leavers found, more offers wasted, and the ranking barely moves.
- **Smaller trees.** `max_tree_depth = 2` on the boosted classifier: ROC AUC about 0.833. On this data, shallower trees are at least as good.

## What you saw

| Step | What you found |
|---|---|
| Three classifiers on the same customers | |
| Training against validation | |
| One engineered feature, two deals | |
| The test, once | |

## References

Telco Customer Churn, IBM sample data; course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md). BigQuery ML: [CREATE MODEL for boosted trees](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-boosted-tree), [for random forests](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-random-forest), [ML.EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate), Google Cloud.
