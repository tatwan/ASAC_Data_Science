# Activity 06 · How to propose a change

In this activity, you will change a packing list the way a team changes a project: note what is needed, make the change on a copy, show it to others, and accept it. You play both parts, the person who asks and the person who agrees.

## What you will learn

- How to write an issue
- How to make a change on a branch, so `main` stays as it was
- How to open a pull request, read what it would change, and merge it
- How a pull request closes its issue

## Before you start

Sign in to [github.com](https://github.com) ([no account yet?](../README.md#before-you-start-a-github-account)). Nothing else is needed.

> **Words used here.** A **repository** is the folder for one project, with its history. A **commit** is a saved change with a short message. `main` is the version visitors see. The **+** menu is at the top right of every GitHub page, and the **pencil** (**Edit this file**) is above a file, at the right. More in [GitHub words in plain language](../Resources/github-words.md).

**Issue, branch, pull request and merge**

| Word | What it is | In the packing list |
|---|---|---|
| **Issue** | A note about something to fix or add | "It rains there in May. Add a rain jacket" |
| **Branch** | A separate copy where you make changes | The list with the rain jacket in it |
| **Pull request** | A request to bring those changes into `main` | "Please look at my list" |
| **Merge** | Accepting the request | The jacket is now on everybody's list |

## 1. Create the repository and its first list

**Why this step.** You need something to change. A packing list is short enough to see every change at a glance.

1. **+ → New repository**. **Repository name:** `trip-packing-list`. Choose **Public** and turn **Add README** on. **Create repository**.
2. Open `README.md`, click the pencil, delete what is there and type:

```markdown
# Packing list for a weekend trip

- Passport
- Phone charger
- Walking shoes
```

3. **Commit changes…**, message `Start the packing list`, keep **Commit directly to the main branch**, **Commit changes**.

**C1.** The front page shows a list of three things.

## 2. Open an issue

**Why this step.** People forget an idea mentioned in passing. An issue records it, gives it a number, and gives people a place to discuss it.

1. Open the **Issues** tab and click **New issue**.
2. **Title:** `Add a rain jacket`. **Description:** `It rains there in May.`
3. Click **Create** (or **Submit new issue**).

**C2.** The issue is **Open** and its title ends in **#1**. That number is its name from now on.

## 3. Make the change on a branch

**Why this step.** `main` is what everyone sees. On a branch you can try a change without touching it.

1. Go back to the **Code** tab, open `README.md`, click the pencil, and add a line **between Passport and Phone charger**:

```markdown
- Rain jacket
```

2. Click **Commit changes…**. Message: `Add a rain jacket to the list`.
3. This time, choose **Create a new branch for this commit and start a pull request**. Name the branch `add-rain-jacket`.
4. Click **Propose changes**. GitHub opens a page for a pull request. Leave it open.

**C3.** Open your repository's front page in a second tab. The list still has **three** things: `main` has not changed. Now open the menu that says **main**, above the file list, and choose `add-rain-jacket`. The list has **four**.

## 4. Open the pull request

**Why this step.** A pull request shows others what you would like to change and why, before it happens.

1. Return to the first tab. In the description, type:

```text
It rains there in May, so everyone needs a jacket.

Closes #1
```

2. Click **Create pull request**.
3. Open the **Files changed** tab.

**C4.** **Files changed** shows one file and **one green line**: `- Rain jacket`. The pull request has its own number, **#2**.

**Why `Closes #1`?** It ties the request to the issue. When the pull request is merged, GitHub closes issue 1 by itself.

## 5. Review it and merge

**Why this step.** In a team, someone else reads the change first, and the discussion stays with it. Today that person is you.

1. In **Files changed**, hover over the green line, click the blue **+**, write `Good idea. A light one is enough.` and click **Add single comment** (or **Comment**).
2. Open the **Conversation** tab. Click **Merge pull request**, then **Confirm merge**.
3. Click **Delete branch**. The change is in `main` now, so the branch is no longer needed.

**C5.** The pull request is **Merged**. Open the **Code** tab: the list on `main` has **four** things. Open the **Issues** tab and click **Closed**: issue 1 is there, closed by your pull request.

**What just happened.** The issue holds the reason, the pull request shows the added line, and the history shows when it was merged. Someone new to the project can read all three.

## What you can do now

Suggest a change to a project, show exactly what it would change, and bring it in without touching `main` until it is agreed.

## Challenge

Do it with someone else's list. Open a classmate's `trip-packing-list`, open its `README.md` and click the pencil. You cannot change their repository directly, so GitHub offers to make your own copy of it, called a **fork**: click **Fork this repository**. Add one useful thing, click **Propose changes**, then **Create pull request**. Ask them to merge it.

Expected: your line is on their list, and your name is in their history.

## Resources

- [Hello World](https://docs.github.com/en/get-started/using-github/hello-world), GitHub's own version of this exercise
- [Linking a pull request to an issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue)
- [GitHub words in plain language](../Resources/github-words.md)
