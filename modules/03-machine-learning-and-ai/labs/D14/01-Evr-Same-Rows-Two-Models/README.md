# The same rows for every model, and two models on them

In this activity, you will split the 1,338 insured people into three fixed groups, train D11's linear model and a prepared boosted-trees model on the same training rows, and score both on the same validation rows.

**Time:** about 30 minutes in class, following along · **Data:** `ml.insurance` (D11) → the view `ml.insurance_groups` · **Starter:** `Unsolved/same_rows_two_models.sql`

## The story

On D11 you predicted each insured person's yearly medical charges from six facts about them. The model missed by about 4,200 dollars on average. The insurer's pricing team asks two questions: *can we do better, and how would we know?*

The second question comes first. To say one model is better than another, both must be scored on the **same** people, chosen before either model is trained. Today every model is trained on one group and scored on another, and the groups never change.

## What you will learn

- Why a fair comparison needs the same rows for every model, and how to fix them in a view.
- To train with `data_split_method = 'NO_SPLIT'` when you chose the rows yourself.
- To train a `BOOSTED_TREE_REGRESSOR` and score it beside a `LINEAR_REG` in one table.

## Before you start

You need the table `ml.insurance` from D11 activity 03. Check: `SELECT COUNT(*) FROM ml.insurance;` returns 1,338. If the table is missing, download [`insurance.csv`](../../../../../shared/datasets/ml_classics/insurance.csv) and upload it as `insurance` in the `ml` dataset (**⋮** → **Create table**, Upload, CSV, **Auto detect**). If `ml` is missing too: `CREATE SCHEMA IF NOT EXISTS ml OPTIONS (location = 'US');`

## Steps

1. **Fix the groups (block 1).** On D11, `data_split_method = 'RANDOM'` held 20% aside. Google's page says that random split is worked out from the data *including its column names*, so a model with different columns can hold aside different people. Two models scored on different people cannot be compared fairly.

    The view numbers the people in order of their charges with `ROW_NUMBER()` (D10) and deals them out like cards: `MOD(…, 5)` is the remainder after dividing by 5, so it runs 1, 2, 3, 4, 0, 1, 2 … Remainder 3 goes to **validation**, 4 to **test**, the rest to **training**. Because the order is fixed, everyone in the class gets the same three groups, every time.

    | Group | Used for |
    |---|---|
    | training | the rows every model learns from |
    | validation | comparing models and choosing one |
    | test | one final score, once, for the model we choose after comparing |

2. **Check the deal (block 2).** Dealing in order of charges spreads cheap and expensive people across all three groups, so their averages are close.

3. **D11's model, on the training rows (block 3).** The same six features as D11. Two changes: `WHERE split = 'train'`, and `data_split_method = 'NO_SPLIT'`, which tells BigQuery not to hold any more rows aside: we already did.

4. **A prepared boosted-trees model (block 4).** Read it before you run it: the `SELECT` and the `WHERE` are the same as block 3. Only `model_type` changes, to `'BOOSTED_TREE_REGRESSOR'`, with every other setting left at Google's default. What boosted trees are comes later in class; for now it is a different way to learn from the same rows.

    Trees take much longer to train than the line: in a sandbox, 10 to 15 minutes or more (a random forest on this table took about 15). Start block 4 and read on while it trains. If it stops with an error, or has not finished when you need it, follow **If CREATE MODEL fails** below and you will score the same model from a prepared file.

5. **Both models, one table (block 5).** `ML.EVALUATE` with a `SELECT` scores the rows you pass: here the 268 validation people, for both models. `UNION ALL` (D07) stacks the two results.

    | Column | Read it as |
    |---|---|
    | `mae` | the average miss in dollars |
    | `rmse` | the average miss with big misses counting more |
    | `r2` | the share of the variation in charges the model explains: 0 no better than the average, 1 perfect |

6. **The guess to beat (block 6).** The training average, about 13,267 dollars, for everyone. Its average miss on the validation people is the bar both models must clear.

## Check yourself

| Block | Rows returned | One value to check |
|---|---:|---|
| 2 | 3 | training 803 people, average ≈ 13,267, 171 smokers · validation 268, ≈ 13,346, 53 · test 267, ≈ 13,204, 50 |
| 5 | 2 | linear: MAE ≈ 4,241, R² ≈ 0.74 · boosted trees: MAE ≈ 2,630 (2,500 to 2,800), R² ≈ 0.83 (0.82 to 0.85) |
| 6 | 1 + 1 | guess 13,267 · its MAE ≈ 9,153 |

The linear numbers are exact for these rows. The boosted-trees numbers were computed outside BigQuery with Google's default settings and can differ a little from yours.

**What it means.** On the same 268 people, the boosted trees miss by about 1,600 dollars less on average than the line, and the line misses by less than half as much as the guess. In class, one tree drawn on these training people shows where the trees' advantage comes from.

## If something goes wrong

- **`Not found: Table ml.insurance`:** see Before you start.
- **`smoker` is BOOLEAN** (Auto detect reads the file's yes/no as true/false), so block 2 counts smokers with `smoker = TRUE`. If your schema shows `smoker` as STRING, you uploaded without Auto detect: write `smoker = 'yes'` instead.
- **Your counts are not 803, 268 and 267:** check that block 1 reads `ORDER BY charges` and that the table has 1,338 rows.
- **Your linear R² is close to 1.0:** check that `charges` is not also listed as a feature.

### If CREATE MODEL fails

Download [`d14_insurance_predictions.csv`](../Resources/fallback/d14_insurance_predictions.csv) and upload it as `d14_predictions` in `ml`. It holds every person with their group and the predictions each of today's models makes (computed outside BigQuery with the same settings). The [Resources README](../Resources/README.md) has the query that scores them, in plain SQL.

## Bonus

The boosted model never predicts a negative charge; D11's line did for some young, slim non-smokers. Check it: `SELECT COUNTIF(predicted_charges < 0) FROM ML.PREDICT(MODEL ml.ins_linear, (SELECT * FROM ml.insurance_groups))`, then the same for `ml.ins_boosted`: about 23 of the 1,338 people for the line, none for the trees. A line keeps going down as age and BMI go down; a tree's prediction is built from averages of real charges, so it stays above zero here.

## References

Medical Cost Personal Datasets (Kaggle, `mirichoi0218/insurance`), from Brett Lantz, *Machine Learning with R* (Packt, 2013); course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md), taken 18 October 2026. BigQuery ML: [CREATE MODEL for boosted trees](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-boosted-tree) (the split options and their defaults), [ML.EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate), Google Cloud.
