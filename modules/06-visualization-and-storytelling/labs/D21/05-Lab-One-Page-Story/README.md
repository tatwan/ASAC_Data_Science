# Lab 05 · A one-page story with one supported finding

After class. You build one report page that tells the manager one thing the data supports, in a form they can check. This is practice for Assignment 3: the assignment asks for the same parts.

Start from Activity 04's file. Use your mockup from Activity 01.

| Step | What you add | Check |
|---|---|---|
| 1 | The page from your mockup | Cards along the top |
| 2 | The comparison behind the finding | 96,422.00 and 122,583.00 |
| 3 | The finding in four parts | Growth 27.1% |
| 4 | Accessibility settings | Alt text on every visual |

## 1. Build the page from your mockup

**Why this step.** The mockup already says which question each zone answers. Building from it keeps the page on one question.

Add a page named `Story`. Place the three cards along the top (Completed Revenue, Orders, Average Order Value), the monthly line in the middle left, the category bars in the middle right, and your detail zone at the bottom. Add the channel buttons from Activity 04 if they fit.

**C1.** The page matches your mockup's zones. The cards show 316,023.50, 2,771 and 114.05.

## 2. Add the comparison the finding needs

**Why this step.** A growth claim needs two periods of the same length. D20 showed that comparing eight months of 2026 with twelve months of 2025 gives a false fall.

Add a clustered bar chart with `dates[year]` and Completed Revenue. Filter the visual to `dates[month_no]` 1 to 8 and years 2025 and 2026.

**C2.** 2025 shows **96,422.00** and 2026 **122,583.00**.

## 3. Write the finding in four parts

**Why this step.** A finding a manager can act on says what happened, shows the numbers, says what to do, and says what the data cannot show.

Add a text box at the top of the page with four short lines:

- **Headline:** what happened, with the period. *Completed revenue grew 27.1% in January–August 2026.*
- **Evidence:** the two numbers and where they are on the page.
- **Recommendation:** one action the manager can take.
- **Limits:** what the data does not include (completed orders only; data ends 31 August 2026; the reason for the growth is not in the data).

You may write a different finding. It must name its period, its population and a number on the page.

**C3.** (122,583.00 − 96,422.00) ÷ 96,422.00 = **27.1%**. A classmate can find every number in your text on the page.

## 4. Make the page accessible

**Why this step.** Some readers use a screen reader or cannot tell colours apart. The page should still make sense to them.

For each visual, open **Format → General → Alt text** and write one sentence with the visual's main number. In **View → Selection**, open the **Tab order** list and order the visuals as your mockup reads: title, cards, trend, breakdown, detail. Check that no chart relies on colour alone: add data labels or a sign.

**C4.** Every visual has alt text, and the tab order follows the reading order.

**Save** the file as `D21-story.pbix`. Bring the page to the next class.

[Microsoft: accessibility in Power BI reports](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-accessibility-overview)
