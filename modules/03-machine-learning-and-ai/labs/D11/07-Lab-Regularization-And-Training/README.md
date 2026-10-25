# Lab 07 · Ridge, Lasso and Elastic Net, and how training runs

In this self-guided lab, you will train the same car model four ways (with no penalty, then Ridge, Lasso and Elastic Net), see what each does to the weights, and check whether any of them predicts better on cars the model has not seen.

**When:** after class, at your own pace. Not submitted. · **Data:** `ml.cars_clean` (lab 05) · **SQL:** `Solved/regularization_and_training.sql`

## How to work through this lab

Run each query, compare with **What to look for**, and answer **Think** in one line. If `ml.cars_clean` does not exist, run step 1 of lab 05 first.

Part A is the lab. Part B is optional: it shows how BigQuery trains a model, for those who want to look behind the scenes.

Every model here uses `RANDOM` with 0.2 on the same `SELECT * FROM ml.cars_clean`. A random split is the same every time for the same data and columns (lab 05, step 4), so **every model holds aside the same cars**. The penalty is the only thing that changes, and the scores are a fair comparison.

The D11 slides show these four models fitted in Python on all 398 cars. Your BigQuery weights will be different: BigQuery measures the penalty on its own scale, and it learns from 80% of the cars. The strengths are different too: a penalty that drops a feature in Python can do nothing visible in BigQuery (step 4). Look for the same patterns, not the same numbers.

## Part A · Ridge, Lasso and Elastic Net

Regularization adds a penalty on large weights, so training aims for small errors **plus** small weights. BigQuery has two penalties, and the three methods you will meet in every machine-learning library are made from them:

| Method | In BigQuery | What it does to the weights |
|---|---|---|
| Ordinary linear regression | `l1_reg = 0`, `l2_reg = 0` (the default) | no penalty |
| **Ridge** | `l2_reg` above 0 | shrinks them; none reaches exactly 0 |
| **Lasso** | `l1_reg` above 0 | pushes the weak ones to exactly 0 |
| **Elastic Net** | both above 0 | some go to 0; the rest are shrunk and shared |

There is no `RIDGE`, `LASSO` or `ELASTIC_NET` model type. All four are `LINEAR_REG` with different penalties.

### Step 1 · The baseline: no penalty

```sql
CREATE OR REPLACE MODEL ml.cars_plain
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2) AS
SELECT * FROM ml.cars_clean;

SELECT processed_input, ROUND(weight, 2) AS weight
FROM ML.WEIGHTS(MODEL ml.cars_plain, STRUCT(TRUE AS standardize))
ORDER BY processed_input;
```

Standardized weights (lab 06, step 3) put every feature on one yardstick: each weight is the change in mpg for one typical spread of that feature. Read the result as an equation:

```text
mpg = __INTERCEPT__ + (weight of cylinders) × cylinders + … + (weight of acceleration) × acceleration
```

**What to look for:** `weight` has by far the largest weight, negative; `acceleration` is close to 0. On the slides the equation was `mpg = 23.5 − 0.61 × cylinders − 0.15 × displacement − 1.49 × horsepower − 4.54 × weight − 0.02 × acceleration`. Copy your five weights into a note: every step below compares against them.

Score it:

```sql
SELECT ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_plain);
```

**What to look for:** MAE about 3.3 and R² about 0.7, as in lab 05.

### Step 2 · Why hold weights back at all?

Four of the five features describe one thing: how big the car and its engine are. Heavier cars tend to have bigger engines, more cylinders and more horsepower.

```sql
SELECT ROUND(CORR(displacement, weight), 2) AS displacement_weight,
       ROUND(CORR(displacement, cylinders), 2) AS displacement_cylinders,
       ROUND(CORR(horsepower, weight), 2) AS horsepower_weight
FROM ml.cars_clean;
```

**What to look for:** all three above 0.85.

When features carry the same information, many different sets of weights fit the training cars almost equally well. The model can give one feature a large weight and another a large weight of the opposite sign, and a few different cars in the training rows can swing them. A penalty on large weights makes training prefer the smaller, steadier set.

Correlated features do not by themselves mean the model is overfitting. Whether a penalty actually helps is decided on the rows held aside, in step 6.

