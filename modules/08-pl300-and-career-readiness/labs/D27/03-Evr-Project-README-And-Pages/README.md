# Activity 03 · Your project README, then GitHub Pages

The README is the page an employer reads. Its first screen should answer the question: what you found, with a number, and the screenshot that proves it. How you did it comes after, for the reader who wants to check. Then you publish the same README as a small website with GitHub Pages.

| Step | What the reader needs | Section |
|---|---|---|
| 1 | A page with the right sections in the right order | The template |
| 2 | What you found, first | Finding |
| 3 | The proof and how to check it | Screenshot, more findings, limits |
| 4 | A link that opens without a code site | GitHub Pages |

## 1. Put the template into `README.md`

**Why this step.** The template has the eight parts of a portfolio README in reading order, and the question, data and method already filled in from D23. You only write the parts that are yours.

1. Open the [README template](../Resources/README-template.md). Click **Raw** (above the file, top right), select all and copy.
2. In your repository, open `README.md` and click the pencil icon. Select all of its text, delete it, and paste the template.
3. Click **Preview**.

**C1.** Preview shows the title **Austin's bikes, 2023**, a bold **Finding:** line in capitals, your screenshot, and the sections *The question*, *The data*, *Method*, *More findings*, *Limits*, *Tools*.

If the screenshot shows as a broken icon, your image is not at `images/story-page.png`. Check the folder and the file name (letter case counts), and fix the path in the line that starts with `![`.

## 2. Write the finding, with its number

**Why this step.** Many readers stop after the first screen. A sentence that names the tools tells them nothing; a sentence with a finding and a number tells them what you can do.

Click **Edit** and replace the capitals after **Finding:** with your own sentence. Use your own words and your own D23 numbers. For example:

> Austin's bikes follow the school calendar first and the heat second: October averaged 1,249 rides a day, July 531.

Then replace the line in italics under the screenshot with what the reader should look at, for example: *October is the busiest month; June and July, without classes, are the quietest.*

**C2.** In **Preview**, the first line under the title states a finding with at least one number from your D23 work.

## 3. More findings and the limits

**Why this step.** Two or three more findings show the depth of the work. The limits show judgement: they tell a reader what not to conclude, which builds trust.

Replace the capitals under **More findings** and **Limits**. D23 gives you several to choose from:

| Finding | Number |
|---|---|
| With the month held fixed, a hot day has fewer rides | about 226 fewer (model weights) |
| October against December, same weekday and weather | about 705 more rides a day |
| Students took most of the trips | 51.4% of 283,964 |
| The model beats a simple guess | off by 171.4 rides a day, against 271.1 for the median |

| Limit | Why |
|---|---|
| 2023 only | Rider types changed on 24 July 2024, so later years do not compare |
| Stations table out of date | 11 of the 82 station numbers used in 2023 are missing from it |
| One weather station | Camp Mabry stands for the whole city |

Click **Commit changes…**, message `Write the project README`, **Commit changes**.

**C3.** The repository's front page shows your README under the file list: the finding, then the screenshot. Click the **sql/d23_bigquery.sql** link in *Method*: your SQL opens.

## 4. Turn on GitHub Pages

**Why this step.** Some readers will never open a code site. GitHub Pages publishes the same README as a web page, at an address made of your username and the repository name. On a free account the repository must be public, and yours is.

1. In the repository, click **Settings** (the tab at the top right; under **…** on a narrow screen).
2. In the left menu, click **Pages**.
3. Under **Build and deployment**, set **Source** to **Deploy from a branch**. Set the branch to **main** and the folder to **/ (root)**. Click **Save**.
4. Leave it to build and go on to Activity 04. GitHub says a site can take up to 10 minutes to appear.

**C4.** The Pages settings show the branch `main` and the folder `/ (root)` as saved. A few minutes later, the top of the page says your site is live at `https://your-username.github.io/austin-bikes-2023/`, with a **Visit site** button.

**What just happened.** Your README now leads with the answer and backs it with a screenshot, findings, limits and the SQL. The same file is about to become a website: Pages uses `README.md` as the home page when there is no `index` file, and rebuilds it after every commit.
