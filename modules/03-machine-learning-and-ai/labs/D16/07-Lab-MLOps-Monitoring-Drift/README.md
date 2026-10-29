# Lab 07 · Watching a model after it ships: skew and drift

In this self-guided lab, you will describe the diamonds table, check whether a new batch of diamonds looks like the rows the price model learned from, see how much worse the model does on a batch that does not, and run Google's "stop when the data has changed" script by hand.

**When:** after class, at your own pace. Not submitted. · **Data:** `ml.diamonds` and `ml.titanic` (activities 01 and 02); `ml.diamonds_groups` and `ml.diamond_price_v1` (lab 06, or step 1 here) → `ml.batch_normal`, `ml.batch_big_stones`, `ml.diamonds_new_batch`, `ml.diamonds_new_batch_scored` · **SQL:** `Unsolved/mlops_monitoring_drift.sql` to run step by step, `Solved/mlops_monitoring_drift.sql`

## The story

The jeweller's price model learned from 32,364 diamonds, most of them under one carat. Then the jeweller opens a second shop that deals mainly in large stones, and its diamonds start arriving in the same table. Nothing breaks: `ML.PREDICT` returns a price for every stone, the view serves them, the report refreshes. The question is whether those prices are still any good, and how you would find out before a customer does.

A model is only as good as the match between the rows it learned from and the rows it is asked about. This lab measures that match with BigQuery ML's monitoring functions. Google's pages say they are billed like ordinary queries; the sandbox page does not list them, so they should run there.

Two words from Google's model monitoring page:

- **Data skew:** "Data skew occurs when the distribution of feature values for training data is significantly different from serving data in production." *Serving data* is the rows you ask the model to predict.
- **Data drift:** "Data drift occurs when feature data distribution in production changes significantly over time." Drift compares two batches of serving data with each other.

## What you will learn

- To summarise every column of a table with `ML.DESCRIBE_DATA`.
- To compare a batch with the model's training data with `ML.VALIDATE_DATA_SKEW`, and to read its output: `input`, `metric`, `threshold`, `value`, `is_anomaly`.
- To compare two batches with each other with `ML.VALIDATE_DATA_DRIFT`, which needs no model.
- To check whether a flagged batch actually costs accuracy, with `ML.EVALUATE`.
- To write a script with `DECLARE`, `IF … THEN … ELSE … END IF` and `ERROR()` that refuses to score a skewed batch, and what scheduling it would need.

## Before you start

You need `ml.diamonds` and `ml.titanic`, uploaded in "Before you start" of [activity 01](../01-Evr-Diamond-Prices/README.md) and [activity 02](../02-Evr-Titanic-Survival/README.md). Check: `SELECT COUNT(*) FROM ml.diamonds;` returns 53,940 and `SELECT COUNT(*) FROM ml.titanic;` returns 1,309. If either is missing, upload it as those activities show (the files are in [`shared/datasets/ml_recap`](../../../../../shared/datasets/ml_recap/README.md)).

This lab watches `ml.diamond_price_v1`, the plain linear model from [lab 06](../06-Lab-MLOps-Versions-And-Promotion/README.md). It uses version 1 because its label is the price in dollars, so `ML.EVALUATE` reports its errors in dollars. If you have not done lab 06, step 1 creates the groups and the model; if you have, step 1 changes nothing.

Work like the other labs: read the step, run its SQL, compare with **What you should see**, and answer **Think** in one line. Google's monitoring pages say each of these functions "uses BigQuery on-demand compute pricing", the same as an ordinary query; on tables this size that is a tiny share of the sandbox's free monthly allowance. The MAE values marked "about" were computed outside BigQuery with the same rows; the counts are exact. The skew and drift values themselves were not computed outside BigQuery, so the steps tell you which rows to look at instead of a number to match.

## Checkpoints

- **C1:** the description of `ml.diamonds`, and a skew check on ordinary validation diamonds with no column flagged (steps 2 and 4).
- **C2:** the big-stone batch with its flagged columns, and the model's MAE on it beside its MAE on ordinary rows (steps 5 and 6).
- **C3:** the monitoring script, run by hand on both batches: one run that scores, one that stops with your message (step 8).

## Step 1 · The groups and version 1, if you do not have them

```sql
CREATE VIEW IF NOT EXISTS ml.diamonds_groups AS
SELECT *,
       CASE MOD(diamond_id, 5)
         WHEN 0 THEN 'test'
         WHEN 1 THEN 'validation'
         ELSE 'train'
       END AS split
FROM ml.diamonds;

CREATE MODEL IF NOT EXISTS ml.diamond_price_v1
OPTIONS (model_type = 'LINEAR_REG',
         input_label_cols = ['price'],
         data_split_method = 'NO_SPLIT') AS
SELECT * EXCEPT (diamond_id, split)
FROM ml.diamonds_groups
WHERE split = 'train';
```

