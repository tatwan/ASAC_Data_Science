# Who was likely to survive the Titanic? Classification, start to finish

In this activity, you will take 1,309 Titanic passengers through the same five steps as the diamonds, this time predicting a yes or no: did the passenger survive? In part 2 you train two more models on the same passengers, one with `TRANSFORM`, and learn to read and compare the evaluation charts BigQuery draws for them.

**In class:** following along · **Data:** `ml.titanic` (uploaded in "Before you start") → `ml.titanic_survival`, `ml.v_titanic_scored` · **Starter:** `Unsolved/titanic_survival.sql`

## The story

The Titanic sank in April 1912. Of the 1,309 passengers in this table, 500 survived. Survival was not random: the order "women and children first" and where your cabin was both mattered. A model that learns from these passengers can say how likely a new passenger, described the same way, would have been to survive. It is the most famous practice dataset on Kaggle, and the steps are the ones you used for D12's churn.

## What you will learn

- The same five steps with a TRUE or FALSE label: `LOGISTIC_REG` in place of `LINEAR_REG`.
- To compare accuracy with the majority guess before calling a model good.
- To score passengers you type in yourself, and to keep the probability of TRUE with `UNNEST`.
- Part 2: to keep the preparation of the data inside the model with `TRANSFORM`, and to read precision and recall by threshold, the precision-recall curve and the ROC curve, and say which of two models is better.

## Before you start: upload `titanic.csv`

Each of today's four activities starts by uploading its own file into your `ml` dataset. The four files are in the course GitHub repository, in the folder [`shared/datasets/ml_recap`](../../../../../shared/datasets/ml_recap/README.md).

1. **Download the file.** Open [`titanic.csv`](../../../../../shared/datasets/ml_recap/titanic.csv) on GitHub and click **Download raw file** (the downward arrow, top right). Do not open it in Excel and save it again.
2. **Upload it.** Next to `ml`, **⋮** → **Create table**. **Create table from:** Upload; choose `titanic.csv`; **File format:** CSV. **Table:** `titanic`. **Schema:** tick **Auto detect**. **Create table**. The steps are the same as in [Upload a CSV to BigQuery](../../../../02-sql/resources/upload-a-csv-to-bigquery.md).

**Check:** `SELECT COUNT(*) FROM ml.titanic;` returns 1,309, and `survived` is BOOLEAN in the table's **Schema** tab.

## Step 1 · Look: one row is one passenger

```sql
SELECT sex,
       COUNT(*) AS passengers,
       COUNTIF(survived) AS survivors,
       ROUND(AVG(IF(survived, 1, 0)), 3) AS share_survived
FROM ml.titanic
GROUP BY sex;
```

**What you should see:** two rows. Women: 466 passengers, 339 survived, 0.727. Men: 843, 161, 0.191. Over all 1,309 passengers, 0.382 survived, so the guess "nobody survived" is right 62% of the time. The model has to beat that.

## Step 2 · Create the model

```sql
CREATE OR REPLACE MODEL ml.titanic_survival
OPTIONS (model_type = 'LOGISTIC_REG',
         input_label_cols = ['survived']) AS
SELECT * EXCEPT (passenger_id)
FROM ml.titanic;
```

The only changes from the diamonds: the model type and the label. `age` is empty for 263 passengers; BigQuery fills an empty number with the column's average when it trains, so they stay in.

## Step 3 · Evaluate

```sql
SELECT ROUND(accuracy, 3) AS accuracy,
       ROUND(precision, 3) AS precision,
       ROUND(recall, 3) AS recall,
       ROUND(roc_auc, 3) AS roc_auc
FROM ML.EVALUATE(MODEL ml.titanic_survival);
```

**What you should see:** accuracy about 0.78, against about 0.62 for "nobody survived" on the same held-aside passengers. Precision about 0.74, recall about 0.68, ROC AUC about 0.84. Your numbers move by a few hundredths, because about 260 passengers are held aside at random.

## Step 4 · Predict: two passengers you describe

