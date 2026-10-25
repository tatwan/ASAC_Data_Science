# Better features for the line

In this activity, you will turn the pattern the trees found into two new columns, give them to D11's straight line, and see whether a simple model with better features can match the trees. Then you will meet a column that looks helpful and is not.

**Time:** about 20 minutes in class, following along · **Data:** `ml.insurance_groups` → the view `ml.insurance_features` · **Starter:** `Unsolved/better_features.sql`

## The story

The trees beat the line because they can ask a question of smokers that they do not ask of anyone else: is the BMI above 30? A line cannot do that on its own. It adds one fixed amount for smoking and one fixed amount per BMI point, the same for everybody. But a line can use any column you give it. If you build a column that says "smoker with a BMI of 30 or more", the line can give that group its own amount.

Building new columns from the ones you have, so a model can use a pattern it could not see, is called **feature engineering**. It is often the cheapest way to a better model.

## What you will learn

- To spot an **interaction** (a pattern that holds for one group only) in a grouped table.
- To build features in SQL with `IF` and arithmetic, in a view, and train on them.
- To read the new weights in business words.
- To ask of every new column: **would we know this column when we make the prediction?** A column built from the label never passes; nor does one filled in only after the event

## Before you start

You need `ml.insurance_groups` and `ml.ins_linear` from [activity 01](../01-Evr-Same-Rows-Two-Models/README.md).

## Steps

1. **The pattern (block 1).** Four groups of training people: smokers or not, BMI below 30 or not. Read the averages across: for non-smokers, a BMI of 30 or more adds under a thousand dollars; for smokers it nearly doubles the charges. That is an interaction. Only training rows are used: patterns are looked for on training rows, never on the rows we score on.

2. **Two new columns (block 2).** A view adds them to every row, in every group:

    | Column | Built as | Why |
    |---|---|---|
    | `smoker_obese` | `IF(smoker = TRUE AND bmi >= 30, 1, 0)` | gives the line a switch for exactly the group the trees found |
    | `age_sq` | `age * age` | charges rise faster at older ages; with age and age² the line can bend |

    BMI 30 is the usual medical cut-off for obesity, and it is where the trees put their question.

3. **The same line, two more features (block 3).** Same model type, same training rows, eight features instead of six.

4. **Old line against new line (block 4).** On the same 268 validation people.

5. **What it learned (block 5).** Read two weights in words:

    - `smoker_obese` about 18,840: *a smoker with a BMI of 30 or more costs about 18,800 dollars a year more than a smoker below 30, other things equal.*
    - In `category_weights` for `smoker`, `true` now sits about 14,000 above `false`: the extra cost of smoking below BMI 30. On D11 one number, about 23,800, had to cover every smoker.

    `age` and `age_sq` work together: about 15 dollars per year of age plus about 3 dollars per year squared, so the yearly step grows with age.

6. **A dead end, on purpose (block 6).** A colleague offers a column from the billing system: *monthly charges*. Train with it and look at the score: R² of 1.000, an average miss near zero. Too good to be true, because monthly charges are the yearly charges divided by 12: **the column is built from the label**. When a new customer asks for a price, their charges for the year do not exist yet. This is a **leak**, as on D12. Do not keep this model.

## Check yourself

| Block | Rows returned | One value to check |
|---|---:|---|
| 1 | 4 | non-smokers: 305 · 7,861 and 327 · 8,657 · smokers: 84 · 21,632 and 87 · 41,473 |
| 4 | 2 | six features: MAE ≈ 4,241, R² 0.74 · with the two new features: MAE ≈ 2,419, R² 0.86 |
| 5 | 9 | eight features and the intercept · `smoker_obese` ≈ 18,839 · `age_sq` ≈ 3.1 |
| 6 | 1 | R² 1.000 |

The linear models' numbers are exact for these rows: a line has no random part.

**What it means.** Two columns took the line from 0.74 to 0.86, a little ahead of the forest (≈ 0.84) and the boosted trees (≈ 0.83) on the same people, and, as activity 06 shows, on every deal of the rows. The trees found the pattern; the feature handed it to a model whose weights anyone can read.

## If something goes wrong

- **`smoker` shows as STRING in the schema:** you uploaded without Auto detect. In block 2 write `smoker = 'yes'` instead of `smoker = TRUE`; block 1 then shows `yes` and `no` instead of `true` and `false`.
- **`Unrecognized name: smoker_obese` in block 4:** the second query must read from `ml.insurance_features`, not `ml.insurance_groups`.
- **Block 6's second query fails with a missing column:** `ML.EVALUATE` needs every feature the model was trained on, so the query adds `charges / 12 AS monthly_charges` as well.

## Bonus

Train the boosted trees on the eight features too (copy activity 01's block 4 and add `smoker_obese, age_sq`). Do the trees gain as much as the line did? (Computed outside BigQuery: about 0.84, a little up from 0.83. The trees had already found the pattern for themselves.)

## References

BigQuery ML: [ML.WEIGHTS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-weights), [feature preprocessing overview](https://docs.cloud.google.com/bigquery/docs/preprocess-overview), Google Cloud. BMI 30 as the threshold for obesity: World Health Organization. Data as in activity 01.
