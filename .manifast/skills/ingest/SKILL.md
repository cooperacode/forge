---
name: ingest
description: "Add new sources to the wiki, creating and updating pages as needed. Always update the index and log. Default is non-interactive. Pass -buddy for step-by-step confirmation."
---

# Skill: Ingest

You were invoked by the orchestrator because the user wants to add a new source to the wiki. Follow every step in order. Do not skip steps. Do not proceed to the next step without completing the current one.

The orchestrator passed `INPUT_PATH`, `WIKI_PATH`, and `WORK_ITEM_PATH` at the top of this prompt — use those values for all file operations.

If these variables are not explicitly set, derive them from `.env`:
- `INPUT_PATH = {MWI_PATH}/input/`
- `WIKI_PATH = docs/wiki/`
- `WORK_ITEM_PATH = {MWI_PATH}`

Derive `OUTPUT_PATH = {WORK_ITEM_PATH}/output/`.

---

## Buddy mode

By default this skill runs non-interactively — it processes all files in `{INPUT_PATH}` sequentially without pausing for confirmation.

If the user invoked the skill with `-buddy` (e.g. `/ingest -buddy`), activate **buddy mode**:

- Pause at Steps 2, 4, and 7 to ask the user for input before proceeding.
- At Step 1, present a numbered menu and wait for the user to select a file.
- At Step 2, surface key takeaways and wait for the user's response before writing anything.
- At Step 4, present the page list and wait for approval before updating.
- At Step 7, ask "Anything you want me to revisit?" before closing.

---

## Step 1 — Select the source

**Default mode:**

1. List all files in `{INPUT_PATH}`. If the folder does not exist or is empty, tell the user and stop.

2. Read `{OUTPUT_PATH}index.md` (if it exists) and extract every entry under `## Sources`. Each entry slug corresponds to an already-ingested file. Compute the expected slug for each file in `{INPUT_PATH}` as the lowercase hyphen-separated filename without extension (e.g. `meeting-notes.pdf` → `meeting-notes`). Filter out any file whose slug already appears in the Sources section — those have been ingested in a previous call.

3. From the remaining unprocessed files, take the first batch of **up to 5**. Display the batch before starting:

```
Files in input/: 12 total — 7 already ingested, 5 to process now.

Batch (5 of 5 remaining):
[1/5] filename-a.pdf
[2/5] filename-b.md
[3/5] filename-c.docx
[4/5] filename-d.pdf
[5/5] filename-e.txt

Starting with: filename-a.pdf
```

4. Do not wait for user input. For each file in the batch, announce it before reading:

```
[1/5] Processing: filename-a.pdf
```

Read each file in full and process it through Steps 2–7 before moving to the next file in the batch.

- If a file is a PDF or image, extract all readable text first.
- If a file has images with relevant content (charts, diagrams, screenshots), note them explicitly — you will reference them in the summary page.

**Buddy mode:** List the contents of `{INPUT_PATH}` and present a numbered menu:

```
Files available in input/:

1. filename-a.pdf
2. filename-b.md
3. filename-c.docx

Which file do you want to ingest? (enter the number)
```

- Wait for the user to reply with a number. Do not guess or assume a default.
- Once the user selects a file, confirm the choice ("You selected: filename-a.pdf — proceeding.") and read it in full using the Read tool. Never infer or synthesize its content from context.

**Do not ingest from outside `{INPUT_PATH}` under any circumstance.**

---

## Step 2 — Discuss before writing

**Default mode:** Print the key takeaways (3–5 bullet points) and proceed immediately with your own judgment. Do not wait for a response.

**Buddy mode:** Before touching any wiki file, surface the key takeaways. Be concise: 3–5 bullet points max. Then ask:

- Is there anything here you want emphasized or ignored?
- Does this contradict or reinforce anything already in the wiki?
- Are there entities or concepts here that already have pages?

Wait for the user's response. Adjust your understanding before proceeding. If the user says "go ahead" with no changes, proceed with your own judgment.

