# Choose a model, then test it once

In this activity, you and a partner will choose the model to give the pricing team, using only validation scores, write down why, and then score your choice once on the test people.

**Time:** about 18 minutes: 10 to choose, 8 to test · **Data:** `ml.insurance_features` and `ml.ins_linear_plus` (activity 05) · **Starter:** `Unsolved/choose_and_test.sql`

## The story

You now have seven ways to predict yearly charges. The pricing team will use one. They ask for three sentences: which model, why, and how far off it will be for a new customer. The last answer must come from people no model has seen and no choice has used: the test group. It is used once, after the choice, so that it stays an honest preview of new customers.

## What you will learn

- To choose between models whose scores are close, and to say why.
- Why a small difference on 268 people may be noise, and how a second deal of the rows shows it.
- To use the test group once, for the chosen model only.

## Before you start

You need `ml.insurance_features` and `ml.ins_linear_plus` from [activity 05](../05-Evr-Better-Features/README.md). If you choose a different model, you need it too (activities 01, 03 and 04).

## Steps

1. **Read the scoreboard.** Validation scores from activities 01 to 05, with each model's score on its own training rows:

    | Model | Validation MAE | Validation R² | Training R² |
    |---|---:|---:|---:|
    | guess: the training average | 9,153 | 0.00 | 0.00 |
    | linear, six features | 4,241 | 0.74 | 0.76 |
    | one tree, depth 15 | ≈ 2,860 | ≈ 0.73 | 1.00 |
    | one tree, depth 3 | ≈ 2,810 | ≈ 0.84 | ≈ 0.87 |
    | random forest | ≈ 2,570 | ≈ 0.84 | ≈ 0.89 |
    | boosted trees | ≈ 2,630 | ≈ 0.83 | ≈ 0.97 |
    | linear + `smoker_obese` + `age_sq` | 2,419 | 0.86 | 0.87 |

2. **Is the gap real?** The validation group is one deal of the cards. Below, the same models were trained and scored four times, each time retraining every model on three of the four non-test groups and scoring it on the fourth, about 268 people (the test people were never touched). The table gives validation R² for each deal:

    | Deal | Linear | Linear + two features | Random forest | Boosted trees |
    |---|---:|---:|---:|---:|
    | 1 | 0.77 | 0.89 | 0.88 | 0.86 |
    | 2 | 0.75 | 0.86 | 0.84 | 0.83 |
    | 3 | 0.76 | 0.87 | 0.86 | 0.84 |
    | 4 (today's validation group) | 0.74 | 0.86 | 0.84 | 0.83 |

    The scores move by up to 0.04 from deal to deal: that is how much one group of about 268 people can shift a score. A difference of 0.01 between two models on one deal says little. A model that comes first on every deal says more. Repeating the split like this is called **cross-validation**. Coming first every time is good evidence that a result is steady, not proof that the model will always win.

3. **Choose, with your partner.** Write three sentences: which model, why, and what a new customer's average miss will probably be. Think about the score, how steady it is across deals, how easy the model is to explain to a pricing manager, and the gap between training and validation.

4. **The test, once (blocks 1 and 2).** Only after you have written your sentences. Score the chosen model on the 267 test people, and the guess on the same people. The starter tests `ml.ins_linear_plus`; if you chose another model, change only the model name: `ml.insurance_features` holds every column any of today's models needs, and the same test people.

## Check yourself

| Block | Rows returned | One value to check |
|---|---:|---|
| 1 | 1 | for the line with two features: MAE ≈ 2,537, RMSE ≈ 4,720, R² 0.84 |
| 2 | 1 | the guess: MAE ≈ 9,024 |

**What it means.** The test score is close to the validation score (2,537 against 2,419; 0.84 against 0.86), so the choice did not depend on a lucky validation group. A new customer's charges will be missed by about 2,500 dollars on average, against about 9,000 for the guess and about 4,200 for D11's line. There is no rule that the simpler model wins; here it did because the features gave it what the trees had found.

## If something goes wrong

- **You ran the test before choosing:** that is fine as practice, but note it. A test score that has influenced the choice is no longer a preview of new customers.
- **Your test MAE is very different from your validation MAE:** check the `WHERE split = 'test'` and that the table holds the features the model needs.

## Bonus

Score D11's six-feature line on the test people too, *after* your choice is written. Its test MAE is about 4,186. How much does the pricing team gain from today's work, in dollars per customer per year?

## References

Data and models as in activities 01 to 05. The four deals were computed outside BigQuery with the same settings and are given here so the activity fits in class; [lab 07](../07-Lab-Trees-For-Churn/README.md) shows how to run a second deal yourself in SQL.