```sql
SELECT pclass, sex, age, predicted_survived,
       ROUND(p.prob, 2) AS chance_of_surviving
FROM ML.PREDICT(MODEL ml.titanic_survival,
       (SELECT 1 AS pclass, 'female' AS sex, 17.0 AS age, 0 AS sibsp, 1 AS parch
        UNION ALL
        SELECT 3, 'male', 20.0, 0, 0)),
     UNNEST(predicted_survived_probs) AS p
WHERE p.label = TRUE;
```

A 17-year-old woman in first class travelling with a parent, and a 20-year-old man in third class travelling alone. `predicted_survived_probs` holds two probabilities, one for TRUE and one for FALSE; `UNNEST` turns them into rows and `WHERE p.label = TRUE` keeps the chance of surviving (D12).

**What you should see:** about 0.95 for her (`predicted_survived` TRUE) and about 0.14 for him (FALSE).

## Step 5 · Save the predictions as a view

```sql
CREATE OR REPLACE VIEW ml.v_titanic_scored AS
SELECT passenger_id, pclass, sex, age, survived, predicted_survived,
       ROUND(p.prob, 3) AS survival_chance
FROM ML.PREDICT(MODEL ml.titanic_survival, TABLE ml.titanic),
     UNNEST(predicted_survived_probs) AS p
WHERE p.label = TRUE;

SELECT pclass, sex, COUNT(*) AS passengers,
       ROUND(AVG(survival_chance), 2) AS average_chance
FROM ml.v_titanic_scored
GROUP BY pclass, sex
ORDER BY pclass, sex;
```

**What you should see:** six rows. First-class women about 0.88 on average, third-class men about 0.10. The view has 1,309 rows, one per passenger, ready for a Power BI report.

## Part 2 · TRANSFORM, and reading the evaluation charts

Part 2 is complete on its own: it needs only `ml.titanic` (see "Before you start": `SELECT COUNT(*) FROM ml.titanic;` returns 1,309). `TRANSFORM` was first taught on D15 (activity 08) and the charts on D12 (activity 02 and lab 03); this part repeats both from the beginning.

### Step 6 · Fix the passengers you score on

To compare two models fairly, both must learn from the same passengers and be scored on the same other passengers. Use the passenger number: one passenger in five, those whose number divides by 5, is kept aside for scoring.

```sql
SELECT COUNTIF(MOD(passenger_id, 5) <> 0) AS to_learn_from,
       COUNTIF(MOD(passenger_id, 5) = 0)  AS to_score_on,
       COUNTIF(MOD(passenger_id, 5) = 0 AND survived) AS survivors_to_score
FROM ml.titanic;
```

**What you should see:** 1,048 to learn from, 261 to score on, 97 of them survivors (37 in 100).

### Step 7 · Model A: sex only

A deliberately simple model, to have something to compare with.

```sql
CREATE OR REPLACE MODEL ml.titanic_sex_only
OPTIONS (model_type = 'LOGISTIC_REG',
         input_label_cols = ['survived'],
         data_split_method = 'NO_SPLIT') AS
SELECT sex, survived
FROM ml.titanic
WHERE MOD(passenger_id, 5) <> 0;
```

`data_split_method = 'NO_SPLIT'` tells BigQuery to learn from every row it is given: we keep our own scoring rows aside with the `WHERE`.

### Step 8 · Model B: the preparation inside the model, with TRANSFORM

Three columns need preparing before they help: `age` is empty for 263 passengers, children (under 13) were saved first, and `sibsp` and `parch` together give the family's size. You could prepare them in the `SELECT`, but then every query that uses the model later must repeat the same preparation, with the same numbers. `TRANSFORM` keeps the preparation inside the model.

```sql
CREATE OR REPLACE MODEL ml.titanic_transform
TRANSFORM (pclass,
           sex,
           ML.IMPUTER(age, 'median') OVER () AS age,
           IF(age < 13, TRUE, FALSE) AS is_child,
           sibsp + parch + 1 AS family_size,
           survived)
OPTIONS (model_type = 'LOGISTIC_REG',
         input_label_cols = ['survived'],
         data_split_method = 'NO_SPLIT') AS
SELECT pclass, sex, age, sibsp, parch, survived
FROM ml.titanic
WHERE MOD(passenger_id, 5) <> 0;
```

