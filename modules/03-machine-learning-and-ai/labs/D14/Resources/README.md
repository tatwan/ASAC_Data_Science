# D14 resources: fallback files, and where each option is used

## If tree models will not train in your sandbox

Boosted trees and random forests are what Google calls *external* models: BigQuery hands their training to another Google service (its pricing page says they are "trained on Gemini platform"). They do train in the BigQuery sandbox, but slowly: a random forest on the insurance table took about 15 minutes. If yours is still training when you need it, or `CREATE MODEL` with `BOOSTED_TREE_REGRESSOR` or `RANDOM_FOREST_REGRESSOR` stops with an error, you can still do every comparison in today's activities from a prepared file. The linear models (`LINEAR_REG`) train quickly; keep training those yourself.

### Insurance (activities 01 to 06)

Download [`fallback/d14_insurance_predictions.csv`](fallback/d14_insurance_predictions.csv) and upload it as `d14_predictions` in `ml` (**⋮** → **Create table**, Upload, CSV, **Auto detect**).

One row is one insured person: `person_id` (their place in the order by charges), `split` (the same three groups as `ml.insurance_groups`), the six features, `charges`, and one column per model:

| Column | Model |
|---|---|
| `pred_linear` | linear, six features (activity 01) |
| `pred_tree3` | one tree, depth 3 (activity 03) |
| `pred_tree15` | one tree, depth 15 (activity 03) |
| `pred_forest` | random forest, defaults (activity 04) |
| `pred_boosted` | boosted trees, defaults (activities 01 and 04) |
| `pred_linear_plus` | linear with `smoker_obese` and `age_sq` (activity 05) |

The predictions were computed outside BigQuery with the same settings, on the same training rows. Score any of them on any group in plain SQL. MAE is the average miss; R² compares the squared misses with those of the group's own average:

```sql
WITH scored AS (
  SELECT split, charges,
         AVG(charges) OVER (PARTITION BY split) AS group_avg,
         pred_linear, pred_tree3, pred_tree15, pred_forest, pred_boosted, pred_linear_plus
  FROM ml.d14_predictions
)
SELECT split,
       ROUND(AVG(ABS(charges - pred_linear))) AS mae_linear,
       ROUND(AVG(ABS(charges - pred_forest))) AS mae_forest,
       ROUND(AVG(ABS(charges - pred_boosted))) AS mae_boosted,
       ROUND(1 - SUM(POW(charges - pred_linear, 2)) / SUM(POW(charges - group_avg, 2)), 2) AS r2_linear,
       ROUND(1 - SUM(POW(charges - pred_tree3, 2)) / SUM(POW(charges - group_avg, 2)), 2) AS r2_tree3,
       ROUND(1 - SUM(POW(charges - pred_tree15, 2)) / SUM(POW(charges - group_avg, 2)), 2) AS r2_tree15,
       ROUND(1 - SUM(POW(charges - pred_forest, 2)) / SUM(POW(charges - group_avg, 2)), 2) AS r2_forest,
       ROUND(1 - SUM(POW(charges - pred_boosted, 2)) / SUM(POW(charges - group_avg, 2)), 2) AS r2_boosted,
       ROUND(1 - SUM(POW(charges - pred_linear_plus, 2)) / SUM(POW(charges - group_avg, 2)), 2) AS r2_linear_plus
FROM scored
WHERE split <> 'test'
GROUP BY split
ORDER BY split;
```

The `WHERE` leaves the test people out: they are scored once, for the model you choose, at the end of activity 06.

**What you should see:** two rows. On `validation`: MAE linear 4,241, forest about 2,600, boosted about 2,630; R² linear 0.74, depth 3 0.84, depth 15 0.73, forest 0.84, boosted 0.83, linear with two features 0.86. On `train`: depth 15 R² 1.00, boosted 0.97, forest 0.89.

**Another way to score: `ML.METRICS`.** Google's `ML.METRICS` computes the scores from any table of actual and predicted values, with no model, so it works on the fallback file as it is. Google marks it as **Preview**: a pre-release feature, available "as is", that "might have limited support". It returns one row per call, for one predicted column:

