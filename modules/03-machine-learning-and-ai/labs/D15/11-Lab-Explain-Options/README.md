# Lab 11 · Explaining models, argument by argument

In this self-guided lab, you will change every argument of `ML.EXPLAIN_PREDICT`, read every column it returns, explain a classifier as well as a regression, and put `ML.GLOBAL_EXPLAIN` beside D14's `ML.FEATURE_IMPORTANCE`.

**When:** after class, about 45 minutes, at your own pace. Not submitted. · **Data:** `ml.insurance_groups` and `ml.ins_boosted` (D14 activity 01), `ml.ins_explain` (activity 07); `ml.telco_groups` and `ml.telco_boosted` (D14 lab 07) · **SQL:** `Unsolved/explain_options.sql` to run step by step, `Solved/explain_options.sql`

## The story

In class you explained five insured people and the model overall. Two questions came up that class had no time for. The retention team from D12 asks for the same thing on their churn model: why does the model think this customer will leave? And the pricing team asks which of the two tables to believe, `ML.GLOBAL_EXPLAIN` or `ML.FEATURE_IMPORTANCE`, when they rank the features differently. This lab answers both.

## What you will learn

- What `top_k_features`, `threshold` and `approx_feature_contrib` change in `ML.EXPLAIN_PREDICT`, and what every output column means.
- How explanations work for a classifier: the predicted class, its probability, and attributions in log-odds.
- To use `ML.GLOBAL_EXPLAIN` with and without `class_level_explain`, and why it needs `ENABLE_GLOBAL_EXPLAIN = TRUE` at training.
- To compare three ways of ranking features: global attribution, gain and split counts.

## Before you start

You need:

- `ml.insurance_groups` and `ml.ins_boosted` from [D14 activity 01](../../D14/01-Evr-Same-Rows-Two-Models/README.md), and `ml.ins_explain` from [activity 07](../07-Evr-Explain-Five-People/README.md), step 3. Check: `SELECT COUNT(*) FROM ml.insurance_groups;` returns 1,338. [`Resources/restart_d15.sql`](../Resources/restart_d15.sql) rebuilds all three.
- For steps 6 and 8: `ml.telco` from D12 and the view `ml.telco_groups` and model `ml.telco_boosted` from [D14 lab 07](../../D14/07-Lab-Trees-For-Churn/README.md), steps 1 and 2. Check: `SELECT COUNT(*) FROM ml.telco;` returns 7,043. If `ml.telco` is missing, upload [`telco_churn.csv`](../../../../../shared/datasets/ml_classics/telco_churn.csv) as `telco` in `ml` with **Auto detect**, then run D14 lab 07's steps 1 and 2.

Boosted trees are *external* models. They train in the sandbox, but slowly (10 to 15 minutes or more), so start each `CREATE MODEL` and read on while it runs. If yours is not ready or stops with an error, read the steps and their expected values; [activity 07](../07-Evr-Explain-Five-People/README.md), step 5, has the five explanations in a prepared file.

Work like the other labs: read the step, run its SQL, compare with **What you should see**, and answer **Think** in one line. The values marked "about" were computed outside BigQuery with BigQuery's settings (XGBoost underneath); yours can differ a little.

## Step 1 · The five people, once, as a view

```sql
CREATE OR REPLACE VIEW ml.five_people AS
SELECT CASE ROUND(charges, 2)
         WHEN 4391.65 THEN 'A' WHEN 10370.91 THEN 'B' WHEN 13228.85 THEN 'C'
         WHEN 17904.53 THEN 'D' WHEN 43578.94 THEN 'E'
       END AS person,
       age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups
WHERE split = 'validation'
  AND ROUND(charges, 2) IN (4391.65, 10370.91, 13228.85, 17904.53, 43578.94);

SELECT person, age, smoker, ROUND(bmi, 1) AS bmi FROM ml.five_people ORDER BY person;
```

Activity 07's people A to E, with a letter each, so the later steps stay short.

**What you should see:** 5 rows: A 25, B 49, C 60, D 33, E 57; D and E are the smokers.

## Step 2 · top_k_features

```sql
SELECT e.person, COUNT(*) AS attributions_returned,
       STRING_AGG(a.feature ORDER BY ABS(a.attribution) DESC) AS features_by_size
FROM ML.EXPLAIN_PREDICT(MODEL ml.ins_boosted,
  (SELECT * FROM ml.five_people),
  STRUCT(5 AS top_k_features)) AS e,
  UNNEST(e.top_feature_attributions) AS a
GROUP BY e.person
ORDER BY e.person;
```