This step exists because the human curates, the LLM executes. Do not skip it even if the source seems straightforward.

---

## Step 3 — Create the source summary page

Create `{WIKI_PATH}sources/<slug>.md` where `<slug>` is a lowercase hyphenated version of the source title.

Use this exact frontmatter:

```yaml
---
title: "Full title of the source"
slug: source-slug
type: source
date_ingested: YYYY-MM-DD
original_file: {INPUT_PATH}filename.ext
source_workitem: {WORK_ITEM_PATH}
authors: []
tags: []
related_concepts: []
related_entities: []
---
```

Page structure:

```markdown
## Summary

2–4 paragraphs. What is this source about? What is its main argument or contribution?
Write as if explaining to someone who will never read the original.

## Key claims

- Claim 1 — be specific, include data or quotes where relevant.
- Claim 2
- ...

## Connections to existing wiki

What does this source confirm, challenge, or add nuance to?
Reference existing pages using [[wikilinks]].
If it contradicts an existing page, flag it explicitly:

> [!contradiction] This source disputes [[concepts/existing-page]] on X.

## Open questions

What does this source leave unanswered? What would be worth investigating next?

## Notable quotes

> "Direct quote if relevant." (p. N or timestamp)
```

---

## Step 4 — Identify pages to update

Before writing anything, scan `{WIKI_PATH}index.md` and list every page that this source touches. Think across two categories:

**Entities** — people, organizations, products, datasets, models named in the source. Check if a page already exists. If yes, update it. If no, create it.

**Concepts** — themes, techniques, theories, arguments the source engages with. Same rule: update if exists, create if not.

Write this list out before proceeding:

```
Pages to update:
- entities/author-name (exists)
- concepts/self-attention (exists)
- concepts/cross-attention (new)
```

**Default mode:** Print the list and proceed immediately without waiting for a response.

**Buddy mode:** Ask the user if this list looks right. Adjust if needed.

---

## Step 5 — Update or create each page

Work through the list from Step 4 one page at a time.

### Updating an existing page

Read the current page fully. Then:

- Add new information in the appropriate section.
- Do not delete existing content unless it is factually wrong — use `> [!outdated]` instead.
- If the source contradicts something on the page, add a `> [!contradiction]` callout with a link to the source page.
- Add `[[sources/slug]]` to the page's `related_sources` frontmatter field.
- Add a `## From [[sources/slug]]` subsection if the source adds substantial new content.

### Creating a new entity page

Frontmatter:

```yaml
---
title: "Entity Name"
slug: entity-slug
type: entity
subtype: person | organization | model | dataset | product
source_workitem: {WORK_ITEM_PATH}
tags: []
related_sources: [sources/slug]
related_concepts: []
---
```

Write a factual summary of who or what this entity is, based only on what your sources say. Do not add external knowledge not present in the wiki.

### Creating a new concept page

Frontmatter:

```yaml
---
title: "Concept Name"
slug: concept-slug
type: concept
source_workitem: {WORK_ITEM_PATH}
tags: []
related_sources: [sources/slug]
related_entities: []
related_concepts: []
---
```

Page structure:

```markdown
## Definition

What is this concept? One clear paragraph.

## How it works

Mechanism, process, or explanation.

## Evidence and claims

What do ingested sources say about this? Cite with [[wikilinks]].

## Connections

Links to related concepts and entities.

## Open questions
```

---

## Step 6 — Update navigation files

After all pages are written, update four navigation files — two global, two local.

**`{WIKI_PATH}index.md`** (global) — update two areas:

1. **Navigation**: add new pages in the correct category (`## Sources`, `## Entities`, `## Concepts`). For updated pages, do not add a duplicate entry. Entries use paths relative to `docs/wiki/`.
2. **Synthesis**: update the `## Synthesis` section with a one-paragraph summary of what this source contributes to the overall picture. Update `### Current state of knowledge` if the source meaningfully changes the thesis. Add any new contradictions or unresolved tensions to `### Open tensions`. Create these subsections if they do not exist yet.

