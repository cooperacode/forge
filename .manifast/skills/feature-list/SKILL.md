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

## Step 1 — Verify wiki has content

Read `{OUTPUT_PATH}index.md`.

- If the file does not exist or is empty, stop. Tell the user the wiki has no content yet and suggest running `/ingest` first.
- Note the total number of pages indexed.

---

## Step 2 — Read all wiki pages

Read in this order:

1. `{OUTPUT_PATH}overview.md`
2. All `sources/` pages listed in `{OUTPUT_PATH}index.md`
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

## Step 4 — Write the feature list artifact

Create `{OUTPUT_PATH}artifacts/feature-list.md`:

```markdown
---
title: "Feature List — {WORK_ITEM_TITLE}"
type: artifact
subtype: feature-list
work_item_type: {WORK_ITEM_TYPE}
hierarchy_level: Product
generated: YYYY-MM-DD
sources_read: N
total_features: N
---

# Feature List: {WORK_ITEM_TITLE}

## Summary

One paragraph: scope of this list, how many features were found, and any significant gaps.

---

## Features

| ID | Feature | Description | Beneficiary | Priority | Dependencies | Source |
|----|---------|------------|-------------|----------|-------------|--------|
| F-001 | {name} | {what it does} | {user / system} | MVP / Post-MVP / Unclassified | F-00X, F-00Y | [[sources/slug]] |
| F-002 | ... | ... | ... | ... | — | [[sources/slug]] |

**Priority values:**
- **MVP** — required for the first viable release (stated in the wiki)
- **Post-MVP** — confirmed desirable but explicitly deferred
- **Unclassified** — wiki did not assign priority; requires team decision

---

## Out of Scope

Features explicitly excluded in the wiki:

| Feature | Reason for exclusion | Source |
|---------|---------------------|--------|
| {name} | {reason} | [[sources/slug]] |

---

## Gaps

Areas where the wiki described a need but without enough detail to define a feature:

> [!gap] {Description of what is unclear and what type of source would resolve it}

---

## Dependency Map

Features that depend on other features being delivered first:

```
F-003 depends on → F-001, F-002
F-005 depends on → F-003
```

If no dependencies were identified, state: "No dependencies detected in the wiki."

---

## Open Questions

Questions that affect feature scope but remain unresolved:

- [ ] ...

---

## Sources

- [[overview]]
- [[sources/...]]
- [[concepts/...]]
```

---

## Step 5 — Update navigation files

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

## Step 6 — Close the loop

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
- **Priority must come from the wiki.** Do not assign MVP/Post-MVP based on your own judgment — use "Unclassified" when the wiki is silent.
- **This skill is Product-only.** If invoked for a Strategic or Tactical work item, stop immediately and tell the user.