**Think:** in your own words, why can two features that say the same thing make their weights unstable?

### Step 3 · Ridge: `L2_REG`

Ridge penalises the **squares** of the weights. Big weights cost the most, so it trims the biggest ones hardest.

```sql
CREATE OR REPLACE MODEL ml.cars_ridge
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         l2_reg = 10) AS
SELECT * FROM ml.cars_clean;

SELECT processed_input, ROUND(weight, 2) AS weight
FROM ML.WEIGHTS(MODEL ml.cars_ridge, STRUCT(TRUE AS standardize))
ORDER BY processed_input;
```

Put the weights beside step 1's. Then add up the squared weights of each model, the quantity Ridge holds back:

```sql
SELECT ROUND(SUM(weight * weight), 2) AS sum_of_squared_weights
FROM ML.WEIGHTS(MODEL ml.cars_ridge, STRUCT(TRUE AS standardize))
WHERE processed_input != '__INTERCEPT__';
```

Run it again with `ml.cars_plain`.

`10` is a penalty strength, not a percentage, and no value is "moderate" for every dataset. Google suggests trying values across several orders of magnitude. Train `cars_ridge` again with `l2_reg = 100`, then `1000`, and re-run both queries each time.

**What to look for:**

- The sum of squared weights is smaller than the baseline's, and falls further as `l2_reg` grows.
- No weight becomes exactly 0.
- Not every weight shrinks. Ridge shrinks the **total**, and the overlapping features can **share** the credit: on the slides, weight's −4.54 fell to −2.36 while cylinders went from −0.61 to −1.15 and displacement from −0.15 to −1.34.

If nothing seems to change at 10, the penalty is too weak for this data: that is what the larger values are for.

**Think:** as the penalty grows, what happens to the weights? Keep your answer for step 6.

### Step 4 · Lasso: `L1_REG`

Lasso penalises the **sizes** of the weights. For a weak feature, keeping any weight at all costs more than it saves, so its weight goes to exactly 0.

An L1 penalty has no one-calculation answer, so BigQuery trains this model step by step, with gradient descent (Part B shows the steps). Two options make that clear:

| Option | What it does here |
|---|---|
| `optimize_strategy = 'BATCH_GRADIENT_DESCENT'` | train in steps. The default, `AUTO_STRATEGY`, already switches to steps whenever `l1_reg` is set; writing it down shows whoever reads your SQL how the model was trained |
| `early_stop = FALSE` | take every step allowed, so the effect of the penalty is clear. Google gives the same advice when you test regularization |

Start with a small penalty:

```sql
CREATE OR REPLACE MODEL ml.cars_lasso
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         optimize_strategy = 'BATCH_GRADIENT_DESCENT',
         l1_reg = 10, early_stop = FALSE) AS
SELECT * FROM ml.cars_clean;

SELECT processed_input, ROUND(weight, 3) AS weight,
       IF(weight = 0, 'DROPPED', 'KEPT') AS status
FROM ML.WEIGHTS(MODEL ml.cars_lasso, STRUCT(TRUE AS standardize))
WHERE processed_input != '__INTERCEPT__'
ORDER BY ABS(weight) DESC;
```

**What to look for:** every feature `KEPT`. The weights moved a little from step 1's, but none reached 0. Nothing is broken: on BigQuery's scale, 10 is a weak penalty for these cars.

Raise it. Train `cars_lasso` again with `l1_reg = 100`, then `l1_reg = 500`, and re-run the weights query each time.

**What to look for:**

- As `l1_reg` grows, the weights shrink and some reach 0. In our class run, strengths in the tens kept every feature; at **500**, `cylinders` was `DROPPED`. Find where it happens in yours.
- **A weight of 0 drops the feature.** `0 × cylinders` is 0 for every car, so changing a car's cylinders no longer moves its prediction. Lasso chose the features for you.
- Which features go first depends on the data and on the strength. On the slides, `acceleration` and `cylinders` went to 0 while `displacement`, which says much the same as cylinders, stayed. Look at `acceleration` in yours too. Among features that overlap, Lasso tends to keep one and drop the others.
- More steps did not change the story. Try `max_iterations = 50` at 500 (the default is 20): in class the weights came out about the same. The strength decided which features went, not the number of steps.

