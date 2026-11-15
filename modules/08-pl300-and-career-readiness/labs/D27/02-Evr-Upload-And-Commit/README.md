# Activity 02 · Upload your D23 files and read the history

Your project needs its evidence: the screenshot that shows the finding and the SQL that produced it. You add both in the browser, each as a commit with a message, make one small edit, and then read the history GitHub keeps of every change.

| Step | What you add | How |
|---|---|---|
| 1 | Your screenshot, in a folder named `images` | Add file → Upload files |
| 2 | Your SQL, in a folder named `sql` | Add file → Create new file |
| 3 | One changed line in the practice file | The pencil icon |
| 4 | Nothing: you read what changed | Commits, then one commit |

## 1. Upload your screenshot into `images/`

**Why this step.** A README can show an image only if the image is in the repository. Keeping images in their own folder keeps the front page tidy, and the README will point to `images/story-page.png`.

1. On your laptop, check that you have a folder named `images` with your D23 story-page screenshot inside, named `story-page.png` (lowercase, no spaces). Crop the screenshot to the report page first: GitHub shrinks wide images, and small text becomes unreadable.
2. On the repository page, open **Add file → Upload files**.
3. Drag the **whole `images` folder** onto the page, not the file inside it. Dragging the folder keeps the folder.
4. Under the file list, type the commit message `Add D23 screenshots` and click **Commit changes**.

**C1.** The file list shows an `images` folder. Open it and click `story-page.png`: your screenshot appears.

**If the folder was not kept** and `story-page.png` sits next to `README.md`, carry on. In Activity 03, write the image path as `story-page.png` instead of `images/story-page.png`.

## 2. Add your SQL into `sql/`

**Why this step.** The SQL is how a reviewer checks your work. Typing a folder name followed by `/` in a new file's name creates that folder; GitHub has no separate "new folder" button.

1. Go back to the repository's front page (click `austin-bikes-2023` at the top). Open **Add file → Create new file**.
2. In the name box, type `sql/`. The `sql` part turns into a folder. Then type `d23_bigquery.sql`.
3. Paste your D23 SQL into the editor. If you did not keep it, open the course's [d23_bigquery.sql](../../../../07-power-bi-service/labs/D23/Resources/d23_bigquery.sql), copy it all, and paste.
4. **Commit changes…**, message `Add the D23 SQL`, **Commit changes**.

**C2.** The front page lists `images`, `sql`, `README.md` and `markdown-practice.md`. Inside `sql`, `d23_bigquery.sql` opens with numbered lines.

## 3. Edit one line

**Why this step.** Most of a project's life is small edits. A finding with its number is stronger than one without, so you change one sentence and see how GitHub records the change.

1. Open `markdown-practice.md` and click the pencil icon (**Edit this file**).
2. Change the line under **The finding**, ``Hot days had **fewer** rides. The view `v_days` has one row per day.``, to:

```markdown
Hot days averaged **622.6** rides, against 830.9 on other days.
```

3. **Commit changes…**, message `Add the numbers to the finding`, **Commit changes**.

**C3.** The file shows the new sentence with **622.6** in bold.

## 4. Read the history and one diff

**Why this step.** Every commit is kept with its message, its time and exactly what changed. This is what makes a mistake easy to undo, and why a clear message matters: it is how you will find a change later.

1. On the repository's front page, click **Commits** (the clock icon with a number, at the top right of the file list).
2. Click the commit `Add the numbers to the finding`.

**C4.** History lists **5 commits**: `Initial commit`, `Add Markdown practice`, `Add D23 screenshots`, `Add the D23 SQL`, `Add the numbers to the finding`. The last one shows **one red line** (the old sentence) and **one green line** (the new one).

**What just happened.** The repository now holds the evidence for your finding, and every change is on record with a message saying what it was. Nothing you commit is lost, which is also why nothing private should ever be committed.
