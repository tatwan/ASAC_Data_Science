# ASAC build tools

| Path | Use |
|---|---|
| [Instructor slide scripts](../instructor/slides/) | Build and check editable decks. The adjacent day-specific source notes list inputs and verification. |
| [D19 filter figures](../instructor/slides/d19_filter_figures.py) | Builds the seven editable redraw figures and computes the shown totals from the D19 start CSVs. Imported by [build_D19.py](../instructor/slides/build_D19.py). |
| [D19 start and check scripts](../instructor/w07/) | Prepare and verify the Week 7 practice data. See the [D19 source notes](../instructor/slides/D19-SOURCES.md). |
| [Model guide builder](../instructor/slides/build_PL300_Model.py) | Builds the 97-page standalone PL-300 guide on the ASAC template; recomputes values from D20 CSVs. |
| [Model guide text](../instructor/slides/pl300_model_content.py) | Authored skill definitions, worked examples, limits and original questions/answers used by the builder. |
| [Model guide PDF renderer](../instructor/slides/render_PL300_Model.py) | Exports the guide’s supported native shapes and text to a vector PDF with embedded fonts, links and bookmarks. Requires matplotlib, Pillow, python-pptx and pypdf. |
| [Model guide checks](../instructor/slides/check_PL300_Model.py) | Checks 97 pages, 16 skill starts, computed values, inventory keys/balances, local links and ASAC collisions; optional PDF parity checks. |
| [PL-300 review builder](../instructor/slides/build_PL300_Review.py) | Builds the 54-page four-domain review deck in module 08. |
| [Final Mash review builder](../instructor/slides/build_final_review_markdownmash.py) | Builds the 80-page explained version of the last Mash in module 08; build the review deck first, because READ MORE page numbers are looked up by title in it and in D17–D22. Needs Archivo and IBM Plex Mono in `~/.fonts` for correct fitting. |
| [Model guide number and inventory generator](../instructor/w07/make_pl300_model_numbers.py) | Generates the number registry and synthetic stock fixture from D20 sales plus stated opening balances and deliveries. |
| [D27 penguin chart](../instructor/w08/d27_penguin_chart.py) | Draws the chart in D27 Activity 03 from its CSV and prints the numbers the README and deck use. |
