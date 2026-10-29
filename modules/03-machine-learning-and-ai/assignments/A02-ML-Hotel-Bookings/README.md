# Assignment 2: Predict hotel cancellations

**Module 3, machine learning · 20% of the course grade · Issued Thursday 29 October · Due before 4:00 PM, Thursday 5 November**

## The story

You work for two hotels in Portugal: a resort hotel in the Algarve and a city hotel in Lisbon. Many guests book a
room and then cancel. The revenue manager (the person who decides room prices) wants your help.

Last year a consultant sold her a cancellation model. He said it was "100% accurate". It did not help her at all.
So she asks you for two things:

1. Build models that answer her three questions (below).
2. Tell her, in plain words, **whether each model is really useful for the hotels**, not only whether its score is high.

That second point is the main lesson of this assignment: **a high score does not always mean a useful model.**

| Her question | The kind of model |
|---|---|
| A. Which bookings will cancel? | Classification (`LOGISTIC_REG`, D12) |
| B. What is a fair price per night? | Regression (`LINEAR_REG`, D11) |
| C. What kinds of guests do we have? | Clustering (`KMEANS`, D13) |

## What you hand in

Two files, before **4:00 PM on Thursday 5 November**, through the link your TA shares in your group channel:

| File | What is in it |
|---|---|
| `A02_<FirstName>_<LastName>.sql` | Every query you ran, in order, under the question numbers. Start from [`a02_starter.sql`](a02_starter.sql) |
| `A02_<FirstName>_<LastName>.docx` | Your answers, written in the Word answer sheet [`A02_answer_sheet.docx`](A02_answer_sheet.docx), **with your screenshots pasted in** where you see 📸 (or save it as PDF) |

**Points:** the core questions are worth 100 points. The bonus questions are optional and give up to 10 extra
points (your total cannot go above 100). The full rubric is in [`A02_rubric.md`](A02_rubric.md): read it before you
start, so you know what a full-mark answer looks like.

**How long:** most of the SQL is in the starter file already. Plan about 6 to 8 hours across the week: Part 1 on the
first day, Parts 2 and 3 over the next days, Part 4 (the memo) last.

**Help:** your TA can help you read an error message. They will not write a query or an answer for you. Your SQL may
look like a classmate's. Your answers and your memo must be in your own words.

## Words you will see

| Word | What it means here | Example |
|---|---|---|
| booking | One row of the table: one room reservation | A family books 3 nights in August |
| cancellation rate | The share of bookings that were cancelled | 37 cancelled out of 100 = 37% |
| `lead_time` | Days between the day of booking and the arrival day | Booked on 1 May for 1 June: lead time 31 |
| `adr` | The price per night, in euros (average daily rate) | 95.50 |
| label | The column the model learns to predict | `is_canceled` |
| leak | A column that contains the answer, or is only filled in **after** the answer is known | `reservation_status` says "Canceled" |
| simple guess | A rule with no model, used to check the model is better | "Nobody cancels"; "every room costs the average price" |
| validation rows | Rows the model did not train on, used to compare models | 23,878 bookings |
| test rows | Rows used **once**, at the very end, for the model you chose | 23,878 bookings |
| threshold | The probability at or above which we say "will cancel" | 0.5: a booking with probability 0.62 counts as "will cancel" |
| MAE | Mean absolute error: the average miss, in euros | MAE 22 = on average the predicted price is €22 too high or too low |
| segment (cluster) | A group of similar bookings found by k-means | "Families in summer" |

## Before you start (about 20 minutes)

1. **Download the data:** [`hotel_bookings.csv`](../../../../shared/datasets/hotel_bookings/hotel_bookings.csv)
   (17 MB, 119,390 rows). Column meanings: [dataset README](../../../../shared/datasets/hotel_bookings/README.md).
