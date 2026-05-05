---
title: "DER — {WORK_ITEM_TITLE}"
type: artifact
subtype: der
work_item_type: {WORK_ITEM_TYPE}
hierarchy_level: Product
generated: YYYY-MM-DD
entities_count: N
relationships_confirmed: N
relationships_inferred: N
---

# DER: {WORK_ITEM_TITLE}

## Diagrama

```mermaid
erDiagram
    ENTITY_A {
        type attribute_name "description"
    }
    ENTITY_A ||--o{ ENTITY_B : "relationship label"
```

## Entity Glossary

| Entity | Description | Attributes documented | Source |
|--------|------------|----------------------|--------|
| ... | ... | ... | [[entities/...]] |

## Confirmed Relationships

| Relationship | Cardinality | Label | Source |
|-------------|-------------|-------|--------|
| ... | ... | ... | [[entities/...]] |

## Inferred Relationships

| Relationship | Cardinality | Evidence | Source |
|-------------|-------------|----------|--------|
| ... | ... | ... | [[sources/...]] |

## Gaps

> [!gap] ...

## Open Questions

- [ ] ...

## Sources

- [[overview]]
- [[entities/...]]
- [[concepts/...]]
- [[sources/...]]
