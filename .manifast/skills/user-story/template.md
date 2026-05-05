---
title: "{SELECTED_FEATURE_ID} · {story.id} — {WORK_ITEM_TITLE}"
type: artifact
subtype: user-story
feature_id: {SELECTED_FEATURE_ID}
story_id: {story.id}
work_item_type: {WORK_ITEM_TYPE}
hierarchy_level: Tactical
persona: {story.persona}
generated: YYYY-MM-DD
sources_read: N
---

# User Story: {story.action short title}

> As a **{story.persona}**,
> I want **{story.action}**,
> so that **{story.benefit}**.

## Business Context

...

## Acceptance Criteria

| # | Criterion | Source |
|---|-----------|--------|
| AC-1 | ... | [[sources/slug]] |

## Gherkin Scenarios

```gherkin
Feature: {story.action short title}
  Scenario: ...
```

## Business Rules

| # | Rule | Source |
|---|------|--------|
| BR-1 | ... | [[sources/slug]] |

## Definition of Done

- [ ] ...

## Dependencies & Blockers

| Type | Item | Status | Source |
|------|------|--------|--------|
| ... | ... | ... | [[sources/slug]] |

## Out of Scope

- ...

## Open Questions

- [ ] ...

## Sources

- [[overview]]
- [[sources/...]]
- [[concepts/...]]
- [[entities/...]]
