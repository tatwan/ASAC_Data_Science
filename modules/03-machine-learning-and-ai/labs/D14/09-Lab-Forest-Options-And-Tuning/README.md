# Lab 09 · Random forests, option by option, then letting BigQuery tune

In this self-guided lab, you will change the number of trees, their depth and the two random draws of the forest from class, and then ask BigQuery to try ten combinations of boosted-tree settings for you, scored on our own validation people.

**When:** after class, about 40 minutes, at your own pace. Not submitted. · **Data:** `ml.insurance_groups` (activity 01) and `ml.ins_forest` (activity 04) · **SQL:** `Solved/forest_options_and_tuning.sql`

## The story

The forest in class used Google's four defaults (100 trees, depth 15, 80% of the rows, 80% of the columns at each question) and scored about 0.84 on validation. Lab 08 changed boosted-tree settings by hand, one at a time. With many settings, trying combinations by hand gets slow. BigQuery can do it for you, if you tell it which settings to try, how many models to train, and which rows to judge them on.

## What you will learn

- What `NUM_PARALLEL_TREE`, `MAX_TREE_DEPTH`, `SUBSAMPLE` and `COLSAMPLE_BYNODE` do in a forest.
- Why adding trees makes a forest steadier and does not add overfitting.
- How hyperparameter tuning works: `NUM_TRIALS`, `HPARAM_RANGE`, `HPARAM_CANDIDATES`, `HPARAM_TUNING_OBJECTIVES`, a `CUSTOM` split and `ML.TRIAL_INFO`.

## Before you start

You need `ml.insurance_groups` and `ml.ins_forest` from activities [01](../01-Evr-Same-Rows-Two-Models/README.md) and [04](../04-Evr-Forest-And-Boosted/README.md). Score every model in steps 1 to 3 on the validation rows with the pattern from lab 08:

```sql
SELECT ROUND(r2_score, 3) AS validation_r2, ROUND(mean_absolute_error) AS validation_mae
FROM ML.EVALUATE(MODEL ml.ins_forest, (SELECT * FROM ml.insurance_groups WHERE split = 'validation'));
```

The values below were computed outside BigQuery with BigQuery's settings, not yet run in BigQuery. A forest is random: your numbers can differ by about 0.01, and differ again if you train the same model twice.

## Step 1 · How many trees

```sql
CREATE OR REPLACE MODEL ml.ins_forest_2
OPTIONS (model_type = 'RANDOM_FOREST_REGRESSOR', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT',
         num_parallel_tree = 2) AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups WHERE split = 'train';

CREATE OR REPLACE MODEL ml.ins_forest_300
OPTIONS (model_type = 'RANDOM_FOREST_REGRESSOR', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT',
         num_parallel_tree = 300) AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups WHERE split = 'train';
```

`NUM_PARALLEL_TREE` (default 100, at least 2 for a forest) is the number of trees averaged.

**What you should see:**

| Trees | Validation R², five runs |
|---:|---|
| 2 | between about 0.82 and 0.84 |
| 10 (try it: `num_parallel_tree = 10`) | between about 0.83 and 0.84 |
| 100 (class) | about 0.84 |
| 300 | about 0.84 |

**Think:** more trees did not raise the score much, but they made it steadier from run to run. Each tree is grown the same way whatever their number. Why does averaging more of them not add overfitting?

## Step 2 · How deep

```sql
CREATE OR REPLACE MODEL ml.ins_forest_d6
OPTIONS (model_type = 'RANDOM_FOREST_REGRESSOR', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT',
         max_tree_depth = 6) AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups WHERE split = 'train';
```

**What you should see:** depth 6 about 0.84 on validation (training about 0.88); depth 3 (try it: `max_tree_depth = 3`) about 0.83 to 0.84 (training about 0.86); depth 15, the default, about 0.84 (training about 0.89). Unlike the single tree in activity 03, the forest barely suffers from deep trees: the averaging absorbs it.

## Step 3 · The two random draws

```sql
CREATE OR REPLACE MODEL ml.ins_forest_cols50
OPTIONS (model_type = 'RANDOM_FOREST_REGRESSOR', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT',
         colsample_bynode = 0.5) AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups WHERE split = 'train';
```

| Option | Default | Draws |
|---|---:|---|
| `SUBSAMPLE` | 0.8 | the share of training rows each tree learns from (must be below 1.0 for a forest) |
| `COLSAMPLE_BYNODE` | 0.8 | the share of columns each question may choose from |

