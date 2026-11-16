# Assignment 3 rubric: A Power BI dashboard of New York taxi trips, 2019–2020

This is how your work is marked. Core tasks: **100 points**. Bonus tasks: up to **10 extra points** (your total
cannot go above 100).

**Every part is marked on the evidence you hand in:** the `.pbix` file, and the "how I built it" slides in your PDF.
If you work in the browser and hand in the PDF only, the slides (S1–S5 and one per page) are the evidence: a step that is not on a slide
cannot get its points. Small differences in a number caused by rounding (19.10 against 19.1) do not lose points.

## Part 1. Clean the data in Power Query (20 points)

| Task | Points | Full points | Half points | Zero |
|---|---:|---|---|---|
| 1.1 Column types | 3 | Dates as Date/Time, money and distance as decimals, IDs and counts as whole numbers | One group of columns wrong | Types left as text |
| 1.2 Three rules | 9 | 3 points for each rule: the right rows removed, in a step of its own, and the row count shown after it | The rule is applied but the count is not shown, or it is wrong | The rule is missing |
| 1.3 Fill two gaps | 3 | Empty `payment_type` → 5 and empty `RatecodeID` → 99 | One of the two | Neither |
| 1.4–1.5 Date and columns | 3 | `pickup_date` added with type Date (1); the five columns removed (1); 14 columns left (1) | | None of the three |
| 1.6 Count and keep three kinds of odd rows | 2 | The three odd groups kept, and one sensible sentence on 0-mile trips | Kept, no sentence | Removed without a reason |

## Part 2. Build the model (15 points)

| Task | Points | Full points |
|---|---:|---|
| 2.1 Date table | 4 | 731 rows, 2019–2020, with `date`, `year`, `month_no`, `month` (2 points for the table, 2 for the columns) |
| 2.2 Relationships | 6 | All five, many to one, single direction (1 point each); the dropoff one inactive and the pickup one active (1 point) |
| 2.3 Tidy model | 3 | Marked as date table, months sorted by number, keys hidden (1 point each) |
| Model diagram | 2 | All five lines visible in Model view (PDF only: on slide S2) |

## Part 3. Write the measures (20 points)

Each measure gets its points when it returns the check number and its formula can be read: in the `.pbix`, or on slide
S3 if you hand in the PDF only. A correct number with no formula to read gets half.

| Measure | Points | Full points |
|---|---:|---|
| `Trips`, `Revenue`, `Average per Trip` | 6 | 2 each; `Average per Trip` uses `DIVIDE` |
| `Trips LY`, `Trips YoY %` | 4 | 2 each; YoY formatted as a percentage |
| `Revenue YTD` | 2 | Matches June and December 2020 |
| `% of Trips` | 2 | Manhattan 90.9%, and the share does not become 100% on each row |
| `Dropoff Trips` | 3 | Uses `USERELATIONSHIP` on the dropoff column; Manhattan 192,089 |
| `Card Tip %` | 3 | Card payments only, tips over fares; 22.6% and 23.4% |

## Part 4. Build the three pages (30 points)

| Task | Points | Full points | Half points |
|---|---:|---|---|
| Page 1, Overview | 10 | Every box of the mockup, with its visual and fields (6); the year slicer works and does not filter the tip chart (2); Trips and Trips LY on one line chart, months in calendar order (2) | Most boxes, or the slicer filters everything |
| Page 2, Places | 8 | Every box (5); Top 10 by a Top N filter (1); the year and borough slicers work, and the year and borough slicers do not filter the airport chart (1); the dropoff chart uses `Dropoff Trips` (1) | Most boxes |
| Page 3, Story | 5 | The title is the finding with a number (2); two evidence visuals that support it, with the page filtered to 2020 (2); a "what to do next" text (1) | A title with no number, or evidence that does not match the title |
| Reads well | 4 | Visual titles say what they show; bars sorted (months in calendar order); number formats fit (counts with no decimals, money with two, percentages with one); "1 trip in 500" on every page (1 each) | |
| Your own touch | 3 | A theme and colours used the same way on every page (1); at least one addition the mockup does not ask for (1), named on slide S4 with why it helps (1) | |

**Matching the mockup** means every box is there, in about the same place, with the visual and the fields it names. A
different chart type for the same question is fine if slide S4 says why it reads better. A page that looks nothing
like the mockup gets half the points for its boxes at most.

## Part 5. The story (10 points)

| Task | Points | Full points | Half points |
|---|---:|---|---|
| The finding | 3 | One sentence with a number, as the title of the first slide | A topic ("Trips 2019–2020") instead of a finding |
| The evidence | 3 | One or two slides, each with a visual from your report and a sentence that says what to see | Screenshots with no sentence |
| What to do | 3 | One recommendation the owner can act on, one thing to check first, and what "1 trip in 500" means for the totals (1 each) | |
| Easy to read | 1 | 3 to 5 slides, one idea each, readable on a phone | |

## Part 6. Share it (5 points)

| Route | Full points |
|---|---|
| A. Publish | A screenshot of your report open in the browser, from My workspace |
| B. Plan it | Who should see it, who should not see what, and how often it would be refreshed, each in one clear line |

Either route can get 5 points. Using **Publish to web** loses these 5 points.

## Bonus (optional): 2 points each, best five count, up to 10

Each bonus gets 2 points for everything in its row, and 1 point if it is partly done (for example, the visual works
but the explaining sentence is missing).

| Bonus | Full points (2) |
|---|---|
| B1 A role that shows only Manhattan pickups | The role, **View as** showing 197,459 trips on a page with no year filter, and what the Dropoff Trips chart shows under the role, explained from Microsoft's USERELATIONSHIP page |
| B2 Drillthrough | A working drillthrough page for one zone, with a screenshot of it reached from page 2 |
| B3 Tooltip page | A tooltip page that shows the three measures for the borough under the mouse |
| B4 Bookmarks | Two buttons that switch the trend chart, with a screenshot of each state |
| B5 Visual calculation | The running total, and one sentence on how it differs from `Revenue YTD` |
| B6 Trip length | `trip_minutes`, the histogram, 516 trips over 3 hours, the longest trip, and a reasoned keep-or-remove decision |
| B7 Revenue against trips | Both measures, and the name of the Part 3 measure that explains the gap, with its two values |

## Common reasons for losing points

- A rule from Part 1 applied, but no row count on the slide: the marker cannot see that it worked.
- `Dropoff Trips` made by changing which relationship is active: page 1 then counts dropoffs instead of pickups.
- `Card Tip %` over all trips: cash trips have no recorded tips, so the share comes out too low.
- A page 3 title that names a topic instead of saying what happened.
- Totals shown without saying they come from 1 trip in 500.
