# Activity 05 · A story page, published with no gateway

Your model gives the answer; one report page has to tell it. You build three visuals in the order a reader needs them, write the finding as the title, publish the report, and set its credentials so it can refresh from BigQuery. The source is in the cloud, so the Service needs no gateway (D22).

| Step | What the reader needs | Visual |
|---|---|---|
| 1 | When do people ride? | Column chart, average rides by month |
| 2 | How much does the weather change it? | Bar chart, average rides by day type |
| 3 | Does the model capture the pattern? | Line chart, actual and predicted |
| 4 | The report online, able to refresh | Publish, credentials, refresh |

Continue in the file from Activity 04. Add a new page and name it **Story**.

## 1. Average rides by month

**Why this step.** The biggest pattern goes first. Monthly totals depend on how many days a month has; an average per day compares months fairly.

Add a **Clustered column chart**. Put `v_days[day]` on the X-axis and keep only **Month** in its date hierarchy. Put `v_days[trips]` on the Y-axis and change its summary from **Sum** to **Average**.

**C1.** October is highest at **1,249.3** rides a day. July (531.0), June (538.1), May (563.2) and December (572.5) are the lowest: the months without classes.

## 2. Average rides by day type

**Why this step.** This is the quick answer from Activity 01. Showing it next to the months lets the reader see that the hot days sit inside the quiet months.

Add a **Clustered bar chart** with `v_days[day_type]` on the Y-axis and **Average of trips** on the X-axis. Sort by the average.

**C2.** Other 830.9, Rain 769.5, Hot 622.6.

## 3. Actual and predicted rides

**Why this step.** The model's predictions show whether the month, weekday and weather explain the year's shape. Where the two lines part, something else happened.

Add a **Line chart** with `v_predictions[day]` on the X-axis (Month only), and **Sum of trips** and **Sum of predicted_trips** on the Y-axis.

**C3.** In October the lines are close: **38,728** actual and **39,021** predicted.

Give the page a title in a text box: **Austin's bikes follow the school calendar first and the heat second.** Under it, one sentence: *With the month held fixed, a 100 °F day costs about 226 rides; the autumn semester adds up to about 700 a day.*

## 4. Publish and set the credentials

**Why this step.** In the Service, the semantic model needs its own sign-in to BigQuery: your Desktop sign-in stays on your laptop. BigQuery is reached over the internet, so no gateway is involved.

Save the file as `D23.pbix`. Select **Home → Publish → My workspace**. In the Service, open **My workspace**, select the **D23** semantic model's **More options (…) → Settings**. Under **Data source credentials**, select **Edit credentials**, choose **OAuth2** and sign in with the same Google account. Select **Refresh now** on the semantic model.

**C4.** Under **Gateway and cloud connections**, the Service lists Google BigQuery and does not ask for a gateway. **Refresh history** shows **Completed**, and the report's `v_trips` card shows 283,964 in the browser.

**What just happened.** The report went from a public dataset to a page anyone with access can open: SQL shaped the data, views handed it to Power BI, a model tested the quick answer, and the page states the finding as its title. A refresh copies the imported views again; the DirectQuery table needs no refresh at all, because it asks BigQuery each time.

[Microsoft: configure scheduled refresh](https://learn.microsoft.com/en-us/power-bi/connect-data/refresh-scheduled-refresh)
