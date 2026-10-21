# BigQuery ML functions in Module 3

Every `ML.` function you meet in D11 to D15, in class or in the after-class labs, on one page. A model is something you query: you train it with `CREATE MODEL`, then each function below reads something out of it (predictions, scores, weights, explanations) or prepares the features it trains on. Use the table to find what a function is for and where you ran it; each name links to Google's page for that function, with every argument and output column. "Activity" means in class; "lab" means after class. Each day's deck has the same list for that day on its "BigQuery ML functions today" slide, just before the close.

## Predict and score

| Function | What it is for | Days and where | Notes |
|---|---|---|---|
| [`ML.PREDICT`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-predict) | A prediction for each row you pass in: a number, a class with its probabilities, or a k-means group with its distances | D11: activities 02, 03; lab 08 · D12: activities 01, 02; labs 03, 05 · D13: activities 01, 03, 04; labs 05, 07–09 · D14: activities 01, 03; lab 11 · D15: activity 08 | Columns the model does not use are passed through to the output, so you can keep an ID or a `split` column beside the prediction |
| [`ML.EVALUATE`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate) | The scores on the rows you pass: MAE and R² for a number; accuracy, precision, recall, F1, log loss and ROC AUC for a class; the Davies–Bouldin index and mean squared distance for k-means; MAE and other errors for a forecast | D11: activities 02–04; labs 05–08 · D12: activities 01, 02; labs 03, 04, 05, 06 · D13: activity 04; labs 05, 06 · D14: activities 01, 03–06; labs 07–11 · D15: labs 10, 12 | For an `ARIMA_PLUS` model, pass the actual values to compare with; without them, Google points you to `ML.ARIMA_EVALUATE` |
| [`ML.CONFUSION_MATRIX`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-confusion) | The counts of right and wrong answers, by class | D12: activity 02; lab 05 | Classifiers. A threshold works only with a table or query to score |
| [`ML.ROC_CURVE`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-roc) | Recall, false positive rate and the four counts at each threshold | D12: activity 02; labs 03, 04 | Precision is one division of its counts: `true_positives / (true_positives + false_positives)` |
| [`ML.METRICS`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-metrics) | Regression or classification scores from any table or query of actual and predicted values, with no model | D14: Resources · D15: lab 10 | **Preview** (Google's Pre-GA terms). Rows with a NULL are left out. BOOL labels are scored for the TRUE class; STRING labels as a macro-average over all classes |

## Inspect the model

| Function | What it is for | Days and where | Notes |
|---|---|---|---|
| [`ML.WEIGHTS`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-weights) | The numbers the model learned, feature by feature (one per category for a text column) | D11: activities 02, 03; labs 06, 07 · D12: activities 01, 02 · D14: activity 05 | Linear and logistic regression; for trees, use `ML.FEATURE_IMPORTANCE` |
| [`ML.ADVANCED_WEIGHTS`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-advanced-weights) | The weights with their standard errors and p-values | D11: lab 06 (bonus) | Linear and logistic regression |
| [`ML.FEATURE_INFO`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-feature) | What the model was given: for each input column, its min, max, mean, median, standard deviation, number of categories and number of NULLs | D14: activity 04, Resources · D15: lab 12 | With `TRANSFORM`, it describes the columns before the transform |
| [`ML.TRAINING_INFO`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-train) | One row per training step (iteration): the loss on the training rows, the loss on the rows held aside, and how long the step took | D11: lab 07 · D13: lab 06 · D14: lab 08 | For k-means, also each group's size and radius. The held-out loss is empty when no rows were held aside (`NO_SPLIT`) |

## Explain

| Function | What it is for | Days and where | Notes |
|---|---|---|---|
| [`ML.EXPLAIN_PREDICT`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-explain-predict) | Each prediction with the features that pushed it up or down from a baseline | D15: activity 07; lab 11 | `ML.PREDICT` with explanations added. `top_k_features` (default 5) sets how many features come back per row. For linear models and trees the attributions are exact |
| [`ML.GLOBAL_EXPLAIN`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-global-explain) | How much each feature drives the predictions over the whole model: the average size of its pushes | D15: activity 07; lab 11 | Needs `ENABLE_GLOBAL_EXPLAIN = TRUE` in `CREATE MODEL`; the explanation is computed when the model is trained |
| [`ML.FEATURE_IMPORTANCE`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-importance) | How often, and how usefully, each feature was used to split the data | D14: activity 04; lab 07 · D15: activity 07; lab 11 | Boosted trees and random forests only |

## Time series

| Function | What it is for | Days and where | Notes |
|---|---|---|---|
| [`ML.FORECAST`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-forecast) | The next periods of a series, each with a lower and upper bound | D15: activities 02, 04–06, 08; labs 09, 10, 13 | `horizon` defaults to 3 periods and `confidence_level` to 0.95 |
| [`ML.EXPLAIN_FORECAST`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-explain-forecast) | Every period, past and forecast, split into its parts: trend, season, holiday effect, spikes and dips, step changes and what is left | D15: activity 04; labs 09, 10, 13 | Needs `DECOMPOSE_TIME_SERIES` left at TRUE when the model is trained |
| [`ML.ARIMA_EVALUATE`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-arima-evaluate) | The ARIMA order the model chose (p, d, q and drift), with its fit statistics (AIC) and the seasons it found | D15: labs 09, 10, 13 | Needs no input data |
| [`ML.ARIMA_COEFFICIENTS`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-arima-coefficients) | The coefficients of the chosen ARIMA: AR, MA, and the intercept or drift | D15: lab 10 | |
| [`ML.DETECT_ANOMALIES`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-detect-anomalies) | Which rows are unusual: for `ARIMA_PLUS`, values outside the expected range; for k-means, rows far from their nearest centre | D13: lab 08 · D15: lab 10 | **Billed even in a sandbox**: "All queries that use the ML.DETECT_ANOMALIES function are billable, regardless of the pricing model." `anomaly_prob_threshold` (time series) and `contamination` (k-means) set how many rows are flagged |

## Clustering

| Function | What it is for | Days and where | Notes |
|---|---|---|---|
| [`ML.CENTROIDS`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-centroids) | The centre of each k-means group, feature by feature | D13: activity 01 | Returned in the original units unless you ask for them standardized (`STANDARDIZE`, default FALSE) |

`ML.PREDICT`, `ML.EVALUATE`, `ML.TRAINING_INFO` and `ML.DETECT_ANOMALIES` also work on k-means models; see the tables above.

## Preprocessing inside TRANSFORM

A `TRANSFORM` clause in `CREATE MODEL` keeps the preprocessing inside the model. Functions that look at every row (they take an empty `OVER ()`) compute their statistics from the training rows, and BigQuery reuses those statistics, unchanged, at every prediction.

| Function | What it is for | Days and where | Notes |
|---|---|---|---|
| [`ML.QUANTILE_BUCKETIZE`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-quantile-bucketize) | A number cut into quantile bands of about equal size | D14: lab 10 · D15: activity 08; lab 12 | Needs `OVER ()`. Inside `TRANSFORM`, the training quantiles are reused at prediction |
| [`ML.BUCKETIZE`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-bucketize) | A number cut into bands at split points you choose | D14: lab 10 · D15: lab 12 | No `OVER ()` |
| [`ML.FEATURE_CROSS`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-feature-cross) | Categorical features combined into new features, two at a time by default | D14: lab 10 · D15: lab 12 | `degree` from 2 to 4, default 2; the original features are not repeated |
| [`ML.POLYNOMIAL_EXPAND`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-polynomial-expand) | Numeric features plus their squares and products | D14: lab 10 · D15: lab 12 | `degree` from 1 to 4, default 2; the original features are included |
| [`ML.STANDARD_SCALER`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-standard-scaler) | A number as a z-score: minus the mean, divided by the standard deviation | D15: lab 12 | Needs `OVER ()`; the training mean and standard deviation are reused at prediction |
| [`ML.MIN_MAX_SCALER`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-min-max-scaler) | A number scaled to the range 0 to 1 | D15: lab 12 | Needs `OVER ()`; at prediction, values outside the training range are capped at 0 and 1 |
| [`ML.MAX_ABS_SCALER`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-max-abs-scaler) | A number divided by its largest absolute value, so it falls between −1 and 1 | D15: lab 12 | Needs `OVER ()`; does not shift or centre the data |
| [`ML.ROBUST_SCALER`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-robust-scaler) | A number minus its median, divided by its quantile range | D15: lab 12 (described, not run) | Needs `OVER ()`; `quantile_range` defaults to [25, 75] |
| [`ML.TRANSFORM`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-transform) | The features a model's `TRANSFORM` clause makes from the rows you pass, with the training statistics applied | D15: lab 12 | Returns an error for a model trained without `TRANSFORM` |

D15 lab 12 also lists the other preprocessing functions on Google's [manual preprocessing page](https://docs.cloud.google.com/bigquery/docs/manual-preprocessing) without running them: `ML.IMPUTER`, `ML.NORMALIZER`, `ML.HASH_BUCKETIZE`, `ML.LABEL_ENCODER`, `ML.MULTI_HOT_ENCODER`, `ML.ONE_HOT_ENCODER`, `ML.NGRAMS`, `ML.BAG_OF_WORDS` and `ML.TF_IDF`.

## Tuning

| Function | What it is for | Days and where | Notes |
|---|---|---|---|
| [`ML.TRIAL_INFO`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-trial-info) | One row per hyperparameter-tuning trial, with its settings and its score | D14: lab 09 | For a model trained with tuning (`NUM_TRIALS`); see Google's [hyperparameter tuning overview](https://docs.cloud.google.com/bigquery/docs/hp-tuning-overview) |

## Analysis

| Function | What it is for | Days and where | Notes |
|---|---|---|---|
| [`ML.GET_INSIGHTS`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-get-insights) | The segments that explain a change between two periods (for example, revenue this year against last), each with its change, its unexpected change and its share of the data | D15: lab 14 (optional) | Reads a model with `MODEL_TYPE = 'CONTRIBUTION_ANALYSIS'`: a model type, not a function. Rows come sorted by contribution, largest first. Google's pages do not say whether contribution analysis trains in a sandbox |

More on each model type, and Google's own courses and tutorials: [bigquery-ml-reference-links.md](bigquery-ml-reference-links.md).
