# Machine learning and BigQuery ML: reference links

Official pages to read alongside Module 3. Start with **Start here**; then use the tables when a day or a lab sends you to an option or a function. Every link is to Google's own documentation or course, except the Kaggle courses at the end.

## Start here

| Read | Why |
|---|---|
| [Introduction to ML in BigQuery](https://docs.cloud.google.com/bigquery/docs/bqml-introduction) | What BigQuery ML is, which models it offers, and where to begin |
| [End to end: every step of a BigQuery ML model](https://docs.cloud.google.com/bigquery/docs/e2e-journey) | Every step of a model's life (create, preprocess, tune, evaluate, explain, predict) and the SQL for each, by model type |
| [Google's Machine Learning Crash Course](https://developers.google.com/machine-learning/crash-course) | Free, short modules on the ideas behind the models, with interactive exercises |
| [Get started with BigQuery ML using SQL](https://docs.cloud.google.com/bigquery/docs/create-machine-learning-model) | A first model, step by step, outside class |
| [The BigQuery sandbox](https://docs.cloud.google.com/bigquery/docs/sandbox) | What the free sandbox allows, and its limits (tables and models expire after 60 days) |

## The ideas: Machine Learning Crash Course, by day

| Day | Crash Course module | What it adds to class |
|---|---|---|
| D11 | [Linear regression](https://developers.google.com/machine-learning/crash-course/linear-regression) | Loss, gradient descent, learning rate and other hyperparameters, with interactive charts |
| D11 | [Working with categorical data](https://developers.google.com/machine-learning/crash-course/categorical-data) | One-hot encoding and why text must become numbers |
| D11 | [Working with numerical data](https://developers.google.com/machine-learning/crash-course/numerical-data) | Scaling (standardizing) features, outliers |
| D11 | [Datasets, generalization, and overfitting](https://developers.google.com/machine-learning/crash-course/overfitting) | Training, validation and test sets; overfitting; regularization |
| D12 | [Logistic regression](https://developers.google.com/machine-learning/crash-course/logistic-regression) | The sigmoid, probabilities, log loss |
| D12 | [Classification](https://developers.google.com/machine-learning/crash-course/classification) | Thresholds, the confusion matrix, accuracy, precision, recall, ROC and AUC |
| D12 | [ML fairness](https://developers.google.com/machine-learning/crash-course/fairness) | Which features should be in a model at all |
| D13 | [Clustering](https://developers.google.com/machine-learning/clustering) (an advanced course beside the Crash Course) | Similarity measures, k-means, judging a clustering, with exercises |
| D15 | [Production ML systems](https://developers.google.com/machine-learning/crash-course/production-ml-systems) | What happens to a model after it is trained |
| D24 | [Intro to large language models](https://developers.google.com/machine-learning/crash-course/llm) | How the models behind generative AI are built |

## How BigQuery ML prepares, tunes, evaluates and explains

| Page | Use it for |
|---|---|
| [Automatic feature preprocessing](https://docs.cloud.google.com/bigquery/docs/auto-preprocessing) | What BigQuery does to your columns before training: one-hot encoding of text, standardizing numbers, filling missing values |
| [Feature preprocessing overview](https://docs.cloud.google.com/bigquery/docs/preprocess-overview) | Doing your own preprocessing, including the `TRANSFORM` clause |
| [Model evaluation overview](https://docs.cloud.google.com/bigquery/docs/evaluate-overview) | Which rows each model is scored on, and the metrics for each model type |
| [Hyperparameter tuning overview](https://docs.cloud.google.com/bigquery/docs/hp-tuning-overview) | Letting BigQuery try settings for you (`NUM_TRIALS`, `HPARAM_RANGE`); D14 lab 09 |
| [Explainable AI overview](https://docs.cloud.google.com/bigquery/docs/xai-overview) | Which features drive a model's predictions (`ENABLE_GLOBAL_EXPLAIN`) |
| [Model selection guide (PDF)](https://docs.cloud.google.com/static/bigquery/images/ml-model-cheatsheet.pdf) | Which model type fits which question |
| [BigQuery ML pricing](https://cloud.google.com/bigquery/pricing#bqml) | What training costs. Linear and logistic regression, k-means and time series train inside BigQuery; boosted trees, random forest, neural networks and AutoML are trained on Vertex AI and billed separately |

## CREATE MODEL, by model type

Each page lists every option for that model type, with its default. The labs change them one at a time.

| Day | Model | Reference |
|---|---|---|
| D11, D12 | Linear and logistic regression (`LINEAR_REG`, `LOGISTIC_REG`) | [CREATE MODEL for generalized linear models](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm) |
| D13 | K-means clustering (`KMEANS`) | [CREATE MODEL for k-means](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-kmeans) |
| D14 | Boosted trees | [CREATE MODEL for boosted trees](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-boosted-tree) |
| D14 | Random forest | [CREATE MODEL for random forest](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-random-forest) |
| D15 | Time series (`ARIMA_PLUS`) | [CREATE MODEL for time series](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-time-series) |
| D15 lab 14 (optional) | Contribution analysis (`CONTRIBUTION_ANALYSIS`): which segments explain a change between two periods | [CREATE MODEL for contribution analysis](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-contribution-analysis) |
| D12 (named), recognition only | Deep neural networks, wide & deep, AutoML | [DNN](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-dnn-models) · [Wide & deep](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-wnd-models) · [AutoML](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-automl) |
| D12 (named), recognition only | Classifying free text with Gemini, no training (`AI.CLASSIFY`; needs a billed project) | [The AI.CLASSIFY function](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-ai-classify) |
| All | Every model type and option on one page | [The CREATE MODEL statement](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create) |

## The ML functions used in class and in the labs

| Function | What it returns | First used |
|---|---|---|
| [`ML.PREDICT`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-predict) | a prediction (and, for classifiers, probabilities) for each row you pass in | D11 |
| [`ML.EVALUATE`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate) | the scores: MAE and R², or accuracy, precision, recall, F1, log loss and ROC AUC; for k-means, the Davies–Bouldin index and mean squared distance | D11 |
| [`ML.WEIGHTS`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-weights) | the numbers the model learned | D11 |
| [`ML.ADVANCED_WEIGHTS`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-advanced-weights) | weights with standard errors and p-values | D11 lab 06 |
| [`ML.FEATURE_INFO`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-feature) | what the model was given: per input column, min, max, mean, median, standard deviation, number of categories and of NULLs (with `TRANSFORM`, the columns before it) | D11 lab 06; D14 activity 04; D15 lab 12 |
| [`ML.TRAINING_INFO`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-train) | the loss at each training step (for k-means, also each group's size and radius) | D11 labs 05, 07; D13 lab 06 |
| [`ML.GLOBAL_EXPLAIN`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-global-explain) | how much each feature drives the predictions, over the whole model (needs `ENABLE_GLOBAL_EXPLAIN = TRUE` when the model is created) | D11 lab 06; D15 |
| [`ML.CONFUSION_MATRIX`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-confusion) | the counts of right and wrong answers by class | D12 |
| [`ML.ROC_CURVE`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-roc) | recall, false positive rate and the four counts at each threshold; precision and PR AUC are computed from them (D12 lab 03) | D12 |
| [`ML.METRICS`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-metrics) (Preview) | regression or classification scores from any table of actual and predicted values, with no model | D12 lab 03; D14 Resources; D15 lab 10 |
| [`ML.CENTROIDS`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-centroids) | the centre of each k-means group, feature by feature | D13 |
| [`ML.TRIAL_INFO`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-trial-info) | one row per hyperparameter-tuning trial, with its settings and score | D14 lab 09 |
| [`ML.DETECT_ANOMALIES`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-detect-anomalies) | which rows are unusual; for k-means, by distance to the nearest centre; for `ARIMA_PLUS`, months outside the expected range. Billed even in the sandbox | D13 lab 08; D15 lab 10 |
| [`ML.FORECAST`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-forecast) | the next months of a time series, each with a lower and upper bound | D15 |
| [`ML.EXPLAIN_FORECAST`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-explain-forecast) | the parts of a forecast: trend, season, holidays, spikes and dips | D15 |
| [`ML.ARIMA_EVALUATE`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-arima-evaluate) | the ARIMA order the model chose, with its fit statistics and the seasons it found | D15 lab 10 |
| [`ML.ARIMA_COEFFICIENTS`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-arima-coefficients) | the coefficients of the chosen ARIMA | D15 lab 10 |
| [`ML.EXPLAIN_PREDICT`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-explain-predict) | each prediction with the features that pushed it up or down | D15 |
| [`ML.FEATURE_IMPORTANCE`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-importance) | for tree models, how often and how usefully each feature was used | D14; D15 lab 11 |
| [`ML.QUANTILE_BUCKETIZE`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-quantile-bucketize) | a number turned into equal-sized bands; inside `TRANSFORM`, the cut points come from the training rows | D14 lab 10; D15 |
| [`ML.BUCKETIZE`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-bucketize) | a number turned into bands at cut points you choose | D15 lab 12 |
| [`ML.GET_INSIGHTS`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-get-insights) | a contribution analysis model's segments, each with its change, unexpected change and size | D15 lab 14 |

## Tutorials to try on your own

| Tutorial | Model |
|---|---|
| [Predict penguin weight](https://docs.cloud.google.com/bigquery/docs/linear-regression-tutorial) | Linear regression on a public table |
| [Classification with logistic regression](https://docs.cloud.google.com/bigquery/docs/logistic-regression-prediction) | Logistic regression on census data |
| [Cluster London bicycle hire stations](https://docs.cloud.google.com/bigquery/docs/kmeans-tutorial) | K-means |
| [Forecast a single time series](https://docs.cloud.google.com/bigquery/docs/arima-single-time-series-forecasting-tutorial) | `ARIMA_PLUS` |

## More practice outside BigQuery

Kaggle Learn's free, short courses, recommended on Google's introduction page: [Intro to Machine Learning](https://www.kaggle.com/learn/intro-to-machine-learning) · [Data Cleaning](https://www.kaggle.com/learn/data-cleaning) · [Feature Engineering](https://www.kaggle.com/learn/feature-engineering) · [Intermediate Machine Learning](https://www.kaggle.com/learn/intermediate-machine-learning). They use Python, not SQL; the ideas are the same.

## The datasets used in Module 3

Sources and licences: [`shared/datasets/ml_classics`](../../../shared/datasets/ml_classics/README.md).

Links checked 18 October 2026.
