# Lab 06 · What goes into the line: the intercept, text features, and reading weights fairly

In this self-guided lab, you will switch the intercept off and watch the line break, see the two ways BigQuery turns text into numbers, and find out why raw weights can rank features in the wrong order.

**When:** after class, at your own pace. Not submitted. · **Data:** `ml.salary_data`, `ml.insurance` (class), `ml.cars_random` (lab 05) · **SQL:** `Solved/intercept_and_categories.sql`

## How to work through this lab

Run each query, compare with **What you should see**, and answer **Think** in one line. If you have not done lab 05, do its steps 1 and 3 first: they create `ml.cars_clean` and `ml.cars_random`.

## Step 1 · `FIT_INTERCEPT`: does the line need a starting point?

In class the salary model was *25,792 + 9,450 × years*. The 25,792 is the **intercept**: the prediction when every feature is 0. `FIT_INTERCEPT` (default TRUE) lets training choose it. Switch it off:

```sql
CREATE OR REPLACE MODEL ml.salary_no_intercept
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['salary'],
         fit_intercept = FALSE) AS
SELECT years_experience, salary
FROM ml.salary_data;

SELECT processed_input, ROUND(weight, 1) AS weight
FROM ML.WEIGHTS(MODEL ml.salary_no_intercept);

SELECT ROUND(mean_absolute_error) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.salary_no_intercept);
```

**What you should see:** one weight only, about 13,255 per year, and no intercept row. MAE about 10,881 dollars, against about 4,644 with the intercept. R² about 0.76, against about 0.96.

The line is now forced through zero: zero years of experience, zero salary. To get close to the hires anyway, it tilts steeply: a new graduate with 1.1 years is predicted about 14,600 dollars, and the real one earned 39,343.

**Think:** when would a line through zero make sense? (Hint: what is the cost of making zero units?)

## Step 2 · `CATEGORY_ENCODING_METHOD`: how text becomes numbers

A model multiplies numbers. `region` is text, so BigQuery turns it into 0-or-1 columns before training. There are two ways, and the option chooses:

| Method | What it makes for `region` (4 values) | How to read a weight |
|---|---|---|
| `ONE_HOT_ENCODING` (default) | 4 columns, one per region | each region's own weight |
| `DUMMY_ENCODING` | 3 columns: one region is dropped and becomes the baseline | how much each region differs **from the baseline** |

Train the insurance model both ways:

```sql
CREATE OR REPLACE MODEL ml.insurance_onehot
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['charges'],
         category_encoding_method = 'ONE_HOT_ENCODING') AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance;

CREATE OR REPLACE MODEL ml.insurance_dummy
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['charges'],
         category_encoding_method = 'DUMMY_ENCODING') AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance;
```

Both have 1,338 rows, so `AUTO_SPLIT` holds 20% aside. Look at `region` in each:

```sql
SELECT cw.category, ROUND(cw.weight, 1) AS weight
FROM ML.WEIGHTS(MODEL ml.insurance_onehot), UNNEST(category_weights) AS cw
WHERE processed_input = 'region'
ORDER BY cw.category;
```

`category_weights` holds a small list per text feature; `UNNEST` turns that list into rows, one per category. Run it again with `ml.insurance_dummy` in place of `ml.insurance_onehot`.

**What you should see:** one-hot gives four region weights. Dummy gives three: one region is missing, because it became the baseline. Write down which one. Each dummy weight is that region's charges compared with the baseline, other things equal. With `northeast` as the baseline they are about −353 (northwest), −1,035 (southeast) and −960 (southwest). With another baseline the numbers shift, but the gap between any two regions stays the same: southeast is always about 680 below northwest.

Now compare the two scores with `ML.EVALUATE`. **What you should see:** almost the same. The encoding changes how the weights read, not what the model predicts.

**Think:** which version would you show a manager who asks "how much more does the southeast cost?"

## Step 3 · Raw weights against standardized weights

Back to cars. Which feature hurts fuel efficiency most? Ask the raw weights first:

```sql
SELECT processed_input, ROUND(weight, 4) AS weight
FROM ML.WEIGHTS(MODEL ml.cars_random)
WHERE processed_input != '__INTERCEPT__'
ORDER BY ABS(weight) DESC;
```

**What you should see:** `cylinders` first (about −0.36) and `weight` near the bottom (about −0.0054).

Now standardized:

```sql
SELECT processed_input, ROUND(weight, 2) AS weight
FROM ML.WEIGHTS(MODEL ml.cars_random, STRUCT(TRUE AS standardize))
WHERE processed_input != '__INTERCEPT__'
ORDER BY ABS(weight) DESC;
```

**What you should see:** `weight` first (about −4.5), then `horsepower` (about −1.5) and `cylinders` (about −0.6). The order flips.

A raw weight is "mpg per one unit of this feature". One pound of car weight is tiny; one cylinder is a big step. Ranking raw weights ranks units. A standardized weight is "mpg per one typical spread (standard deviation) of the feature", the same yardstick for every feature. Use raw weights to say what one unit is worth; use standardized weights to rank features.

**Think:** a colleague says "cylinders hurt mpg the most". What do you tell them?

## Bonus · Which weights would survive new data?

Not required. A weight learned from 1,338 people could be partly luck. A **p-value** asks: if this feature truly had no effect, how often would a weight this far from zero appear by chance? Below 0.05 is the usual line for "very likely real".

```sql
CREATE OR REPLACE MODEL ml.insurance_pvalues
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['charges'],
         category_encoding_method = 'DUMMY_ENCODING',
         calculate_p_values = TRUE,
         data_split_method = 'NO_SPLIT') AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance;

SELECT processed_input, category, ROUND(weight, 1) AS weight, ROUND(p_value, 4) AS p_value
FROM ML.ADVANCED_WEIGHTS(MODEL ml.insurance_pvalues);
```

BigQuery computes p-values only with dummy encoding. Expect tiny p-values for `smoker`, `age`, `bmi` and `children`, and large ones for `sex` (about 0.69) and the northwest region (about 0.46): the data cannot tell those from zero. That is why, in class, three features did as well as six.

## What you saw

| Option | Changed | What happened |
|---|---|---|
| `FIT_INTERCEPT = FALSE` | the line must pass through zero | |
| `CATEGORY_ENCODING_METHOD` | one-hot against dummy | |
| `STRUCT(TRUE AS standardize)` | weights on one yardstick | |

## References

Salary data and Medical Cost Personal Datasets (Kaggle); Auto MPG, UCI Machine Learning Repository, CC BY 4.0. Course copies in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md). BigQuery ML: [CREATE MODEL for linear regression](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm), [ML.WEIGHTS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-weights), [ML.ADVANCED_WEIGHTS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-advanced-weights), Google Cloud.
