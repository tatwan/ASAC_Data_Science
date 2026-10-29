# A forest and boosted trees, on the same rows

In this activity, you will train a random forest, put every model of the day side by side on the same validation people, compare each with its score on the rows it learned from, and read which columns the boosted trees used.

**Time:** about 22 minutes in class, following along · **Data:** `ml.insurance_groups`, `ml.ins_linear` and `ml.ins_boosted` (activity 01), `ml.ins_tree3` and `ml.ins_tree15` (activity 03) · **Starter:** `Unsolved/forest_and_boosted.sql`

## The story

One deep tree memorised its training rows; one shallow tree was readable but coarse, eight answers for everyone. Two ideas use many trees instead of one. A **random forest** grows many deep trees, each on a different random sample of the rows, and averages them. **Boosting** grows small trees one after another, each fixing what the trees before it still get wrong. The pricing team wants to know whether either beats the single trees and the line, on people none of them has seen.

## What you will learn

- To train a `RANDOM_FOREST_REGRESSOR` and read its four main settings.
- To compare five models on the same rows in one table, and to read the gap between training and validation scores.
- To read `ML.FEATURE_IMPORTANCE`: how often a column was used against how much it helped.

## Before you start

You need `ml.insurance_groups`, `ml.ins_linear` and `ml.ins_boosted` from [activity 01](../01-Evr-Same-Rows-Two-Models/README.md) and `ml.ins_tree3` and `ml.ins_tree15` from [activity 03](../03-Evr-One-Tree-Too-Deep/README.md). Run those first if any is missing.

## Steps

1. **A random forest (block 1).** The four settings are BigQuery's defaults, written out so you can read them:

    | Option | Default | What it does |
    |---|---|---|
    | `num_parallel_tree` | 100 | how many trees; their predictions are averaged |
    | `max_tree_depth` | 15 | each tree may grow deep; averaging many of them keeps them in check |
    | `subsample` | 0.8 | each tree learns from a random 80% of the training rows, each row at most once |
    | `colsample_bynode` | 0.8 | at every question, each tree chooses among a random 80% of the columns |

    The two random draws make the trees differ from one another. A tree that memorises an odd person is outvoted by trees that never saw that person. (The slides' bootstrap draws rows *with* replacement; BigQuery's forest draws 80% *without* replacement. The idea is the same: every tree learns from different rows.)

2. **Every model, the same 268 people (block 2).** Sorted by R², best first. Before you run it, predict the order.

3. **The same models, on their training rows (block 3).** Compare each training R² with its validation R² from block 2. The bigger the drop, the more the model memorised its own rows.

4. **Which columns did the boosted trees use? (block 4).** `ML.FEATURE_IMPORTANCE` works only for tree models.

    | Column | Read it as |
    |---|---|
    | `importance_weight` | how many questions, across all the trees, used this column |
    | `importance_gain` | how much those questions lowered the miss, on average per question |
    | `share_of_gain` | weight × gain, the column's total gain, as a share of all columns' total, computed with `SUM(…) OVER ()` (D10) |

    Look at `smoker`: about 20 questions, about two thirds of all the gain. One question about smoking does more than hundreds of small questions about BMI and age. Importance says what the model leaned on; it does not say what *causes* the charges.

## Check yourself

| Block | Rows returned | One value to check |
|---|---:|---|
| 2 | 5 | random forest R² ≈ 0.84, MAE ≈ 2,570 · boosted ≈ 0.83, MAE ≈ 2,630 · depth 3 ≈ 0.84 · linear 0.74 · depth 15 ≈ 0.73 |
| 3 | 5 | depth 15: 1.00 · boosted ≈ 0.97 · forest ≈ 0.89 · depth 3 ≈ 0.87 · linear 0.76 |
| 4 | 6 | `smoker` first, about 0.68 of the gain from about 20 questions · `bmi` about 0.18 from about 320 · `age` about 0.11 from about 280 |

Computed outside BigQuery with the same settings. The forest is random, so your forest numbers can differ by about 0.01 from your neighbour's. The order of the top three can change: their scores are within about 0.01 of each other.

**What it means.** Three models land close together, near 0.84: the forest, the boosted trees and the shallow tree. All three beat the line by about 0.10. The gaps in block 3 say how they got there: the boosted trees learned their training rows almost perfectly (0.97) and lose more on unseen people than the forest does (0.89 → 0.84). None of the tree models beats the others clearly on 268 people. After the break, a straight line with one better feature reaches the same score and a little more.

## If something goes wrong

- **The models are still training, or `CREATE MODEL` stopped with an error:** use the fallback file (activity 01): its `pred_forest` and `pred_boosted` columns, scored with the query in the [Resources README](../Resources/README.md).
- **`ML.FEATURE_IMPORTANCE` fails on `ml.ins_linear`:** it works only for boosted trees and random forests. A line's equivalent is `ML.WEIGHTS` (D11).
- **Block 2 lists fewer than five rows:** one of the models is missing; train it again from activity 01 or 03.
- **`ML.FEATURE_IMPORTANCE` shows 0 for `smoker`: check how BigQuery read your columns.** `ML.FEATURE_INFO` lists what a model was given, one row per input column:

    ```sql
    SELECT input, min, max, category_count, null_count
    FROM ML.FEATURE_INFO(MODEL ml.ins_forest);
    ```

    Google's page says `min` and `max` are NULL "for non-numeric inputs" and `category_count` is NULL "for non-categorical columns"; it does not say how a BOOLEAN column is shown. Read the `smoker` row, then the table's **Schema** tab. If `smoker` is BOOLEAN there, this was seen in a sandbox on 19 October 2026: a random forest trained through the console on an insurance table with `smoker` as BOOLEAN reported 0 importance for `smoker`, while its loss on the rows held aside (about 4,820) was what a forest that uses `smoker` reaches. Google's pages do not explain it. To avoid it, train on text: in the model's `SELECT`, write `CAST(smoker AS STRING) AS smoker` in place of `smoker`, and pass the same column to `ML.EVALUATE` and `ML.PREDICT`, for example `(SELECT * REPLACE (CAST(smoker AS STRING) AS smoker) FROM ml.insurance_groups WHERE split = 'validation')`. The categories are then `true` and `false` instead of `yes` and `no`.

## Bonus

Run block 4 on `ml.ins_forest`. Does the forest lean on the same columns? (Its trees choose among a random 80% of the columns at each question, so they are forced to try `bmi` and `age` more often.)

## References

BigQuery ML: [CREATE MODEL for random forests](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-random-forest), [ML.FEATURE_IMPORTANCE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-importance), [ML.FEATURE_INFO](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-feature), Google Cloud. Data as in activity 01.
