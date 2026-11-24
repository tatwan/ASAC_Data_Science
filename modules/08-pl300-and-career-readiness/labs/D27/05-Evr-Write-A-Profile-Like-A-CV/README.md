# Activity 05 · How to write a profile that reads like your CV

In this activity, you will write the page people see when they open `github.com/your-username`. It works like a CV that links to the evidence: who you are, what you want to do, what you can show, and how to reach you.

## What you will learn

- How to make GitHub show a README at the top of your profile
- How to write a headline, an about section and a goal that say something specific
- How to list skills, with or without badges (small coloured labels)
- How to fill in the rest of the profile: photo, bio, links and pinned repositories

## Before you start

Sign in to [github.com](https://github.com) ([no account yet?](../README.md#before-you-start-a-github-account)). Open [github.com/tatwan](https://github.com/tatwan) in another tab, as an example of a full profile. Yours will be shorter, and that is fine.

| Section on Tarek's profile | What it tells a visitor | Your version today |
|---|---|---|
| The title and the line of roles | Who this is | Your name and a headline |
| The badges under it | Where else to look | LinkedIn and your GitHub Page |
| About Me | The work, in a few sentences | Two or three sentences |
| What I Offer | What to ask for | What you want to do |
| Recognition & Achievements | Why to believe it | Education and training |
| Technical Expertise | Tools and languages | Skills you can show |
| What You'll Find Here | What is in the repositories | Your work |
| How to Reach Me | What to do next | Contact |

> **Words used here.** A **repository** is the folder for one project, with its history. A **commit** is a saved change with a short message. `main` is the version visitors see. The **+** menu is at the top right of every GitHub page, and the **pencil** (**Edit this file**) is above a file, at the right. A **README** is the file GitHub shows first; it is written in **Markdown**, plain text with marks such as `#` for a heading. More in [GitHub words in plain language](../Resources/github-words.md).

## 1. Create the repository named after your username

**Why this step.** GitHub shows a README on your profile when four things are true: the repository's name is exactly your username, it is public, it has a file named `README.md` at its top level, and that file is not empty.

1. **+ → New repository**.
2. **Repository name:** your username, exactly as it is written on your profile.
3. Choose **Public** and turn **Add README** on.
4. **C1.** Before you go on, look under the name. GitHub says that this repository is special: its `README.md` will appear on your public profile. If you see no such message, compare the spelling with your username.
5. Click **Create repository**. If GitHub says the name is taken, you already have this repository: open it and go to step 2.

## 2. Put the template in, and write your name and headline

**Why this step.** A visitor decides in a few seconds whether to read on. Your name and one line say who you are.

1. In the new repository, open `README.md` and click the pencil. Delete what is there (GitHub puts in a short example of its own).
2. Open the [profile template](Resources/profile-template.md), click the **Copy raw file** icon above it, and paste it in.
3. Replace `Your Name`, and write your headline: the job you want, and the two or three tools you would use in it.
4. Two badges sit under the headline. In the first, replace `your-profile` with the part after `/in/` in your LinkedIn address. In the second, replace `your-username`. **If you have no LinkedIn or no GitHub Page, delete that whole line.**

**C2.** In **Preview**: your name in large letters, your headline in bold, and the badges you kept.

**How a badge works.** `[![words](picture address)](link address)` is an image inside a link. The picture is drawn by [shields.io](https://shields.io) from its address: `badge/LinkedIn-connect-blue` gives a blue badge with the words *LinkedIn* and *connect*. The second address is where a click goes.

## 3. Write about yourself and what you want to do

**Why this step.** A CV lists jobs and dates. These two sections say who you are and what work you want. They are the hardest to write, because general words come first. Ask of each sentence: could someone else have written it?

| Too general | Specific |
|---|---|
| I am a motivated and hard-working person. | I worked three years in a pharmacy, where I kept the stock records in Excel. |
| I am passionate about data. | I like finding out why two reports disagree. |
| Looking for opportunities in a dynamic company. | I am looking for a junior analyst role in retail or health care, where I can build reports people use every week. |

1. Under **About me**, write two or three sentences: what you did or studied before, what you can do now, and one thing that makes you different.
2. Under **What I want to do**, write the role, the kind of organisation or subject, and what you want to get better at.

**C3.** Read both sections aloud, to someone if you can. After one reading, they can say what you want to do.

## 4. Education, skills and languages

**Why this step.** Like a CV, these are lists. Keep them short enough to read at a glance.

1. Under **Education and training**, list the newest first. Include this programme.
2. Under **Skills I can show**, keep only what you could talk about for two minutes. Delete the rest.
3. Under **Languages**, list the ones you can work in.

**C4.** Every skill on your list is something you have done at least once, and can describe.

**Badges for skills.** If you like coloured badges better than plain words, use this pattern, one for each skill: `![SQL](https://img.shields.io/badge/SQL-3B4AE0)`. Replace the two `SQL`s with the name and keep the colour, or change it. A space in a name is written `_`, as in `Power_BI`, and a hyphen is written `--`.

## 5. Your work and how to reach you

**Why this step.** A reader can click from your profile to the work and check it.

1. Under **My work**, write one line for each thing you made: its name, what you did, what came out of it. Link it when there is something to open.
2. If you have nothing public yet, keep the line **Coming next** and say what you are working on.
3. Under **How to reach me**, keep only what you want strangers to see.
4. **Commit changes…**, message `Write my profile`, **Commit changes**.

**C5.** Open `github.com/your-username`. Your README is at the top of the page. Click every link in it: each one opens. Then open `README.md` in the repository, click **Code**, and search it (Ctrl+F, or Cmd+F on a Mac) for `your-` and for `WRITE` in capitals: nothing is left from the template.

## 6. Photo, bio and links

**Why this step.** The column at the left of your profile is shown to everyone, and GitHub shows your photo and name beside everything you do.

1. On your profile, click **Edit profile** under your picture (or open **Settings → Public profile**).
2. Fill in **Name**, **Bio** (up to 160 characters: your headline works), **Location** (a city is enough) and the links to LinkedIn and to your GitHub Page, if you have them. Save.
3. To add a photo: **Settings → Public profile → Profile picture**. A clear picture of your face is best.

**C6.** Your profile shows your name and bio, and any links you added, at the left, beside your README.

## 7. Pin your repositories

**Why this step.** Pinned repositories appear below your README with their descriptions. Choose them, or GitHub chooses for you.

1. On your profile, click **Customize your pins**, above the list of repositories.
2. Tick up to six. Leave out practice repositories you would not want to talk about. **Save pins**.
3. Open each pinned repository, click the gear beside **About**, and give it a one-line description.

**C7.** Your profile shows your README, then **Pinned**, with a description on each repository. If you have no repository to pin yet, come back to this step when you do.

## What you can do now

Send one link that says who you are, what you want to do and what you have done.

## Challenge

Swap links with someone. Read their profile for ten seconds, close it, and tell them what you remember. If it is not what they meant to say, help them rewrite the headline.

## Resources

- [Profile template](Resources/profile-template.md) and [a finished example](Resources/example-profile.md), written for an invented person
- [Managing your profile README](https://docs.github.com/en/account-and-profile/how-tos/profile-customization/managing-your-profile-readme)
- [Pinning items to your profile](https://docs.github.com/en/account-and-profile/how-tos/profile-customization/pinning-items-to-your-profile)
- [Static badges on shields.io](https://shields.io/badges/static-badge)
