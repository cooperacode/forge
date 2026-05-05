---
name: brief
description: "Generate a strategic brief artifact by synthesizing all wiki knowledge for the active Strategic work item. Use when the hierarchy level is Strategic (Theme or Initiative)."
---

# Skill: Brief (Strategic)

You were invoked by the orchestrator because the user wants to generate a **strategic brief** for the active work item. Your job is to synthesize all ingested knowledge from the wiki into a structured, decision-ready brief.

The orchestrator passed `OUTPUT_PATH` and `WORK_ITEM_META` at the top of this prompt — use those values for all file operations and document metadata.

Follow every step in order.

---

## Step 1 — Verify wiki has content

Read `{OUTPUT_PATH}index.md` (the local wiki index for this work item).

- If the file does not exist or has no entries under Sources, Concepts, or Entities, tell the user no sources have been ingested for this work item and stop. Suggest running `/ingest` first.
- If it exists, note the total number of pages listed (sources, concepts, entities).

---

## Step 2 — Load all referenced wiki pages

From `{OUTPUT_PATH}index.md`, collect every page link listed. Each link points to a file in `docs/wiki/`. Load them in this order:

1. `docs/wiki/overview.md` — the synthesis layer; read this first. (Read directly — it is always the global synthesis.)
2. All `sources/` pages listed in the local index — follow each link to load from `docs/wiki/`.
3. All `concepts/` pages listed in the local index.
4. All `entities/` pages listed in the local index.

**If `{CONTEXT_PATH}` is non-empty**, read all files present in `{CONTEXT_PATH}` after completing the list above. These are upstream artifacts from the parent work item. Treat them as authoritative constraints that take precedence over inferences from the local wiki when there is a conflict. Note each upstream source explicitly when you carry a fact forward (e.g., "per upstream `requirements.md`").

As you read, extract and track:

- **Goals & outcomes** explicitly stated across pages.
- **Constraints & boundaries** (what is out of scope or explicitly excluded).
- **Key stakeholders** (people, teams, organizations mentioned as responsible or affected).
- **Success metrics or KPIs** mentioned in any source.
- **Risks, blockers, and dependencies** flagged across pages.
- **Open questions** — any `## Open questions` sections or `[!contradiction]` callouts.
- **Timeline signals** — dates, milestones, or delivery expectations mentioned.

Do not write the brief yet. Complete the full read first.

---

## Step 3 — Confirm scope with the user

Before writing, surface a one-paragraph synthesis to the user:

```
Based on the wiki ({N} pages), here is what I plan to cover in the brief:

• [Goal or outcome 1]
• [Goal or outcome 2]
• [Key risk or open question]
• ...

Is this the right framing? Anything you want emphasized, excluded, or reworded?
```

Wait for a response. Adjust your understanding if the user provides corrections. If the user says "go ahead", proceed with your judgment.

---

## Step 4 — Write the strategic brief

Create the file `{OUTPUT_PATH}artifacts/brief.md`.

Use the template from `template.md` in this same skill directory. Fill all placeholders and preserve the section order.

Optional quality check: run `scripts/validate.sh {OUTPUT_PATH}artifacts/brief.md`.

Reference output format example: `examples/sample.md`.

Rules while writing:
- Every factual claim must cite a wiki page with `[[wikilinks]]`.
- Do not add facts from your training data. If the wiki does not cover a section, use a `> [!gap]` callout.
- Flag contradictions with `> [!contradiction]` and cite both sides.
- Write in plain, direct language. No filler. No passive voice where avoidable.

---
## Step 5 — Update navigation files

After writing the brief, update:

**`{OUTPUT_PATH}artifacts/index.md`** — create if it does not exist, then add or update the brief entry:

```markdown
# Artifacts — {WORK_ITEM_TITLE}

## Strategic

- [[brief]] — Strategic Brief (generated YYYY-MM-DD)
```

**`{OUTPUT_PATH}log.md`** — append one entry at the top:

```markdown
## [YYYY-MM-DD] artifact | Strategic Brief

Generated: artifacts/brief.md
Sources read: N pages (sources: N, concepts: N, entities: N)
Gaps flagged: N
Open questions: N
```

---

## Step 6 — Close the loop

Tell the user what was done:

```
Done. Strategic brief generated at {OUTPUT_PATH}artifacts/brief.md.

Pages read: N total (sources: N, concepts: N, entities: N)
Gaps flagged: N (sections with missing wiki coverage)
Open questions carried forward: N

Anything you want me to revise before we continue?
```

---

## Rules

- **Write all content in `{LANGUAGE}`.** If `LANGUAGE` is `pt-BR`, write in Brazilian Portuguese. If `LANGUAGE` is `en`, write in English. Apply this to artifact content, section headings, and all messages shown to the user. If `LANGUAGE` is not set, default to English.
- **Never write content not supported by the wiki.** Use `> [!gap]` for any section the wiki does not cover. Do not fill gaps with your training knowledge.
- **Never modify source or concept pages.** Brief generation is read-only on the wiki (`docs/wiki/`). The only files you write are `artifacts/brief.md`, `artifacts/index.md`, and `log.md` — all inside `{OUTPUT_PATH}`.
- **Never skip Step 3.** The user must confirm scope before you write 400+ words. This keeps the brief aligned with intent.
- **If `overview.md` does not exist**, proceed using source and concept pages only — note in the brief that the overview is absent.
- **If the wiki has fewer than 3 pages**, warn the user that the brief will have significant gaps and ask if they want to proceed or ingest more sources first.
