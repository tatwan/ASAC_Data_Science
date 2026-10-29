# Lab 08 · Boosted trees, option by option

In this self-guided lab, you will change the settings of the boosted-trees model from class one group at a time (how many rounds and how big a step, how big each tree, how much shrinking, how much randomness) and watch the training and validation scores move.

**When:** after class, about 45 minutes, at your own pace. Not submitted. · **Data:** `ml.insurance_groups` and `ml.ins_boosted` (activity 01) · **SQL:** `Solved/boosted_tree_options.sql`

## The story

In class, `ml.ins_boosted` used Google's default settings and scored about 0.83 on validation, with 0.97 on its own training rows: it learned its rows a little too well. Every default is a choice someone made for an average table. This lab shows what each setting does on yours, so that the next time a boosted model overfits, you know which setting to reach for.

## What you will learn

- What `MAX_ITERATIONS`, `LEARN_RATE`, `EARLY_STOP` and `MIN_REL_PROGRESS` do, and how to read `ML.TRAINING_INFO`.
- How `MAX_TREE_DEPTH`, `MIN_TREE_CHILD_WEIGHT` and `MIN_SPLIT_LOSS` limit each tree.
- What `L1_REG` and `L2_REG`, `SUBSAMPLE`, the three `COLSAMPLE_*` options, `NUM_PARALLEL_TREE`, `BOOSTER_TYPE = 'DART'`, `TREE_METHOD` and `CATEGORY_ENCODING_METHOD` change.

## Before you start

You need `ml.insurance_groups` and `ml.ins_boosted` from [activity 01](../01-Evr-Same-Rows-Two-Models/README.md). Each step trains one or two small models on the 803 training people and scores them on the 268 validation people, the same rows as in class.

Work like the other labs: run each query, compare with **What you should see**, and answer **Think** in one line. The values were computed outside BigQuery with BigQuery's settings (XGBoost underneath), not yet run in BigQuery; yours can differ by about 0.01. If tree models will not train in your sandbox, read the steps and the values: the lesson is in the comparison.

Every step scores its models with the same pattern. Here it is once, for the model from class:

```sql
SELECT 'default' AS model,
       ROUND(r2_score, 3) AS validation_r2, ROUND(mean_absolute_error) AS validation_mae
FROM ML.EVALUATE(MODEL ml.ins_boosted, (SELECT * FROM ml.insurance_groups WHERE split = 'validation'));
```

**What you should see:** about 0.832 and 2,630.

## Step 1 · Rounds, and what training recorded

```sql
SELECT iteration, ROUND(loss) AS training_loss, eval_loss, duration_ms
FROM ML.TRAINING_INFO(MODEL ml.ins_boosted)
ORDER BY iteration;
```

Boosting adds one tree per round (an **iteration**). `MAX_ITERATIONS` (default 20) is the most rounds it may take. With `EARLY_STOP = TRUE` (the default), training stops early when a round lowers the loss by less than `MIN_REL_PROGRESS` (default 0.01, that is 1%).

**What you should see:** one row per round, up to 20. The training loss (mean squared error, in dollars squared) falls quickly over the first rounds, then slowly. `eval_loss` is empty: with `NO_SPLIT`, BigQuery kept no rows of its own to check against, so early stopping watched the training loss.

## Step 2 · Many rounds, no stopping

```sql
CREATE OR REPLACE MODEL ml.ins_boost_200
OPTIONS (model_type = 'BOOSTED_TREE_REGRESSOR', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT',
         max_iterations = 200, early_stop = FALSE) AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups WHERE split = 'train';
```

Score it with the pattern above, and on the training rows too (`split = 'train'`).

**What you should see:** training R² 1.00; validation about 0.80 (MAE about 3,060). Computed round by round outside BigQuery, the validation score peaks near round 10 (about 0.84) and then slowly falls, while the training score keeps rising: boosting overfits if you let it run.

**Think:** which default protected the class model from this?

## Step 3 · A smaller step

