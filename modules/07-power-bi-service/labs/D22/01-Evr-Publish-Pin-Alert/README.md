# Activity 01 · Publish the report, pin a tile and set a data alert

The online manager wants to see online revenue each morning without opening Desktop, and to hear about it when revenue passes a target. You publish the report to the Power BI service, pin the online card to a dashboard and set an alert on it. Everything here works on a free account.

Start from the file in the [D22 entry page](../README.md). Completed Revenue on a card is 316,023.50.

| Step | What the manager needs | Feature |
|---|---|---|
| 1 | A card that shows online revenue only | Visual filter |
| 2 | The report in the Service | Publish |
| 3 | The number on a page of key figures | Pin to a dashboard |
| 4 | A message when the number passes a target | Data alert |

## 1. Add an online revenue card

**Why this step.** A dashboard tile is pinned from one visual and keeps that visual's filters. A card filtered to online gives the manager one number to watch.

Add a new page named `Service`. Add a **Card** with Completed Revenue. With the card selected, open the **Filters** pane and drag `sales_lines[channel]` into **Filters on this visual**. Tick **online** only. Give the card the title `Online revenue`.

**C1.** The card shows **110,685.50**. A second card without the filter shows 316,023.50.

## 2. Publish to My workspace

**Why this step.** Desktop files live on your laptop. Publishing copies the report and its model to the Service, where other people and dashboards can reach them. A free account can publish to My workspace only.

Save the file. Select **Home → Publish**, choose **My workspace** and select **Select**. When Desktop says it succeeded, select **Open 'D22.pbix' in Power BI**.

**C2.** In My workspace there are two items named `D22`: a **Report** and a **Semantic model**. The report's online card still shows **110,685.50**.

**What just happened.** One file became two items. The report holds the pages; the semantic model holds the tables, measures and data. Refresh, security and sharing are set on the semantic model.

## 3. Pin the online card to a new dashboard

**Why this step.** A dashboard collects key numbers from one or more reports on one page. It exists only in the Service, and each tile links back to its report.

In the report (reading view), hover over the online card and select **Pin visual** (the pin icon). Choose **New dashboard**, name it `Nakheel overview` and select **Pin**. Select **Go to dashboard**.

**C3.** The dashboard has one tile that shows **110,685.50**. Selecting the tile opens the `Service` page of the report.

## 4. Add a data alert to the tile

**Why this step.** An alert checks the tile after each data refresh and notifies you when it crosses a threshold. It saves the manager from checking the number every day. Alerts work on card, gauge and KPI tiles.

On the tile, select **More options (…) → Manage alerts → Add alert rule**. Set **Condition** to **Above** and **Threshold** to `120000`. Set **Maximum notification frequency** to **At most once a day**. Tick **Send me email, too** if you want an email. Select **Save and close**.

**C4.** **Manage alerts** lists one rule, *Above 120,000*. No notification arrives: 110,685.50 is below the threshold, and the data has not refreshed since you published.

**What just happened.** The alert is yours alone; nobody else who opens the dashboard sees it. It will only fire after a refresh, which the Monday 23 November class covers.

## Trial or Pro: share the report with a neighbour

With a trial or Pro account, open the report, select **Share**, choose **Specific people**, type your neighbour's course email and untick **Allow recipients to build content with the data associated with this report**. Your neighbour opens it from **Shared with me**. A free account cannot open a shared report, so this needs both of you on a trial or Pro.

[Microsoft: data alerts](https://learn.microsoft.com/en-us/power-bi/create-reports/service-set-data-alerts) · [Microsoft: share reports](https://learn.microsoft.com/en-us/power-bi/collaborate-share/service-share-dashboards)
