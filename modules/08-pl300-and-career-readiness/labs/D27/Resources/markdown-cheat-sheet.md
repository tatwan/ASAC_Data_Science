# Markdown cheat sheet

GitHub's full guide is [Basic writing and formatting syntax](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax).

| You type | You get |
|---|---|
| `# Title` · `## Section` · `### Part` | Headings at three levels. A space after the `#` signs is required |
| `**bold**` · `*italic*` | **bold** · *italic* |
| `` `species` `` | Inline code: `species` |
| An empty line | A new paragraph |
| `- item` | A bulleted list. Two spaces before the dash put it one level down |
| `1. step` | A numbered list |
| `- [ ] task` · `- [x] task` | A checkbox, empty or ticked |
| `[words](https://address)` | A link |
| `[words](sql/file.sql)` | A link to a file in the same repository (a relative link) |
| `![alt text](images/file.png)` | An image. The alt text is read aloud by screen readers |
| `\| a \| b \|` then `\|---\|---:\|` | A table. The row of dashes is required; `---:` lines a column up on the right |
| Three backticks and `sql`, the code, three backticks | A code block with coloured keywords |
| Three backticks and `mermaid`, the diagram, three backticks | A diagram GitHub draws |
| `> text` | A quotation |
| `---` on its own line | A horizontal line |

## Common Markdown mistakes and how to fix them

| Mistake | What you see | Fix |
|---|---|---|
| No space after the `#` signs | `#Title` as plain text | Add the space |
| A space in an image file name | Your typed text instead of the image | Rename the file: `weight-by-species.png` |
| Wrong letter case in a path | A broken image or a 404 page | Copy the name from the file list |
| No row of dashes under a table header | The `\|` signs (pipes) shown as text | Add `\|---\|---\|` |
