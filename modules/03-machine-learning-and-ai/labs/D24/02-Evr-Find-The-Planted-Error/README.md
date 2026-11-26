# Activity 02 · Find the error in an answer that had the schema

In this activity, you will review two answers an assistant gave to a well-written prompt: the tables, the columns and what one row is were all in it. Both queries run without an error, and both are wrong. You find each error with a number you already know, and you write the follow-up that fixes it.

**Files:** [Unsolved/answers_to_review.md](Unsolved/answers_to_review.md)

**Data:** nothing to load. The check numbers are below; they come from `nakheel.orders` and `nakheel.order_items` (D03) and the D19 number registry.

| What you already know | Value |
|---|---|
| Orders, all statuses | 3,000 |
| Completed orders | 2,771 |
| Completed revenue, `SUM(qty * price)` | 316,023.50 |
| Customers with a completed order | 452 |
| First and last `order_date` in the data | 1 September 2024 and 31 August 2026 |

| Step | What you do | Why |
|---|---|---|
| 1 | Review Answer A | One right number on a row does not make the other right |
| 2 | Review Answer B | The model cannot know facts about your data that the prompt left out |
| 3 | Write the two follow-ups | A precise correction is a prompt too |
| 4 | Try the prompts in your own assistant | Yours may or may not make the same mistake |

## 1. Review Answer A

**Why this step.** The analyst asked for two numbers in one query. The revenue matches the number you trust, so it is tempting to accept the whole row.

1. Open [Unsolved/answers_to_review.md](Unsolved/answers_to_review.md) and read the prompt for Answer A, then the SQL.
2. Before reading the result, say what one row is after the join: one order, or one order line?
3. Compare both numbers in the result with the table above.

**C1.** Answer A returned **6,951** completed orders and **316,023.50** revenue. Write in one sentence why the revenue is right and the count is wrong.

## 2. Review Answer B

**Why this step.** The prompt gave the tables and the definition. It did not say when the data ends. The assistant filled that gap with the only date it has: today.

1. Read the prompt for Answer B, then the SQL. Find the date the 90 days are counted back from.
2. Compare the result with the number of customers who have a completed order (452) and with the last date in the data.

**C2.** Answer B returned **447** lapsed customers out of 452 when it was run on 26 November 2026. Run on any day from 30 November 2026, the same query returns **452**: every customer. Write in one sentence why the answer changes when the data does not.

## 3. Write the two follow-ups

**Why this step.** "That's wrong, try again" gives the assistant nothing to work with. Say the number you got, the number you expected and why.

1. For each answer, write a follow-up of one or two sentences.
2. Decide what you would add to the original prompt so the error is less likely next time.

**C3.** Each follow-up names the wrong number, what it should be or what it should be checked against, and the cause. Compare with `Solved/errors_named.md` when it is shown in class.

## 4. Try the prompts in your own assistant

**Why this step.** These answers were written for the course, so everyone reviews the same code. Real assistants differ, and the same one can answer differently on another day.

1. In a new chat, send the prompt for Answer A, then the prompt for Answer B.
2. Check what comes back the same way: what is one row, and what date does it count from?

**C4.** Whether your assistant made the mistake or not, you only know because you checked against numbers you trust.

**What just happened.** The prompts were good and the code was valid. The errors came from things the prompt did not settle: the grain after a join, and the date the data ends. A check you run yourself is what found them.

## Hint

Answer A: a join to `order_items` gives one row per line, and an order has two or three lines. Answer B: look for `CURRENT_DATE()`.

## Bonus

Write the query for Answer B so that it never needs editing: take the end date from the data itself instead of typing it.

## References

Nakheel Retail: course-generated synthetic data. Check numbers from the D19 number registry and the dataset README (period 1 September 2024 to 31 August 2026). The answers to review were written for this course in the style of an assistant; they are not transcripts of a particular product.