**What you should see:** `colsample_bynode = 0.5`: about 0.82. With only six columns, half of them often leaves out `smoker`, the column that matters most, at the top of a tree. Try two more by changing the option in the same statement: `subsample = 0.5`: about 0.84; `colsample_bynode = 1.0`: about 0.83 to 0.84, with the trees then differing only through their rows. BigQuery draws a forest's rows without replacement: each tree sees 80% of the training people, each at most once. The idea is the bootstrap's: every tree learns from different rows.

The forest also accepts `MIN_TREE_CHILD_WEIGHT`, `MIN_SPLIT_LOSS`, `L1_REG`, `L2_REG`, `COLSAMPLE_BYTREE`, `COLSAMPLE_BYLEVEL` and `TREE_METHOD`, with the meanings from lab 08.

## Step 4 · Tell BigQuery which rows are which

Tuning trains many models and needs rows to judge them on. Left to itself, BigQuery would split the rows at random, 80% to train each trial, 10% to judge it and 10% held back. Give it our groups instead, so the trials are judged on the same validation people as everything else today. With tuning, a `CUSTOM` split needs a text column whose values are `TRAIN`, `EVAL` and `TEST`:

```sql
CREATE OR REPLACE VIEW ml.insurance_tuning AS
SELECT * EXCEPT (split),
       CASE split WHEN 'train' THEN 'TRAIN' WHEN 'validation' THEN 'EVAL' ELSE 'TEST' END AS tuning_group
FROM ml.insurance_groups;

SELECT tuning_group, COUNT(*) AS people
FROM ml.insurance_tuning
GROUP BY tuning_group;
```

**What you should see:** TRAIN 803, EVAL 268, TEST 267: the same people as in class.

## Step 5 · Ten trials

```sql
CREATE OR REPLACE MODEL ml.ins_boost_tuned
OPTIONS (
  model_type = 'BOOSTED_TREE_REGRESSOR',
  input_label_cols = ['charges'],
  data_split_method = 'CUSTOM',
  data_split_col = 'tuning_group',
  num_trials = 10,
  max_parallel_trials = 2,
  learn_rate = HPARAM_RANGE(0.05, 0.5),
  max_tree_depth = HPARAM_CANDIDATES([2, 3, 4, 6]),
  hparam_tuning_objectives = ['R2_SCORE']
) AS
SELECT age, sex, bmi, children, smoker, region, charges, tuning_group
FROM ml.insurance_tuning;
```

- `num_trials = 10`: train up to ten models. Without it there is no tuning. Google suggests at least ten trials per setting tuned; ten here keeps the lab short.
- `learn_rate = HPARAM_RANGE(0.05, 0.5)`: any value in the range. `max_tree_depth = HPARAM_CANDIDATES([2, 3, 4, 6])`: one of the listed values.
- `max_parallel_trials = 2`: two at a time. With the default search method (`'VIZIER_DEFAULT'`), trials run side by side learn less from each other.
- `hparam_tuning_objectives = ['R2_SCORE']`: the score to maximise, on the `EVAL` rows. It is also the default for a regressor; a classifier's default is `'ROC_AUC'`.
- `data_split_col = 'tuning_group'` is used only to split the rows; it is never a feature.

## Step 6 · Read the trials

```sql
SELECT trial_id,
       ROUND(hyperparameters.learn_rate, 3) AS learn_rate,
       hyperparameters.max_tree_depth AS max_tree_depth,
       ROUND(hparam_tuning_evaluation_metrics.r2_score, 3) AS eval_r2,
       status, is_optimal
FROM ML.TRIAL_INFO(MODEL ml.ins_boost_tuned)
ORDER BY eval_r2 DESC;
```

**What you should see:** ten rows. The best trials score about 0.85 on the `EVAL` rows (ten random trials of the same ranges, computed outside BigQuery, gave a best of 0.85 every time), usually with shallow trees; `is_optimal` marks the one BigQuery keeps. That is about what lab 08's hand-picked settings reached.

**Careful:** `ML.EVALUATE` on a tuned model with no table scores the `TEST` rows. Leave it for now: the test group is for one final score, after you have chosen.

**Think:** the best trial beat the class default by about 0.02 on 268 people. Activity 06 showed how much one group of that size can move a score. Is the tuned model clearly better?

## What you saw

| Model | Validation R² | Steadier or less steady than the class forest? |
|---|---:|---|
| 2 trees | | |
| 300 trees | | |
| depth 6 | | |
| `colsample_bynode = 0.5` | | |
| best tuning trial | | |

## References

BigQuery ML: [CREATE MODEL for random forests](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-random-forest), [CREATE MODEL for boosted trees](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-boosted-tree) (tuning options and the `CUSTOM` split; pages updated 14 October 2026), [ML.TRIAL_INFO](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-trial-info), [hyperparameter tuning overview](https://docs.cloud.google.com/bigquery/docs/hp-tuning-overview), Google Cloud. Data as in activity 01.
