---
title: "DER — {WORK_ITEM_TITLE}"
type: artifact
subtype: der
work_item_type: {WORK_ITEM_TYPE}
hierarchy_level: Product
generated: YYYY-MM-DD
language: {LANGUAGE}
entities_count: N
relationships_confirmed: N
relationships_inferred: N
---

# DER: {WORK_ITEM_TITLE}

## Diagrama

```mermaid
erDiagram
    ENTIDADE_A {
        type nome_atributo "descrição"
    }
    ENTIDADE_A ||--o{ ENTIDADE_B : "rótulo do relacionamento"
```

## Glossário de Entidades

| Entidade | Descrição | Atributos documentados | Fonte |
|----------|-----------|------------------------|-------|
| ... | ... | ... | [[entities/...]] |

## Relacionamentos Confirmados

| Relacionamento | Cardinalidade | Rótulo | Fonte |
|----------------|--------------|--------|-------|
| ... | ... | ... | [[entities/...]] |

## Relacionamentos Inferidos

| Relacionamento | Cardinalidade | Evidência | Fonte |
|----------------|--------------|-----------|-------|
| ... | ... | ... | [[sources/...]] |

## Lacunas

> [!gap] ...

## Questões Abertas

- [ ] ...

## Fontes

- [[overview]]
- [[entities/...]]
- [[concepts/...]]
- [[sources/...]]