`IF NOT EXISTS` creates the view and the model only when they are missing; if lab 06 made them, both statements leave them alone. Lab 06, steps 1 and 2, explains the groups and the model.

**What you should see:** both statements succeed, and `ml` has the view `diamonds_groups` and the model `diamond_price_v1`.

## Step 2 · Describe the table (C1, part 1)

```sql
SELECT *
FROM ML.DESCRIBE_DATA(TABLE ml.diamonds,
                      STRUCT(4 AS num_quantiles, 3 AS top_k));
```

`ML.DESCRIBE_DATA` returns "one row for each column in the input data", with descriptive statistics for each. It takes a table or a query and no model. Two arguments are set here: `num_quantiles` (default 2) sets how many quantiles are computed for each number column, and `top_k` (default 1) how many of the most common values are listed for each column. The columns to read first:

| Column | Read it as |
|---|---|
| `name` | the column described on this row |
| `num_rows`, `num_nulls`, `num_zeros` | how many rows, how many empty, how many exactly zero |
| `min`, `max`, `mean`, `stdev`, `median` | the usual summaries, for number columns |
| `quantiles` | the quantiles of a number column: values that split the sorted column into equal parts |
| `unique` | how many different values |
| `top_values` | the most common values and how often each appears |

**What you should see:** 11 rows, one per column of `ml.diamonds`. Every `num_rows` is 53,940 and no column has empty values. `carat` runs from 0.2 to 5.01 with a mean of about 0.798. `length_mm` has 8 zeros, `width_mm` 7 and `height_mm` 20: the recording errors the dataset README warns about. `cut` has 5 different values, `color` 7, `clarity` 8; the most common are Ideal, G and SI1.

**C1, part 1:** the 11 rows. Which column would you check first if someone said "the new shop's diamonds look different"?

## Step 3 · Two batches to check

```sql
CREATE OR REPLACE VIEW ml.batch_normal AS
SELECT * EXCEPT (split)
FROM ml.diamonds_groups
WHERE split = 'validation';

CREATE OR REPLACE VIEW ml.batch_big_stones AS
SELECT * EXCEPT (split)
FROM ml.diamonds_groups
WHERE split = 'validation' AND carat >= 1.5;

SELECT 'normal' AS batch, COUNT(*) AS diamond_count, ROUND(AVG(carat), 2) AS average_carat,
       ROUND(AVG(price), 1) AS average_price
FROM ml.batch_normal
UNION ALL
SELECT 'big stones', COUNT(*), ROUND(AVG(carat), 2), ROUND(AVG(price), 1)
FROM ml.batch_big_stones;
```

The second shop's diamonds are not in the table, so the lab stands in for them with real diamonds the model never learned from: the validation diamonds of 1.5 carats or more. The first view is an ordinary batch, every validation diamond.

**What you should see:** 2 rows. Normal: 10,788 diamonds, average 0.8 carats, 3,932.1 dollars. Big stones: 1,243 diamonds, average 1.77 carats, 12,351.3 dollars. Among the training diamonds, only about 12 in 100 weigh 1.5 carats or more.

## Step 4 · Skew on an ordinary batch (C1, part 2)

```sql
SELECT input, metric, threshold, ROUND(value, 3) AS value, is_anomaly
FROM ML.VALIDATE_DATA_SKEW(MODEL ml.diamond_price_v1,
       (SELECT carat, cut, color, clarity, depth_pct, table_pct,
               length_mm, width_mm, height_mm
        FROM ml.batch_normal),
       STRUCT(0.3 AS categorical_default_threshold,
              0.3 AS numerical_default_threshold))
ORDER BY input;
```

`ML.VALIDATE_DATA_SKEW` compares the batch with statistics BigQuery saved when it trained the model. Google's page: "Training statistics for the model are saved during model training, so the original training data isn't required for you to use skew detection." The query passes the nine feature columns, the columns a new diamond would arrive with; the price is not known yet when a stone needs pricing.

For each column, the function measures how far apart the two distributions are and compares that with a threshold. Both thresholds are written out here at their default, 0.3.

