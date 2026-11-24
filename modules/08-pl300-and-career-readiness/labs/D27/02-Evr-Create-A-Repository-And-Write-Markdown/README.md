# Activity 02 · How to create a repository and write Markdown

In this activity, you will make your first repository and write a recipe in it: a peanut butter sandwich. A recipe has a title, a list, steps, a table and a link. A project page uses the same parts. You write them in **Markdown**: plain text with a few marks that GitHub turns into a page.

## What you will learn

- How to create a public repository
- How to write headings, bold text, lists, links and tables in Markdown
- How to save a change as a commit with a useful message
- How to read what changed, and how to find an older version

## Before you start

Sign in to [github.com](https://github.com) ([no account yet?](../README.md#before-you-start-a-github-account)). Nothing else is needed.

## 1. Create the repository

**Why this step.** A repository is the folder for one project. Anything you put in it is kept together, with its history.

1. At the top right of any GitHub page, open the **+** menu and choose **New repository**.
2. **Repository name:** `sandwich-recipe`. **Description:** `A peanut butter sandwich, step by step`.
3. Choose **Public**.
4. Turn **Add README** on. (On some screens it is a box, **Add a README file**.)
5. Click **Create repository**.

**C1.** The page shows `your-username / sandwich-recipe`, the word **Public**, and one file, `README.md`.

## 2. Write a title, a section and a sentence

**Why this step.** Headings are what a reader scans first. One `#` makes the title and two make a section. The space after the `#` is required.

1. Click `README.md`, then the **pencil** icon (**Edit this file**).
2. Delete what is there and type:

```markdown
# Peanut butter sandwich

A **five-minute** lunch for one person.

## What you need
```

3. Click **Preview**.

**C2.** A large title, a sentence with **five-minute** in bold, and a smaller heading under it.

**What just happened.** You typed plain text with three kinds of mark (`#`, `##` and `**`), and GitHub drew a page. **Edit** shows what you typed; **Preview** shows what a visitor will see. Switch between them after every change.

## 3. Add a list and numbered steps

**Why this step.** A dash makes a bullet, for things in any order. A number makes a step, for things that must happen in order.

Click **Edit**, go to the end, press Enter and add:

```markdown
- 2 slices of bread
- Peanut butter
- Jam
  - Strawberry, if you have it

## Steps

1. Spread peanut butter on one slice.
2. Spread jam on the other.
3. Put them together and cut.
```

If the editor types a dash or a number for you when you press Enter, delete the extra one.

**C3.** In **Preview**: three bullets, with the strawberry line indented under **Jam**, then steps 1 to 3.

## 4. Add a table and a link

**Why this step.** A table puts a few numbers side by side. A link lets a reader go to the source and check.

Click **Edit**, go to the end and add this, with one empty line above the heading:

```markdown
## For more people

| People | Slices of bread | Spoons of peanut butter |
|---|---:|---:|
| 1 | 2 | 1 |
| 4 | 8 | 4 |
| 10 | 20 | 10 |

Read about [peanut butter](https://en.wikipedia.org/wiki/Peanut_butter).
```

The row of dashes tells GitHub that the row above it is the header. The colon in `---:` lines that column up on the right, which is how numbers are easiest to compare.

**C4.** In **Preview**: a table with a header and **3 rows**, numbers on the right, and a blue link.

## 5. Save it as a commit

**Why this step.** On GitHub, saving is called a **commit**. Each commit asks for a short message saying what changed, because that is how you and others find the change later.

1. Click **Commit changes…** at the top right.
2. Replace the suggested message with `Write the sandwich recipe`.
3. Keep **Commit directly to the main branch** and click **Commit changes**.

**C5.** Your recipe is drawn as a page, and the repository's front page now shows it under the file list.

## 6. Change one line and read the history

**Why this step.** This is what a repository gives you that a folder on your laptop does not: every version, with what changed.

1. Open `README.md`, click the pencil, and change `cut` in step 3 to `cut it into triangles`.
2. **Commit changes…**, message `Say how to cut the sandwich`, **Commit changes**.
3. On the repository's front page, click **Commits** (the clock icon).
4. Click `Say how to cut the sandwich`.

**C6.** The history lists **3 commits**: `Initial commit`, `Write the sandwich recipe`, `Say how to cut the sandwich`. The last one shows **one red line** and **one green line**.

5. Go back to the list of commits. On the line of `Write the sandwich recipe`, click the **`<>`** icon (**Browse repository at this point**). You see the repository as it was before the last change. Click `your-username / sandwich-recipe` at the top to return to the latest version.

**What just happened.** Nothing was lost. You changed the recipe, and the earlier version is one click away. Anything you commit by mistake also stays in the history, so read it through before you commit.

## If you fall behind

Open `README.md`, click the pencil, delete everything, paste this, and commit with the message `Write the sandwich recipe`. Then do step 6.

```markdown
# Peanut butter sandwich

A **five-minute** lunch for one person.

## What you need

- 2 slices of bread
- Peanut butter
- Jam
  - Strawberry, if you have it

## Steps

1. Spread peanut butter on one slice.
2. Spread jam on the other.
3. Put them together and cut.

## For more people

| People | Slices of bread | Spoons of peanut butter |
|---|---:|---:|
| 1 | 2 | 1 |
| 4 | 8 | 4 |
| 10 | 20 | 10 |

Read about [peanut butter](https://en.wikipedia.org/wiki/Peanut_butter).
```

## What you can do now

Create a repository, write a page in Markdown, save it with a message, and find any earlier version.

## Challenge

Add a file for a dish you like: on the front page, **Add file → Create new file**, and name it `recipes/my-dish.md`. Typing `recipes/` makes a folder. Use at least one heading, one list and one table. The folder `recipes` should appear in the file list.

## Resources

- [Markdown cheat sheet](../Resources/markdown-cheat-sheet.md)
- [Basic writing and formatting syntax](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)
