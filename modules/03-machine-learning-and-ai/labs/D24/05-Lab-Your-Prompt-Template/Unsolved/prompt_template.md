# A prompt template for an analyst

Copy this and fill each part. Send table and column names only, never rows.

```text
THE SETTING
[The language and the tool: BigQuery SQL, or DAX in Power BI. The dataset or model name.]

THE DATA
[Each table as name(columns): one row is one ___]
[For DAX: the relationships, and the measures that already exist.]

THE TASK
[The question in one sentence.]
[Your definition of every number in it, and which rows count.]

THE CHECK
[What the result should look like: how many rows, and a total or a value you know.]

HOW TO ANSWER
[Explain the joins or the filters in two lines, then give the code.]
```
