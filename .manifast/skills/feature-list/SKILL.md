---
name: feature-list
description: "Generate a Feature List artifact from the active wiki for Product-level work items (Epic or Feature). Lists features with descriptions, dependencies, and traceability to wiki sources."
---

# Skill: Feature List

You were invoked by the orchestrator because the user wants to generate a feature list for the active work item. Your job is to extract all features described in the wiki and present them in a structured, prioritized list.

The orchestrator passed `OUTPUT_PATH`, `WORK_ITEM_TITLE`, and `WORK_ITEM_TYPE` — use those values for all file operations and metadata.

This skill is for **Product-level work items only** (Epic, Feature). If `{WORK_ITEM_TYPE}` is Strategic or Tactical, tell the user this artifact is not applicable for that layer and stop.

Follow every step in order.

---

## Step 1 — Verify content sources

Attempt to read `{OUTPUT_PATH}index.md` (the local wiki index for this work item) and check whether `{CONTEXT_PATH}` is non-empty.

Determine the content situation using the table below:

| `{OUTPUT_PATH}index.md` | `{CONTEXT_PATH}` | Action |
|--------------------------|------------------|--------|
| exists and has entries   | any              | Set `LOCAL_WIKI = true`. Note the total number of pages listed. |
| missing or no entries    | has content      | Set `LOCAL_WIKI = false`. Warn the user: "No sources ingested for this work item — proceeding with upstream context only." |
| missing or no entries    | empty or absent  | Stop. Tell the user no sources have been ingested and there is no upstream context. Suggest running `/ingest` first. |

---

## Step 2 — Read all wiki pages

**If `LOCAL_WIKI = true`**, read in this order:

1. `docs/wiki/overview.md` — global synthesis (read directly)
2. All `sources/` pages listed in `{OUTPUT_PATH}index.md` — follow each link to load from `docs/wiki/`
3. All `concepts/` pages listed in `{OUTPUT_PATH}index.md`
4. All `entities/` pages listed in `{OUTPUT_PATH}index.md`

**If `{CONTEXT_PATH}` is non-empty**, read all files present in `{CONTEXT_PATH}` after completing the list above. These are upstream artifacts from the parent work item:
- Upstream `brief.md` defines the strategic goals — features that do not serve any stated goal should be flagged as unaligned.
- Upstream `requirements.md` (NFR) lists constraints — any feature that would violate a constraint must be flagged.
- Note each upstream source when carrying a constraint or framing forward.

While reading, extract every **feature** mentioned — a feature is a distinct capability that delivers value to a user or system. Look for:

- Named functionalities with a described behavior
- User-facing actions or interactions
- System-to-system integrations
- Administrative or configuration capabilities
- Explicitly excluded capabilities (out-of-scope features)

For each feature found, note:
- Name / short title
- Description (what it does)
- User or system that benefits
- Dependencies on other features (if stated)
- Priority signals (MVP, post-MVP, phase 2, etc.)
- Source wiki page

---

## Step 3 — Confirm the feature list with the user

Before writing, surface what you found:

```
Based on the wiki ({N} pages), I identified {N} features:

In scope:
1. {Feature name} — {one-line description} [{MVP | Post-MVP | Unclassified}]
2. ...

Explicitly out of scope:
- {Feature name} — {reason from wiki}

Gaps: {N} areas where wiki coverage was insufficient to define a feature clearly.

Does this look right? Any features I missed or that should be regrouped?
```

Wait for a response. If the user says "go ahead", proceed.

---

## Step 4 — Lock the output language

Before writing any file, resolve and declare the language that will be used throughout:

1. Read `{LANGUAGE}` from the parameters passed by the orchestrator.
2. Map to the expected locale:
   - `pt-BR` → Brazilian Portuguese
   - `en` → English
   - anything else → English (and warn the user)
3. If `{LANGUAGE}` is not set or is empty, default to `en` and warn: "LANGUAGE was not set — defaulting to English."
4. State the resolved language explicitly before proceeding:

```
Output language locked: {resolved language} ({LANGUAGE})
All artifact content, headings, and messages will be written in this language.
```

**Do not begin writing any file until this step is complete.** This prevents language drift across multiple generated files.

---

## Step 5 — Write the feature list artifact

Create `{OUTPUT_PATH}artifacts/feature-list.md`.

Use the template from `template.md` in this same skill directory. Fill all placeholders and preserve the section order.

Optional quality check: run `scripts/validate.sh {OUTPUT_PATH}artifacts/feature-list.md`.


---
## Step 6 — Update navigation files

**`{OUTPUT_PATH}index.md`** — add or update the `## Artifacts` section:

```markdown
## Artifacts

- [[artifacts/feature-list]] — Feature List ({N} features, generated YYYY-MM-DD)
```

**`{OUTPUT_PATH}log.md`** — append one entry at the top:

```markdown
## [YYYY-MM-DD] artifact | Feature List

Generated: artifacts/feature-list.md
Features documented: N (MVP: N, Post-MVP: N, Unclassified: N)
Out of scope: N
Gaps flagged: N
Sources read: N pages
```

---

## Step 7 — Close the loop

```
Done. Feature list generated at {OUTPUT_PATH}artifacts/feature-list.md.

Features documented: N (MVP: N · Post-MVP: N · Unclassified: N)
Out of scope: N
Gaps flagged: N
Sources read: N pages

Anything you want me to revise?
```

---

## Rules

- **Write all content in `{LANGUAGE}`.** If `LANGUAGE` is `pt-BR`, write in Brazilian Portuguese. If `LANGUAGE` is `en`, write in English. Apply this to artifact content, section headings, and all messages shown to the user. If `LANGUAGE` is not set, default to English.
- **Never invent features not present in the wiki.** If a capability is implied but not described, use `> [!gap]`.
- **Never merge distinct features into one row** to make the list shorter. One capability = one row.
- **Never write to source/concept/entity pages.** This skill is read-only on the wiki.
- **Never skip Step 3.** Misidentified features here produce a misleading artifact.
- **Never skip Step 4.** Language must be locked before any file is written — never assume or infer the language mid-generation.
- **Priority must come from the wiki.** Do not assign MVP/Post-MVP based on your own judgment — use "Unclassified" when the wiki is silent.
- **This skill is Product-only.** If invoked for a Strategic or Tactical work item, stop immediately and tell the user.
- **Source citation format:** use `[[sources/slug]]`, `[[concepts/slug]]`, or `[[entities/slug]]` for local wiki pages. For files read from `{CONTEXT_PATH}`, substitute the actual runtime value and write the full repo-relative path: `[[docs/strategic/initiatives/20260504-foo/output/artifacts/brief.md]]`. Never use short names (`[[brief.md]]`) or computed relative paths (`[[../../...]]`) for cross-work-item references — they resolve to the wrong location.
