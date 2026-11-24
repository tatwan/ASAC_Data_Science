# Activity 01 · How to read a repository

In this activity, you will look around a real repository, the one that holds this course, and find its files, its history and one change somebody made. You create nothing yet.

## What you will learn

- How to say what a repository is, and who owns it
- How to open a file, and how GitHub shows data, SQL and text differently
- How to read a commit: who changed what, and when
- How to keep a repository for later with a star

## Before you start

Sign in to [github.com](https://github.com) ([no account yet?](../README.md#before-you-start-a-github-account)). Nothing else is needed.

## 1. Open the repository and read its front page

**Why this step.** Most of what you will use on GitHub is other people's repositories. They all have the same front page, so learning one teaches you all of them.

1. Open [github.com/tatwan/ASAC_Data_Science](https://github.com/tatwan/ASAC_Data_Science).
2. Read the two names at the top: `tatwan` / `ASAC_Data_Science`. The first is the **owner**, the second is the **repository**, the folder for one project.
3. Find the list of files and folders. Beside each one is the message of the last change made to it.
4. Scroll down past the list. What you see there is the file `README.md`.

**C1.** The file list shows the folders `course`, `modules` and `shared`, and the file `README.md`. Beside the repository's name is the word **Public**.

## 2. Open three kinds of file

**Why this step.** A visitor should be able to read your work without downloading it. GitHub shows each kind of file in the way that suits it.

1. A table: open [`shared/datasets/ml_classics/penguins.csv`](https://github.com/tatwan/ASAC_Data_Science/blob/main/shared/datasets/ml_classics/penguins.csv). GitHub shows the CSV as rows and columns, with a search box above it. Type `Torgersen`.
2. Code: open [`d23_bigquery.sql`](https://github.com/tatwan/ASAC_Data_Science/blob/main/modules/07-power-bi-service/labs/D23/Resources/d23_bigquery.sql). The lines are numbered and the SQL words are coloured.
3. Text: open [the README of the datasets folder](https://github.com/tatwan/ASAC_Data_Science/blob/main/shared/datasets/README.md), then click **Code** above it, beside **Preview**. You see the plain text and marks the page is made from. That is **Markdown**: plain text with a few marks, such as `#` for a heading.

**C2.** You have seen a CSV as a table, SQL with coloured words, and one README two ways: as a page and as plain text.

## 3. Read the history and one change

**Why this step.** A shared folder shows you only the latest version. GitHub keeps every saved change, with the person, the time and the exact lines. This is the main reason teams use it.

1. Go back to [the front page](https://github.com/tatwan/ASAC_Data_Science) and click **Commits** (the clock icon with a number, at the top right of the file list). Each line is one **commit**: one saved change.
2. Open this commit: [d711401](https://github.com/tatwan/ASAC_Data_Science/commit/d711401).
3. Read the **diff**. Lines that were removed are red with a `−`; lines that were added are green with a `+`. GitHub also darkens the words that changed inside the line.

**C3.** The commit changed **one file**, with **one red line** and **one green line**. Tarek added one sentence at the end of the line, about the number of trips left after cleaning: 168,547 and 48,791.

**Why two lines for one small edit?** GitHub compares files line by line. Change one word and it reports the old line as removed and the new line as added.

## 4. Star it, and find how to download

**Why this step.** You will want to find good repositories again, and sometimes take one file from them.

1. At the top right of the repository, click **Star**. A star is a bookmark: your starred repositories are listed under your profile picture, in **Your stars** (or **Stars**).
2. Click the green **Code** button. **Download ZIP** would give you the whole repository as one file. This one is large, so do not download it now.
3. Open `penguins.csv` again and find the **Download raw file** icon above the table, at the right. That is how you take a single file.

**C4.** The **Star** button now says **Starred**, and you know where **Download ZIP** and **Download raw file** are.

## 5. See a profile and a website made from repositories

**Why this step.** You have read a repository. A repository can also become a profile page or a website. You can make both today.

| Open | What it is | You make yours in |
|---|---|---|
| [github.com/tatwan](https://github.com/tatwan) | A profile: a README about a person, with their best repositories pinned below it | Activity 05 |
| [tatwan.github.io](https://tatwan.github.io) | A website made from the files in a repository | Activity 04 |
| [github.com/tatwan/tatwan](https://github.com/tatwan/tatwan) | The repository behind the profile. Its name is the same as its owner's | Activity 05 |

On Tarek's profile, look for four things: who he is, what he does, how to reach him, and the pinned repositories.

**C5.** You can point at the README on the profile and at the repository it comes from.

## What you can do now

Open any repository and say who owns it, what is in it, what changed last, and who changed it.

## Challenge

Search GitHub (the search box at the top) for a subject you care about, for example `football data` or `recipes`. Open one repository and answer four questions: who owns it, what is it for, when was the last commit, and does the README tell you enough to use it?

## Resources

- [About repositories](https://docs.github.com/en/repositories/creating-and-managing-repositories/about-repositories)
- [GitHub words in plain language](../Resources/github-words.md)
