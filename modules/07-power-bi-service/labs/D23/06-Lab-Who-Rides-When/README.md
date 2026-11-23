# Lab 06 · Who rides when: the student share by month

Activity 03 says the school calendar moves Austin's rides more than the heat does. If that is true, the share of rides taken by students should rise and fall with the semesters. You test it with one measure on the DirectQuery table, read it by month, and write one finding. About 20 minutes, after class.

**Where you are:** after the route (01 Explore → 02 Views → 03 Model → 04 Connect → 05 Story). You test the model's claim with the report you built.

**Remember (D19).** `CALCULATE` evaluates a measure under a changed filter; `DIVIDE` divides and returns a blank instead of an error. A share is one count under a filter, divided by the same count without it, as D19's percent of total.

**What you are testing.** Activity 03 said the school calendar moves rides about three times as much as the heat. If that is true, the share of rides taken by students should be high in term time and low in the summer and in December. If the share were flat all year, the calendar story would be wrong.

| Step | What you need | Power BI |
|---|---|---|
| 1 | The share of rides taken by students | A measure with `CALCULATE` and `DIVIDE` |
| 2 | The share in each month | Line and column chart |
| 3 | One sentence a manager can act on | A text box |

Start from your Activity 05 file. If you do not have it, do Activities 02 and 04 first.

## 1. A Student share measure

**Why this step.** A share is a ratio of two counts under different filters: student rides over all rides. `CALCULATE` adds the student filter to the top count; `DIVIDE` returns a blank instead of an error when a month has no rides.

Select `v_trips`, then **New measure**:

```DAX
Student share =
DIVIDE (
    CALCULATE ( COUNTROWS ( v_trips ), v_trips[rider_group] = "Student" ),
    COUNTROWS ( v_trips )
)
```

Format it as a percentage with one decimal place.

**C1.** On a card, Student share for the whole year is **51.5%**.

## 2. Read it by month

**Why this step.** One number for the year hides the pattern. By month, you can lay the share next to the rides and see whether they move together.

Add a **Line and clustered column chart**. X-axis: `v_days[day]`, Month only. Column y-axis: **Average of trips** from `v_days`. Line y-axis: **Student share**.

The measure counts rows in BigQuery (DirectQuery); the month comes from the imported `v_days` through the relationship you built in Activity 04.

**C2.** September **66.3%** and October **64.9%** are the highest; May **24.6%** and June **26.6%** the lowest. The columns are high where the line is high.

## 3. Write the finding

**Why this step.** A chart is evidence; the reader still needs the sentence. A good finding names the pattern, its size and what to do about it.

Add a text box above the chart with one finding and one action. For example: *In term time two thirds of rides are students'; in May and June a quarter are. Plan bike maintenance and station moves for the summer break, not for the hottest weeks.*

**C3.** Your sentence uses two numbers from the chart and ends with an action.

**What just happened.** You tested the model's explanation with a second, independent measure. Students take 66.3% of September's rides and 24.6% of May's, and the months with the most students are the months with the most rides. The heat makes summer worse; the students' calendar makes it quiet.
