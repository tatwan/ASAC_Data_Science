# Assignment 2 rubric: Predict hotel cancellations

This is how your work is marked. Core questions: **100 points**. Bonus questions: up to **10 extra points** (your total
cannot go above 100).

**Every written answer is marked on three things:** it answers the question asked, it uses a number from your
result, and a manager could understand it. Small differences in your numbers (for example 0.776 against 0.781) do
not lose points. A missing screenshot loses half the points of that question, unless the table below gives the screenshot its own point.

## Part 1. Understand the data with SQL (20 points)

| Question | Points | Full points | Half points | Zero |
|---|---:|---|---|---|
| 1.1 Bookings | 3 | Correct counts and years; says one row is one booking; says a guest can appear more than once | Correct counts, but the sentence is missing or wrong | No query, or wrong table |
| 1.2 Cancellation rate | 4 | Rate for both hotels together and each hotel; "about __ of every 100 City Hotel bookings" | Rates correct, no sentence for the manager | No rate |
| 1.3 Deposit | 4 | Rates by deposit type; names the strange result; gives a reasonable guess why | Names the strange result, no guess | Does not see what is strange |
| 1.4 Lead time | 4 | Six bands with rates; one clear sentence about the pattern | Bands correct, no pattern sentence | No bands |
| 1.5 Prices | 5 | Both screenshots; names at least two kinds of rows to leave out, with reasons; names the most expensive month for the resort | One kind of row, or no reason | Nothing about which rows to leave out |

## Part 2. Find the mistakes (20 points)

| Question | Points | Full points | Partial |
|---|---:|---|---|
| 2.1 The plan | 10 | All three mistakes marked, each with the correct answer and a reason | 3 points for each mistake found with the correct answer, +1 if every reason is given |
| 2.2 Known at booking? | 10 | All three wrong rows marked "Disagree", each with a reason; the other seven marked "Agree"; the Block 2 screenshots | 3 points for each wrong row found with a reason, +1 for the screenshots; −1 for each correct row marked "Disagree" (not below 0) |

## Part 3. Build and check the models (25 points)

| Question | Points | Full points |
|---|---:|---|
| 3.1a The consultant's model | 2 | Accuracy written; says why it was useless (it used a column that already contains the answer) |
| 3.1b Your model | 2 | Accuracy, precision and recall on the validation rows |
| 3.1c Three checks | 5 | The six blanks filled (3 points); the true sentence chosen, with the two numbers that prove it (2 points) |
| 3.1d Threshold and cost | 2 | Lowest-cost threshold and best-accuracy threshold named; says whether they are the same |
| 3.1e The test | 1 | Test result with your threshold, run once; says if it is close to validation |
| 3.2a Price model | 2 | MAE and R² on the validation rows |
| 3.2b Simple guesses | 3 | The three MAE values in the table (2 points); by how many euros the model is better than the hotel-and-month guess (1 point) |
| 3.2c August and January | 3 | The four numbers (1 point); the true sentence chosen (2 points) |
| 3.3 Guests | 5 | The profile screenshot (1 point); a name that fits the numbers (2 points) and one action (2 points) for every segment |

## Part 4. The memo (35 points)

| Part | Points | Full points | Half points |
|---|---:|---|---|
| 1. Cancellations | 12 | Says what the model is useful for and not useful for, with numbers; the threshold and why (cost, not accuracy); why not the consultant's model | Says the model is good or bad, with one number, but not for which bookings |
| 2. Prices | 8 | The average miss in euros; where it is most wrong; a clear yes or no on setting prices, with a reason | The miss in euros only |
| 3. Guests | 7 | Every segment with a name and an action | Names without actions, or some segments missing |
| 4. One warning | 4 | One real risk, and why it matters | A risk with no reason |
| Clear writing | 4 | Short sentences; numbers in euros and bookings; technical words explained | Mostly clear, some unexplained words |

## Bonus (optional, 2 points each; we count your best five, up to 10)

| Bonus | Full points |
|---|---|
| B1 Test your guess | A query that checks your 1.3 explanation, and what it shows |
| B2 Explain one booking | `ML.EXPLAIN_PREDICT` result, explained in plain words, with a judgement: do the reasons make sense? |
| B3 Train on all rows | The lowest predicted price, and why it should not go on the website |
| B4 Hidden leaks | The new accuracy, and why the manager would not have these columns |
| B5 Fix the month mistake | The new August prices and MAE, and why the new column helps |
| B6 Choose k | Davies–Bouldin for k = 3, 4 and 5, and which k marketing would prefer, with a reason |
| B7 Nationality | The new score, and a reasoned yes or no on using a guest's country |

## Common reasons for losing points

- "The accuracy is 78%, so the model is good." A score alone is not an answer: say what it means for the hotel.
- Using the consultant's model as your model.
- Using the test rows more than once, or to choose the threshold.
- No numbers in the memo, or only model scores and no euros.