| Column | Read it as |
|---|---|
| `input` | the column checked |
| `metric` | how the distance was measured: `L_INFTY` for text columns (the largest gap between the two shares of any one value), `JENSEN_SHANNON_DIVERGENCE` for number columns (0 for identical distributions, larger as they separate) |
| `threshold` | the distance above which the column counts as skewed |
| `value` | the distance measured |
| `is_anomaly` | TRUE when `value` is above `threshold` |

**What you should see:** 9 rows, one per column, and `is_anomaly` FALSE on every row. The validation diamonds were dealt out like the training diamonds, so they look the same. Worked out from the table, the largest gap in shares for `cut`, `color` and `clarity` is under 0.01 for each.

**C1, part 2:** the 9 rows, all FALSE.

## Step 5 · Skew on the big-stone batch (C2, part 1)

```sql
SELECT input, metric, threshold, ROUND(value, 3) AS value, is_anomaly
FROM ML.VALIDATE_DATA_SKEW(MODEL ml.diamond_price_v1,
       (SELECT carat, cut, color, clarity, depth_pct, table_pct,
               length_mm, width_mm, height_mm
        FROM ml.batch_big_stones),
       STRUCT(0.3 AS categorical_default_threshold,
              0.3 AS numerical_default_threshold))
ORDER BY is_anomaly DESC, value DESC;
```

The same check, on the second shop's stones.

**What you should see:** 9 rows. `carat`, `length_mm`, `width_mm` and `height_mm` should come first with `is_anomaly` TRUE: the big stones' average size is 7.7 × 7.7 × 4.8 mm against 5.7 × 5.7 × 3.5 mm in training. The text columns move less. Worked out from the table, the largest gaps in shares are about 0.14 for `cut` (fewer Ideal), 0.10 for `color` (more I) and 0.14 for `clarity` (more SI2), all below 0.3, so expect FALSE for those three. `depth_pct` and `table_pct` barely change on average (61.8 and 58.1 against 61.75 and 57.46 in training); check whether BigQuery flags them.

**Think:** the skew check found the change without knowing a single price from the new shop. Why does that matter for a shop whose stones have not sold yet?

## Step 6 · Does the skew cost accuracy? (C2, part 2)

```sql
SELECT 'normal' AS batch, ROUND(mean_absolute_error, 1) AS mae
FROM ML.EVALUATE(MODEL ml.diamond_price_v1,
       (SELECT * EXCEPT (diamond_id) FROM ml.batch_normal))
UNION ALL
SELECT 'big stones', ROUND(mean_absolute_error, 1)
FROM ML.EVALUATE(MODEL ml.diamond_price_v1,
       (SELECT * EXCEPT (diamond_id) FROM ml.batch_big_stones));
```

`ML.EVALUATE` with a query scores the rows you pass, and needs the label (`price`) in them. This is the check you can only run once the prices are known, weeks after the stones arrive.

**What you should see:** 2 rows. Normal: about 742 dollars. Big stones: about 1,764 dollars, more than twice as far off. Part of that is size: the big stones cost about three times as much on average, so the same share of a price is more dollars. Even so, the model learned mostly from small stones, and a straight line that fits them cannot follow prices that climb faster and faster as stones get bigger.

**C2:** the flagged columns from step 5 and the two MAEs. One sentence: what would you tell the jeweller before the second shop's prices go on the report?

## Step 7 · Drift: two batches, no model

```sql
SELECT input, metric, threshold, ROUND(value, 3) AS value, is_anomaly
FROM ML.VALIDATE_DATA_DRIFT(
       (SELECT carat, cut, color, clarity, depth_pct, table_pct,
               length_mm, width_mm, height_mm
        FROM ml.batch_normal),
       (SELECT carat, cut, color, clarity, depth_pct, table_pct,
               length_mm, width_mm, height_mm
        FROM ml.batch_big_stones),
       STRUCT(0.3 AS categorical_default_threshold,
              0.3 AS numerical_default_threshold))
ORDER BY is_anomaly DESC, value DESC;
```

`ML.VALIDATE_DATA_DRIFT` takes a *base* batch first and a *study* batch second, and compares them column by column with the same metrics and output columns as step 4. It needs no model, so it works for any two sets of rows: last month's orders against this month's, one shop against another. Google's page gives the typical use: "you might want to compare the current serving data to historical serving data from a table snapshot".

**What you should see:** 9 rows. The size columns may be flagged as in step 5, but not certainly: the ordinary batch includes one diamond recorded as 31.8 mm high, which stretches the range BigQuery compares, so read `value` beside `threshold` rather than only `is_anomaly`. Here the base is the ordinary batch, not the training rows, so the values differ from step 5's.

Now a drift check on another table, the Titanic passengers: first class as the base, third class as the study.

