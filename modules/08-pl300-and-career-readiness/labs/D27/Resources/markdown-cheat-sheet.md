# Markdown cheat sheet

Everything used in D27, with what it gives you. GitHub's full guide is [Basic writing and formatting syntax](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax).

| You type | You get |
|---|---|
| `# Title` · `## Section` · `### Part` | Headings at three levels. A space after the `#` signs is required |
| `**bold**` · `*italic*` | **bold** · *italic* |
| `` `v_days` `` | Inline code: `v_days` |
| An empty line | A new paragraph. Also needed before a list or a table |
| `- item` | A bulleted list. Two spaces before the dash put it one level down |
| `1. step` | A numbered list |
| `[words](https://address)` | A link |
| `[words](sql/file.sql)` | A link to a file in the same repository (a relative link) |
| `![alt text](images/file.png)` | An image. The alt text is read aloud by screen readers |
| `\| a \| b \|` then `\|---\|---:\|` | A table. The dashes row is required; `---:` lines a column up on the right |
| Three backticks and `sql`, the code, three backticks | A code block with coloured keywords |
| `> text` | A quotation block |
| `---` on its own line | A horizontal rule |

## Four mistakes and their fix

| Mistake | What you see | Fix |
|---|---|---|
| No empty line before a list or table | Dashes or pipes inside a sentence | Add an empty line above |
| A space in an image file name | A broken image | Rename the file: `story-page.png` |
| Wrong letter case in a path | A broken image or a 404 link | Copy the name from the file list |
| No dashes row under a table header | Pipes shown as text | Add `\|---\|---\|` |
