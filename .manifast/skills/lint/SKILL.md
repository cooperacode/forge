---
name: lint
description: "Scan the wiki for structural, factual, and navigational problems — and fix what you can, flag what you cannot."
---

# Skill: Lint

You were invoked by the orchestrator because the user wants to check the health of the wiki. Your job is to find structural, factual, and navigational problems — and fix what you can, flag what you cannot.

Lint is a maintenance operation, not a content operation. You are not adding new knowledge. You are making the existing knowledge more reliable and navigable.

The orchestrator passed `WIKI_PATH` at the top of this prompt — use that value for all file operations.

If `WIKI_PATH` is not explicitly set, derive it: `WIKI_PATH = docs/wiki/`

Follow every step in order. Complete the full scan before fixing anything.

---

## Step 1 — Load the full index

Read `{WIKI_PATH}index.md` in full. Build an internal map of:

- Every page that exists, by category (sources, entities, concepts).
- Every page's one-line summary.
- Total page count.

If `{WIKI_PATH}index.md` is missing or empty, tell the user and stop. There is nothing to lint.

Then read `{WIKI_PATH}log.md` — specifically the last 10 entries. Note:

- Which sources were recently ingested.
- Which queries were run but not filed as pages.
- Whether lint has been run before and when.

---

## Step 2 — Scan for structural problems

Work through each category of problem below. For each one, maintain a running list as you scan. Do not fix yet — complete the full scan first.

### 2a — Orphan pages
Pages that exist in `{WIKI_PATH}index.md` but have no incoming `[[wikilinks]]` from any other page. These are dead ends — reachable only via the index, invisible in organic navigation.

To find them: for each page, check whether any other page links to it. This requires reading pages — be efficient, use frontmatter `related_*` fields first before reading full content.

### 2b — Missing index entries
Pages that exist as files in `{WIKI_PATH}` but are absent from `{WIKI_PATH}index.md`. This happens when a page is created during ingest but the index update is missed.

To find them: list all `.md` files in `{WIKI_PATH}sources/`, `{WIKI_PATH}entities/`, and `{WIKI_PATH}concepts/`. Cross-reference against `{WIKI_PATH}index.md`.

### 2c — Broken wikilinks
`[[wikilinks]]` that reference a slug that does not correspond to any existing file. These are dangling pointers — they look like navigation but lead nowhere.

To find them: scan pages for `[[...]]` patterns and verify each target exists.

### 2d — Missing frontmatter fields
Pages missing required frontmatter fields as defined in `{WIKI_PATH}SCHEMA.md`. At minimum: `title`, `slug`, `type`, `source_workitem`, `date_ingested` (for sources) or equivalent.

### 2e — Empty or stub pages
Pages with frontmatter but no substantive body content — less than 3 lines of non-frontmatter text. These were likely created as placeholders and never filled in.

### 2f — Orphan work item references
Pages whose `source_workitem` field points to a work item path that no longer exists in `docs/manifast.yaml`. These are wiki pages left behind by removed work items.

---

## Step 3 — Scan for content problems

### 3a — Contradictions
Pages that contain `> [!contradiction]` callouts. List each one with both sides of the contradiction. These are known and flagged — your job is to surface them for the user, not silently resolve them.

Also scan for implicit contradictions: claims across different pages that are logically incompatible but not yet flagged. This requires reading overlapping concept and source pages. Use judgment — do not over-flag. Only flag if the conflict is clear and material.

### 3b — Outdated content
Pages that contain `> [!outdated]` callouts. List them. Then check: has a newer source been ingested that could resolve the outdated section? If yes, note which source.

Also check: for each source ingested in the last 3 log entries, are there older concept or entity pages whose claims are now superseded? Compare publication dates and claims.

### 3c — Unfiled queries
Queries logged in `{WIKI_PATH}log.md` with "not filed" that produced substantive answers. These are knowledge that was synthesized but not persisted. List them as candidates for filing.

### 3d — Concept gaps
Entities or concepts mentioned by name inside wiki pages but without their own page. Scan for `[[wikilinks]]` pointing to non-existent pages — these are explicit gaps. Also look for proper nouns in body text that appear across multiple pages but have no entry.

### 3e — Stale overview
Check `{WIKI_PATH}overview.md` last-modified context against `{WIKI_PATH}log.md`. If more than 3 sources have been ingested since the overview was last substantially updated, flag it as stale.

---

## Step 4 — Report findings

Present a structured report to the user before fixing anything. Format:

```
## Lint report — YYYY-MM-DD

### Structural
- Orphan pages (N): entity/x, concept/y, ...
- Missing index entries (N): ...
- Broken wikilinks (N): page → [[target]] does not exist
- Missing frontmatter (N): ...
- Stub pages (N): ...
- Orphan work item refs (N): page → source_workitem path not in manifast.yaml

### Content
- Known contradictions (N): concept/x ↔ sources/y on topic Z
- Implicit contradictions (N): ...
- Outdated sections (N): ...
- Unfiled queries (N): "question text" — YYYY-MM-DD
- Concept gaps (N): term appears in N pages, no page exists
- Stale overview: yes/no — last updated after ingest X, N ingests ago

### Summary
N issues found. N auto-fixable. N require your input.
```

