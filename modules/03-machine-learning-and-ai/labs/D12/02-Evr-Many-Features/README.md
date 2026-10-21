# Eight features: better than a guess, and who gets an offer?

In this activity, you will train a classifier on eight features, compare it with a simple guess, read its confusion matrix and ROC curve, move the threshold, look at the leavers it misses, read what it learned, and let invented costs choose the threshold.

**Data:** `ml.telco` (activity 01) · **Starter:** `Unsolved/many_features.sql`

## The story

The one-feature model ranked customers by tenure only. The retention team knows more about each customer: the contract, the monthly bill, the internet service, how they pay, whether they have tech support. With more to learn from, can the model find the leavers better? And once it gives a probability, which customers should actually get an offer?

## What you will learn

- To judge a classifier against the **majority guess**, not against zero.
- To read accuracy, precision, recall, F1 and ROC AUC, and the confusion matrix, in business words.
- To move the threshold, and to see that each choice trades leavers found against offers wasted.
- To look at the leavers the model misses, and to read its weights as what went with leaving, not as causes.
- To let the costs of each mistake choose the threshold.

## Before you start

You need `ml.telco` from activity 01.

## Steps

1. **Train with eight features (block 1).** `tenure`, `MonthlyCharges`, `Contract`, `InternetService`, `PaymentMethod`, `SeniorCitizen`, `PaperlessBilling`, `TechSupport`. Five are categories, not numbers (four text columns, and `PaperlessBilling`, which is TRUE or FALSE): BigQuery one-hot encodes them, as in D11. `customerID` is left out (an identifier says nothing about leaving), and so is `TotalCharges`.

2. **Score it (block 2).** `ML.EVALUATE` scores the 20% held aside at threshold 0.5:

    | Column | Question it answers |
    |---|---|
    | `accuracy` | what share of all customers did it get right? |
    | `precision` | of the customers it said would leave, what share did? |
    | `recall` | of the customers who left, what share did it find? |
    | `f1_score` | one number that balances precision and recall |
    | `roc_auc` | how well it ranks leavers above stayers, over every threshold: 0.5 is guessing, 1 is perfect |

    Expect about 0.80, 0.64, 0.52, 0.58 and 0.84. Your numbers may differ a little from these.

3. **The guess to beat (block 3).** Say "stays" for everyone. `COUNTIF(Churn = FALSE)` counts the customers who stayed, so the guess is right for 0.735 of all customers. The model's 0.80 is only a little higher, but the guess finds **no** leavers and the model finds about half. When one class is much bigger than the other, accuracy hides what matters.

    Block 3 counts all 7,043 customers, while block 2 scored only the 20% held aside. Is that a fair comparison? Block 4, next, shows it: 925 + 109 = 1,034 of the 1,407 held-aside customers stayed, and 1,034 ÷ 1,407 is 0.735 too.

4. **The matrix in SQL (block 4).** `ML.CONFUSION_MATRIX` counts the held-aside customers by what really happened (rows) and what the model said (columns). About 925 stayed and were left alone; 109 stayed but got an offer; 178 left without an offer; 195 left and got one.

5. **The ROC curve (block 5).** `ML.ROC_CURVE` lists many thresholds and, for each, the recall and the false positive rate (the share of stayers wrongly flagged). As the threshold falls, both rise.

6. **Move the threshold (block 6).** The same `ML.ROC_CURVE` rows as block 5, with two new columns in the retention team's words: **offers** (everyone flagged: `true_positives + false_positives`) and **leavers caught** (`true_positives`). Precision is leavers caught ÷ offers; work it out for the three rows. Find the rows closest to 0.3, 0.5 and 0.7:

    | Threshold | Offers | Leavers caught | Precision | Recall |
    |---|---:|---:|---:|---:|
    | 0.3 | ≈ 538 | ≈ 286 | ≈ 0.53 | ≈ 0.77 |
    | 0.5 | ≈ 304 | ≈ 195 | ≈ 0.64 | ≈ 0.52 |
    | 0.7 | ≈ 93 | ≈ 72 | ≈ 0.77 | ≈ 0.19 |

    A lower threshold finds more leavers and wastes more offers. There is no setting that is free. Your counts may differ a little from these.