**`{WIKI_PATH}log.md`** (global) — append one entry at the top (most recent first):

```markdown
## [YYYY-MM-DD] ingest | Title of source

Pages touched: sources/slug, entities/x, concepts/y (N total)
New pages created: concepts/cross-attention
Contradictions flagged: 1 (see sources/slug)
Work item: {WORK_ITEM_PATH}
```

**`{OUTPUT_PATH}index.md`** (local) — add new pages created or updated in this ingest. This is a subset view of the global wiki scoped to this work item. Entries use repo-root paths (e.g., `docs/wiki/sources/slug.md`). Create the file if it does not exist, using this frontmatter:

```yaml
---
title: "Local Index — {WORK_ITEM_TITLE}"
type: local-index
work_item: {WORK_ITEM_PATH}
last_updated: YYYY-MM-DD
---
```

For each new or updated page, add an entry under the correct category. Do not duplicate entries that already exist in the local index.

```markdown
## Sources

- [slug](docs/wiki/sources/slug.md) — one-line description

## Entities

- [slug](docs/wiki/entities/slug.md) — one-line description

## Concepts

- [slug](docs/wiki/concepts/slug.md) — one-line description
```

**`{OUTPUT_PATH}log.md`** (local) — append one entry at the top, same format as the global log entry above. Create the file if it does not exist.

---

## Step 7 — Close the loop

Tell the user what was done in plain language. No need to list every file — summarize:

```
Done. Ingested "Attention Is All You Need" (2017).

Created: sources/attention-is-all-you-need, concepts/cross-attention
Updated: concepts/self-attention, concepts/transformer, entities/vaswani-ashish
Flagged: 1 contradiction with concepts/positional-encoding
```

**Default mode:** Print the per-file summary. Announce the transition to the next file in the batch before continuing:

```
[1/5] Done: filename-a.pdf
[2/5] Next: filename-b.md — starting now.
```

After all files in the current batch are processed, print a consolidated summary:

```
Batch complete. Processed 5 files.

Created: sources/filename-a, sources/filename-b, concepts/x, entities/y (N total)
Updated: concepts/z, overview
Flagged: 1 contradiction (see sources/filename-a)
```

If unprocessed files still remain in `{INPUT_PATH}`, append:

```
N files still pending in input/. Run /ingest again to process the next batch.
```

Then stop. Do not process beyond the 5-file batch limit per call.

**Buddy mode:** Append "Anything you want me to revisit before we continue?" and wait for a response before moving on or closing.

---

## Language

Write all wiki pages and messages to the user in `{LANGUAGE}`. If `LANGUAGE` is `pt-BR`, write in Brazilian Portuguese. If `LANGUAGE` is `en`, write in English. If `LANGUAGE` is not set, default to English.

## Rules

- Never ingest a file that is not in `{INPUT_PATH}`. If the user pastes content directly into chat, ask them to save it to `{INPUT_PATH}` first, then ingest from there. This keeps the source layer clean.
- Never create or write files inside `{INPUT_PATH}`. That folder is read-only for this skill — only the user places files there.
- Never fabricate or synthesize source content. If you cannot read a real file from `{INPUT_PATH}`, stop. Do not proceed with invented or inferred content.
- Never overwrite existing wiki content without reading it first.
- Never answer questions during ingest. If the user asks something mid-flow, note it and say you will answer after the ingest is complete.
- If a step produces more than ~20 file changes, pause and ask the user if they want to continue or scope down.
- Prefer updating existing pages over creating new ones. Fragmentation is the enemy of a useful wiki.
- Only `index.md` and `log.md` may exist at the root of `{WIKI_PATH}`. All other wiki pages go inside subfolders (`sources/`, `entities/`, `concepts/`). Never create any other file directly at the wiki root.
- Only `index.md` and `log.md` may exist at the root of `{OUTPUT_PATH}`. Never create any other file directly inside the work item's `output/` folder — artifacts go in `output/artifacts/`.
