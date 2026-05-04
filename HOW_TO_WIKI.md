# How To: Create and Maintain a Wiki

This guide covers the three operations that build and maintain your knowledge base: ingesting sources, querying the wiki, and running health checks. It assumes you have an active work item (`/workitem`) and at least one source document ready.

---

## What is the wiki?

The wiki is the layer between your raw source documents and your generated artifacts. Every time you ingest a source, Claude reads it and writes structured wiki pages — summaries, concept definitions, entity profiles, and a synthesis overview. Artifacts are then generated from the wiki, not from the raw files.

```
input/          →    /ingest    →    output/wiki    →    /artifact    →    output/artifacts/
(raw sources)                       (structured)                           (briefs, ADRs, etc.)
```

The wiki lives entirely inside `output/` and is made of plain Markdown files organized into four folders:

```
output/
  sources/      ← one page per ingested document
  concepts/     ← themes, patterns, techniques extracted from sources
  entities/     ← people, organizations, systems, datasets named in sources
  overview.md   ← running synthesis of everything ingested so far
  index.md      ← navigation index: all pages listed by category
  log.md        ← audit trail: every ingest, query, and lint recorded
```

---

## The three operations

| Command | What it does | When to use |
|---|---|---|
| `/ingest` | Reads a source and writes wiki pages | Each time you add a new document to `input/` |
| `/query` | Answers a question from the wiki, with citations | Any time — before or after generating artifacts |
| `/lint` | Scans the wiki for problems and fixes what it can | Periodically, especially before generating artifacts |

---

## `/ingest` — Adding a source

### Step 1 — Place the file in `input/`

Drop the document into the active work item's `input/` folder:

```
docs/strategic/initiatives/20260503-redesign-the-onboarding-process/
  input/
    product-spec.pdf
    stakeholder-meeting-notes.md
    client-email.txt
```

Supported formats: **Markdown**, **plain text**, **PDF**, **images** (charts, screenshots, diagrams).

> One file per `/ingest` call. If you have five documents, run `/ingest` five times. Each source gets its own wiki page, and the wiki grows incrementally.

### Step 2 — Run the command

```
/ingest
```

Claude reads the file in full before doing anything else. For PDFs and images, it extracts all readable text first.

### Step 3 — Review key takeaways

Before writing any wiki page, Claude surfaces what it found:

```
Key takeaways from "stakeholder-meeting-notes.md":

• Budget is fixed at $80k with a 3-month delivery window.
• The client's main pain point is the manual status-update emails — 4h/week per coordinator.
• Authentication strategy is undecided: SSO vs. local login is an open question.
• Apelações (appeals) were mentioned but the client is unsure if they belong in MVP.

Is there anything here you want emphasized or ignored?
Does this contradict anything already in the wiki?
```

This is your chance to guide what gets preserved. You can:
- Say **"go ahead"** to proceed with Claude's judgment.
- Ask Claude to emphasize or ignore specific points.
- Flag a contradiction with something already in the wiki.

> This step is intentional and cannot be skipped. The human curates; Claude executes.

### Step 4 — Confirm the pages to update

Claude identifies which wiki pages will be created or updated:

```
Pages to update:
- sources/stakeholder-meeting-notes (new)
- concepts/budget-constraint (new)
- entities/client-coordinator (new)
- concepts/mvp-scope (exists — will update)
- overview (always updated)

Does this list look right?
```

Approve the list or adjust it. Then Claude writes each page.

### Step 5 — Review the summary

```
Done. Ingested "stakeholder-meeting-notes.md".

Created: sources/stakeholder-meeting-notes, concepts/budget-constraint, entities/client-coordinator
Updated: concepts/mvp-scope, overview
Flagged: 1 contradiction — sources/stakeholder-meeting-notes disputes concepts/mvp-scope
         on whether appeals belong in MVP.

Anything you want me to revisit before we continue?
```

Contradictions are flagged but never silently resolved. Claude marks them with a `> [!contradiction]` callout and leaves the decision to you.

---

### What a source page looks like

Every ingested document gets its own page at `output/sources/<slug>.md`:

```markdown
---
title: "Stakeholder Meeting Notes — 2026-05-03"
slug: stakeholder-meeting-notes
type: source
date_ingested: 2026-05-03
original_file: input/stakeholder-meeting-notes.md
---

## Summary

The kickoff meeting with the client's operations team...

## Key claims

- Budget is fixed at $80k with a 3-month window.
- Manual status-update emails consume ~4h/week per coordinator.
- ...

## Connections to existing wiki

This source reinforces [[concepts/mvp-scope]] on phased delivery.
It disputes [[concepts/mvp-scope]] on appeals: the client example
edital requires a 3-day appeal window, which phase 1 does not support.

> [!contradiction] This source disputes [[concepts/mvp-scope]] on whether
> appeals are a phase 1 requirement.

## Open questions

- [ ] Will authentication follow SSO or local login?
- [ ] Are appeals in or out of MVP scope?
```

---

## `/query` — Asking questions

You can query the wiki at any point — before, during, or after generating artifacts. Every answer is grounded in wiki pages, which trace back to source documents.

### Running a query

```
/query What does the wiki say about the authentication decision?
```

Claude reads `index.md`, identifies relevant pages, reads them, and answers with inline citations:

```
The authentication strategy is currently an open question in the wiki.

[[sources/systems-analyst-technical-notes]] identifies two options:
SSO (institutional) and local login. No decision has been made —
this appears as an open question in both that source and
[[sources/stakeholder-meeting-notes]].

[[concepts/role-based-access-control]] establishes that access must
follow the principle of least privilege, which constrains both options
but does not determine the choice between them.

Note: [[sources/technology-team-mandates]] does not address
authentication strategy — the wiki has no coverage on which
option is preferred by the technical team.

The wiki does not yet contain a resolution. Consider ingesting
a source with the technical team's position on this.
```

