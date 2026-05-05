---
title: "Process Flow — Exemplo"
type: artifact
subtype: diagram
diagram_type: process-flow
hierarchy_level: Product
generated: 2026-05-05
---

# Process Flow: Exemplo

## Diagram

```mermaid
flowchart TD
  A[Cliente envia pedido] --> B{Pedido válido?}
  B -->|Sim| C[Registrar pedido]
  B -->|Não| D[Retornar erro]
```
