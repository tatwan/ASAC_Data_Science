# Finish the store list

In this activity, you will finish the `stores` query on your own: split the position into latitude and longitude, add a short name for charts with **Column From Examples**, and answer a facilities manager's question.

**In class:** on your own · **Data:** the `stores` query from activity 04 · **Tool:** Power BI Desktop or the browser

## The story

The facilities manager wants a map of the shops later in the course, short names that fit on a chart, and one number today: how much selling floor does Nakheel have in Amman?

## What you will learn

- Split coordinates and check that decimal values were read correctly.
- Infer a short-name rule from examples and inspect the resulting formula.
- Sum known floor areas without inventing a value for an unknown size.

## Before you start

You need `stores` from activity 04: 12 rows with `gov_code`, `governorate`, `area` and `size_m2`. If you do not have it, do activity 04 first.

## Instructions

1. Split `lat / long` into two columns, `latitude` and `longitude`, both **Decimal Number**.

    Translate: **Split Column** → **By Delimiter**, a custom delimiter of space, slash, space; then rename and set the types.

2. Add a column `short_name` that holds the name without the word "Nakheel": `Abdali`, `Sweifieh`, `University Street`.

    Translate: select `store_name`, then **Add Column** → **Column From Examples** → **From Selection**. Type `Abdali` in the first row and `University Street` in the fourth, press **Enter**, check every row, then **OK**. Read the formula Power Query shows above the grid.

3. Rename the generated column to `short_name` if it has a different name. Check all twelve results before accepting the rule. A formula such as `Text.AfterDelimiter([store_name], " ")` keeps the text after the first space, so `Nakheel University Street` becomes `University Street`, with both words kept.

    If **Column From Examples** is unavailable in your browser editor, use **Add Column → Custom Column**, name it `short_name` and enter `Text.AfterDelimiter([store_name], " ")`. This gives the same result; practising inference from examples can wait until you have Desktop.

4. Check that `opened` is a **Date**, then **Close & Apply** (browser: **Save**, then refresh the report).

5. How many square metres of selling floor does Nakheel have in Amman, and in the whole country?

    Translate: a **Table** visual with `governorate` and `size_m2` (Sum), or two cards with a filter.

Save your changes before continuing: **File → Save** on Desktop; in the browser, **Save** Power Query changes, refresh the report and save the report.

## Check yourself

| Question | One value to check |
|---|---|
| 1 | Abdali: latitude 31.9632, longitude 35.9106; no errors in either column |
| 2 | 12 rows; `Nakheel Irbid City Centre` becomes `Irbid City Centre` |
| 4 | `opened` for Jerash: 15 September 2026 |
| 5 | Amman 1,060 m² · all shops 2,880 m² (Jerash's size is unknown) |

## Hint

If `latitude` turns into errors or into numbers such as 319632, your computer reads decimals with a comma. Set the type with the column's right-click menu → **Change Type** → **Using Locale…** → **Decimal Number**, **English (United States)**. Microsoft: locale "is used to interpret text values and convert them into other data types."

## Bonus

Try **Column From Examples** on the raw `size` text in `stores_raw` (type `420` beside `420 m²`). What does it make of `unknown`? Compare its formula with the split you did in activity 04. Delete the step afterwards: `stores_raw` stays as the file is.

## References

Nakheel Retail store files, synthetic course data; see [`shared/datasets/nakheel_stores`](../../../../../shared/datasets/nakheel_stores/README.md). Use the [D17 guide](../README.md) for saving, browser navigation and row-count checks. Button and menu names can vary between Desktop and the browser. Power BI changes every month: if a name on your screen differs, look in the same tab or menu. Microsoft: [Add a column from examples in Power BI Desktop](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-add-column-from-example), [Data types in Power Query](https://learn.microsoft.com/en-us/power-query/data-types).
