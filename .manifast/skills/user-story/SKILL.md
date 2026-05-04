---
name: user-story
description: "Generate a User Story artifact with Gherkin acceptance scenarios, Definition of Done, and dependency map from the active wiki. Tactical level only."
---

# Skill: User Story

You were invoked by the orchestrator because the user wants to generate a User Story from the active wiki. Your job is to extract user-facing behavior described in the wiki and structure it into a complete, implementable story — with Gherkin scenarios ready for validation.

The orchestrator passed `OUTPUT_PATH`, `WORK_ITEM_TITLE`, and `WORK_ITEM_TYPE` — use those values for all file operations and metadata.

This skill is for **Tactical-level work items only** (User Story, Task, Bug). If `{WORK_ITEM_TYPE}` is Strategic or Product, tell the user this artifact is not applicable for that layer and stop.

Follow every step in order.

---

## Step 1 — Verify wiki has content

Read `{OUTPUT_PATH}index.md`.

- If the file does not exist or is empty, stop. Tell the user the wiki has no content yet and suggest running `/ingest` first.
- Check whether an `artifacts/feature-list.md` exists in `{OUTPUT_PATH}`. If it does, read it — the feature list provides scope context that makes the story more precise.

---

## Step 2 — Read all wiki pages

Read in this order:

1. `{OUTPUT_PATH}artifacts/feature-list.md` (if it exists)
2. `{OUTPUT_PATH}overview.md`
3. All `sources/` pages listed in `{OUTPUT_PATH}index.md`
4. All `concepts/` pages listed in `{OUTPUT_PATH}index.md`
5. All `entities/` pages listed in `{OUTPUT_PATH}index.md`

**If `{CONTEXT_PATH}` is non-empty**, read all files present in `{CONTEXT_PATH}` after completing the list above. These are upstream artifacts from the parent work item:
- Upstream `feature-list.md` is the authoritative scope — the story must map to a feature listed there. If it does not, flag it as out of scope before proceeding to Step 3.
- Upstream `requirements.md` (functional) provides acceptance criteria candidates — carry them forward into this story's AC table rather than re-deriving them.
- Upstream `der.md` defines the canonical entity names — use them verbatim in Gherkin scenarios (Given a **{EntityName}**...).
- Note each upstream source when carrying a fact into the story.

While reading, identify and extract:

**Persona candidates** — people, roles, or user types mentioned across the wiki. Look in `entities/` pages with `subtype: person`, and in source pages for any mention of who uses the system or triggers the behavior.

**Behavior to implement** — what the user or system needs to do. Look for:
- Action verbs with a subject ("the customer submits", "the system validates")
- Described flows or interactions
- Rules that gate or shape behavior
- Success and failure conditions explicitly stated

**Business value** — why this behavior matters. Look for problem statements, goals, or outcomes linked to the behavior.

**Constraints and rules** — validations, business rules, limits that must hold.

**Related features** — if `feature-list.md` exists, identify which feature(s) this story belongs to.

---

## Step 3 — Confirm persona and story framing with the user

This is the most critical step. A User Story written for the wrong persona is useless.

Present what you found and ask for confirmation before writing:

```
Based on the wiki, I propose this story framing:

As a {persona},
I want {action},
so that {benefit}.

Persona "{persona}" was identified from: [[entities/slug]]
Action derived from: [[sources/slug]]
Benefit derived from: [[sources/slug]]

{If multiple personas were found:}
Alternative personas detected: {persona B} [[entities/slug]], {persona C} [[entities/slug]]
Should I use a different persona?

{If the action or benefit are not clearly supported by the wiki:}
> [!gap] The {action | benefit} is not explicitly stated in the wiki — this is inferred. Confirm or correct before I proceed.

Does this framing look right?
```

Wait for confirmation or correction. Do not write the artifact until the user approves the framing.

---

## Step 4 — Write the user story artifact

Create `{OUTPUT_PATH}artifacts/user-story.md`:

