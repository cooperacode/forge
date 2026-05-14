---
title: "{story.id} — {WORK_ITEM_TITLE}"
type: artifact
subtype: user-story
feature_id: "{SELECTED_FEATURE_ID}"
story_id: {story.id}
work_item_type: {WORK_ITEM_TYPE}
hierarchy_level: Tactical
language: {LANGUAGE}
persona: {story.persona}
generated: YYYY-MM-DD
sources_read: N
---

# História de Usuário: {story.action short title}

> Como **{story.persona}**,
> quero **{story.action}**,
> para que **{story.benefit}**.

## Contexto de Negócio

...

## Critérios de Aceitação

| # | Critério | Fonte |
|---|----------|-------|
| AC-1 | ... | [[sources/slug]] |

## Cenários Gherkin

```gherkin
Feature: {story.action short title}
  Scenario: ...
    Given ...
    When ...
    Then ...
```

## Regras de Negócio

| # | Regra | Fonte |
|---|-------|-------|
| RN-1 | ... | [[sources/slug]] |

## Definição de Pronto

- [ ] ...

## Dependências e Bloqueios

| Tipo | Item | Status | Fonte |
|------|------|--------|-------|
| ... | ... | ... | [[sources/slug]] |

## Fora de Escopo

- ...

## Questões Abertas

- [ ] ...

## Fontes

- [[overview]]
- [[sources/...]]
- [[concepts/...]]
- [[entities/...]]
