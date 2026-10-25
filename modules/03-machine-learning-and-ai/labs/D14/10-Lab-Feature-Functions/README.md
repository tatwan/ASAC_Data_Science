# Lab 10 · Feature engineering with BigQuery ML's functions

In this self-guided lab, you will build features with four of BigQuery ML's preprocessing functions (bands with `ML.BUCKETIZE` and `ML.QUANTILE_BUCKETIZE`, crosses with `ML.FEATURE_CROSS`, squares and products with `ML.POLYNOMIAL_EXPAND`), see which ones help the line, and meet the one trap they share.

**When:** after class, about 35 minutes, at your own pace. Not submitted. · **Data:** `ml.insurance_groups` · **SQL:** `Solved/feature_functions.sql`

## The story

In class you wrote the smoker-and-BMI feature by hand with `IF`. That works for one feature. BigQuery ML has functions for the common shapes of feature: bands of a number, combinations of categories, powers and products of numbers. They do not know anything you do not: you still choose which columns to combine, and why. This lab shows each one on the insurance data and checks it the way the class did, on the same validation people.

## What you will learn

- To cut a number into bands with fixed cut points (`ML.BUCKETIZE`) or equal-sized groups (`ML.QUANTILE_BUCKETIZE`).
- To combine two categories into one with `ML.FEATURE_CROSS`, the general form of the class's `smoker_obese`.
- To list squares and products with `ML.POLYNOMIAL_EXPAND`.
- Why a function that looks at every row (`… OVER ()`) can leak information from the validation and test rows, and where that is fixed (D15).

## Before you start

You need `ml.insurance_groups` and `ml.ins_linear` from [activity 01](../01-Evr-Same-Rows-Two-Models/README.md). Every model here is a `LINEAR_REG`, so it trains in every sandbox and its numbers are exact for these rows.

Work like the other labs: run each query, compare with **What you should see**, and answer **Think** in one line.

## Step 1 · Age bands with fixed cut points

```sql
SELECT ML.BUCKETIZE(age, [30, 45, 60]) AS age_band,
       MIN(age) AS youngest, MAX(age) AS oldest, COUNT(*) AS people
FROM ml.insurance_groups
WHERE split = 'train'
GROUP BY age_band
ORDER BY age_band;
```

Three cut points make four bands. Each band runs from its lower cut point up to, but not including, the next: `bin_1` under 30, `bin_2` 30 to 44, `bin_3` 45 to 59, `bin_4` 60 and over. The output is text, so a model treats it as a category.

**What you should see:** 247 · 233 · 261 · 62 training people.

```sql
CREATE OR REPLACE MODEL ml.ins_linear_ageband
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT') AS
SELECT age, ML.BUCKETIZE(age, [30, 45, 60]) AS age_band, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups WHERE split = 'train';

SELECT ROUND(r2_score, 3) AS validation_r2, ROUND(mean_absolute_error) AS validation_mae
FROM ML.EVALUATE(MODEL ml.ins_linear_ageband,
  (SELECT *, ML.BUCKETIZE(age, [30, 45, 60]) AS age_band FROM ml.insurance_groups WHERE split = 'validation'));
```

**What you should see:** R² about 0.742, MAE about 4,320. Almost no change from the six-feature line (0.739). Age was not the line's problem.

## Step 2 · A cross of two categories

```sql
SELECT ML.FEATURE_CROSS(STRUCT(IF(smoker, 'yes', 'no') AS smoker, IF(bmi >= 30, '30plus', 'under30') AS bmi_group)).smoker_bmi_group
         AS smoker_bmi,
       COUNT(*) AS people, ROUND(AVG(charges)) AS avg_charges
FROM ml.insurance_groups
WHERE split = 'train'
GROUP BY smoker_bmi
ORDER BY avg_charges;
```