```sql
SELECT input, metric, threshold, ROUND(value, 3) AS value, is_anomaly
FROM ML.VALIDATE_DATA_DRIFT(
       (SELECT sex, age, sibsp, parch FROM ml.titanic WHERE pclass = 1),
       (SELECT sex, age, sibsp, parch FROM ml.titanic WHERE pclass = 3),
       STRUCT(0.3 AS categorical_default_threshold,
              0.3 AS numerical_default_threshold))
ORDER BY input;
```

**What you should see:** 4 rows. From the table: 44.6% of the 323 first-class passengers were women against 30.5% of the 709 in third class, a gap of 0.14, so `sex` stays FALSE. First-class passengers were older (39.2 years on average against 24.8), so `age` differs most, but it may stay under the 0.3 threshold. Read `value` for each row: a column can be close to the threshold without crossing it.

**Think:** the Titanic model from activity 02 was trained on all three classes. If a shipping company used it only for third-class passengers, would a skew check on its training data find the same columns as this drift check?

## Step 8 · Stop when the data has changed: the script, by hand (C3)

Google's `ML.VALIDATE_DATA_SKEW` page ends with an example called "Automate skew detection": a script that runs the skew check and, when it finds an anomaly, retrains the model and stops with an error; otherwise it predicts. The script below follows the same pattern, with one change: when it finds skew it does not retrain, it refuses to score the batch and says why. Retraining on one batch of big stones would teach the model about big stones only; that decision belongs to a person.

The batch arrives in one place, the view `ml.diamonds_new_batch`. First, an ordinary batch:

```sql
CREATE OR REPLACE VIEW ml.diamonds_new_batch AS
SELECT * FROM ml.batch_normal;
```

Then the script. Run it all at once: select all of it, or open it on its own in a new query tab, and click **Run**.

```sql
-- A script: select from DECLARE down to END IF; and run it all at once, not line by line.
DECLARE skewed_columns STRING;

SET skewed_columns = (
  SELECT STRING_AGG(input, ', ' ORDER BY input)
  FROM ML.VALIDATE_DATA_SKEW(MODEL ml.diamond_price_v1,
         (SELECT carat, cut, color, clarity, depth_pct, table_pct,
                 length_mm, width_mm, height_mm
          FROM ml.diamonds_new_batch),
         STRUCT(0.3 AS categorical_default_threshold,
                0.3 AS numerical_default_threshold))
  WHERE is_anomaly
);

IF skewed_columns IS NOT NULL THEN
  SELECT ERROR(CONCAT('Data skew in: ', skewed_columns,
                      '. The batch was not scored. Check the new diamonds before using the model on them.'));
ELSE
  CREATE OR REPLACE TABLE ml.diamonds_new_batch_scored AS
  SELECT diamond_id, carat, cut, color, clarity,
         ROUND(predicted_price) AS predicted_price
  FROM ML.PREDICT(MODEL ml.diamond_price_v1, TABLE ml.diamonds_new_batch);
END IF;
```

Read it from the top:

- `DECLARE` makes a variable, `skewed_columns`, that holds text. A script declares its variables first.
- `SET` fills it with the names of the flagged columns, joined with commas by `STRING_AGG`. When no column is flagged, there are no rows to join and the variable stays empty (`NULL`).
- `IF … THEN … ELSE … END IF` takes one branch. With skew, `ERROR()` stops the script with your message, the way a failed query stops. Without skew, the batch is scored and saved as a table.

**What you should see:** the script runs a few statements; the last one creates `ml.diamonds_new_batch_scored`. `SELECT COUNT(*) FROM ml.diamonds_new_batch_scored;` returns 10,788.

Now the second shop's batch arrives in the same place:

```sql
CREATE OR REPLACE VIEW ml.diamonds_new_batch AS
SELECT * FROM ml.batch_big_stones;
```

Run the script again, unchanged.

**What you should see:** the script stops with an error that starts `Data skew in:` and lists the flagged columns from step 5 (`carat`, `height_mm`, `length_mm`, `width_mm`, and any others BigQuery flagged). `ml.diamonds_new_batch_scored` still holds the 10,788 rows from the first run: nothing was overwritten.

**C3:** the error message from the second run, and one sentence: why is a run that stops with an error better here than a run that quietly scores the batch?

## Step 9 · Running it on a schedule (read only)

In a company, nobody runs step 8 by hand. Google's pages describe the next step:

- ML pipelines overview: "After creating a multi-statement query, you can save and schedule the query to automate model training, inference, and monitoring."
- Model monitoring overview: "You can automate monitoring by using a scheduled query to run the monitoring function, evaluate the output, and retrain the model if anomalies are detected. You must enable email notifications as part of setting up the scheduled query."

