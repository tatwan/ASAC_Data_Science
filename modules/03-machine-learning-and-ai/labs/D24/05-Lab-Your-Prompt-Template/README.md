# Lab 05 · Your own prompt template

In this lab, you will build a prompt template you can reuse, and test it on a question whose answer you already know. Do it after class. It is not submitted or graded.

**Files:** [Unsolved/prompt_template.md](Unsolved/prompt_template.md)

**Data:** nothing is uploaded. Use the Nakheel table names (D03) or the tables of a project of your own. Send names only, never rows.

| Step | What you do | Why |
|---|---|---|
| 1 | Fill the template | The four parts stop the assistant guessing |
| 2 | Test it on a known total | A template that has never been checked is a guess too |
| 3 | Review two answers | You practise naming an error precisely |

## 1. Fill the template

**Why this step.** In class the four parts were written for you. A template makes you write them every time: the setting, the data and what one row is, the task with your definition, and the check.

1. Open [Unsolved/prompt_template.md](Unsolved/prompt_template.md) and copy it.
2. Fill it in for this question: "What is the average value of a completed order?"

**C1.** Your prompt names the tables and what one row is in each, defines the average (revenue divided by the number of orders, completed only), and gives the expected value: **114.05**.

## 2. Test it on a known total

**Why this step.** You know the answer is 114.05. If the assistant's SQL or DAX gives 45.46, it averaged the lines; if it gives 113.46, it kept every status.

1. Send your prompt to any assistant in a new chat.
2. Check the answer by reading it, and by running it if your tables or your D19 Power BI file are to hand.

**C2.** The answer divides completed revenue (316,023.50) by completed orders (2,771) and reaches 114.05.

## 3. Review two answers

**Why this step.** Reviewing is the skill you will use most: more of your time will go on checking generated work than on writing prompts.

1. Ask the assistant two more questions with your template: completed revenue for the online channel, and the number of customers with a completed order.
2. Check each against the numbers below. If one is wrong, write the follow-up: the number you got, the number you expected and why.

**C3.** Online completed revenue is **110,685.50**. Customers with a completed order are **452**.

**What just happened.** You now have a template that has passed a test, and three numbers you can use to test any tool on this data.

## More practice (not checked)

- Rewrite the template for DAX instead of SQL: name the model's tables, the relationships and the measures that already exist.
- Fill the template for your Assignment 3 data, using a check number from your own report.

## References

Check numbers from the D19 number registry (completed: 316,023.50 revenue, 2,771 orders, 452 customers, 114.05 average order; online 110,685.50).
