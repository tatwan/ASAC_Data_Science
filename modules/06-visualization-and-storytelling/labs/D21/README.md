# D21 · Visualize and analyze

Today you turn the D20 overview page into a report a manager can explore alone, and you write what it shows. Every activity uses the same Nakheel model and completed sales through 31 August 2026.

## Before you start

You need a working Nakheel model with the measures from D20.

- **If your D20 file works**, open it and save a copy as `D21.pbix`. Keep the overview page from [D20 Lab 04](../D20/04-Lab-Overview-Page/README.md).
- **If not**, start a new file from [D20's four start files](../../../05-data-modeling-and-dax/labs/D20/Resources/start/) and follow [D20 Activity 01](../../../05-data-modeling-and-dax/labs/D20/01-Evr-Load-Start-Files-And-Measures/README.md). Then add Revenue YTD and Revenue LY from [D20 Activity 02](../../../05-data-modeling-and-dax/labs/D20/02-Evr-Time-Intelligence/README.md).

**Check:** a card with Completed Revenue shows **316,023.50**.

Add a page filter on every page you build today: `sales_lines[status]` is completed and `dates[date]` is on or before 31 August 2026.

## Activities

| # | Activity | What you build | Check |
|---|---|---|---|
| 01 | [Sketch a mockup](01-Evr-Sketch-A-Mockup/README.md) | A paper or PowerPoint plan of the channel page | Five zones, each with its question |
| 02 | [Slicers, sync and interactions](02-Evr-Slicers-Sync-Interactions/README.md) | A channel slicer on two pages; a filter interaction | Online 110,685.50 |
| 03 | [Drillthrough and tooltip](03-Evr-Drillthrough-And-Tooltip/README.md) | An Outerwear detail page and a tooltip page | Outerwear 76,637.00 |
| 04 | [Bookmarks and visual calculations](04-Evr-Bookmarks-And-Visual-Calculations/README.md) | Two buttons; a running total and a rank | August 122,583.00 |
| 05 | [Lab: a one-page story](05-Lab-One-Page-Story/README.md) | One page with one supported finding (after class) | Jan–Aug growth +27.1% |
| 06 | [Count rows, Top N, a second label, single select](06-Evr-Four-Moves-For-A3/README.md) | Rows counted and kept; a Top 5; a share label; a single-select slicer | Outerwear 24.3% |
| 07 | [Add reference lines with the Analytics pane](07-Evr-Analytics-Pane-Lines/README.md) | Average, median, min, max, a 15,000 target and a trend line on the monthly chart | Average 13,167.65 |
| 08 | [Find patterns with the AI visuals](08-Evr-AI-Visuals/README.md) | Anomalies, a decomposition tree, key influencers, Q&A | April 2026 flagged |


Activities 01–04 and 06 follow the class demo (06 prepares Assignment 3's new steps); finish any you miss on your own with the same checks. Lab 05 is after class and is practice for Assignment 3. Activities 07 and 08 start from their own file, [Resources/start/sales_lines.csv](Resources/start/sales_lines.csv), so they need nothing from the other activities.

**In Desktop and on the web.** Desktop is the route these READMEs describe. Where the web editor differs, a short "On the web" note says so. Some features (the mobile layout, some analytics options) are Desktop only.
