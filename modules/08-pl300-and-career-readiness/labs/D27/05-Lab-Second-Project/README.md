# Lab 05 · A second project, the same way

A portfolio grows one project at a time. Your Assignment 1 SQL on international football results is a second project an employer can read. You give it the same shape as `austin-bikes-2023`: the finding first, then the evidence. Nothing here is graded or submitted.

| Step | What you build | Check |
|---|---|---|
| 1 | The repository and the SQL | `sql/` holds your A1 queries |
| 2 | A README with the finding first | The first screen shows a finding and a number |
| 3 | GitHub Pages and a pin | Your profile pins two projects |
| 4 (optional) | A Pages theme | The website has a styled header |

## 1. The repository and the SQL

**Why this step.** Each project gets its own repository, so each one can be pinned and linked on its own.

Use your Week 1 repository `asac-sql-portfolio` if you have it; otherwise create a public repository with that name and **Add a README file**. Then add your A1 queries with **Add file → Create new file**, a name such as `sql/01-goals-by-decade.sql`, one query per file. Wait until Assignment 1 has been graded before you publish your answers.

**C1.** `sql/` lists your query files, each opening with numbered lines.

## 2. A README with the finding first

**Why this step.** The same rule as Activity 03: the first screen answers the question.

Copy the [README template](../Resources/README-template.md) into `README.md` and adapt it: the question A1 asked, your two or three findings with their numbers, the data (international football results, with its source and licence from the A1 brief), the method (the SQL you used, for example a CTE and a window function), and one or two limits. If you have no screenshot, delete the image line, or upload a screenshot of a BigQuery result into `images/`.

**C2.** The repository's front page shows a finding with a number as its first line.

## 3. GitHub Pages and a pin

**Why this step.** Two pinned projects show a range of work, from SQL to a published report.

Turn on Pages as in Activity 03 step 4, add a one-line description beside **About**, then add the project to your profile with **Customize your pins**. Add it to the **Projects** list of your profile README as well, with both links.

**C3.** Your profile shows two pinned projects, each with a one-line finding.

## 4 (optional). A theme for your Pages site

**Why this step.** A theme gives the website a header and nicer type with one line of text. GitHub supports a list of Jekyll themes, among them Minimal, Cayman and Slate.

In the repository, **Add file → Create new file**, name it `_config.yml`, and type one line:

```yaml
theme: jekyll-theme-minimal
```

Commit with the message `Add a Pages theme`. A few minutes later, reload your website.

**C4.** The website shows the repository name in a styled header beside your README.

## After Assignment 3 is graded

Make a third repository the same way: your report's screenshots, the story, the data and its licence, and the limits. Do not publish Assignment 3 before it is graded.
