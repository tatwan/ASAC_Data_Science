# Activity 07 · Add reference lines to the monthly chart with the Analytics pane

The sales director asks: was April 2026 a good month, and is revenue growing? A line of 24 months cannot answer that by eye. You add the reference lines that the Analytics pane computes, one at a time, and read what each one says. The slides for this activity are D21 pages 36–42.

| Step | What the director needs | Analytics pane line |
|---|---|---|
| 1 | The monthly line | (a line chart on a date axis) |
| 2 | A typical month to compare with | Average, median |
| 3 | The best and the worst month | Min, max |
| 4 | The months that passed the target | Constant line |
| 5 | Which way revenue is going | Trend line |
| 6 | Why the trend option sometimes disappears | (planned dead end) |
| 7 | The next three months (optional) | Forecast |

**Data:** [Resources/start/sales_lines.csv](../Resources/start/sales_lines.csv) → table `sales_lines`. It is the D20 sales lines with category, city and month added, so it needs no other table and no file from an earlier day. One row is one line on an order.

## 1. Build the monthly line

**Why this step.** The Analytics pane works on a visual, so you need a line of completed revenue by month first.

In a new Power BI Desktop file, select **Get data → Text/CSV**, choose `sales_lines.csv` and select **Load**. In Table view, check that `month_start` is a **Date** column. Add two measures with **Home → New measure**:

```DAX
Total Revenue = SUM(sales_lines[line_value])
```

```DAX
Completed Revenue = CALCULATE([Total Revenue], sales_lines[status] = "completed")
```

Add a **Line chart**. Put `month_start` on the X-axis and choose **month_start** in its drop-down (not Date Hierarchy). Put Completed Revenue on the Y-axis.

**Check.** 24 points from September 2024 to August 2026. The highest is April 2026, **20,237.00**.

## 2. Add an average line and a median line

**Why this step.** "Is 15,000 good?" needs something to compare with. The average is the typical month; the median is the middle month, and one very big month moves it less.

Select the chart. In the **Visualizations** pane, select the magnifying-glass icon: this is the **Analytics pane**. Open **Average line → Add line**. Open **Median line → Add line**.

**Check.**

| Line | Value |
|---|---|
| Average | 13,167.65 (316,023.50 ÷ 24) |
| Median | 12,874.00 |

**What just happened.** Both lines are computed from the 24 values in the visual. The average is higher than the median because April 2026 pulls it up.

## 3. Add min and max lines

**Why this step.** The range from the worst to the best month tells the director how unusual April was.

Add **Min line** and **Max line**.

**Check.** Min **9,772.50** (November 2025); max **20,237.00** (April 2026).

## 4. Add a constant line for the target

**Why this step.** The business set a target of 15,000 a month. A constant line is a value you type: Power BI computes nothing.

Open **Constant line → Add line**. Set **Value** to `15000`. Turn **Data label** on.

**Check.** Four months are above the line: September 2025, April 2026, June 2026, July 2026.

## 5. Add a trend line

**Why this step.** The trend line is a straight line fitted through the months. Its slope answers "is revenue growing?"

Open **Trend line** and turn it **On**.

**Check.** The line rises from left to right, about **213** a month.

**What just happened.** The trend line says revenue tended to grow. It does not say why.

## 6. Planned dead end: the trend option disappears

**Why this step.** You will meet this on your own data, and it looks like a missing feature.

Drag `year_month` (text) onto the X-axis in place of `month_start`. Open the Analytics pane: **Trend line** and **Forecast** are gone. Put `month_start` back, and check **Format → X-axis → Type** is **Continuous**.

**What just happened.** A text month is a label, so Power BI cannot measure the distance between months. Trend and forecast need a continuous axis: a date or a number.

## 7. Optional: add a forecast

Open **Forecast**, turn it **On**, set **Forecast length** to `3` points and keep the **Confidence interval** at 95%. Select **Apply**.

**Check.** A line continues past August 2026 with a shaded range that widens with each month.

## Check yourself

| Question | Answer |
|---|---|
| Was April 2026 a good month? | The best of 24: 20,237.00 against an average of 13,167.65 |
| Is revenue growing? | Yes, by about 213 a month on the trend line |
| How often was the target met? | 4 of 24 months |

**Bonus.** Add a channel slicer and select **online**. Every line moves to online sales only. Which months pass 15,000 now?

[Microsoft: the Analytics pane](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-analytics-pane)
