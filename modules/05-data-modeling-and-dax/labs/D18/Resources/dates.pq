// D18 · the date table, dates: one row per day, 1 January 2024 to 31 December 2026 (1,096 rows).
// Paste into Home → Advanced Editor of a Blank Query, or copy single formulas into Custom Column.
// "en-US" keeps month names and the yyyy-MM text in English digits and words whatever your computer's language.
// fiscal_year is Nakheel's September-to-August year: 1 September 2025 is in 2025-26.
let
    Source = List.Dates(#date(2024, 1, 1), 1096, #duration(1, 0, 0, 0)),
    #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Renamed Columns" = Table.RenameColumns(#"Converted to Table", {{"Column1", "date"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns", {{"date", type date}}),
    #"Inserted Year" = Table.AddColumn(#"Changed Type", "year", each Date.Year([date]), Int64.Type),
    #"Inserted Month" = Table.AddColumn(#"Inserted Year", "month_no", each Date.Month([date]), Int64.Type),
    #"Inserted Month Name" = Table.AddColumn(#"Inserted Month", "month", each Date.MonthName([date], "en-US"), type text),
    // Custom Column 1 · year_month
    #"Added year_month" = Table.AddColumn(#"Inserted Month Name", "year_month",
        each Date.ToText([date], "yyyy-MM", "en-US"), type text),
    // Custom Column 2 · fiscal_year
    #"Added fiscal_year" = Table.AddColumn(#"Added year_month", "fiscal_year",
        each let y = if Date.Month([date]) >= 9 then Date.Year([date]) else Date.Year([date]) - 1
             in Text.From(y) & "-" & Text.End(Text.From(y + 1), 2), type text)
in
    #"Added fiscal_year"
