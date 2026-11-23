# Activity 01 · The same question, with and without the schema

In this activity, you will ask an assistant for the same SQL twice: once in one line, and once with the context an analyst would give. Then you check the second answer against a number you already know.

**Files:** [Unsolved/prompts.md](Unsolved/prompts.md) (the two prompts to copy)

**Data:** nothing is uploaded. You send table and column names only. The tables are `nakheel.orders`, `nakheel.order_items` and `nakheel.products` (D03).

| Step | What you do | Why |
|---|---|---|
| 1 | Send the short prompt | See what the assistant guesses |
| 2 | Send the full prompt in a new chat | See what context changes |
| 3 | Check the SQL | Decide whether you can use it |
| 4 | Write one line | Say what the context was worth |

## 1. Send the short prompt

**Why this step.** An assistant always answers. When you leave something out, it fills the gap with a guess, and the guess looks as confident as a fact.

1. Open any AI assistant in your browser and start a new chat.
2. Send exactly this:

```text
Write SQL for revenue by category.
```

3. Read the SQL it wrote. Do not run it.

**C1.** Write down three things the assistant decided for you. Usual ones: the table name, the name of the revenue column, and whether cancelled orders count.

## 2. Send the full prompt in a new chat

**Why this step.** The four parts below are what you would tell a new colleague: the setting, the data and what one row is, the task with your definition, and a number the answer must reach.

1. Start a **new chat**, so the first answer is not in the context.
2. Copy the full prompt from [Unsolved/prompts.md](Unsolved/prompts.md) and send it. It starts with `BigQuery SQL. Dataset: nakheel.`
3. Read the explanation of the joins first, then the SQL.

**C2.** The SQL uses your three table names, joins `order_items` to `orders` on `order_id` and to `products` on `product_id`, keeps only `status = 'completed'`, and sums `qty * price`.

## 3. Check the SQL

**Why this step.** A query that reads well can still be wrong. You know the answer already, so use it.

1. Compare the assistant's SQL with the three points in C2. If one is missing, tell the assistant which one and why, in one sentence, and read the corrected SQL.
2. If your `nakheel` tables still exist in BigQuery, run the SQL. Sandbox tables expire 60 days after they were made, so yours may be gone; in that case compare with the result below.

**C3.** The result has 6 rows and adds up to **316,023.50**:

| category | revenue |
|---|---:|
| Outerwear | 76,637.00 |
| Shoes | 62,373.50 |
| Bottoms | 50,535.00 |
| Accessories | 43,525.00 |
| Sportswear | 42,365.00 |
| Tops | 40,588.00 |

## 4. Write one line

Finish this sentence in your notes: "The second prompt gave the assistant ___, so it did not have to guess ___."

**What just happened.** You did four of the five steps yourself: you framed the task, gave the context, checked the answer and decided. The assistant did one step. That split is the same in every tool.

## Hint

If the total is 988,971.50, the SQL summed `order_total` after joining to the lines. `order_total` belongs to an order and repeats on each of its lines.

## Bonus

Add one line to the full prompt: "Return the categories from highest revenue to lowest, with a share of total column." Check that Outerwear's share is 24.3%.

## References

Nakheel Retail: course-generated synthetic data. Check numbers from the D19 number registry.