2. **Upload it to BigQuery.** Open your `ml` dataset (the one from D11). Click **Create table**. Choose **Upload**
   and select the file. Table name: `hotel_bookings`. Under **Schema**, tick **Auto detect**. Click **Create table**.
   The same steps with pictures: [upload guide](../../../02-sql/resources/upload-a-csv-to-bigquery.md).
3. **Check it.** Run `SELECT COUNT(*) FROM ml.hotel_bookings;` The answer must be **119,390**.
   If BigQuery shows `adr` or `children` as STRING (text), you did not tick Auto detect: delete the table and upload again.
4. **Open the starter.** Copy [`a02_starter.sql`](a02_starter.sql) into a new BigQuery query tab. Run **Block 0**
   (the first block). It makes a view, `ml.hotel_groups`, that puts every booking in one of three groups, the same idea
   as D14:

   | split | Bookings | What you use it for |
   |---|---:|---|
   | `train` | 71,634 | Training every model |
   | `validation` | 23,878 | Checking and comparing models, as many times as you like |
   | `test` | 23,878 | **One time only**, at the end (question 3.1e) |

> **Tip.** Run one block at a time: select the lines with the mouse, then click **Run**. A `CREATE MODEL` can take 1
> to 3 minutes. Wait until it says it is finished before you run the next query.

---

## Part 1. Understand the data with SQL (20 points)

For each question: write the query (the starter has the query with blanks `___` for you to fill in), run it, paste a 📸 screenshot of
the result into the answer sheet, and answer in **one or two full sentences**.

> **What a good answer sounds like** (an example from a gym, not from our hotels): *"About 30 of every 100 new
> members stop paying within one year. Members who joined in January stop more often (41 of 100) than members who
> joined in September (22 of 100)."* It uses numbers, and a manager can understand it.

**1.1 How many bookings are there?** 📸
Count the bookings for each hotel, and find the first and last arrival year.
Then answer: *One row in this table is one ___. Can the same guest be in more than one row?*
> **Hint.** Look at the column `is_repeated_guest`. What does it mean if it is 1?

**1.2 How many bookings are cancelled?** 📸
Find the cancellation rate for both hotels together, and for each hotel.
Then answer: *Out of every 100 bookings at the City Hotel, about how many are cancelled?*
> **Hint.** `is_canceled` is 1 or 0, so `AVG(is_canceled)` is the cancellation rate. Multiply by 100 for a percent.

**1.3 Does a deposit stop people from cancelling?** 📸
Find the cancellation rate for each `deposit_type`.
Then answer: *Which result is strange? Why do you think it happens?* A guess is fine here: say what you think and why.
> **Hint.** Normally, people who paid and cannot get their money back should cancel **less**. Is that what you see?

**1.4 Do people who book early cancel more?** 📸
The starter puts `lead_time` into six bands with `CASE` (0–7 days, 8–30, 31–90, 91–180, 181–365, over a year).
Fill in the blanks and run it. Then answer: *Describe the pattern in one sentence.*

**1.5 Can we trust the prices?** 📸 (two screenshots)
Run the two price queries in the starter: the price checks, and the average price for each month.
Then answer: *Which rows would you leave out of a model that predicts prices, and why?*
*In which month is the resort most expensive?*
> **Hint.** Can a hotel room cost less than €0? Is €5,400 for one night likely? What could a price of exactly €0 mean?

### Check yourself (Part 1)

If your number is different, check your `WHERE` and `GROUP BY` first.

| Question | One value to check |
|---|---|
| 1.1 | City Hotel 79,330 bookings, Resort Hotel 40,060 |
| 1.2 | 44,224 cancelled bookings in total |
| 1.4 | 19,746 bookings made 0 to 7 days before arrival |
| 1.5 | The highest `adr` is 5,400 |

---

## Part 2. Find the mistakes (20 points)

No new SQL in this part, except the three short queries already written in the starter (Block 2). In the answer
sheet, **we filled in two tables, and we made some mistakes on purpose.** Your job is to find them.

