# How To — manifast quick-start

End-to-end workflow in execution order. Run each step once per work item.

---

## 0. Setup

```bash
git remote add origin git@github.com:cooperacode/manifast.git
cd manifast
```

Then open the folder in your editor:

```bash
# Claude Code
claude --plugin .

# VS Code — open the folder; commands load automatically
```

---

## 1. Set language _(optional)_

```
/language
```

Defaults to `en`. Pass a code to skip the menu:

```
/language pt-BR
/language en
```

Supported: `en` · `pt-BR`

---

## 2. Register or select a work item

```
/workitem
```

**Create new** → choose hierarchy level → choose type → fill in details → link a parent (optional).

**Select existing** → pick from the list.

Both paths write the active item to `.env`.

Work item levels and types:

| Level | Types |
|---|---|
| Strategic | Theme, Initiative |
| Product | Epic, Feature |
| Tactical | User Story, Task, Bug |

---

## 3. Drop source files into `input/`

Copy documents into the active work item's input folder:

```
{work-item-path}/input/
  ├── spec.pdf
  ├── meeting-notes.md
  └── stakeholder-brief.txt
```

Accepted formats: Markdown, plain text, PDF, images.

---

## 4. Ingest knowledge

```
/ingest
```

Claude reads each source, surfaces 3–5 key takeaways, waits for your feedback, then writes structured wiki pages into `output/`.

After confirming (or typing **"go ahead"**), the command creates:

```
output/
  sources/     ← one page per source file
  concepts/    ← extracted concepts
  entities/    ← extracted entities
  overview.md
  index.md
  log.md
```

Repeat for each source file.

---

## 5. Query the wiki

```
/query What are the MVP requirements for X?
```

Every answer cites a wiki page. Gaps and contradictions are surfaced explicitly.

---

## 6. Generate artifacts

```
/artifact
```

Omit the type to see the menu. Pass a type to skip it:

```
/artifact brief          → Strategic Brief
/artifact requirements   → Requirements (quality attributes & constraints for Strategic; functional for Product)
/artifact adr            → Architecture Decision Records
/artifact diagram        → Architecture or flow diagram (Mermaid)
/artifact der            → Entity-Relationship Diagram (Mermaid ER)
/artifact feature-list   → Feature List with priorities and dependencies
/artifact user-story     → User Story with Gherkin scenarios
```

### Recommended generation order

```
brief → requirements → feature-list → adr → der → diagram → user-story → diagram (seq/state)
```

Each artifact enriches the next. `feature-list` is a hard dependency for `user-story`.

### Available artifacts by level

| Level | Available types |
|---|---|
| Strategic | `brief` · `requirements` · `adr` · `diagram` |
| Product | `requirements` · `der` · `adr` · `feature-list` · `diagram` |
| Tactical | `user-story` · `diagram` |

All artifacts are written to `{work-item-path}/output/artifacts/`.

---

## 7. Lint — wiki health check

```
/lint
```

Scans for orphan pages, broken wikilinks, missing frontmatter, stale content, and contradictions. Auto-fixes structural issues; presents content issues for your review.

---

## Full sequence at a glance

```
git clone + open folder
      ↓
/language          (once per repo, optional)
      ↓
/workitem          (once per work item)
      ↓
drop files → input/
      ↓
/ingest            (once per source file)
      ↓
/query             (any time)
      ↓
/artifact          (brief → requirements → feature-list → adr → der → diagram → user-story)
      ↓
/lint              (periodic health check)
```

---

## Command reference

| Command | Purpose |
|---|---|
| `/language` | Set artifact language (`en`, `pt-BR`) |
| `/workitem` | Register or select a work item |
| `/ingest` | Add a source file to the wiki |
| `/query` | Ask questions with wiki-backed citations |
| `/artifact [type]` | Generate a software engineering artifact |
| `/lint` | Find and fix wiki structural and content issues |