`top_k_features` (INT64, default 5) "specifies how many top feature attribution pairs are generated for each row of input data. The features are ranked by the absolute values of their attributions." Five is the default, written out. If you ask for more than the model has, you get all of them.

**What you should see:** 5 rows, 5 attributions each: one of the six features is left out for every person, the one with the smallest push. Computed outside BigQuery, for E that is `sex` (about −85). Run it again with `6 AS top_k_features` (all six) and with `2`: does every person get the same top two?

## Step 3 · Every output column

```sql
SELECT person, charges,
       ROUND(predicted_charges, 2) AS predicted_charges,
       ROUND(baseline_prediction_value, 2) AS baseline_prediction_value,
       ROUND(prediction_value, 2) AS prediction_value,
       approximation_error,
       ROUND(baseline_prediction_value
             + (SELECT SUM(a.attribution) FROM UNNEST(top_feature_attributions) AS a), 2) AS rebuilt
FROM ML.EXPLAIN_PREDICT(MODEL ml.ins_boosted,
  (SELECT * FROM ml.five_people),
  STRUCT(6 AS top_k_features))
ORDER BY person;
```

| Column | Read it as |
|---|---|
| `predicted_charges` | `predicted_<label>`: the prediction, as `ML.PREDICT` gives it |
| `top_feature_attributions` | the array of `feature` and `attribution` pairs |
| `baseline_prediction_value` | for trees, "the bias term, which is the expected output of the model over the training dataset" |
| `prediction_value` | the raw prediction; for a regression the same as `predicted_charges`, for a classifier the log-odds (step 6) |
| `approximation_error` | 0 for exact methods; Tree SHAP for trees is exact |
| `person`, `charges` | input columns the model does not use; they pass through |

**What you should see:** 5 rows; `rebuilt` equals `prediction_value` on every row, and `approximation_error` is 0. Computed outside BigQuery: baseline about 13,219.11; E's prediction about 43,525.61.

## Step 4 · approx_feature_contrib

```sql
SELECT ex.person, ex.feature,
       ROUND(ex.attribution) AS exact_attribution,
       ROUND(ap.attribution) AS approximate_attribution
FROM (
  SELECT e.person, a.feature, a.attribution
  FROM ML.EXPLAIN_PREDICT(MODEL ml.ins_boosted, (SELECT * FROM ml.five_people),
                          STRUCT(6 AS top_k_features, FALSE AS approx_feature_contrib)) AS e,
       UNNEST(e.top_feature_attributions) AS a
) AS ex
JOIN (
  SELECT e.person, a.feature, a.attribution
  FROM ML.EXPLAIN_PREDICT(MODEL ml.ins_boosted, (SELECT * FROM ml.five_people),
                          STRUCT(6 AS top_k_features, TRUE AS approx_feature_contrib)) AS e,
       UNNEST(e.top_feature_attributions) AS a
) AS ap
  ON ex.person = ap.person AND ex.feature = ap.feature
ORDER BY ex.person, ABS(ex.attribution) DESC;
```

`approx_feature_contrib` (BOOL, default FALSE) "applies only to boosted tree and random forest models". TRUE uses a faster approximation of each feature's contribution instead of Tree SHAP; Google's explainability overview lists both methods for trees.

**What you should see:** 30 rows. Both columns still add up to each prediction, but the split between features can differ, sometimes noticeably. On five people speed does not matter; on millions of rows it might.

**Think:** when would you accept approximate attributions?

## Step 5 · max_output_tokens

The syntax block on the `ML.EXPLAIN_PREDICT` page lists one more argument, `max_output_tokens`, but the page's argument list does not describe it. It does not apply to the models in this course; leave it out.

## Step 6 · A classifier: threshold, probability and log-odds

First, the Telco groups from D14 lab 07, in plain SQL:

```sql
SELECT split, COUNT(*) AS customers
FROM ml.telco_groups
GROUP BY split
ORDER BY customers DESC;
```

Then explain five validation customers, at two thresholds:

```sql
SELECT customerID, Churn, predicted_Churn, ROUND(probability, 3) AS probability,
       ROUND(prediction_value, 3) AS log_odds, top_feature_attributions
FROM ML.EXPLAIN_PREDICT(MODEL ml.telco_boosted,
  (SELECT * FROM ml.telco_groups WHERE split = 'validation' ORDER BY customerID LIMIT 5),
  STRUCT(3 AS top_k_features, 0.5 AS threshold))
ORDER BY customerID;
```