`ML.FEATURE_CROSS` takes a `STRUCT` of text columns only. `smoker` is BOOLEAN, so `IF(smoker, 'yes', 'no') AS smoker` turns it back into text under the same name (Google's page asks for a `STRUCT` of STRING values). The function returns a `STRUCT` with one field per pair, named after the two columns (`smoker_bmi_group`) and holding the two values joined (`yes_30plus`). The class's `smoker_obese` was one of these four combinations; the cross gives the line all four.

**What you should see:** `no_under30` 305 · 7,861 · `no_30plus` 327 · 8,657 · `yes_under30` 84 · 21,632 · `yes_30plus` 87 · 41,473: activity 05's table, in one column.

```sql
CREATE OR REPLACE MODEL ml.ins_linear_cross
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT') AS
SELECT age, sex, bmi, children, smoker, region,
       ML.FEATURE_CROSS(STRUCT(IF(smoker, 'yes', 'no') AS smoker, IF(bmi >= 30, '30plus', 'under30') AS bmi_group)).smoker_bmi_group
         AS smoker_bmi,
       charges
FROM ml.insurance_groups WHERE split = 'train';

SELECT ROUND(r2_score, 3) AS validation_r2, ROUND(mean_absolute_error) AS validation_mae
FROM ML.EVALUATE(MODEL ml.ins_linear_cross,
  (SELECT *,
          ML.FEATURE_CROSS(STRUCT(IF(smoker, 'yes', 'no') AS smoker, IF(bmi >= 30, '30plus', 'under30') AS bmi_group)).smoker_bmi_group
            AS smoker_bmi
   FROM ml.insurance_groups WHERE split = 'validation'));
```

**What you should see:** R² about 0.854, MAE about 2,474, close to the class's 0.858 with `smoker_obese` and `age_sq`. Add the age bands from step 1 as well and it reaches about 0.859.

**Think:** the cross helped and the age bands did not. What does that say about where the line's error came from?

## Step 3 · Bands of equal size, and a trap

```sql
SELECT bmi_quarter, MIN(bmi) AS lowest, MAX(bmi) AS highest, COUNT(*) AS people
FROM (
  SELECT bmi, ML.QUANTILE_BUCKETIZE(bmi, 4, 'bucket_ranges') OVER () AS bmi_quarter
  FROM ml.insurance_groups
)
GROUP BY bmi_quarter
ORDER BY lowest;
```

`ML.QUANTILE_BUCKETIZE(bmi, 4)` chooses the cut points itself, so that each band holds about a quarter of the rows. It is an **analytic function**, like D10's window functions: it always needs `OVER ()`, and it looks at every row the query reads. The `'bucket_ranges'` argument shows the cut points instead of `bin_1` to `bin_4`.

**What you should see:** cut points near 26.3, 30.4 and 34.7, about 335 people per band.

Now the trap. This query read all 1,338 people, including the validation and test groups. The cut points therefore depend a little on people the model is supposed never to have seen. Computed on the training rows only, they are about 26.3, 30.3 and 34.4. The difference is small here; on other data it can matter, and it is the same mistake as a leak: information from the rows you score on finds its way into training. The fix on D15: put the function inside a `TRANSFORM` clause, which computes the cut points once, on the training rows, and reuses them for every prediction.

## Step 4 · Squares and products

```sql
SELECT age, bmi,
       ML.POLYNOMIAL_EXPAND(STRUCT(age, bmi), 2) AS expanded
FROM ml.insurance_groups
WHERE split = 'train'
LIMIT 3;
```

`ML.POLYNOMIAL_EXPAND` returns every power and product of the numbers you give it, up to the degree you ask (2 here; at most 4): `age`, `age_age`, `age_bmi`, `bmi`, `bmi_bmi`. The class's `age_sq` is `age_age`.

**What you should see:** three rows, each with a `STRUCT` of five fields; for a person of 40 with a BMI of 30, `age_age` 1,600, `age_bmi` 1,200 and `bmi_bmi` 900.

**Think:** with ten numeric columns and degree 2 you would get 65 features. Why might that hurt a model trained on 803 people? (D11's degree-9 curve is a hint.)

## What you saw

| Feature | Validation R² of the line | Helped? |
|---|---:|---|
| none (six features) | 0.739 | |
| age bands | | |
| smoker × BMI group | | |
| both | | |

## References

BigQuery ML: [manual preprocessing functions](https://docs.cloud.google.com/bigquery/docs/manual-preprocessing), [ML.BUCKETIZE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-bucketize), [ML.QUANTILE_BUCKETIZE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-quantile-bucketize), [ML.FEATURE_CROSS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-feature-cross), [ML.POLYNOMIAL_EXPAND](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-polynomial-expand), Google Cloud. Data as in activity 01.
