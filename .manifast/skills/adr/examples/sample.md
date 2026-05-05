---
title: "ADR-001: Adotar API REST para o módulo de manifestos"
type: artifact
subtype: adr
adr_number: 001
status: accepted
work_item_type: Feature
hierarchy_level: Product
generated: 2026-05-05
---

# ADR-001: Adotar API REST para o módulo de manifestos

## Status

accepted

---

## Context

A equipe precisava expor operações CRUD de manifestos para web e mobile com baixa complexidade de integração. As fontes [[sources/arquitetura-atual]] e [[concepts/integracoes]] mostram que os consumidores já usam HTTP/JSON e não há requisito de consultas compostas avançadas.

---

## Decision

**We will adotar API REST como padrão para o módulo de manifestos.**

Os endpoints seguirão convenções de recursos e versionamento por `/v1` para manter compatibilidade evolutiva.

---

## Alternatives Considered

| Alternative | Why rejected |
|-------------|-------------|
| GraphQL | Maior custo inicial de schema e governança para o escopo atual [[sources/arquitetura-atual]] |
| gRPC | Menor aderência aos clientes externos já existentes |

---

## Consequences

### Positive
- Adoção rápida pelos clientes existentes.
- Curva de aprendizado menor para o time.

### Negative / Trade-offs
- Possível overfetch em alguns endpoints.

### Neutral
- Mantém alinhamento com o restante da plataforma.

---

## Sources

Wiki pages that informed this ADR:

- [[sources/arquitetura-atual]]
- [[concepts/integracoes]]