```sql
SELECT 'forest' AS model, ROUND(mean_absolute_error, 1) AS mae, ROUND(mean_squared_error, 1) AS mse,
       ROUND(mean_squared_log_error, 4) AS msle, ROUND(median_absolute_error, 1) AS median_ae,
       ROUND(r2_score, 3) AS r2, ROUND(explained_variance, 3) AS explained_variance
FROM ML.METRICS((SELECT charges, pred_forest FROM ml.d14_predictions WHERE split = 'validation'),
                predicted_col => 'pred_forest', actual_col => 'charges', task_type => 'regression')
UNION ALL
SELECT 'boosted', ROUND(mean_absolute_error, 1), ROUND(mean_squared_error, 1),
       ROUND(mean_squared_log_error, 4), ROUND(median_absolute_error, 1),
       ROUND(r2_score, 3), ROUND(explained_variance, 3)
FROM ML.METRICS((SELECT charges, pred_boosted FROM ml.d14_predictions WHERE split = 'validation'),
                predicted_col => 'pred_boosted', actual_col => 'charges', task_type => 'regression');
```

**What you should see:** two rows, the same MAE and R² as the query above, with more decimals, and four more columns.

| Model | `mae` | `mse` | `msle` | `median_ae` | `r2` | `explained_variance` |
|---|---:|---:|---:|---:|---:|---:|
| forest | 2,606.1 | 24,540,083.4 | 0.1862 | 1,107.3 | 0.837 | 0.840 |
| boosted | 2,626.6 | 25,193,576.1 | 0.2152 | 917.2 | 0.832 | 0.833 |

The boosted trees miss the typical person by less (median 917 against 1,107) but miss a few people by much more, so their average miss is larger. Computed on the fallback file with the usual definitions; Google's page names the six columns without formulas. The two columns must have the same type (here both FLOAT64). `pred_linear` has negative predictions, and Google's page does not say what `mean_squared_log_error` does with them, so use the query above for the line.

After you have chosen (activity 06), the test, once, for the chosen model only. For the line with two features:

```sql
WITH scored AS (
  SELECT charges, pred_linear_plus, AVG(charges) OVER () AS group_avg
  FROM ml.d14_predictions
  WHERE split = 'test'
)
SELECT ROUND(AVG(ABS(charges - pred_linear_plus))) AS mae,
       ROUND(1 - SUM(POW(charges - pred_linear_plus, 2)) / SUM(POW(charges - group_avg, 2)), 2) AS r2
FROM scored;
```

**What you should see:** MAE about 2,537, R² 0.84. For another model, change both `pred_linear_plus`.

### Telco (lab 07)

Download [`fallback/d14_telco_probabilities.csv`](fallback/d14_telco_probabilities.csv) and upload it as `d14_telco` in `ml`. One row is one customer: `customerID`, `split` (the same groups as `ml.telco_groups`), `Churn`, and each model's probability of leaving: `prob_logistic`, `prob_boosted`, `prob_forest`. The file says Yes or No; Auto detect loads `Churn` as BOOLEAN (TRUE left), as on D12. Accuracy at threshold 0.5, for example:

```sql
SELECT split,
       ROUND(AVG(IF((prob_logistic >= 0.5) = Churn, 1, 0)), 3) AS accuracy_logistic,
       ROUND(AVG(IF((prob_boosted >= 0.5) = Churn, 1, 0)), 3) AS accuracy_boosted,
       ROUND(AVG(IF((prob_forest >= 0.5) = Churn, 1, 0)), 3) AS accuracy_forest
FROM ml.d14_telco
WHERE split = 'validation'
GROUP BY split;
```

**What you should see:** about 0.797, 0.789 and 0.793. After you have chosen (lab 07, step 7), score only the chosen column on `WHERE split = 'test'`: for `prob_logistic`, about 0.788.

### If `ML.FEATURE_IMPORTANCE` shows 0 for `smoker`: check how BigQuery read your columns

`ML.FEATURE_INFO` lists what a model was given, one row per input column, with `min`, `max`, `mean`, `median`, `stddev`, `category_count` and `null_count`:

```sql
SELECT input, min, max, category_count, null_count
FROM ML.FEATURE_INFO(MODEL ml.ins_forest);
```

Google's page says `min` and `max` are NULL "for non-numeric inputs" and `category_count` is NULL "for non-categorical columns"; it does not say how a BOOLEAN column is shown. Read the `smoker` row, then the table's **Schema** tab. If `smoker` is BOOLEAN there, this was seen in a sandbox on 19 October 2026: a random forest trained through the console on an insurance table with `smoker` as BOOLEAN reported 0 importance for `smoker`, while its loss on the rows held aside (about 4,820) was what a forest that uses `smoker` reaches. Google's pages do not explain it. To avoid it, train on text: write `CAST(smoker AS STRING) AS smoker` in place of `smoker` in the model's `SELECT`, and pass the same column to `ML.EVALUATE` and `ML.PREDICT` (`SELECT * REPLACE (CAST(smoker AS STRING) AS smoker) FROM …`). The categories are then `true` and `false`.