Then ask:

```
How do you want to proceed?
(a) Fix everything auto-fixable now, show me the rest
(b) Go through issues one by one
(c) Fix only a specific category
(d) Just the report — I'll decide later
```

Wait for the user's response before doing anything.

---

## Step 5 — Fix what is auto-fixable

The following can be fixed without human judgment. Fix these only if the user chose (a) or (c) for the relevant category.

| Problem | Auto-fix |
|---|---|
| Missing index entry | Add the page to `{WIKI_PATH}index.md` in the correct category with a one-line summary extracted from the page's frontmatter or first paragraph. |
| Broken wikilink pointing to a stub that should exist | Create a minimal stub page with correct frontmatter and an `## Open questions` section noting it needs content. Add to index. |
| Missing frontmatter fields | Add missing fields with inferred values where possible (`slug` from filename, `type` from folder). Flag inferred values with `# inferred` comment. |
| Orphan page | Find the 2–3 most relevant pages that should link to it and add the wikilink in their `related_*` frontmatter. |

Do not auto-fix contradictions, outdated content, concept gaps, or orphan work item references. These require human judgment or new ingestion.

Report each fix as you make it:

```
Fixed: added missing index entry for concepts/cross-attention
Fixed: created stub for entities/hinton-geoffrey (broken link target)
Fixed: added slug field to sources/attention-is-all-you-need (inferred)
```

---

## Step 6 — Present items requiring judgment

For each issue that cannot be auto-fixed, present it clearly and offer options. Go one at a time if the user chose (b), or present all grouped if (a).

### Contradiction
```
Contradiction: concepts/self-attention says "O(n²) complexity is unavoidable"
but sources/flash-attention claims "sub-quadratic attention is achievable."

Options:
(1) Update concepts/self-attention to reflect the newer claim from sources/flash-attention
(2) Add an explicit [!contradiction] callout to concepts/self-attention
(3) Leave as-is and note for future ingest
```

### Outdated section
```
Outdated: entities/openai has a section on GPT-3 as "largest model available"
which is superseded by sources/gpt4-technical-report (ingested 2024-03-15).

Options:
(1) Update the section using content from sources/gpt4-technical-report
(2) Mark with [!outdated] and leave for manual update
(3) Skip
```

### Concept gap
```
Gap: "mixture of experts" appears in 4 pages (concepts/scaling-laws,
sources/switch-transformer, sources/mixtral, overview) but has no page.

Options:
(1) Create concepts/mixture-of-experts now, synthesizing from those 4 pages
(2) Add to a "pages to create" section in {WIKI_PATH}index.md for later
(3) Skip
```

### Unfiled query
```
Unfiled query (2024-11-02): "What do my sources say about attention sink?"
This answer was synthesized but not saved.

Options:
(1) Re-run the query and file the result as concepts/attention-sink
(2) Skip — the question is no longer relevant
```

### Orphan work item reference
```
Orphan reference: sources/some-document has source_workitem pointing to
docs/strategic/initiatives/20260503-deleted-initiative/ which is no longer
in manifast.yaml.

Options:
(1) Update source_workitem to the closest active work item
(2) Clear source_workitem field (set to "")
(3) Leave as-is
```

Wait for the user's choice on each item before proceeding.

---

## Step 7 — Update log

After lint is complete, append to `{WIKI_PATH}log.md`:

```markdown
## [YYYY-MM-DD] lint | Full wiki scan

Issues found: N total
Auto-fixed: N (missing index entries: N, broken links: N, frontmatter: N, orphans: N)
Resolved with input: N
Deferred: N
Contradictions outstanding: N
Next recommended lint: after N more ingests or in ~30 days
```

---

## Rules

- **Write all content in `{LANGUAGE}`.** If `LANGUAGE` is `pt-BR`, write in Brazilian Portuguese. If `LANGUAGE` is `en`, write in English. Apply this to the lint report and all messages shown to the user. If `LANGUAGE` is not set, default to English.
- **Complete the full scan before fixing anything.** Never fix as you go — you need the complete picture before touching files.
- **Never resolve contradictions unilaterally.** Surface them, present options, wait for the user. The human decides what the wiki believes.
- **Never delete pages.** If a page is a confirmed duplicate or error, mark it with a `> [!deprecated]` callout and remove it from `{WIKI_PATH}index.md`. The file stays.
- **Never ingest new sources during lint.** If a gap would be best filled by ingesting a new source, say so and stop. Tell the user to run ingest separately.
- **Never read or modify work item `output/` folders.** Lint operates on `{WIKI_PATH}` only.
- **If the wiki has fewer than 10 pages**, skip Step 3c (unfiled queries) and Step 3e (stale overview) — they are not meaningful at small scale.
- **One lint session covers one full scan.** Do not run partial lint. If the user wants to check only orphans, that is a query ("which pages have no incoming links?"), not a lint.
