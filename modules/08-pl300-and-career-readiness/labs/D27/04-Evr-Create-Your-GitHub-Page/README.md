# Activity 04 · How to create your GitHub Page

In this activity, you will publish a one-page website about yourself at `https://your-username.github.io`. GitHub gives every account one such site, free, made from the files in one repository. You start from a finished page and replace its words with yours.

## What you will learn

- How GitHub Pages turns the files in a repository into a website
- How to read and change a simple HTML page
- How to update your site: change a file, commit, reload

## Before you start

1. Sign in to [github.com](https://github.com) ([no account yet?](../README.md#before-you-start-a-github-account)).
2. Open [github-page.zip](Resources/github-page.zip), click the **Download raw file** icon at the right, and unzip it. On Windows, right-click the file and choose **Extract All**, then work from the extracted folder and not from the ZIP's own window. On a Mac, double-click it, unless it is already a folder.

| File | What it is |
|---|---|
| `index.html` | The page: its words, in order. A website opens the file with this name first. HTML is the language web pages are written in |
| `style.css` | How the page looks: colours, sizes and spacing |

Windows may hide the endings and show `index` and `style`. They are the right files.

3. Double-click `index.html` on your computer. It opens in your browser, so you can see the page before you publish it.

> **Words used here.** A **repository** is the folder for one project, with its history. A **commit** is a saved change with a short message. `main` is the version visitors see. The **+** menu is at the top right of every GitHub page, and the **pencil** (**Edit this file**) is above a file, at the right. More in [GitHub words in plain language](../Resources/github-words.md).

## 1. Create the repository `your-username.github.io`

**Why this step.** GitHub looks for one repository whose name is your username followed by `.github.io`. Its files become the site at that address.

1. **+ → New repository**.
2. **Repository name:** your username, in small letters, then `.github.io`. If your username is `firstname-lastname`, the name is `firstname-lastname.github.io`. If your username has capital letters, type them small here.
3. Choose **Public** and turn **Add README** on. On a free account, the site needs a public repository.
4. Click **Create repository**. If GitHub says the name is taken, you already have this repository: open it and go to step 2.

**C1.** The page shows `your-username / your-username.github.io`. Apart from capitals, the two usernames match letter by letter. A spelling difference gives the site a different address.

## 2. Upload the two files

**Why this step.** The website is made of these files. They must sit at the top level of the repository, not inside a folder.

1. **Add file → Upload files**. Drag `index.html` and `style.css` onto the page: the two files, not the folder they are in.
2. Message: `Add the first version of my page`. Click **Commit changes**.

**C2.** The front page lists `README.md`, `index.html` and `style.css`, with no folder.

## 3. Turn on GitHub Pages

**Why this step.** You tell GitHub which files to publish: the `main` branch, from the top of the repository.

1. Open **Settings** (the repository's own tab, at the right of the row that starts with **Code**; on a narrow screen it is under **…**).
2. In the left menu, click **Pages**.
3. Under **Build and deployment**, set **Source** to **Deploy from a branch**, the branch to **main** and the folder to **/ (root)**. Click **Save**. If `main` is already chosen, there is nothing to save.
4. GitHub now builds the site, that is, makes the web page from your files. It can take up to 10 minutes. Go on to step 4 while it runs.

**C3.** The Pages screen shows **Deploy from a branch**, `main` and `/ (root)`.

## 4. Read the page's HTML and make it yours

**Why this step.** You will change the words without changing the layout, so you need to see which is which. HTML wraps each piece of text in a pair of **tags** that say what it is.

| In the file | What it makes |
|---|---|
| `<h1>Your Name</h1>` | The biggest heading |
| `<h2>About me</h2>` | A section heading |
| `<p>…</p>` | A paragraph |
| `<li>…</li>` | One line of a list |
| `<a href="https://…">GitHub</a>` | A link: the address inside the quotes, the words between the tags |
| `<!-- EDIT 2: … -->` | A note for you. Visitors do not see it |

The opening tag has no slash and the closing tag has one. **Change the words between the tags and leave the tags alone.** There is one exception: in `href="…"`, replace the address between the quotes, and keep both quotes and one `https://`. Do not type `<` in your own words; write `under 5`, not `<5`.

1. In the repository on GitHub, open `index.html` and click the pencil.
2. Find the notes `EDIT 1` to `EDIT 8`, one after the other, and replace the words below each:

| Note | What to write |
|---|---|
| `EDIT 1` and `EDIT 2` | Your name, and a headline: the job you want, in two to four words |
| `EDIT 3` | What you studied or worked on before, and what you do now |
| `EDIT 4` | The role you are looking for, and what you would like to work on |
| `EDIT 5` | One piece of work you can talk about, and the address of its link. It does not have to be about data |
| `EDIT 6` | The skills you can show. Delete the lines that are not yours |
| `EDIT 7` | Your education, newest first |
| `EDIT 8` | Your GitHub address and your LinkedIn address, or delete that line |

3. **Commit changes…**, message `Write my page`, **Commit changes**.

**C4.** On GitHub, open `index.html` and search (Ctrl+F, or Cmd+F on a Mac) for `your-`, then `Your Name`, then `WRITE` in capitals. None of them is left in the file. Read your headline and your skills once more: they came with the page, so check that they are true of you.

**If you have no link for a piece of work,** delete its whole line, from `<p><a` to `</a></p>`. A link that goes nowhere looks like a mistake.

## 5. Open your site

**Why this step.** This is the page a visitor sees, so check your words here.

1. Open `https://your-username.github.io` in a new tab.
2. Open it on your phone too, or send the link to someone and open theirs.

**C5.** Your page opens with your name and your words.

| What you see | What to do |
|---|---|
| A 404 page (page not found) | Wait a few minutes and reload. Then check the repository's name (C1) and that `index.html` is not inside a folder (C2) |
| The page, but with the old words | The site is built again after every commit. Wait a few minutes and reload |
| The words with no colours | `style.css` is missing, or inside a folder |
| Everything after one point looks wrong | A tag was deleted. In the repository, open `index.html`, click **History**, and compare with the first version |

## 6. Change the colour and watch the site update

**Why this step.** Updating a website is the same as updating any file: edit, commit, reload.

1. Open `style.css` in the repository and click the pencil.
2. In the line `--main: #3b4ae0;`, replace `#3b4ae0` with another colour, for example `#0f766e` (green) or `#9a3412` (brown). Keep the `#` and the semicolon.
3. **Commit changes…**, message `Change the main colour`, **Commit changes**.
4. Wait a few minutes and reload your site.

**C6.** The band at the top, the headings and the links have the new colour.

**What just happened.** You committed the files, then your words, then a colour. GitHub builds the site again after each commit to `main`.

## What you can do now

Publish a website from a repository, change its words and its look, and find out why a page does not appear.

## Challenge

Add a photo. Upload a square picture named exactly `photo.jpg`, in small letters, then add this line in `index.html`, just below `<header>`:

```html
<img src="photo.jpg" alt="Portrait of YOUR NAME" width="140" style="border-radius: 50%">
```

Expected: a round picture above your name. Photos taken with a phone can carry the place where they were taken; a screenshot of the photo does not, but save it as a `.jpg` file or use its own name, such as `photo.png`, in the line above.

## Resources

- [The files](Resources/github-page/) of the starter page. You may copy them and change them as you like
- [Creating a GitHub Pages site](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site)
- [When your site shows a 404](https://docs.github.com/en/pages/getting-started-with-github-pages/troubleshooting-404-errors-for-github-pages-sites)