**Think:** you have 50 columns and want to keep only the useful ones. Ridge or Lasso? Why?

**Think:** 10 did nothing visible here. What does that tell you about copying a penalty strength from another tool, or another dataset?

### Step 5 · Elastic Net: both penalties

```sql
CREATE OR REPLACE MODEL ml.cars_enet
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         optimize_strategy = 'BATCH_GRADIENT_DESCENT',
         l1_reg = 500, l2_reg = 100, early_stop = FALSE) AS
SELECT * FROM ml.cars_clean;

SELECT processed_input, ROUND(weight, 3) AS weight,
       IF(weight = 0, 'DROPPED', 'KEPT') AS status
FROM ML.WEIGHTS(MODEL ml.cars_enet, STRUCT(TRUE AS standardize))
WHERE processed_input != '__INTERCEPT__'
ORDER BY ABS(weight) DESC;
```

Elastic Net has an L1 part, so it trains in steps too. Start from the strengths that changed something in steps 3 and 4: here, the `l1_reg` that dropped a feature and an `l2_reg` from step 3. The same number in `l1_reg` and `l2_reg` does not mean the two penalties count equally: try one larger than the other, and the other way round.

**What to look for:** something of each. Like Lasso, the weakest features can go to 0; like Ridge, the overlapping engine features tend to share the credit instead of one being dropped. On the slides, Elastic Net dropped only `acceleration` and kept all four engine features at similar sizes (−1.08, −1.30, −1.38, −2.30).

**Think:** the four engine features overlap, and you would rather keep them all than lose one. Which method fits?

### Step 6 · Which one predicts best?

Smaller weights are not the goal. A better score on cars the model has not seen is.

```sql
SELECT 'No penalty' AS model, ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_plain)
UNION ALL
SELECT 'Ridge', ROUND(mean_absolute_error, 2), ROUND(r2_score, 3)
FROM ML.EVALUATE(MODEL ml.cars_ridge)
UNION ALL
SELECT 'Lasso', ROUND(mean_absolute_error, 2), ROUND(r2_score, 3)
FROM ML.EVALUATE(MODEL ml.cars_lasso)
UNION ALL
SELECT 'Elastic Net', ROUND(mean_absolute_error, 2), ROUND(r2_score, 3)
FROM ML.EVALUATE(MODEL ml.cars_enet);
```

All four held aside the same cars, so this is a fair comparison. Each model is the version you trained last: `cars_lasso` at `l1_reg = 500` if you followed step 4.

**What to look for:** close scores. With five features and 398 cars, a straight line has little room to overfit, so a penalty has little to fix. On the slides (Python, the average over 300 random splits) no penalty did best: MAE 3.29, against 3.31 for Ridge, 3.48 for Lasso and 3.32 for Elastic Net. Penalties earn their place when there are many features and few rows.

Now overdo it. Train `cars_ridge` once more with `l2_reg = 100000` and re-run the comparison.

**What to look for:** a higher MAE and a lower R². A penalty that is too strong holds the weights back so hard that the model cannot learn the pattern. That is **underfitting**, the opposite of overfitting.

One caution. If you try many strengths and keep the one with the best score here, you have used the held-aside cars to make a choice. Their score now flatters your pick. An honest final score needs a third group that no choice has touched: the test group (lab 05, step 6; D14).

**Think:** which of the four would you hand to a manager, and why?

## Part B · Behind the scenes: how training runs (optional)

### Step 7 · `OPTIMIZE_STRATEGY`: one calculation, or many small steps

Training is a search for the weights that make the errors smallest. BigQuery has two ways to do it:

- **`NORMAL_EQUATION`** works the best weights out directly, in one calculation.
- **`BATCH_GRADIENT_DESCENT`** starts from a guess and improves it in steps (iterations), each step nudging every weight in the direction that makes the errors smaller.

The default, `AUTO_STRATEGY`, picks for you. Google's rules: steps when `l1_reg` is set, when the features have more than 10,000 values between them, or when there are fewer than 10 training rows for each of those values; one calculation otherwise. So the plain and Ridge models in Part A took one calculation, and Lasso and Elastic Net took steps. Train both on purpose:

```sql
CREATE OR REPLACE MODEL ml.cars_normal
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         optimize_strategy = 'NORMAL_EQUATION') AS
SELECT * FROM ml.cars_clean;

CREATE OR REPLACE MODEL ml.cars_steps
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         optimize_strategy = 'BATCH_GRADIENT_DESCENT') AS
SELECT * FROM ml.cars_clean;
```

`ML.TRAINING_INFO` shows each step: the `loss` on the training rows, the `eval_loss` on the rows held aside, and the learning rate. For linear regression both losses are mean squared errors: squared miles per gallon, not the MAE that `ML.EVALUATE` reports, so do not compare the two kinds of number.

```sql
SELECT iteration, ROUND(loss, 2) AS loss, ROUND(eval_loss, 2) AS eval_loss,
       ROUND(learning_rate, 3) AS learning_rate
FROM ML.TRAINING_INFO(MODEL ml.cars_steps)
ORDER BY iteration;
```

**What to look for:** for `cars_steps`, several rows, with the loss falling quickly and then flattening. Run the same query on `cars_normal`: one row. Compare the two with `ML.EVALUATE`: nearly the same MAE and R², since both routes reach about the same line.

Now ask for the impossible: one calculation with an L1 penalty.

```sql
CREATE OR REPLACE MODEL ml.cars_lasso_one_calc
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         optimize_strategy = 'NORMAL_EQUATION', l1_reg = 500) AS
SELECT * FROM ml.cars_clean;
```

**What to look for:** an error instead of a model. Google's page lists `l1_reg` among the cases where `NORMAL_EQUATION` can't be used. Then run the `ML.TRAINING_INFO` query on `ml.cars_lasso`: one row per step, the record that it was trained by gradient descent.

**Think:** looking at the loss column, when would you stop taking steps?

### Step 8 · `MAX_ITERATIONS`: stop early on purpose

Three options decide when gradient descent stops:

| Option | Default | What it does |
|---|---|---|
| `MAX_ITERATIONS` | 20 | the most steps it may take |
| `EARLY_STOP` | `TRUE` | allows it to stop before that, when a step stops helping |
| `MIN_REL_PROGRESS` | 0.01 | what "stops helping" means: a step that improves the loss by less than 1% |

Allow only two steps:

```sql
CREATE OR REPLACE MODEL ml.cars_two_steps
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         optimize_strategy = 'BATCH_GRADIENT_DESCENT', max_iterations = 2) AS
SELECT * FROM ml.cars_clean;

SELECT ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_two_steps);
```

Compare it with `ml.cars_steps` (step 7), which ran until it stopped by itself. Look at the last `loss` and `eval_loss` of each in `ML.TRAINING_INFO` too: a lower training loss is good news only if the `eval_loss` falls with it.

**What to look for:** if the two-step model scores worse, training stopped before it reached a good line: that is **underfitting**, the same word as in step 6, from a different cause. If the two score about the same, this model happened to get close in two steps. Count the rows of `ML.TRAINING_INFO(MODEL ml.cars_steps)`: that is where early stopping ended it.

**Think:** you have now met underfitting twice. What are its two causes?

## What you saw

| Model or option | Value tried | What you saw |
|---|---|---|
| No penalty | `l1_reg = 0`, `l2_reg = 0` | |
| Ridge | `l2_reg` 10 / 100 / 1000 | |
| Lasso | `l1_reg` 10 / 100 / 500 | |
| Elastic Net | both | |
| Too much penalty | `l2_reg = 100000` | |
| `OPTIMIZE_STRATEGY` | NORMAL_EQUATION / BATCH_GRADIENT_DESCENT; NORMAL_EQUATION with `l1_reg` | |
| `MAX_ITERATIONS` | 2 | |

These options are not special to linear regression. Logistic regression (D12) has the same penalties, and boosted trees (D14) have their own `l2_reg`.

## References

Auto MPG, UCI Machine Learning Repository (Quinlan, 1993), CC BY 4.0. BigQuery ML: [CREATE MODEL for linear regression](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm), [Preventing overfitting](https://docs.cloud.google.com/bigquery/docs/preventing-overfitting), [ML.TRAINING_INFO](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-train), [ML.WEIGHTS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-weights), Google Cloud.