### What Claude will never do

- Answer from training knowledge alone — if the wiki doesn't cover it, Claude says so.
- Invent wiki pages or citations that don't exist.
- Give a confident answer when the wiki contains contradictions on the topic.

### Saving an answer as a wiki page

After answering, Claude offers to save the result:

```
Want me to save this as a wiki page?
```

If you say yes, the answer is filed under `output/concepts/<slug>.md` with all citations intact — and the query is logged in `log.md`. This is useful for synthesis questions where the answer itself becomes reusable knowledge.

---

## `/lint` — Wiki health check

Run lint periodically to catch structural problems and surface knowledge that is drifting out of date. It is especially useful before generating a major artifact.

### When to run it

- After ingesting 3 or more new sources in a session.
- Before running `/artifact brief` or `/artifact requirements`.
- If you notice broken links or missing pages while browsing the wiki.

### Running the check

```
/lint
```

Claude does a full scan first — structural problems, then content problems — before touching any file.

### The scan covers two categories

**Structural problems** (auto-fixable):

| Problem | What it means |
|---|---|
| Orphan pages | A wiki page exists but no other page links to it |
| Missing index entries | A file exists but isn't listed in `index.md` |
| Broken wikilinks | A `[[link]]` points to a page that doesn't exist |
| Missing frontmatter | A page is missing required metadata fields |
| Stub pages | A page was created as a placeholder and never filled in |

**Content problems** (require your input):

| Problem | What it means |
|---|---|
| Known contradictions | Pages with `> [!contradiction]` callouts |
| Implicit contradictions | Claims across pages that conflict but aren't flagged yet |
| Outdated sections | Pages with `> [!outdated]` callouts, or claims superseded by newer sources |
| Unfiled queries | Questions that were answered but not saved as wiki pages |
| Concept gaps | Terms mentioned across multiple pages with no page of their own |
| Stale overview | `overview.md` hasn't been updated since 3+ new sources were ingested |

### The lint report

```
## Lint report — 2026-05-04

### Structural
- Orphan pages (1): concepts/audit-trail
- Missing index entries (0)
- Broken wikilinks (2): concepts/mvp-scope → [[concepts/phased-delivery]] (missing)
                        sources/client-email → [[entities/finance-team]] (missing)
- Missing frontmatter (0)
- Stub pages (1): entities/finance-team

### Content
- Known contradictions (1): concepts/mvp-scope ↔ sources/stakeholder-meeting-notes on appeals
- Implicit contradictions (0)
- Outdated sections (0)
- Unfiled queries (1): "What does the wiki say about authentication?" — 2026-05-03
- Concept gaps (1): "phased delivery" appears in 3 pages, no page exists
- Stale overview: no

### Summary
6 issues found. 4 auto-fixable. 2 require your input.
```

### Choosing how to proceed

```
How do you want to proceed?
(a) Fix everything auto-fixable now, show me the rest
(b) Go through issues one by one
(c) Fix only a specific category
(d) Just the report — I'll decide later
```

Auto-fixable issues (structural) are resolved without your involvement. Content issues — contradictions, outdated sections, concept gaps — are presented one at a time with options:

```
Contradiction: concepts/mvp-scope says appeals are out of scope for phase 1.
sources/stakeholder-meeting-notes says the client's example edital requires
a 3-day appeal window, implying they must be in scope.

Options:
(1) Update concepts/mvp-scope to reflect the tension and flag for stakeholder decision
(2) Add a [!contradiction] callout to concepts/mvp-scope citing both sources
(3) Leave as-is and note for future ingest
```

Claude waits for your choice before changing anything.

### After lint

```
Lint complete.

Auto-fixed: 4 (broken links: 2, stub filled: 1, orphan linked: 1)
Resolved with input: 1 (contradiction flagged in concepts/mvp-scope)
Deferred: 1 (unfiled query — you chose to skip)
Contradictions outstanding: 1
Next recommended lint: after 3 more ingests or in ~30 days
```

---

## The full wiki cycle

```
Drop file into input/
        ↓
   /ingest              ← repeat for each source
        ↓
   /query               ← any time, as often as needed
        ↓
   /lint                ← periodic, especially before /artifact
        ↓
   /artifact            ← when the wiki is ready
```

There is no required number of sources before running `/artifact`. The wiki tells you — gaps in the lint report or in query answers are the signal to ingest more before generating.

---

## Common questions

**Can I ingest the same file twice?**
Claude will create a duplicate source page. To avoid this, check `index.md` before ingesting — if the slug is already listed, skip it or ingest an updated version of the file instead.

**Can I paste content directly into the chat instead of using a file?**
No. Claude will ask you to save it to `input/` first. This keeps the source layer clean and traceable — every wiki claim should be resolvable back to a file on disk.

**What if a source contradicts something already in the wiki?**
Claude flags it with a `> [!contradiction]` callout and reports it at the end of ingest. It never silently overwrites existing knowledge. Resolution is always your decision.

**Can I delete a wiki page?**
Avoid it. If a page is wrong or outdated, use `> [!outdated]` or `> [!deprecated]` and remove it from `index.md`. The file stays — it may be referenced by other pages or by `log.md`.

**How often should I run `/lint`?**
A good rule: after every 3–5 ingests, or before generating any artifact. The lint log entry tells you when it was last run and suggests a next date.

---

See [HOW_TO_ARTIFACTS.md](HOW_TO_ARTIFACTS.md) for what to do once the wiki is ready.
