# Assignment 3 rubric: A Power BI dashboard of New York taxi trips, 2019–2020

This is how your work is marked. The core tasks are worth **100 points**. The bonus tasks give up to **10 extra
points**, but your total cannot go above 100.

## How marking works

- **What the marker looks at.** Your PDF. The marker reads your numbers on slide S1 and on the page screenshots P1
  to P3, and compares them with the "Check yourself" tables in the brief. A number that matches gets the full points
  for its row. A step that is not on a slide cannot get its points.
- **Partly right.** Many rows give points for a part done right. Those points are written in the row, as whole
  numbers.
- **One mistake loses points once.** If a mistake in Part 1 or Part 2 changes your numbers later (for example, you
  removed the 0-mile trips), you lose the points where the mistake is. In the later parts, the marker checks your
  formulas and settings instead of the exact numbers.
- **Rounding.** Small differences from rounding (19.10 against 19.1) do not lose points.

## Part 1. Clean the data in Power Query (20 points)

| Task | Points | Full points | Partly right | Zero |
|---|---:|---|---|---|
| 1.1 Column types | 3 | Dates as Date/Time, money and distance as Decimal number, IDs and counts as Whole number | 2: one group of columns has the wrong type · 1: two groups | Types left as text |
| 1.2 Three rules | 9 | 3 for each rule: the right rows removed, in a step of its own (R2 has three small steps), and the row count after it on slide S1 | 2 for a rule that is right but has no count, or a wrong count · 1 for a rule that removes the wrong rows (for example R1 ending at 31 December 00:00) | The rule is missing |
| 1.3 Fill two gaps | 3 | Empty `payment_type` → 5 and empty `RatecodeID` → 99 | 2: one of the two | Neither |
| 1.4–1.5 Date and columns | 3 | 1 for `pickup_date` added with type Date · 2 for the five columns removed, leaving 14 | 1 for `pickup_date` alone · 1 for the columns if some of the five are still there | Neither |
| 1.6 Keep three kinds of odd rows | 2 | The three kinds of odd rows kept, and one sensible sentence on S1 about why a real trip might show 0 miles | 1: kept, no sentence | Removed |

## Part 2. Build the model (15 points)

If `Trips YoY %` reads −71.1% on P1 and the dropoff chart on P2 starts with Upper East Side North at 2,238, the model
works: full 15 points. If not, the marker uses the rows below.

| Task | Points | Full points | Partly right |
|---|---:|---|---|
| 2.1 Date table | 4 | 2 for the table: 731 rows, 1 January 2019 to 31 December 2020. 2 for the columns: `date`, `year`, `month_no`, `month` | 1 for the columns if one or two are missing |
| 2.2 Relationships | 6 | 1 for each of the five: many to one, single direction. 1 more for the dropoff one inactive and the pickup one active | One point for each item done |
| 2.3 Tidy model | 3 | 1 each: `dates` marked as the date table; `month` sorted by `month_no`; the five keys in `trips` hidden | One point for each item done |
| Model diagram | 2 | All five lines visible in Model view (PDF only: on slide S2) | 1: some lines hidden behind tables |

## Part 3. Write the measures (20 points)

Each measure gets its full points when its number on your page screenshots (P1 to P3, year 2020) matches the
brief's "Check yourself" tables. If it does not match, a formula on slide S3 with the right shape but one wrong column
or filter gets 1.

| Measure | Points | Full points |
|---|---:|---|
| `Trips`, `Revenue`, `Average per Trip` | 6 | 2 each. `Trips` 217,338; `Revenue` 4,116,717.47; `Average per Trip` uses `DIVIDE` (2019: 19.10, 2020: 18.41). `Average per Trip` without `DIVIDE`: 1 |
| `Trips LY`, `Trips YoY %` | 4 | 2 each. `Trips LY` for 2020 is 168,547; `Trips YoY %` for 2020 is −71.1% and is formatted as a percentage |
| `Revenue YTD` | 2 | 2020: June 623,273.42 and December 898,025.57 |
| `% of Trips` | 2 | Manhattan 90.9%. A share of 100% on every row gets 0 |
| `Dropoff Trips` | 3 | Uses `USERELATIONSHIP` on the dropoff column; Manhattan 192,089 |
| `Card Tip %` | 3 | Card payments only, tips divided by fares: 2019 22.6%, 2020 23.4% |

## Part 4. Build the three pages (30 points)

