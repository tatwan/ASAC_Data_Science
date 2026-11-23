# Activity 08 · Find patterns with the AI visuals and check what they say

The director now asks why April 2026 stood out and what drives revenue. Power BI's AI visuals find patterns in the rows: an unusual month, the split of a total, the values linked to a bigger sale. You build each one and say what it shows and what it cannot show. The slides for this activity are D21 pages 43–48.

| Step | The director's question | Visual |
|---|---|---|
| 1 | Is April 2026 unusual? | Find anomalies (line chart) |
| 2 | Where does the total come from? | Decomposition tree |
| 3 | What goes with a bigger sale? | Key influencers |
| 4 | Can I just ask? | Q&A |

**Data:** [Resources/start/sales_lines.csv](../Resources/start/sales_lines.csv). Start from your Activity 07 file, or load the file and add the two measures as in [Activity 07, step 1](../07-Evr-Analytics-Pane-Lines/README.md#1-build-the-monthly-line).

## 1. Find the anomalies on the monthly line

**Why this step.** An average line shows which months were above typical. Anomaly detection asks a sharper question: which months are outside the range the rest of the line predicts?

Make a copy of the monthly line (`month_start` on a continuous axis, Completed Revenue). Remove the other analytics lines. In the Analytics pane, open **Find anomalies** and select **Add**.

**Check.** April 2026 is marked. Select the marker: the pane shows the expected range and the actual value, 20,237.00.

**What just happened.** The visual flags the month; it cannot say what happened in it. That is a question for the business.

## 2. Split the total with a decomposition tree

**Why this step.** The reader decides each split, one field at a time, and sees the numbers at every level.

Add a **Decomposition tree**. **Analyze:** Completed Revenue. **Explain by:** `channel`, `category`, `city`. Select **+** next to the total and choose `channel`; then **+** next to store and choose `category`.

**Check.** Store 205,338.00 and online 110,685.50. Under store, Outerwear leads with 51,321.50.

**Planned dead end.** Split the total by `city`. Amman shows 130,848.00 because Power BI ignores case and `amman` joins it, but `Al Zarqa` (663.50) is a separate branch from Zarqa (25,684.50) and the blank cities hold 3,197.00. A tree only splits the values it is given; the fix belongs in Power Query.

## 3. Ask what goes with a bigger sale: key influencers

**Why this step.** Key influencers compares the average of a column with and without each value of the fields you give it, and ranks the biggest differences.

Add a **Key influencers** visual on a new page. **Analyze:** `line_value` (a column, not the measure). **Explain by:** `category`, `channel`. Add a page filter `status` = completed.

**Check.** Category Outerwear is at or near the top. The arithmetic behind it: Outerwear lines average about 72.03 against about 40.66 for every other line.

**What just happened.** Outerwear is linked to bigger lines because a jacket costs more than a pair of socks. Key influencers shows association, not cause.

## 4. Ask a question with Q&A

**Why this step.** Q&A turns a typed question into a visual. Test it on a question you can check before you trust it on a new one.

Add a **Q&A** visual. Type `completed revenue by channel`.

**Check.** Store 205,338.00 and online 110,685.50, the same as the decomposition tree. If the answer differs, the question was read differently: try the exact measure name.

Copilot works the same way but needs a paid Fabric capacity, which free accounts do not have.

## Check yourself

| Visual | What it showed | What it cannot tell you |
|---|---|---|
| Find anomalies | April 2026 is outside the expected range | What happened in April |
| Decomposition tree | Store 205,338.00; Outerwear leads in store | Which split matters to the business |
| Key influencers | Outerwear lines are bigger | Whether selling more Outerwear would raise revenue |
| Q&A | The channel totals | Whether a new question was understood, until you check it |

**Bonus.** Write one sentence about April 2026 that uses two of these visuals and names one limit.

[Microsoft: decomposition tree](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-visualization-decomposition-tree) · [Microsoft: key influencers](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-visualization-influencers) · [Microsoft: anomaly detection](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-visualization-anomaly-detection) · [Microsoft: Q&A](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-visualization-q-and-a)
