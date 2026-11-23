# D22 · Manage, secure and share

Today you publish the Nakheel report, decide which rows each manager sees, and plan how it stays up to date. Every activity uses the same model and completed sales through 31 August 2026.

## Before you start

You need no file from an earlier day. [Activity 00](00-Evr-Build-The-Overview-Report/README.md) builds today's overview report in Desktop from one file, [sales_lines.csv](Resources/start/sales_lines.csv), in about 15 minutes. Every activity after it uses that file, `D22.pbix`.

**Check:** a card with Completed Revenue shows **316,023.50**.

If you already have a working D21 or D20 file with that card, you may use it instead.

Sign in to Power BI Desktop (top right) with your course account. Publishing and the Service steps use that account.

## Your account

Most of you have a free account; some of you started the 60-day trial.

| You can do this on… | Free account | Trial or Pro |
|---|---|---|
| Build roles and test them with View as (Desktop) | Yes | Yes |
| Publish to My workspace, pin a dashboard, set an alert | Yes | Yes |
| Create a workspace, share a report, subscribe | No | Yes |
| Add people to a role in the Service | No | Yes |
| Manage permissions on a semantic model (Read, Build, Reshare) | No: opening it offers to start the trial | Yes |

Steps marked **Trial or Pro** are optional on a free account. Every check that counts can be done on a free account.

## Activities

| # | Activity | What you build | Check |
|---|---|---|---|
| 00 | [Build the Nakheel overview report from one file](00-Evr-Build-The-Overview-Report/README.md) | Three cards, a monthly line, category bars, a channel slicer | Completed revenue 316,023.50 |
| 01 | [Add reference lines with the Analytics pane](01-Evr-Analytics-Pane-Lines/README.md) | Average, median, min, max, a 15,000 target and a trend line on the monthly chart | Average 13,167.65 |
| 02 | [Find patterns with the AI visuals](02-Evr-AI-Visuals/README.md) | Anomalies, a decomposition tree, key influencers, Q&A on an Explore page | April 2026 flagged |
| 03 | [Publish, pin and set an alert](03-Evr-Publish-Pin-Alert/README.md) | The report in My workspace, a dashboard tile and an alert rule | Tile shows 110,685.50 |
| 04 | [A static store role](04-Evr-Static-Role/README.md) | Store and Online roles, tested with View as | Store 205,338.00 |
| 05 | [A dynamic Manager role](05-Evr-Dynamic-Role/README.md) | One role that reads the signed-in email | Lina sees 110,685.50 |
| 06 | [Lab: an access and refresh plan](06-Lab-Access-And-Refresh-Plan/README.md) | A one-page plan for the Nakheel report (after class) | Four decisions with reasons |

Finish any activity you miss on your own with the same checks. Lab 06 is after class and is practice for Assignment 3.

**Data:** [sales_lines.csv](Resources/start/sales_lines.csv) (Activity 00) and [channel_managers.csv](Resources/channel_managers.csv) (Activity 05) are described in [Resources](Resources/README.md).