`threshold` (FLOAT64, default 0.5, between 0.0 and 1.0) is the cutoff for a binary classifier, as on D12. The page: "Feature attributions are returned only for the predicted label." For a classifier, `probability` is the probability of the predicted class, and `prediction_value` is "the logit value (also called log-odds) for the predicted class", so the attributions are in log-odds, not in percentage points.

**What you should see:** the counts first, 3 rows: train 4,226, validation 1,409, test 1,408. Then 5 rows. Run it again with `0.3 AS threshold`: a customer whose probability of `Yes` lies between 0.3 and 0.5 changes from `No` to `Yes`, and their attributions now explain `Yes`.

## Step 7 · ML.GLOBAL_EXPLAIN, and why the option is needed

```sql
SELECT feature, ROUND(attribution) AS attribution
FROM ML.GLOBAL_EXPLAIN(MODEL ml.ins_explain)
ORDER BY attribution DESC;

SELECT feature, attribution
FROM ML.GLOBAL_EXPLAIN(MODEL ml.ins_boosted);
```

Google's page: "You can only use ML.GLOBAL_EXPLAIN with models that are trained with the ENABLE_GLOBAL_EXPLAIN option set to TRUE." The boosted-tree page explains why: "Global explanations are computed when you create the model." The option's default is FALSE. `ML.GLOBAL_EXPLAIN` takes no input rows; it reads what was computed at training. For a regression it returns two columns, `feature` and `attribution`.

**What you should see:** 6 rows for `ml.ins_explain`, `smoker` first. The second query, on `ml.ins_boosted` (trained without the option), stops with an error.

## Step 8 · class_level_explain on a classifier

`class_level_explain` applies only to classifiers, so this step uses D14 lab 07's boosted classifier, trained again under a new name with `enable_global_explain = TRUE` (same features, same training customers):

```sql
CREATE OR REPLACE MODEL ml.telco_explain
OPTIONS (model_type = 'BOOSTED_TREE_CLASSIFIER',
         input_label_cols = ['Churn'],
         data_split_method = 'NO_SPLIT',
         enable_global_explain = TRUE) AS
SELECT tenure, MonthlyCharges, Contract, InternetService, PaymentMethod,
       SeniorCitizen, PaperlessBilling, TechSupport, Churn
FROM ml.telco_groups
WHERE split = 'train';

SELECT feature, ROUND(attribution, 3) AS attribution
FROM ML.GLOBAL_EXPLAIN(MODEL ml.telco_explain)
ORDER BY attribution DESC;

SELECT *
FROM ML.GLOBAL_EXPLAIN(MODEL ml.telco_explain, STRUCT(TRUE AS class_level_explain));
```

`class_level_explain` (BOOL, default FALSE): with TRUE the importances come per class, and "For each class, only the top 10 most important features are returned." The page: "Regression models and AutoML Tables classification models only have model-level global feature importance."

The page names the output columns. Without `class_level_explain`: `feature` and `attribution`, so the first query lists them. With it: `<class_name>`, "a STRING value that contains the name of the class in the label column", then `feature` and `attribution`. The page writes the first one only as a placeholder and does not say what the column is called, so the second query keeps `SELECT *`: run it and read the first column's name in the result.

**What you should see:** the first query, 8 rows (one per feature). The second, one block per class, `No` and `Yes`, 8 rows each (fewer than 10 features, so all of them). D14 lab 07 found `Contract` doing most of the work; expect it near the top of both.

## Step 9 · Global importance, the long way

```sql
SELECT a.feature, ROUND(AVG(ABS(a.attribution)), 2) AS mean_abs_attribution
FROM ML.EXPLAIN_PREDICT(MODEL ml.ins_boosted,
  (SELECT * FROM ml.insurance_groups WHERE split = 'validation'),
  STRUCT(6 AS top_k_features)) AS e,
  UNNEST(e.top_feature_attributions) AS a
GROUP BY a.feature
ORDER BY mean_abs_attribution DESC;
```

Google's overview defines the global explanation as "the mean absolute attribution that each feature receives for all the rows in the evaluation dataset", and the `ML.GLOBAL_EXPLAIN` page says it aggregates "the local explanations of the evaluation data". This query computes the same average yourself, on rows you choose: the 268 validation people.

**What you should see:** 6 rows. Computed outside BigQuery: smoker about 7,736.84, age about 3,315.98, BMI about 2,197.32, children about 817.82, region about 402.88, sex about 94.57. Compare the order with step 7's. Compare the sizes with care: `ml.ins_explain` was trained with `data_split_method = 'NO_SPLIT'`, which the boosted-tree page defines as "No data split; all input data is used as training data", so it has no evaluation rows of its own, and neither page says which rows `ML.GLOBAL_EXPLAIN` averages over in that case. Its numbers need not match these.

