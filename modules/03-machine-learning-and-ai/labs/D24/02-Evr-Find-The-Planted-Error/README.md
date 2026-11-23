# Activity 02 · Find the planted error

In this activity, you will review two answers an assistant gave. Both run without an error, and both are wrong. You find each error with a number you already know, and you write the follow-up prompt that fixes it.

**Files:** [Unsolved/answers_to_review.md](Unsolved/answers_to_review.md)

**Data:** nothing to load. The check numbers are below; they come from `nakheel.orders` (D03) and your D19 Power BI model.

| Step | What you do | Why |
|---|---|---|
| 1 | Review the SQL answer | A missing filter does not raise an error |
| 2 | Review the DAX answer | A valid formula can answer another question |
| 3 | Write the two follow-ups | A precise correction is a prompt too |

## 1. Review the SQL answer

**Why this step.** The manager asked: "How many completed orders do we have?" The assistant's query runs and returns one number. Nothing on the screen says it is wrong.

1. Open [Unsolved/answers_to_review.md](Unsolved/answers_to_review.md) and read Answer A.
2. Before reading its result, say what one row of `nakheel.orders` is.
3. Compare the result with the number you know: completed orders are **2,771**.

**C1.** Answer A returned **3,000**. Write in one sentence what it counted.

## 2. Review the DAX answer

**Why this step.** The manager asked: "What share of completed revenue does each category bring?" The measure is valid DAX and the visual shows a percentage on every row.

1. Read Answer B and the table under it.
2. Ask what filter is on the top number and what filter is on the bottom number when the visual is on the Outerwear row.
3. Compare with the number you know: Outerwear's share is **24.3%**.

**C2.** Answer B shows **100.0%** on every row. Write in one sentence why.

## 3. Write the two follow-ups

**Why this step.** "That's wrong, try again" gives the assistant nothing to work with. Say the number you got, the number you expected and why.

1. For each answer, write a follow-up of one or two sentences.
2. If you have an assistant open, paste the answer and your follow-up, and read what comes back.

**C3.** Each follow-up names the wrong number, the right number and the cause. Compare with `Solved/errors_named.md` when it is shown in class.

**What just happened.** Neither answer had a syntax error, so no tool caught it. A number you trusted did. Keep a few such numbers for every dataset you work on.

## Hint

Answer A: look for a `WHERE`. Answer B: a measure divided by itself, inside the same filters, is always 1.

## Bonus

Answer B's fix removes the category filter from the bottom number. Which D19 function did that?

## References

Check numbers from the D19 number registry: 3,000 orders, 2,771 completed; completed revenue 316,023.50; Outerwear 76,637.00 (24.3%).
