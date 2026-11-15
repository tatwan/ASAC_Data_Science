# Activity 01 · Write Markdown, one mark at a time

A README is a Markdown file: plain text with a few marks that GitHub turns into a page. You learn the marks by writing them in GitHub's own editor, switching to **Preview** after each step to see what a reader will see. The content is your D23 analysis, so nothing you write here is wasted.

| Step | What you add | The mark |
|---|---|---|
| 1 | A repository to hold the project | (no Markdown yet) |
| 2 | A title, a section heading and a sentence | `#`, `##`, `**bold**`, `` `code` `` |
| 3 | A list and a link | `-`, `[words](address)` |
| 4 | The day-type table | pipes and a dashes row |
| 5 | A SQL code block, then save | three backticks and `sql` |

## 1. Create the repository

**Why this step.** A repository is the folder for one project. Everything you make today for D23 goes into this one, so a reader finds it all in one place.

1. At the top right of any GitHub page, open the **+** menu and choose **New repository**.
2. **Repository name:** `austin-bikes-2023`. **Description:** `Austin bike share, 2023: SQL, BigQuery ML and Power BI`.
3. Choose **Public**. Turn on **Add a README file** (the wording may be **Add README**).
4. Click **Create repository**.

**C1.** The page shows `your-username / austin-bikes-2023` with a **Public** label, and one file, `README.md`.

## 2. A title, a section and a sentence

**Why this step.** Headings are what a reader scans first. One `#` is the title; `##` starts a section. The space after the `#` signs is required.

1. Open **Add file → Create new file**. Name the file `markdown-practice.md`. The `.md` ending tells GitHub it is Markdown.
2. Type this in the editor:

```markdown
# Austin's bikes, 2023

## The finding

Hot days had **fewer** rides. The view `v_days` has one row per day.
```

3. Click **Preview**.

**C2.** A large title, a smaller heading under it, and a sentence with **fewer** in bold and `v_days` in a grey code box.

**Why the blank lines.** Markdown starts a new paragraph only after an empty line. Two lines typed one under the other, with no empty line between them, are joined into one.

## 3. A list and a link

**Why this step.** A list lets a reader take in the method at a glance. A link sends them to the source, so they can check where the data came from.

Click **Edit**, then add at the end of the file (keep one empty line above each block):

```markdown
## Method

- SQL in BigQuery
- A model in BigQuery ML
  - LINEAR_REG
- A report in Power BI

Data from [Austin open data](https://data.austintexas.gov).
```

**C3.** In **Preview**: three bullets with `LINEAR_REG` indented under the second, and **Austin open data** in blue. Click it: the City of Austin open data portal opens.

## 4. The day-type table

**Why this step.** A table is the clearest way to show a few numbers side by side. These are the numbers from D23 Activity 01.

Click **Edit** and add:

```markdown
## Rides by day type

| Day type | Days | Rides a day |
|---|---:|---:|
| Hot | 81 | 622.6 |
| Rain | 26 | 769.5 |
| Other | 257 | 830.9 |
```

The row of dashes tells GitHub that the first row is a header. A colon on the right, `---:`, lines a column up on the right, so the decimal points sit under each other.

**C4.** In **Preview**: a table with a header and **3 rows**, the numbers lined up on the right.

## 5. A SQL code block, then save

**Why this step.** SQL pasted as plain text loses its line breaks and spacing. A code block keeps them exactly, and naming the language makes GitHub colour the keywords.

Click **Edit** and add:

````markdown
## The query

```sql
SELECT day_type, COUNT(*) AS days,
       ROUND(AVG(trips), 1) AS rides_a_day
FROM bikes.v_days
GROUP BY day_type;
```
````

Click **Preview** to check, then **Commit changes…**. In the box that opens, type the message `Add Markdown practice`, keep **Commit directly to the main branch**, and click **Commit changes**.

**C5.** In **Preview** before you commit, `SELECT`, `FROM` and `GROUP BY` are coloured. After you commit, `markdown-practice.md` appears in the repository's file list.

**What just happened.** You wrote every mark you need for a README: headings, bold, inline code, a list, a link, a table and a code block. Committing saved the file as a change with a message; Activity 02 is about those changes.

## If you fall behind

Create `markdown-practice.md` and paste the whole file below, then go back to the check you missed and compare it with **Preview**.

````markdown
# Austin's bikes, 2023

## The finding

Hot days had **fewer** rides. The view `v_days` has one row per day.

## Method

- SQL in BigQuery
- A model in BigQuery ML
  - LINEAR_REG
- A report in Power BI

Data from [Austin open data](https://data.austintexas.gov).

## Rides by day type

| Day type | Days | Rides a day |
|---|---:|---:|
| Hot | 81 | 622.6 |
| Rain | 26 | 769.5 |
| Other | 257 | 830.9 |

## The query

```sql
SELECT day_type, COUNT(*) AS days,
       ROUND(AVG(trips), 1) AS rides_a_day
FROM bikes.v_days
GROUP BY day_type;
```
````