Read it from the bottom. The `SELECT` hands the model the raw columns of the 1,048 passengers. `TRANSFORM` then prepares them: `ML.IMPUTER(age, 'median') OVER ()` fills an empty age with the median age of these passengers (28) and remembers that number; `is_child` and `family_size` are worked out from the raw columns; the label `survived` passes through. The model trains on the prepared columns. Google's guide: "When you use ML analytic functions inside the TRANSFORM clause during training, the same statistics are automatically applied to the input in prediction."

### Step 9 · Predict from raw columns

At prediction you pass the raw columns. The model fills the age and works out the new columns itself, with the numbers it learned in training.

```sql
SELECT pclass, sex, age, sibsp, parch, predicted_survived,
       ROUND(p.prob, 2) AS chance_of_surviving
FROM ML.PREDICT(MODEL ml.titanic_transform,
       (SELECT 3 AS pclass, 'male' AS sex, CAST(NULL AS FLOAT64) AS age, 1 AS sibsp, 3 AS parch)),
     UNNEST(predicted_survived_probs) AS p
WHERE p.label = TRUE;
```

**What you should see:** a third-class man of unknown age travelling with a family of five: `predicted_survived` false, a chance of about 0.04. You did not write the median age, `is_child` or `family_size` in this query: the model applied them.

### Step 10 · Score both models on the same 261 passengers

```sql
SELECT 'sex only' AS model, ROUND(accuracy, 2) AS accuracy, ROUND(precision, 2) AS precision,
       ROUND(recall, 2) AS recall, ROUND(roc_auc, 2) AS roc_auc
FROM ML.EVALUATE(MODEL ml.titanic_sex_only,
       (SELECT * FROM ml.titanic WHERE MOD(passenger_id, 5) = 0))
UNION ALL
SELECT 'TRANSFORM', ROUND(accuracy, 2), ROUND(precision, 2), ROUND(recall, 2), ROUND(roc_auc, 2)
FROM ML.EVALUATE(MODEL ml.titanic_transform,
       (SELECT * FROM ml.titanic WHERE MOD(passenger_id, 5) = 0));
```

**What you should see:** accuracy about 0.78 against about 0.81, but ROC AUC about 0.75 against about 0.85. Accuracy, precision and recall are measured at one threshold (0.5); ROC AUC looks at every threshold at once. The charts in step 11 show why the second model is better.

### Step 11 · The three charts, row by row

`ML.ROC_CURVE` returns one row per threshold. Precision is worked out from its counts.

```sql
SELECT ROUND(threshold, 2) AS threshold,
       ROUND(SAFE_DIVIDE(true_positives, true_positives + false_positives), 2) AS precision,
       ROUND(recall, 2) AS recall,
       ROUND(false_positive_rate, 2) AS false_positive_rate
FROM ML.ROC_CURVE(MODEL ml.titanic_transform,
       (SELECT * FROM ml.titanic WHERE MOD(passenger_id, 5) = 0))
ORDER BY threshold;
```

**What you should see:** many rows. Near 0.5: precision about 0.78, recall about 0.67, false positive rate about 0.11. Near 0.3: precision about 0.67, recall about 0.80. Lowering the threshold finds more survivors and makes more false alarms.

Then open the charts BigQuery draws: **Explorer** → `ml` → **Models** → `titanic_transform` → **Evaluation**. Move the threshold slider and watch the numbers change. Because this model learned from every row it was given (`NO_SPLIT`), these charts are measured on its 1,048 training passengers, so they look a little better than step 10's numbers; they read the same way. (A model trained with BigQuery's automatic split, like part 1's, draws them on the rows it held aside.) How to read each chart:

| Chart | Across · up | What good looks like | The line to beat |
|---|---|---|---|
| Precision and recall by threshold | threshold · precision and recall | both high over a wide range of thresholds | none; choose the threshold where the trade suits the business |
| Precision-recall curve | recall · precision | the curve stays high as it moves right: towards the top right corner | a flat line at the share of positives (0.37 here, not 0.5) |
| ROC curve | false positive rate · recall | the curve rises steeply: towards the top left corner | the diagonal (ROC AUC 0.5, guessing) |