So the script from step 8 would become a scheduled query, run every night or every week, and the error from `ERROR()` would arrive as an email. Google's page on scheduled queries says the shortest gap between runs is 5 minutes and that "Scheduled queries are priced the same as manual BigQuery queries."

The sandbox cannot do this. Scheduled queries "use features of BigQuery Data Transfer Service", and the sandbox page lists the BigQuery Data Transfer Service among the features the sandbox does not support. Google's page on enabling that service adds that you must, "in most cases, enable billing on that project". In this course you run the script by hand, which is the same SQL.

Two more limits worth knowing:

- `ML.VALIDATE_DATA_SKEW` does not support ARIMA_PLUS or matrix factorization models (Google's page lists both), so the births forecast and lab 09's recommender cannot be checked this way. `ML.VALIDATE_DATA_DRIFT` needs no model, so it can still compare their input data month by month.
- Both functions can return a `visualization_link` column with charts of each distribution, but only for a model registered in Google's Agent Platform (formerly Vertex AI; lab 08 describes it). Without registration, asking for the link returns an error.

## What you saw

| Check | Batch | Columns flagged | MAE (dollars) |
|---|---|---|---:|
| skew | normal | | |
| skew | big stones | | |
| drift | normal against big stones | | not measured |
| drift | Titanic first against third class | | not measured |
| evaluate | normal | not measured | |
| evaluate | big stones | not measured | |

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 2 | 11 | `num_rows` **53,940** · zeros: `length_mm` **8**, `width_mm` **7**, `height_mm` **20** |
| 3 | 2 | normal **10,788** diamonds, **0.8** carats · big stones **1,243**, **1.77** carats |
| 4 | 9 | `is_anomaly` FALSE on every row |
| 5 | 9 | `carat` very likely TRUE; size columns may be |
| 6 | 2 | normal about **742** · big stones about **1,764** |
| 8 | 1 table, then an error | **10,788** rows scored · an error starting `Data skew in:` |

## Hint

If step 4 or 5 says a column is missing, the model was trained on different columns: run step 1, and check that `ml.diamond_price_v1` was trained with `SELECT * EXCEPT (diamond_id, split)`. If the script in step 8 says a variable is declared in the wrong place, run the script on its own: `DECLARE` must come before every other statement.

## Bonus

- Lower `numerical_default_threshold` to 0.1 in step 4. Does the ordinary batch now have anomalies? What does that tell you about choosing a threshold?
- `THRESHOLDS` sets a threshold per column. Google's page lists it among the arguments of `ML.VALIDATE_DATA_SKEW`; find its format on the page, and give `carat` a stricter threshold than the others.
- Run step 5 with `MODEL ml.diamond_price_v2` (lab 06). The flagged columns are the same; why? Then score version 2 on the big stones in dollars with lab 06's step 4 query and `ml.batch_big_stones`. (Computed outside BigQuery: about 1,807 dollars, against about 320 on the validation diamonds under 1.5 carats.)

## References

Diamonds: the `diamonds` data in the ggplot2 package for R ([`tidyverse/ggplot2`](https://github.com/tidyverse/ggplot2)), MIT licence. Titanic passengers, compiled by Frank Harrell and Robert Dawson ([hbiostat.org](https://hbiostat.org/data/repo/titanic)), as `Titanicp` in the vcdExtra package from the [Rdatasets](https://github.com/vincentarelbundock/Rdatasets) collection, GPL-2 or GPL-3. Course copies in [`shared/datasets/ml_recap`](../../../../../shared/datasets/ml_recap/README.md), taken 27 October 2026. BigQuery ML: [Model monitoring overview](https://docs.cloud.google.com/bigquery/docs/model-monitoring-overview) (skew and drift), [ML.DESCRIBE_DATA](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-describe-data), [ML.VALIDATE_DATA_SKEW](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-validate-data-skew) ("Automate skew detection"), [ML.VALIDATE_DATA_DRIFT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-validate-data-drift), [ML.EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate), [ML pipelines overview](https://docs.cloud.google.com/bigquery/docs/ml-pipelines-overview), [Scheduling queries](https://docs.cloud.google.com/bigquery/docs/scheduling-queries), [Enable the BigQuery Data Transfer Service](https://docs.cloud.google.com/bigquery/docs/enable-transfer-service), [Try BigQuery using the sandbox](https://docs.cloud.google.com/bigquery/docs/sandbox), Google Cloud. Pages read 27 October 2026.