**2.1 The plan for the three models** (10 points)
The answer sheet has a table with one column for each question (A cancellations, B prices, C guests). It says what
kind of model to use, what to predict, which rows to use, what simple guess to compare with, and which number to show
the manager. **There is exactly one mistake in each column.**
For each column, find the one wrong cell.
In the answer sheet, write the row name of each wrong cell, the correct answer, and one sentence why.
> **Hint.** Read the "Words you will see" table again. Then ask for each cell: is this the right kind of model?
> Does a clustering model have a label? What does the manager care about: a high score, or money and bookings?

**2.2 Can the hotel know this column on the day of booking?** 📸 (the three Block 2 queries) (10 points)
A model for next month's bookings can only use columns the hotel **already knows when the guest books**. The
answer sheet lists 10 columns, with our answer for each: "known at booking" or "known later". **Three of our answers
are wrong.** For each row, tick **Agree** or **Disagree**. For each Disagree, write one sentence why.
> **Hint.** First run the three queries in Block 2 of the starter. Look for a group that cancels very much more or
> very much less than the others (near 0%, near 100%, or very different). Then ask: *when is this column filled in?
> Before the guest arrives, or after?*

---

## Part 3. Build and check the models (25 points)

The starter has every `CREATE MODEL` already written. You run it, read the result, and write what it means.

### 3.1 Cancellations (12 points)

**a. The consultant's model** 📸 (2 points)
Run Block 3.1a. It trains a model with **almost every** column, then checks it on the validation rows.
Write its accuracy. Then answer: *Why was this model useless to the manager, even with this score?*
> **Hint.** Look at your answer to 2.2, and find the column that already contains the answer.

**b. Your model** 📸 (2 points)
Run Block 3.1b. It uses only columns known at booking. Write its accuracy, precision and recall on the validation rows.