## Every option on the two CREATE MODEL pages, and where it is used

| Option | Boosted trees | Random forest | Where |
|---|:---:|:---:|---|
| `MODEL_TYPE` (`…_REGRESSOR`, `…_CLASSIFIER`) | ✓ | ✓ | activities 01, 04; lab 07 |
| `INPUT_LABEL_COLS` | ✓ | ✓ | every activity |
| `DATA_SPLIT_METHOD` (`NO_SPLIT`, `CUSTOM`), `DATA_SPLIT_COL` | ✓ | ✓ | activity 01 (`NO_SPLIT`), lab 09 (`CUSTOM`); `RANDOM`, `SEQ` and the fractions in D11 lab 05 |
| `MAX_ITERATIONS`, `EARLY_STOP`, `MIN_REL_PROGRESS` | ✓ | `EARLY_STOP`, `MIN_REL_PROGRESS` | activity 03, lab 08 steps 1–3 |
| `LEARN_RATE` | ✓ | | activity 03, lab 08 step 3 |
| `MAX_TREE_DEPTH` | ✓ (default 6) | ✓ (default 15) | activities 03, 04; labs 08, 09 |
| `MIN_TREE_CHILD_WEIGHT`, `MIN_SPLIT_LOSS` | ✓ | ✓ | lab 08 step 4 |
| `L1_REG`, `L2_REG` | ✓ | ✓ | activity 03 (`L2_REG = 0`), lab 08 step 5 |
| `SUBSAMPLE`, `COLSAMPLE_BYTREE`, `COLSAMPLE_BYLEVEL`, `COLSAMPLE_BYNODE` | ✓ | ✓ | activity 04, lab 08 step 6, lab 09 step 3 |
| `NUM_PARALLEL_TREE` | ✓ (default 1) | ✓ (default 100) | activity 04, lab 08 step 6, lab 09 step 1 |
| `BOOSTER_TYPE`, `DROPOUT`, `DART_NORMALIZE_TYPE` | ✓ | | lab 08 step 7 |
| `TREE_METHOD` | ✓ | ✓ | lab 08 step 8 |
| `CATEGORY_ENCODING_METHOD` | ✓ | | lab 08 step 8 |
| `AUTO_CLASS_WEIGHTS`, `CLASS_WEIGHTS` | ✓ | ✓ | lab 07 more practice; D12 lab 04 |
| `INSTANCE_WEIGHT_COL` | ✓ | ✓ | named in lab 08 step 9; not used |
| `ENABLE_GLOBAL_EXPLAIN`, `APPROX_GLOBAL_FEATURE_CONTRIB` | ✓ | ✓ | D15 |
| `NUM_TRIALS`, `MAX_PARALLEL_TRIALS`, `HPARAM_TUNING_ALGORITHM`, `HPARAM_TUNING_OBJECTIVES` | ✓ | ✓ | lab 09 steps 4–6 |
| `MODEL_REGISTRY`, `VERTEX_AI_MODEL_ID`, `VERTEX_AI_MODEL_VERSION_ALIASES`, `KMS_KEY_NAME` | | ✓ (`KMS_KEY_NAME` both) | not used in this course |

Functions used today: `ML.EVALUATE`, `ML.PREDICT`, `ML.FEATURE_IMPORTANCE` (trees only), `ML.FEATURE_INFO` and `ML.METRICS` (Preview; this page), `ML.TRAINING_INFO`, `ML.TRIAL_INFO`, `ML.WEIGHTS` (lines), and the preprocessing functions `ML.BUCKETIZE`, `ML.QUANTILE_BUCKETIZE`, `ML.FEATURE_CROSS`, `ML.POLYNOMIAL_EXPAND` (lab 10).

## Links

- [CREATE MODEL for boosted trees](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-boosted-tree) and [for random forests](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-random-forest), Google Cloud (both updated 14 October 2026).
- [ML.FEATURE_IMPORTANCE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-importance), [ML.FEATURE_INFO](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-feature), [ML.METRICS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-metrics) (Preview) and [manual preprocessing functions](https://docs.cloud.google.com/bigquery/docs/manual-preprocessing), Google Cloud.
- [BigQuery ML pricing](https://cloud.google.com/bigquery/pricing#bqml): which models are built-in and which are external.
- Google's Machine Learning Crash Course, [Decision forests](https://developers.google.com/machine-learning/decision-forests), for trees, forests and boosting at the depth of today's class.
- The module's [reference links](../../../resources/bigquery-ml-reference-links.md).