## Step 10 · Three rankings side by side

```sql
SELECT g.feature,
       ROUND(g.attribution) AS global_attribution,
       f.importance_weight,
       ROUND(f.importance_gain, 1) AS importance_gain,
       ROUND(f.importance_cover, 1) AS importance_cover
FROM ML.GLOBAL_EXPLAIN(MODEL ml.ins_explain) AS g
JOIN ML.FEATURE_IMPORTANCE(MODEL ml.ins_explain) AS f
  ON g.feature = f.feature
ORDER BY global_attribution DESC;
```

| Column | From | Measures |
|---|---|---|
| `global_attribution` | `ML.GLOBAL_EXPLAIN` | how far, in dollars, the feature moves a typical prediction |
| `importance_weight` | `ML.FEATURE_IMPORTANCE` | "the number of times a feature is used to split the data across all trees" |
| `importance_gain` | `ML.FEATURE_IMPORTANCE` | "the average gain across all splits the feature is used in" |
| `importance_cover` | `ML.FEATURE_IMPORTANCE` | "the average coverage across all splits the feature is used in" |

`ML.FEATURE_IMPORTANCE` works only on boosted trees and random forests and does not need `ENABLE_GLOBAL_EXPLAIN`.

**What you should see:** 6 rows. `smoker` leads on attribution and gain with few splits; `bmi` and `age` are used in the most splits. A feature can be split on often and still move predictions less than one used rarely.

**Think:** the pricing team asks "which feature matters most?" Which column answers that question in their units?

## Step 11 · APPROX_GLOBAL_FEATURE_CONTRIB

One more option on the boosted-tree page belongs with these: `APPROX_GLOBAL_FEATURE_CONTRIB`. The page: "In order to use the fast approximation for feature contribution computations, you need to set both ENABLE_GLOBAL_EXPLAIN and APPROX_GLOBAL_FEATURE_CONTRIB to TRUE." Its default is "TRUE when ENABLE_GLOBAL_EXPLAIN is TRUE and NUM_PARALLEL_TREE >= 10, otherwise it is FALSE." `ml.ins_explain` has one tree per round (`NUM_PARALLEL_TREE` 1), so its global explanation is exact. A random forest (100 parallel trees by default) with `enable_global_explain = TRUE` would use the approximation unless you set this option to FALSE.

## More practice (not checked, not submitted)

- Explain the five people with `ml.ins_forest` from D14 activity 04: do a forest and boosted trees give the same people the same reasons?
- Run step 9 on the test people (`split = 'test'`) after your D14 choice was tested: does the ranking hold on other rows?

## What you saw

| Question | Your answer |
|---|---|
| What does `top_k_features` change, and what stays the same? | |
| What changes in the explanation when the threshold moves? | |
| Why does `ML.GLOBAL_EXPLAIN` fail on `ml.ins_boosted`? | |
| Which ranking would you show the pricing team? | |

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 5 | ages **25**, **49**, **60**, **33**, **57** |
| 6 | 3 | train **4,226** · validation **1,409** · test **1,408** |

The other steps read models trained in BigQuery; each step says how many rows to expect.

## Hint

All the explain functions take `MODEL …` first; `ML.EXPLAIN_PREDICT` then takes the rows to explain in parentheses, then one `STRUCT` of arguments. `ML.GLOBAL_EXPLAIN` and `ML.FEATURE_IMPORTANCE` take no rows.

## Bonus

In step 6, take one customer and add their three attributions to the baseline in log-odds. Convert the sum to a probability with `1 / (1 + EXP(-x))`: does it come close to `probability`? (It will not match exactly with only three of eight features.)

## References

Medical Cost Personal Datasets (Kaggle, `mirichoi0218/insurance`), from Brett Lantz, *Machine Learning with R* (Packt, 2013); Telco Customer Churn, IBM sample data; course copies in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md), taken 18 October 2026. BigQuery ML: [ML.EXPLAIN_PREDICT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-explain-predict), [ML.GLOBAL_EXPLAIN](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-global-explain), [ML.FEATURE_IMPORTANCE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-importance), [Explainable AI overview](https://docs.cloud.google.com/bigquery/docs/xai-overview), [CREATE MODEL for boosted trees](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-boosted-tree) (`ENABLE_GLOBAL_EXPLAIN`, `APPROX_GLOBAL_FEATURE_CONTRIB`), Google Cloud. All pages read 19 October 2026.