```markdown
---
title: "User Story — {WORK_ITEM_TITLE}"
type: artifact
subtype: user-story
work_item_type: {WORK_ITEM_TYPE}
hierarchy_level: Tactical
persona: {persona name}
generated: YYYY-MM-DD
sources_read: N
---

# User Story: {WORK_ITEM_TITLE}

## Story

> As a **{persona}**,
> I want **{action}**,
> so that **{benefit}**.

---

## Business Context

1–2 paragraphs: why this story matters, what problem it solves for the persona, and how it connects to the broader initiative or epic.
Cite wiki pages using [[wikilinks]].

---

## Acceptance Criteria

Conditions that must be true for this story to be considered complete. Each criterion is independently verifiable.

| # | Criterion | Source |
|---|-----------|--------|
| AC-1 | {Specific, testable condition} | [[sources/slug]] |
| AC-2 | ... | [[concepts/slug]] |

If acceptance criteria were not defined in the wiki:
> [!gap] Acceptance criteria are not documented in the ingested sources. Define with the product owner before sprint planning.

---

## Gherkin Scenarios

One scenario per acceptance criterion or significant edge case. Scenarios cover the happy path first, then failure/edge cases.

```gherkin
Feature: {WORK_ITEM_TITLE}

  Background:
    Given {shared precondition from wiki}

  Scenario: {happy path — AC-1}
    Given {initial state}
    When {action taken by persona}
    Then {expected outcome}
    And {additional assertion if needed}

  Scenario: {edge case or failure}
    Given {initial state}
    When {action that triggers the edge case}
    Then {expected system behavior}
```

Write only scenarios supported by wiki content. For uncovered scenarios, use:

> [!gap] Scenario for {AC-N} could not be written — the wiki does not describe the expected behavior in sufficient detail.

---

## Business Rules

Rules and constraints that the implementation must respect, extracted from the wiki:

| # | Rule | Source |
|---|------|--------|
| BR-1 | {Rule statement} | [[sources/slug]] |

---

## Definition of Done

- [ ] All acceptance criteria verified
- [ ] All Gherkin scenarios pass
- [ ] Code reviewed
- [ ] Tests written for each scenario
- [ ] No regression in related features
{Add any DoD items explicitly stated in the wiki sources below:}
- [ ] {wiki-stated requirement}

---

## Dependencies & Blockers

| Type | Item | Status | Source |
|------|------|--------|--------|
| Feature dependency | [[artifacts/feature-list]] F-00X | {required before / can run in parallel} | [[sources/slug]] |
| External dependency | {system or team} | {known / unknown} | [[sources/slug]] |

If no dependencies were detected: "No dependencies identified in the wiki."

---

## Out of Scope

Behaviors explicitly excluded or deferred in the wiki:

- {behavior} — {reason from wiki} [[sources/slug]]

---

## Open Questions

Questions that affect implementation but remain unresolved in the wiki:

- [ ] {Question} — needs input from {stakeholder type}

---

## Sources

- [[overview]]
- [[sources/...]]
- [[concepts/...]]
- [[entities/...]]
```

---

## Step 5 — Update navigation files

**`{OUTPUT_PATH}index.md`** — add or update the `## Artifacts` section:

```markdown
## Artifacts

- [[artifacts/user-story]] — User Story: {WORK_ITEM_TITLE} (generated YYYY-MM-DD)
```

**`{OUTPUT_PATH}log.md`** — append one entry at the top:

```markdown
## [YYYY-MM-DD] artifact | User Story

Generated: artifacts/user-story.md
Persona: {persona name}
Acceptance criteria: N
Gherkin scenarios: N (happy path: N, edge cases: N)
Business rules: N
Gaps flagged: N
Sources read: N pages
```

---

## Step 6 — Close the loop

```
Done. User Story generated at {OUTPUT_PATH}artifacts/user-story.md.

Persona: {persona}
Acceptance criteria: N
Gherkin scenarios: N
Business rules: N
Gaps flagged: N (criteria or scenarios without wiki coverage)
Sources read: N pages

Anything you want me to revise?
```

---

## Rules

- **Write all content in `{LANGUAGE}`.** If `LANGUAGE` is `pt-BR`, write in Brazilian Portuguese. If `LANGUAGE` is `en`, write in English. Apply this to artifact content, section headings, and all messages shown to the user. If `LANGUAGE` is not set, default to English.
- **Never write the artifact before Step 3 is confirmed.** A wrong persona invalidates the entire story. This step is non-negotiable.
- **Never invent acceptance criteria not backed by the wiki.** Use `> [!gap]` for missing criteria.
- **Gherkin must be syntactically valid.** Each scenario must have Given / When / Then in that order. Avoid "And" as the first keyword.
- **One scenario per distinct behavior.** Do not combine multiple behaviors into one scenario — they become impossible to debug when they fail.
- **Never write to source/concept/entity pages.** User story generation is read-only on the wiki.
- **This skill is Tactical-only.** If invoked for Strategic or Product, stop immediately.
- **Business rules must be individually sourced.** Never write a rule without a [[wikilink]] to the page it came from.