**c. Is your model good? Three checks** 📸 for each (5 points)
Run Block 3.1c and fill in the blanks in the answer sheet:
1. "Nobody cancels" is right for ___% of validation bookings. My model is right for ___%.
   (Your model's number is the accuracy from 3.1b × 100. For example 0.776 → 77.6%.)
2. My model is very sure that ___ bookings **will cancel** (probability 0.9 or more). Of these, ___ are `Non Refund`.
   (The query gives one row for each deposit type. Add the rows together for the total.)
3. On `No Deposit` bookings only: my model is right for ___%. "Nobody cancels" is right for ___%.
   (Again, accuracy × 100.)

Then choose the **one true sentence** (A, B, C or D) in the answer sheet, and write which two numbers prove it.

**d. Which threshold costs the hotel least?** 📸 (2 points)
If the model says "will cancel", the hotel sells the room again (overbooking). Two mistakes are possible:
- The model says "will cancel", but the guest arrives: the hotel has no room for them. It pays about **€200** to send
  the guest to another hotel.
- The model says "will come", but the guest cancels: the room stays empty. The hotel loses about **€100** (one night).

Block 3.1d adds up the cost for thresholds 0.3 to 0.9. Write: *Which threshold has the lowest cost? Which has the best
accuracy? Are they the same?*

**e. The test, one time only** 📸 (1 point)
In Block 3.1e, write your chosen threshold (the one with the lowest cost in 3.1d) in place of `___`, and run it on the
test rows. Write the test accuracy. Compare it with the accuracy for the same threshold in your 3.1d table: is it close?

### 3.2 Prices (8 points)

**a. Your price model** 📸 (2 points)
Run Block 3.2a. It trains on rows with a real price (more than €0 and less than €1,000). Write the MAE and R² on the
validation rows.

**b. Is it better than a simple guess?** 📸 (3 points)
Run the two queries in Block 3.2b. They give the MAE of two simple guesses: "every room costs the average price", and
"every room costs the average price of that hotel in that month". Fill in the small table in the answer sheet.
By how many euros is your model better than the second guess?

**c. Where is it wrong?** 📸 (3 points)
Run Block 3.2c. It shows the actual and the predicted average price for the resort in **August** and in **January**.
Fill in the numbers. Then answer: *Why is the model wrong in August?* Choose the **one true sentence** (A, B, C or D).

### 3.3 Guests (5 points)

Run Block 3.3. It makes 4 segments with k-means (only bookings where the guest stayed), then shows each segment's
size and averages in normal units (days, nights, euros). 📸
k-means has no label and no right answer to test, so it uses all these bookings, not only the train rows.
In the answer sheet, give each segment a **name** that a marketing person would use, and **one action** for it.

> **Example of the format** (a gym, not our hotels): segment of 900 members, average age 22, visits 5 times a week,
> mostly evenings → name: **"Evening students"** → action: **"Offer a student price for evening-only membership."**

Your segment numbers (1, 2, 3, 4) may be in a different order from a classmate's. That is normal for k-means.

---

## Part 4. The memo (35 points)

Write the revenue manager **one page** (the answer sheet has space for it). She is not a data person: do not use
words like "R²", "AUC" or "feature" without explaining them. Use numbers in bookings and euros.

The answer sheet gives you a sentence starter for each part:

| Part | Points | What to write |
|---|---:|---|
| 1. Cancellations | 12 | Is the cancellation model useful? For which bookings, and not for which? Which threshold, and why? Why not the consultant's model? |
| 2. Prices | 8 | How far off are the predicted prices, in euros? Where are they most wrong? Should she use the model to set prices? |
| 3. Guests | 7 | Your segments, one line each, with the action |
| 4. One warning | 4 | One thing she should check before she trusts any of these models, and why |
| Clear writing | 4 | Short sentences, numbers in euros and bookings, no unexplained technical words |

> **A strong sentence:** "The model is useful for X but not for Y, because Z (number)."
> **A weak sentence:** "The accuracy is 78%, so the model is good."

---

## Bonus questions (optional, up to 10 extra points)

There are seven bonus questions. Each is worth 2 points, and we count your best five (up to 10 points). Do them
only after the core questions. Put them in the bonus section of the answer
sheet. The starter has a block for each.

- **B1. Test your guess from 1.3.** Write one query that checks your explanation (look at `market_segment`,
  `lead_time` and `country` for `Non Refund` bookings). What does it show?
- **B2. Explain one booking.** Use `ML.EXPLAIN_PREDICT` on one `No Deposit` booking that your model says will cancel.
  Explain, in plain words, why the model thinks so. Do the reasons make sense for a hotel?
- **B3. Train on all rows.** Train the price model on all rows, without removing the strange prices. What is the
  lowest predicted price? Would you put this price on the hotel website? (Remember D16's diamonds.)
- **B4. Hidden leaks.** Add the columns you marked **Disagree** in 2.2 to your cancellation model, **except**
  `reservation_status` (we already know it gives 100%). What happens to the
  accuracy? Would the manager have these columns on the day of booking?
- **B5. Fix the month mistake.** Add the column `CONCAT(hotel, ' ', arrival_date_month) AS hotel_month` to the price
  model. What happens to the August prices and to the MAE? Why does it help?
- **B6. Choose k.** Train k-means with 3 and with 5 segments. Compare the Davies–Bouldin index of k = 3, 4 and 5.
  Which k would a marketing team find most useful? Is it the one with the lowest index?
- **B7. Nationality.** Add `country` to the cancellation model. Is it better? Should a hotel decide whom to overbook
  by the guest's country? (Google's Crash Course module on fairness, from D12, can help.)

---

## If you missed a class, start here

| You need | Where we did it | Read or redo |
|---|---|---|
| `GROUP BY`, `COUNTIF`, rates, `CASE` bands | D04 | The D04 slides; [D04 rates](../../../02-sql/labs/D04/10-Evr-Rates/README.md), [D04 CASE rules](../../../02-sql/labs/D04/07-Ins-Case-Rules/README.md) |
| A CTE and a `JOIN` (to read the given queries) | D06, D09 | The D09 slides; [D09 activity 02](../../../02-sql/labs/D09/02-Evr-Subquery-In-From/README.md) |
| `ROW_NUMBER()` and the fixed groups | D10, D14 | [D10 ranking](../../../02-sql/labs/D10/04-Ins-Rank-Ties/README.md); [D14 same rows, two models](../../labs/D14/01-Evr-Same-Rows-Two-Models/README.md) |
| `LINEAR_REG`, the average guess, MAE, R² | D11 | [D11 first model](../../labs/D11/02-Evr-First-Model/README.md), [D11 data splits](../../labs/D11/05-Lab-Data-Splits/README.md) |
| `LOGISTIC_REG`, the confusion matrix, threshold, precision and recall | D12 | [D12 first classifier](../../labs/D12/01-Evr-First-Classifier/README.md), [D12 thresholds](../../labs/D12/03-Lab-Thresholds-And-Curves/README.md), [D12 imbalance](../../labs/D12/04-Lab-Imbalance-And-Class-Weights/README.md) |
| `KMEANS`, profiles in normal units, choosing k | D13 | [D13 judge the segments](../../labs/D13/04-Evr-Judge-The-Segments/README.md), [D13 choosing k](../../labs/D13/05-Lab-Choosing-K-And-Tuning/README.md), [D13 random starts](../../labs/D13/06-Lab-Starts-And-Stopping/README.md) |
| `ML.EXPLAIN_PREDICT` (bonus B2) | D15 | [D15 explain five people](../../labs/D15/07-Evr-Explain-Five-People/README.md), [D15 explain options](../../labs/D15/11-Lab-Explain-Options/README.md) |
| A model that is "right" but useless | D16 | [D16 Titanic](../../labs/D16/02-Evr-Titanic-Survival/README.md) (against "nobody survived"), [D16 diamonds](../../labs/D16/01-Evr-Diamond-Prices/README.md) (prices below zero) |

## Read this (short, and it helps with Parts 3 and 4)

| Read | Why |
|---|---|
| [Classification: accuracy, recall, precision](https://developers.google.com/machine-learning/crash-course/classification/accuracy-precision-recall) (Google ML Crash Course) | Why a model that always says "no" can have high accuracy and still be useless |
| [Thresholds and the confusion matrix](https://developers.google.com/machine-learning/crash-course/classification/thresholding) (Google ML Crash Course) | Why 0.5 is not always the best threshold when two mistakes cost different amounts |
| [Data leakage](https://www.kaggle.com/code/alexisbcook/data-leakage) (Kaggle Learn) | Columns that are only known after the answer, and how they make a score look good |
| [Predicting hotel booking cancellations](https://www.redalyc.org/pdf/3887/388751309003.pdf) (Antonio, Almeida and Nunes, 2017), the introduction only | The researchers who published this data explain why cancellations cost hotels money |
| [`ML.EVALUATE`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate), [`ML.CONFUSION_MATRIX`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-confusion), [`ML.EXPLAIN_PREDICT`](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-explain-predict), [k-means](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-kmeans) (Google) | The exact options, if you want more than the starter |

All BigQuery ML pages by day: [`bigquery-ml-reference-links.md`](../../resources/bigquery-ml-reference-links.md).

## References

Nuno Antonio, Ana de Almeida and Luís Nunes, "Hotel booking demand datasets", *Data in Brief* 22 (2019) 41–49,
[doi:10.1016/j.dib.2018.11.126](https://doi.org/10.1016/j.dib.2018.11.126), CC BY 4.0. The authors removed anything
that identifies the hotels or the guests. Course copy taken 29 October 2026; details in the
[dataset README](../../../../shared/datasets/hotel_bookings/README.md).