```sql
CREATE OR REPLACE MODEL ml.ins_boost_slow
OPTIONS (model_type = 'BOOSTED_TREE_REGRESSOR', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT',
         learn_rate = 0.1, max_iterations = 100) AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups WHERE split = 'train';

CREATE OR REPLACE MODEL ml.ins_boost_fast
OPTIONS (model_type = 'BOOSTED_TREE_REGRESSOR', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT',
         learn_rate = 1.0) AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups WHERE split = 'train';
```

`LEARN_RATE` (default 0.3) is the share of each tree's correction the model keeps. A smaller share needs more rounds; it usually generalises better.

**What you should see:**

| Model | Rounds kept | Training R² | Validation R² | Validation MAE |
|---|---:|---:|---:|---:|
| `learn_rate = 0.1`, up to 100 rounds | about 50 (early stop) | ≈ 0.96 | ≈ 0.84 | ≈ 2,480 |
| default, 0.3 | 20 | ≈ 0.97 | ≈ 0.83 | ≈ 2,630 |
| `learn_rate = 1.0` | 20 | ≈ 1.00 | ≈ 0.79 | ≈ 3,420 |

Check the rounds kept with `SELECT COUNT(*) AS rounds FROM ML.TRAINING_INFO(MODEL ml.ins_boost_slow);`.

The smaller step alone gains little here, because each tree is still six questions deep. Add `max_tree_depth = 3` to the same statement (try it): about 33 rounds, training about 0.89, validation about 0.85 (MAE about 2,410). Small steps help most with small trees.

## Step 4 · Smaller trees

```sql
CREATE OR REPLACE MODEL ml.ins_boost_d2
OPTIONS (model_type = 'BOOSTED_TREE_REGRESSOR', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT',
         max_tree_depth = 2) AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups WHERE split = 'train';

CREATE OR REPLACE MODEL ml.ins_boost_child20
OPTIONS (model_type = 'BOOSTED_TREE_REGRESSOR', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT',
         min_tree_child_weight = 20) AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups WHERE split = 'train';
```

Three settings limit each tree:

| Option | Default | Stops a tree from … |
|---|---:|---|
| `MAX_TREE_DEPTH` | 6 | asking more than this many questions on a path |
| `MIN_TREE_CHILD_WEIGHT` | 1 | making a leaf with fewer than this many training rows (for a regression, the weight of a row is 1) |
| `MIN_SPLIT_LOSS` | 0 | asking a question that lowers the loss by less than this amount |

**What you should see:** depth 2: validation about 0.85, training about 0.88. At least 20 people per leaf: validation about 0.85, training about 0.92. Depth 10 (try it): validation about 0.82, training about 1.00. Smaller trees overfit less here.

**Think:** the gap between training and validation is the overfitting. Which of the three models has the smallest gap?

## Step 5 · Shrinking: L1 and L2

```sql
CREATE OR REPLACE MODEL ml.ins_boost_l2_10
OPTIONS (model_type = 'BOOSTED_TREE_REGRESSOR', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT',
         l2_reg = 10) AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups WHERE split = 'train';
```

As on D11 for lines, `L2_REG` (default 1.0) and `L1_REG` (default 0) shrink the model. In a tree they shrink each leaf's value towards zero, more strongly for leaves with few rows, so a leaf of one odd person cannot swing the prediction far.

**What you should see:** `l2_reg = 10`: validation about 0.85, training about 0.93. `l2_reg = 0` (try it): validation about 0.82, training about 0.99.

## Step 6 · Randomness: rows, columns and parallel trees

```sql
CREATE OR REPLACE MODEL ml.ins_boost_random
OPTIONS (model_type = 'BOOSTED_TREE_REGRESSOR', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT',
         num_parallel_tree = 4, subsample = 0.8, colsample_bynode = 0.8) AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups WHERE split = 'train';
```

| Option | Default | What it draws at random |
|---|---:|---|
| `SUBSAMPLE` | 1.0 | the share of training rows each round sees |
| `COLSAMPLE_BYTREE` | 1.0 | the share of columns each tree may use |
| `COLSAMPLE_BYLEVEL` | 1.0 | … each new depth of a tree, from the tree's columns |
| `COLSAMPLE_BYNODE` | 1.0 | … each question, from the level's columns |
| `NUM_PARALLEL_TREE` | 1 | trees grown side by side in each round and averaged: above 1 makes a "boosted random forest" |