A box is one rectangle of the mockup: a title, a slicer, a card, a chart or a table. The box points go down by 1 for
each box that is missing or wrong, to 0 at the lowest.

| Task | Points | Full points |
|---|---:|---|
| Page 1, Overview | 10 | Every box, with its visual and fields (6). The year slicer: 1 for single select, 1 for not filtering the tip chart (2). The trend: 1 for `Trips` and `Trips LY` on one line chart, 1 for months in calendar order (2) |
| Page 2, Places | 8 | Every box, with its visual and fields (5). The table and the dropoff chart keep the Top 10 with a Top N filter (1). Both slicers work, and neither filters the airport chart (1). The dropoff chart uses `Dropoff Trips` (1) |
| Page 3, Story | 5 | The title is the finding, with a true number (2; a title with no number, or a number that is wrong: 1). Two evidence visuals that support it, with the page filtered to 2020 (2; evidence that does not match the title, or a page not filtered to 2020: 1). A "what to do next" text box (1) |
| Reads well | 4 | 1 each: visual titles say what they show; bars sorted, with months in calendar order; number formats fit (counts with no decimals, money with two, percentages with one); "1 trip in 500" on every page |
| Your own touch | 3 | 1 each: a theme and colours used the same way on every page; at least one addition the mockup does not ask for; that addition named on slide S4, with why it helps |

**Matching the mockup** means every box is there, in about the same place, with the visual and the fields it names.
A different chart type for the same question is fine if slide S4 says why it reads better. A page where most boxes
are missing or in other places gets at most half its box points: 3 of 6 on page 1, 3 of 5 on page 2.

## Part 5. The story (10 points)

| Task | Points | Full points | Partly right |
|---|---:|---|---|
| The finding | 3 | One sentence with a number, as the title of the first slide | 2: a topic ("Trips 2019–2020") instead of a finding, or a finding with no number |
| The evidence | 3 | One or two slides, each with a visual from your report and a sentence that says what to see | 2: screenshots with no sentence |
| What to do | 3 | 1 each: one recommendation the owner can act on; one thing to check first; what "1 trip in 500" means for the totals | One point for each item done |
| Easy to read | 1 | 3 to 5 slides, one idea each, readable on a phone | |

## Part 6. Share it (5 points)

| Route | Full points |
|---|---|
| A. Publish | A screenshot of your report open in the browser, from My workspace, with the address bar showing |
| B. Plan it | Three clear lines: who should see the report, who should not see what, and how often the data would be refreshed. Two of the three lines: 3. One line: 1 |

Either route can get 5 points. Using **Publish to web** loses these 5 points.

## Bonus tasks (optional): 2 points each, and your best five count, up to 10 points

A bonus task gets 2 points when everything in its row is there, and 1 point when it is partly done (for example, the
visual works but the explaining sentence is missing).

| Bonus | Full points (2) |
|---|---|
| B1 A role that shows only Manhattan pickups | The role; **View as** showing 197,459 trips on a page with no year filter; what the Dropoff Trips chart shows under the role, explained from Microsoft's USERELATIONSHIP page |
| B2 Drillthrough | A working drillthrough page for one zone, with a screenshot of it reached from page 2 |
| B3 Tooltip page | A tooltip page that shows `Trips`, `Trips LY` and `Card Tip %` for the borough under the mouse |
| B4 Bookmarks | Two buttons that switch the trend chart between Trips and Revenue, with a screenshot of each state |
| B5 Visual calculation | The running total of Trips, and one sentence on how it differs from `Revenue YTD` |
| B6 Trip length | `trip_minutes`, the histogram, 516 trips over 3 hours, the longest trip, and a reasoned keep-or-remove decision |
| B7 Revenue against trips | `Revenue LY` and `Revenue YoY %`, and the name of the Part 3 measure that explains the gap, with its two values |

## Common reasons for losing points

- A rule from Part 1 applied, but no row count on slide S1: the marker cannot see that it worked.
- R1 written as "is before or equal to 31/12/2020": it stops at midnight at the start of 31 December and drops that
  day's 94 trips.
- A `Trips YoY %` card that reads +28.9%: the year slicer is not single select, so nothing is chosen.
- `Dropoff Trips` made by changing which relationship is active: page 1 then counts dropoffs instead of pickups.
- `Card Tip %` over all trips: cash trips have no recorded tips, so the share comes out too low.
- A page 3 title that names a topic instead of saying what happened.
- Totals shown without saying they come from 1 trip in 500.
