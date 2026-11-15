# D22 · Manage, secure and share

Today you publish the Nakheel report, decide which rows each manager sees, and plan how it stays up to date. Every activity uses the same model and completed sales through 31 August 2026.

## Before you start

You need a Nakheel model with the Completed Revenue measure.

- **If your D21 or D20 file works**, open it and save a copy as `D22.pbix`.
- **If not**, start a new file from [D20's four start files](../../../05-data-modeling-and-dax/labs/D20/Resources/start/) and follow [D20 Activity 01](../../../05-data-modeling-and-dax/labs/D20/01-Evr-Load-Start-Files-And-Measures/README.md) (about 15 minutes). It loads the tables, draws the relationships and adds the measures.

**Check:** a card with Completed Revenue shows **316,023.50**.

Sign in to Power BI Desktop (top right) with your course account. Publishing and the Service steps use that account.

## Your account

Most of you have a free account; some of you started the 60-day trial.

| You can do this on… | Free account | Trial or Pro |
|---|---|---|
| Build roles and test them with View as (Desktop) | Yes | Yes |
| Publish to My workspace, pin a dashboard, set an alert | Yes | Yes |
| Create a workspace, share a report, subscribe | No | Yes |
| Add people to a role in the Service | No | Yes |

Steps marked **Trial or Pro** are optional on a free account. Every check that counts can be done on a free account.

## Activities

| # | Activity | What you build | Check |
|---|---|---|---|
| 01 | [Publish, pin and set an alert](01-Evr-Publish-Pin-Alert/README.md) | The report in My workspace, a dashboard tile and an alert rule | Tile shows 110,685.50 |
| 02 | [A static store role](02-Evr-Static-Role/README.md) | Store and Online roles, tested with View as | Store 205,338.00 |
| 03 | [A dynamic Manager role](03-Evr-Dynamic-Role/README.md) | One role that reads the signed-in email | Lina sees 110,685.50 |
| 04 | [Lab: an access and refresh plan](04-Lab-Access-And-Refresh-Plan/README.md) | A one-page plan for the Nakheel report (after class) | Four decisions with reasons |

Activity 01 is Monday's; Activities 02 and 03 are Wednesday's. Finish any you miss on your own with the same checks. Lab 04 is after class and is practice for Assignment 3.

**Data:** [channel_managers.csv](Resources/channel_managers.csv) (Activity 03) is described in [Resources](Resources/README.md).
