# Many features, scored honestly: yearly medical charges

In this activity, you will train a model on six features of 1,338 insured people, hold 20% of them aside, score the model on those unseen people, compare it with a simple guess, and read what it learned.

**Data:** [`insurance.csv`](../../../../../shared/datasets/ml_classics/insurance.csv) → `ml.insurance` · **Starter:** `Unsolved/many_features.sql`

## The story

A health insurer prices next year's cover for each customer. It has 1,338 customers with this year's medical charges and six facts about each: age, sex, body mass index (BMI), number of children, whether they smoke, and their region. The question: *what will a customer's yearly medical charges be?*

The salary model had one feature and 30 rows, and it was scored on the same 30 rows it learned from. This time there are six features and enough rows to keep some aside. A model is only useful on people it has not seen, so that is where we score it.

## What you will learn

- To train with several features, including text columns.
- To hold rows aside with `data_split_method = 'RANDOM'` and score the model on them.
- To read MAE and R², and to compare the model with a guess that uses no features.
- To read the learned numbers, and to ask the model about new people.

## Before you start

You need the dataset `ml` from activity 02. Download [`insurance.csv`](../../../../../shared/datasets/ml_classics/insurance.csv) and upload it as the table `insurance` in `ml` (**⋮** → **Create table**, Upload, CSV, **Auto detect**).

## Steps

1. **Look at the data (block 1).** One row is one insured person. Then the average charges for smokers and non-smokers: about 32,050 dollars against 8,434. Before any model, you already know which feature will matter.

    Open the table's **Schema** tab. `sex`, `smoker` and `region` are text (STRING). BigQuery turns each text value into its own 0-or-1 column when it trains (**one-hot encoding**), so you do not have to. Lab 06 shows the other way, dummy encoding.

2. **Train, holding 20% aside (block 2).** Two options are new:

    - `data_split_method = 'RANDOM'` with `data_split_eval_fraction = 0.2`: BigQuery trains on about 80% of the rows and keeps about 20%, 268 people, aside for scoring.
    - Why say it at all? BigQuery's default holds rows aside only for tables of 500 rows or more. The salary table had 30, so its score in activity 02 was on the rows it learned from. Writing the split down makes it visible to whoever reads your SQL.

3. **Ask it about five people (block 3).** Most predictions are within a few thousand dollars; a few are far off. Two questions for the chat: is it any good, and how would we know?

4. **Score it on the rows held aside (block 4).** With no table given, `ML.EVALUATE` scores the 20% it held aside.

    | Column | Read it as |
    |---|---|
    | `mean_absolute_error` (MAE) | the average miss, in dollars, signs dropped |
    | `SQRT(mean_squared_error)` (RMSE) | the average miss in dollars, with big misses counting more (MSE itself is in dollars squared) |
    | `r2_score` (R²) | the share of the variation in charges the model explains, against guessing the average for everyone: 0 no better, 1 perfect |

    Expect an MAE of about 4,200 dollars, an RMSE of about 6,100 dollars and an R² of about 0.75. Your numbers can differ a little from your neighbour's. RMSE is above MAE because a few people are missed by a lot (about 1 in 11 by more than 10,000 dollars).

5. **The guess to beat (block 5).** A model must beat a guess that uses no features at all. The simplest: the average charges, about 13,270, for everyone. That guess misses people by about 9,091 dollars on average (its MAE; 13,270 is the guess, 9,091 its miss). The model's miss is less than half of the guess's. R² puts the comparison in one number, using squared misses: 1 − (model's RMSE ÷ guess's RMSE)² ≈ 1 − (6,100 ÷ 12,100)² ≈ 0.75. The model explains about three-quarters of why charges differ from person to person.

6. **Seen rows against unseen rows (block 6).** The same model scored on all 1,338 rows, most of which it trained on. If the two scores are close, the model learned a pattern. If it were far better on the rows it saw, it would have memorised them: **overfitting**. Here: about 0.75 against 0.75.

7. **Read the learned numbers (block 7).** `age` about 257 dollars a year; `bmi` about 339 per point; `children` about 476 per child. `smoker` has no single weight: it is text, so its weights are in `category_weights`, one per value, and *yes* sits about 23,800 dollars above *no*. In words: *the same person costs about 23,800 dollars more a year as a smoker.* A weight shows what the model learned from these rows. It does not prove cause.

8. **Ask about two new people (block 8).** Two 40-year-old women with the same BMI and one child, one a smoker. Every feature the model was trained on must be in the `SELECT`. About 7,960 and about 31,810.

## Check yourself

| Block | Rows returned | One value to check |
|---|---:|---|
| 1 | 2 | smokers 274, ≈ 32,050 · non-smokers 1,064, ≈ 8,434 |
| 4 | 1 | MAE ≈ 4,200 (3,900 to 4,550) · RMSE ≈ 6,100 (5,650 to 6,600) · R² ≈ 0.75 (0.70 to 0.79) |
| 5 | 1 | the guess is 13,270; its average miss (MAE) ≈ 9,091 |
| 6 | 2 | both R² ≈ 0.75 |
| 8 | 2 | non-smoker ≈ 7,960 · smoker ≈ 31,810 |

The ranges come from repeating a random 80/20 split many times on the course file: your split is one of them.

## If something goes wrong

- **`smoker` shows as BOOLEAN in the schema:** in block 8, write `FALSE` and `TRUE` instead of `'no'` and `'yes'`. Everything else works as written.
- **`Invalid table-valued function ML.PREDICT ... column ... not found`:** block 8 must list all six features with the same names and types as the training data.
- **Your R² is close to 1.0:** check that `charges` is not also listed as a feature.

## Bonus

Some predictions in block 3 can be below zero for young, slim non-smokers. Can charges be negative? A straight line does not know that charges stop at zero. Find them: `ML.PREDICT` on all rows, `WHERE predicted_charges < 0`.

## References

Medical Cost Personal Datasets (Kaggle, `mirichoi0218/insurance`), from Brett Lantz, *Machine Learning with R* (Packt, 2013), simulated from US demographic statistics; course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md), taken 18 October 2026. BigQuery ML: [ML.EVALUATE](https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate), [ML.WEIGHTS](https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-weights), Google Cloud.