**ROC AUC** is the area under the ROC curve: the chance that a random survivor gets a higher probability than a random passenger who died. 1.0 is perfect; 0.5 is guessing.

### Step 12 · Which model is better?

Run step 11 again for `ml.titanic_sex_only`. It returns only a few rows: with one yes-or-no feature the model gives only two probabilities, so its curve is a few straight lines.

To compare two models by their charts:

1. **Same rows.** Both must be scored on the same passengers, as here. Charts from different rows cannot be compared.
2. **The curve that is higher everywhere wins.** On the ROC curve, higher and further left; on the precision-recall curve, higher and further right. The TRANSFORM model's curves lie above the sex-only model's almost everywhere.
3. **If the curves cross**, the better model depends on where you will set the threshold: compare them in that region (for example, the region where recall is above 0.8 if missing a survivor is costly).
4. **One number:** the area under each curve (ROC AUC, or the area under the precision-recall curve) sums the curve up. Use it to rank, then look at the charts before you decide.

**Think, and answer in Slack:** a rescue team would rather check ten people for nothing than miss one survivor. Which threshold region would you look at, and which model would you pick?

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 2 | women 466 · 339 · 0.727 · men 843 · 161 · 0.191 |
| 3 | 1 | accuracy about 0.78 · ROC AUC about 0.84 |
| 4 | 2 | about 0.95 and about 0.14 |
| 5 | 6 | first-class women about 0.88 · third-class men about 0.10 |
| 6 | 1 | 1,048 · 261 · 97 |
| 9 | 1 | false · about 0.04 |
| 10 | 2 | sex only: accuracy about 0.78, ROC AUC about 0.75 · TRANSFORM: about 0.81, about 0.85 |
| 11 | many | near 0.5: precision about 0.78, recall about 0.67 |

The model's numbers come from a check outside BigQuery with the same columns and the same filling of empty ages; yours will differ a little.

## If something goes wrong

- **`No matching signature` or a type error on `survived`:** the column arrived as text. Delete the table and upload again with **Auto detect** ticked; `survived` must be BOOLEAN.
- **Step 4 returns four rows:** the `WHERE p.label = TRUE` line is missing.
- **Step 8: `Unrecognized name` inside TRANSFORM:** every column TRANSFORM uses must be in the `SELECT` below it, and the label `survived` must be listed in TRANSFORM too.
- **Step 9 complains about a missing column:** pass the raw columns the `SELECT` in step 8 used (`pclass`, `sex`, `age`, `sibsp`, `parch`), not `is_child` or `family_size`.
- **Step 11 shows a precision of NULL:** at the highest thresholds nobody is flagged, so there is nothing to divide by (`SAFE_DIVIDE` returns NULL instead of an error). Ignore those rows.
- **Step 4 complains about a missing column:** the passengers you type in need all five features: `pclass`, `sex`, `age`, `sibsp`, `parch`.

## Hint

`pclass` is a number here, so the model treats class 3 as "more" than class 1 in one straight step. Would `CAST(pclass AS STRING)` change that? The bonus tries it.

## Bonus

Retrain with `SELECT * EXCEPT (passenger_id, pclass), CAST(pclass AS STRING) AS ticket_class FROM ml.titanic` and compare the accuracy. Then score yourself: which class would you have travelled in?

## References

Titanic passengers, compiled by Frank Harrell and Robert Dawson ([hbiostat.org](https://hbiostat.org/data/repo/titanic)), in the version `Titanicp` of the vcdExtra package for R (GPL-2 or GPL-3), from the [Rdatasets](https://github.com/vincentarelbundock/Rdatasets) collection; course copy in [`shared/datasets/ml_recap`](../../../../../shared/datasets/ml_recap/README.md), taken 27 October 2026. BigQuery ML: [CREATE MODEL for logistic regression](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm), [ML.EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate), [ML.PREDICT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-predict), [The TRANSFORM clause](https://docs.cloud.google.com/bigquery/docs/bigqueryml-transform), [ML.IMPUTER](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-imputer), [ML.ROC_CURVE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-roc), Google Cloud.
