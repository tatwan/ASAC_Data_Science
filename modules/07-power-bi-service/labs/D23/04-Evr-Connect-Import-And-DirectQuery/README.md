# Activity 04 · Connect Power BI to BigQuery: Import and DirectQuery

Your three views are ready in BigQuery. Power BI can read a view in two ways. **Import** copies the rows into the report file; visuals are fast and the copy is as fresh as the last refresh. **DirectQuery** copies nothing; every visual sends a query to BigQuery when it is drawn, so the data is always current, and every visual costs a query. You import the two small day views and query the trip view live, then watch both at work.

| Step | What you need | Power BI |
|---|---|---|
| 1 | The day views as a copy in the file | Google BigQuery connector, Import |
| 2 | The trip view queried live | Google BigQuery connector, DirectQuery |
| 3 | Day filters that reach the trips | A relationship on `day` |
| 4 | Proof of what each mode does | Performance analyzer, BigQuery job history |

Open Power BI Desktop with a new, blank report, signed in with your course account.

## 1. Import `v_days` and `v_predictions`

**Why this step.** `v_days` has 364 rows and `v_predictions` 364. A small table is cheap to copy, and a copy makes every visual fast. It is also the default, and the mode PL-300 expects you to choose unless there is a reason not to.

Select **Home → Get data → More…**, search for **Google BigQuery**, and select **Connect**. Under **Data Connectivity mode**, choose **Import** and select **OK**. Select **Sign in**, choose your Google account in the Google window and allow access, then select **Connect**. In the **Navigator**, open your project, then `bikes`, tick `v_days` and `v_predictions`, and select **Load**.

If you see **Access Denied … bigquery.jobs.create**, start again and open **Advanced options**: in **Billing Project ID**, type your project's ID (shown in the BigQuery console's project picker). Power BI then runs its queries in your sandbox.

**C1.** On a card, `trips` from `v_days` shows **283,964**.

## 2. Add `v_trips` in DirectQuery

**Why this step.** `v_trips` has one row per trip. Importing it would copy 283,964 rows into the file and repeat the copy at every refresh; DirectQuery leaves them in BigQuery and asks only for the totals each visual needs.

Select **Get data → Google BigQuery** again. This time choose **DirectQuery**, select **OK**, tick `v_trips` in the Navigator and select **Load**. Power BI warns that the report now mixes Import and DirectQuery (a composite model); select **OK**.

**C2.** In **Model view**, select `v_trips`: **Properties → Advanced → Storage mode** says **DirectQuery**, while `v_days` says **Import**. A card with **Count of trip_id** shows **283,964**, the same number as C1, from the other storage mode.

## 3. Relate the days to the trips

**Why this step.** The day type lives in `v_days`; the trips live in `v_trips`. A relationship on `day` lets a filter on hot days reach the trips, even though one table is a copy and the other is in BigQuery.

In Model view, drag `v_days[day]` onto `v_trips[day]`. Check **Many to one** from `v_trips` to `v_days` with **Single** filter direction, and select **Save**. Drag `v_days[day]` onto `v_predictions[day]` too (one to one).

Power BI draws the first line differently: the two tables come from different source groups, so it is a **limited relationship**. It filters correctly; its limits matter for blank rows, which this data does not have.

**C3.** Add a slicer on `v_days[day_type]` and select **Hot**. The `v_days` card shows **50,428** and the `v_trips` card shows **50,428**.

## 4. Watch each mode work

**Why this step.** The choice between Import and DirectQuery is a trade-off you should be able to see, not just recite: a copy refreshed on a schedule against a live query on every click.

Select **Optimize → Performance analyzer → Start recording**, then **Refresh visuals**. Expand the two cards. Then, in the BigQuery console, open **Job history → Personal history**.

**C4.** The `v_trips` card lists a **Direct query** row; the `v_days` card does not. In BigQuery's job history, the newest job is a query from Power BI that reads `bikes.v_trips`, run a moment ago. Each click on the slicer adds another.

**What just happened.** One report reads the same data two ways. The imported tables answered from the copy in your file. The DirectQuery table sent BigQuery a query for each visual, so its numbers are always current and each one costs a few tens of MB of your free terabyte. In a real report you would import small or slowly changing tables and keep DirectQuery for large or live ones. Note that DirectQuery cannot use BigQuery's date-and-time columns; that is why `v_trips` keeps the date and the hour separately.

[Microsoft: Google BigQuery connector](https://learn.microsoft.com/en-us/power-query/connectors/google-bigquery) · [Microsoft: use composite models](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-composite-models)
