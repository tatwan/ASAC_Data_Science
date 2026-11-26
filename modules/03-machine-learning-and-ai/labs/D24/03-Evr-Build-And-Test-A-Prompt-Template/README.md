# Activity 03 · Build, test and version a prompt template

In this activity, you will take a prompt template for Nakheel questions, test it on four questions whose answers you already know, fix what fails, and save the result as version 2 on a library card, the way a team keeps prompts it relies on.

**Files:** [Unsolved/library_card.md](Unsolved/library_card.md) (version 1 of the template and an empty test table)

**Data:** nothing is uploaded. You send table and column names only: `nakheel.orders`, `nakheel.order_items` and `nakheel.products` (D03). The data covers orders from 1 September 2024 to 31 August 2026 ([dataset README](../../../../../shared/datasets/nakheel/README.md)).

| Step | What you do | Why |
|---|---|---|
| 1 | Read version 1 and put your name on it | A template has an owner |
| 2 | Run the four tests | A template that was never tested is a guess |
| 3 | Fix what failed and write version 2 | Change the template, not the question |
| 4 | Run all four tests again | A fix can break something that worked |
| 5 | Keep the library card | The next person needs the version, the tests and the change note |

## 1. Read version 1 and put your name on it

**Why this step.** In a team, every prompt that people reuse has a name, a version and an owner, so everyone knows which one ran and who answers for a change.

1. Open [Unsolved/library_card.md](Unsolved/library_card.md) and copy it into a document of your own.
2. Fill in **Owner** with your name.
3. Read the template. Find the fixed parts (setting, data, rules, how to answer) and the three variables in braces: `{question}`, `{definition}`, `{check}`.

**C1.** You can say what each fixed part tells the assistant, and which three parts change from one question to the next.

## 2. Run the four tests

**Why this step.** You test a template the way you test a query: with questions whose answers you already know. The known answers stay out of the prompt, so the assistant cannot simply repeat them back.

1. For each test in the table below, copy the template, replace the three variables with that test's values, and send it in a **new chat** (a temporary chat if your assistant has memory turned on).
2. Read the assumptions the assistant lists, then the SQL. Decide whether the query would return the known answer. If your `nakheel` tables still exist in BigQuery, run it.
3. Record **Pass** or **Fail** for version 1 on the library card, with one line on why.

| Test | `{question}` | `{definition}` | `{check}` | Known answer |
|---|---|---|---|---:|
| 1 | What is the average value of a completed order? | Completed revenue divided by the number of completed orders; each order counted once | One row, one number | 114.05 |
| 2 | What is completed revenue from the online channel? | Revenue as in the rules, for orders with channel = 'online' | One row, one number | 110,685.50 |
| 3 | How many customers have at least one completed order? | Each customer counted once | One row, one number | 452 |
| 4 | How many customers have not placed a completed order in the last 90 days? | Customers with at least one completed order whose last completed order is more than 90 days ago | One row, one number | 280 |

**C2.** You have a result for each test. With most assistants, tests 1 to 3 pass and test 4 fails: the query counts the 90 days back from `CURRENT_DATE()`, so it returns 447 (on 26 November 2026) or 452 (from 30 November 2026) instead of 280.

## 3. Fix what failed and write version 2

**Why this step.** When a test fails, the fix goes into the template, so every later question gets it. Changing only the one question fixes nothing for the next person.

1. For each failed test, decide what the template did not tell the assistant. Look at the assumptions it listed.
2. Add that to the fixed parts of the template. For test 4: the period the data covers, and the date to measure "the last N days" from.
3. Change **Version** to 2 and write a one-line **change note**: what you changed and which test it fixes.

**C3.** Version 2 has a PERIOD part that says the data ends on 31 August 2026, and the change note names test 4.

## 4. Run all four tests again

**Why this step.** Teams run every test after every change, not only the one that failed. A new line in a template can change answers that were right before.

1. Run tests 1 to 4 on version 2, each in a new chat.
2. Record the version 2 results on the library card.

**C4.** All four tests pass on version 2. Test 4 now counts back from 31 August 2026 and gives 280.

## 5. Keep the library card

**Why this step.** The card is what a team would keep in its prompt library: what the template is for, who owns it, the version, the tests with their known answers, and what changed.

1. Check the card has every part filled in.
2. Save it where you keep your own work. You will reuse it for your own data.

**What just happened.** You did what companies do with prompts they rely on, at the size of one analyst: a named, owned template; tests with known answers; a failure found by a test, fixed in the template, recorded in a change note; and every test run again. In a product, the same steps happen in code, with review and a way to roll back.

## Check yourself

| Test | Known answer | A query that passes | Common wrong answers |
|---|---:|---|---|
| 1 | 114.05 | Divides completed revenue by `COUNT(DISTINCT order_id)`, or averages one total per order | 45.46 (average of the lines); 113.46 (every status kept) |
| 2 | 110,685.50 | Sums `qty * price` for completed online orders | 351,733.50 (`order_total` summed after the join to the lines); 119,768.00 (every status kept) |
| 3 | 452 | `COUNT(DISTINCT customer_id)` over completed orders | 2,771 (one customer counted once per order) |
| 4 | 280 | Counts 90 days back from 31 August 2026, or from `MAX(order_date)` | 447 or 452 (counted back from today) |

## Hint

If the assistant's assumption list says anything about "today" or "the current date", that is test 4's failure before you read any SQL.

## Bonus

- Write a DAX version of the template: name the model's tables, the relationships and the measures that already exist, and test it on tests 1 and 2.
- Swap cards with a classmate. Run their version 2 on one test and tell them whether it passed.

## References

Nakheel Retail: course-generated synthetic data. Known answers computed from `shared/datasets/nakheel/` (orders and order_items) and the D19 number registry; checked 26 November 2026.