**What you should see:** about 0.84 on validation. `subsample = 0.5` on its own: about 0.83. With six columns, sampling columns has little room to help; on wide tables it matters more.

## Step 7 · DART: dropping trees

```sql
CREATE OR REPLACE MODEL ml.ins_boost_dart
OPTIONS (model_type = 'BOOSTED_TREE_REGRESSOR', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT',
         booster_type = 'DART', dropout = 0.1) AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups WHERE split = 'train';
```

`BOOSTER_TYPE` is `'GBTREE'` by default. `'DART'` drops a random share of the earlier trees (`DROPOUT`, default 0) while it builds each new one, so no early tree dominates. `DART_NORMALIZE_TYPE` (`'TREE'` or `'FOREST'`) sets how the new tree is weighted against the dropped ones.

**What you should see:** about 0.84. DART is slower and rarely needed on small tables.

## Step 8 · How the trees are built, and how text becomes numbers

```sql
CREATE OR REPLACE MODEL ml.ins_boost_onehot
OPTIONS (model_type = 'BOOSTED_TREE_REGRESSOR', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT',
         category_encoding_method = 'ONE_HOT_ENCODING', tree_method = 'EXACT') AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups WHERE split = 'train';
```

- `TREE_METHOD`: `'AUTO'` (the default; Google's page says `'HIST'` is the same) groups each column's values into bins before looking for questions, which is fast on big tables; `'EXACT'` tries every value; `'APPROX'` sits between. On 803 rows they give almost the same model.
- `CATEGORY_ENCODING_METHOD`: how text columns become numbers. The default for boosted trees is `'LABEL_ENCODING'` (one whole number per value); `'ONE_HOT_ENCODING'` makes a 0-or-1 column per value, as for lines (D11); `'TARGET_ENCODING'` replaces each value with the average label for that value in the training rows.

**What you should see:** about 0.83, the same as the default. With two-valued columns (`sex`, `smoker`) and a four-valued `region` that matters little, the encoding changes almost nothing here.

## Step 9 · The rest of the page

| Option | Where you meet it |
|---|---|
| `INPUT_LABEL_COLS`, `DATA_SPLIT_METHOD`, `DATA_SPLIT_EVAL_FRACTION`, `DATA_SPLIT_TEST_FRACTION`, `DATA_SPLIT_COL` | D11 lab 05 and today's activity 01 (`NO_SPLIT` on our own groups) |
| `AUTO_CLASS_WEIGHTS`, `CLASS_WEIGHTS` | classifiers only: D12 lab 04, and lab 07's more practice |
| `INSTANCE_WEIGHT_COL` | a column of row weights, for when some rows should count more; not used in this course |
| `ENABLE_GLOBAL_EXPLAIN`, `APPROX_GLOBAL_FEATURE_CONTRIB` | D15, explaining a model |
| `NUM_TRIALS`, `MAX_PARALLEL_TRIALS`, `HPARAM_TUNING_ALGORITHM`, `HPARAM_TUNING_OBJECTIVES` | lab 09: letting BigQuery try settings for you |
| `KMS_KEY_NAME` | encryption with your own key; not used in this course |

## What you saw

| Setting | Training R² | Validation R² | Overfitting more or less than the default? |
|---|---:|---:|---|
| default | | | |
| 200 rounds, no early stop | | | |
| `learn_rate = 0.1` | | | |
| `max_tree_depth = 2` | | | |
| `l2_reg = 10` | | | |

**Think:** smaller trees, at least 20 people per leaf, and more shrinking each gave about 0.85 on validation. What do they have in common?

## References

BigQuery ML: [CREATE MODEL for boosted trees](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-boosted-tree) (every option and its default; page updated 14 October 2026), [ML.TRAINING_INFO](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-train), [automatic preprocessing](https://docs.cloud.google.com/bigquery/docs/auto-preprocessing), Google Cloud. XGBoost's [parameter guide](https://xgboost.readthedocs.io/en/stable/parameter.html). Data as in activity 01.