7. **Who does it miss? (block 7).** Only the customers who left (`Churn = TRUE`), by contract: how many left, how many the model said would stay (`predicted_Churn = FALSE`), and the share it missed.

    | Contract | Leavers | Missed | Miss rate |
    |---|---:|---:|---:|
    | Two year | 48 | 48 | 1.00 |
    | One year | 166 | ≈ 165 | ≈ 0.99 |
    | Month-to-month | 1,655 | ≈ 680 | ≈ 0.41 |

    Read the two columns separately. By count, most missed leavers are month-to-month, because most leavers are. By rate, the model misses almost every leaver on a one- or two-year contract. It learned that these customers stay, so the few who leave slip through. A count tells you where most of the misses are; a rate tells you which group the model is worst at.

    This block predicts for all 7,043 customers, including the 80% the model trained on. That is fine for looking at its mistakes, but it is not a score: block 2's numbers, on the 20% held aside, are the honest ones.

8. **Read what it learned (block 8).** In logistic regression a weight works on the log-odds of leaving. Read the **sign** and compare sizes within a feature; do not read it in dollars. Pushing toward leaving: month-to-month contracts, fiber optic internet, paying by electronic check, paperless billing, being a senior citizen. Pushing toward staying: one- and two-year contracts, longer tenure, tech support.

    Block 8 shows each category feature's weights as a list inside one cell. **Block 8b** gives each category its own row: `UNNEST` opens the list, as it opened the probabilities in activity 01. Number features such as `tenure` have no list, so they drop out of 8b; their weights are in block 8.

    A weight tells you what went with leaving among these customers. It is not proof that one causes the other: moving a customer to a two-year contract may not keep them.

9. **Two new customers (block 9).** The same customer, 12 months in, 70 a month, fiber, electronic check, no tech support: month-to-month about 0.65; two-year contract about 0.31. Only the contract changes, so the gap is what the model learned about contracts. It is still the model's view of past customers, not a promise of what a new contract would do.

10. **Let the costs choose (no SQL).** Invented costs for class: an offer costs 50; a customer who leaves costs 500; an offer keeps 1 in 3 of the leavers who get it. Each caught leaver is worth about 500 ÷ 3 − 50 ≈ 117; each wasted offer costs 50. With the counts from step 6:

    | Threshold | Offers | Leavers caught | Value |
    |---|---:|---:|---:|
    | 0.3 | ≈ 538 | ≈ 286 | ≈ +20,800 |
    | 0.5 | ≈ 304 | ≈ 195 | ≈ +17,300 |
    | 0.7 | ≈ 93 | ≈ 72 | ≈ +7,400 |

    An offer pays when the probability of leaving × 500 ÷ 3 is more than 50, that is above 0.3. Change the costs and the best threshold moves.

    Two honest notes. The 0.3 rule trusts the model's probabilities, and "1 in 3 kept" is invented: a real team would measure it, for example by sending the offer to some at-risk customers and not to others. And we chose the threshold on the same 20% we scored. That is fine for learning; in a real project you choose it on one group and check it once on another, as D14 does.

## Check yourself

| Block | Rows returned | One value to check |
|---|---:|---|
| 2 | 1 | accuracy ≈ 0.80 · recall ≈ 0.52 · ROC AUC ≈ 0.84 |
| 3 | 1 | 0.735 |
| 4 | 2 | one row for FALSE (stayed), one for TRUE (left); your four counts add up to the held-aside rows (about 1,400) |
| 6 | a few dozen | the row nearest 0.3: recall ≈ 0.77 |
| 7 | 3 | two year: 48 leavers, miss rate 1.00 |
| 9 | 2 | month-to-month ≈ 0.65 · two year ≈ 0.31 |

## If something goes wrong

- **`Churn` is STRING in your table:** you uploaded without Auto detect. Write `'Yes'`/`'No'` for `TRUE`/`FALSE`, also for `PaperlessBilling` in block 9.
- **Block 9 fails with a type error:** each typed-in value must have the training column's type: `SeniorCitizen` is a number (0 or 1), `PaperlessBilling` is TRUE or FALSE, the others text.
- **Your counts differ a little from the slides:** that is expected; the slides' numbers were worked out before class on one 20% of the customers.
- **Block 6 shows no row at exactly 0.3:** `ML.ROC_CURVE` picks its own thresholds. Read the row closest to 0.3.

## Bonus

If an offer cost 100 instead of 50, which threshold would the costs choose? (Hint: an offer pays when the probability × 500 ÷ 3 is more than the cost.)

## References

Telco Customer Churn, IBM sample data; course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md). The retention costs are invented for class. BigQuery ML: [ML.EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate), [ML.CONFUSION_MATRIX](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-confusion), [ML.ROC_CURVE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-roc), Google Cloud.
