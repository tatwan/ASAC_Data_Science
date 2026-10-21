# Lab 07 · Holding the weights back, and how training runs

In this self-guided lab, you will watch how BigQuery fits a line (in one calculation, or step by step), see what happens when training stops too early, and use L1 and L2 regularization to hold large weights back.

**When:** after class, at your own pace. Not submitted. · **Data:** `ml.cars_clean` (lab 05) · **SQL:** `Solved/regularization_and_training.sql`

## How to work through this lab

Run each query, compare with **What you should see**, and answer **Think** in one line. If `ml.cars_clean` does not exist, run step 1 of lab 05 first.

Every model in this lab uses the same split (`RANDOM`, 0.2) and the same five features, so the only thing that changes is the option you are looking at.

## Part A · How training runs

### Step 1 · `OPTIMIZE_STRATEGY`: one calculation, or many small steps

For a straight line there are two ways to find the best weights:

- **`NORMAL_EQUATION`** solves for them in one calculation. Exact and fast when there are few features.
- **`BATCH_GRADIENT_DESCENT`** starts from a guess and improves it in steps (iterations). Each step looks at the errors on all training rows and moves every weight a little in the direction that shrinks them. It is how most machine-learning models train, and the only way when there are very many features.

The default, `AUTO_STRATEGY`, picks for you. Train both on purpose:

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

`ML.TRAINING_INFO` shows each training step: the iteration, the `loss` on the training rows (mean squared error), the `eval_loss` on the rows held aside, and the learning rate used.

```sql
SELECT iteration, ROUND(loss, 2) AS loss, ROUND(eval_loss, 2) AS eval_loss,
       ROUND(learning_rate, 3) AS learning_rate
FROM ML.TRAINING_INFO(MODEL ml.cars_steps)
ORDER BY iteration;
```

**What you should see:** for `cars_steps`, several rows: the loss starts high and falls quickly, then flattens. Run the same query on `cars_normal`: one row.

Compare the two scores with `ML.EVALUATE`. **What you should see:** nearly the same MAE and R² (about 3.3 and 0.7). Two routes, the same line.

**Think:** looking at the loss column, when would you stop taking steps?

### Step 2 · `MAX_ITERATIONS`: stop too early on purpose

Gradient descent stops by itself when a step improves the loss by less than 1%, or after 20 steps (`MAX_ITERATIONS`). Stop it after two:

```sql
CREATE OR REPLACE MODEL ml.cars_two_steps
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         optimize_strategy = 'BATCH_GRADIENT_DESCENT', max_iterations = 2) AS
SELECT * FROM ml.cars_clean;

SELECT ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_two_steps);
```

Run it again with `ml.cars_steps` (step 1's model, which trained until it stopped by itself) and compare.

**What you should see:** after two steps the model is worse: a higher MAE and a lower R². It has not finished learning. This is **underfitting**: too simple, or not trained enough, to capture the pattern. Count the rows of `ML.TRAINING_INFO(MODEL ml.cars_steps)`: that is where early stopping ended it.

**Think:** overfitting is learning the training rows too closely. What is underfitting, in your words?

## Part B · Holding the weights back: regularization

### Step 3 · Why hold weights back at all?

Four of the five car features describe one thing: how big the engine and the car are. `cylinders`, `displacement`, `horsepower` and `weight` rise together. When features carry the same information, the model can share the credit between them in many ways that fit almost equally well, and small changes in the data can swing their weights a lot. See how closely they move together:

```sql
SELECT ROUND(CORR(displacement, weight), 2) AS displacement_weight,
       ROUND(CORR(displacement, cylinders), 2) AS displacement_cylinders,
       ROUND(CORR(horsepower, weight), 2) AS horsepower_weight
FROM ml.cars_clean;
```

**What you should see:** all three above 0.85. A **penalty** on large weights makes training prefer smaller, more evenly shared weights. That is **regularization**: the training goal becomes *small errors plus small weights*.

### Step 4 · `L2_REG`: shrink every weight a little

```sql
CREATE OR REPLACE MODEL ml.cars_l2
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         l2_reg = 50) AS
SELECT * FROM ml.cars_clean;

SELECT processed_input, ROUND(weight, 2) AS weight
FROM ML.WEIGHTS(MODEL ml.cars_l2, STRUCT(TRUE AS standardize))
ORDER BY processed_input;
```

Run it again with `ml.cars_normal` (step 1's model, no penalty) and put the two lists side by side. Standardized weights (lab 06, step 3) put every feature on one yardstick, so you can compare sizes.

**What you should see:** with L2, every weight is closer to zero, and the four engine features share the credit more evenly. No weight becomes exactly zero. Compare `ML.EVALUATE` for both: the scores are close, often a little lower with the penalty on data this small.

Try `l2_reg = 500`. **Think:** what happens to the weights, and to R², as the penalty grows?

### Step 5 · `L1_REG`: push weak weights to exactly zero

```sql
CREATE OR REPLACE MODEL ml.cars_l1
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         l1_reg = 50) AS
SELECT * FROM ml.cars_clean;

SELECT processed_input, ROUND(weight, 3) AS weight
FROM ML.WEIGHTS(MODEL ml.cars_l1, STRUCT(TRUE AS standardize))
ORDER BY ABS(weight) DESC;
```

**What you should see:** some weights are exactly 0. The first to go are the features the model needs least, usually `acceleration` and `displacement`; `weight` survives longest. L1 chooses features for you: a weight of zero means the model no longer uses that column.

Run `ML.TRAINING_INFO` on `cars_l1`: several rows. An L1 penalty cannot be solved in one calculation, so BigQuery trains it step by step.

Try `l1_reg = 200`. **Think:** if you had 50 columns and only wanted to keep the useful ones, which of the two penalties would you use, and why?

## What you saw

| Option | Value tried | What you saw |
|---|---|---|
| `OPTIMIZE_STRATEGY` | NORMAL_EQUATION / BATCH_GRADIENT_DESCENT | |
| `MAX_ITERATIONS` | 2 | |
| `L2_REG` | 50 / 500 | |
| `L1_REG` | 50 / 200 | |

These options are not special to linear regression. Logistic regression (D12) has the same ones, and other models have their own versions of them.

## References

Auto MPG, UCI Machine Learning Repository (Quinlan, 1993), CC BY 4.0. BigQuery ML: [CREATE MODEL for linear regression](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm), [ML.TRAINING_INFO](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-train), [ML.WEIGHTS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-weights), Google Cloud.
