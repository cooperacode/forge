# Templates de Diagrama (PT-BR)

Use a seção correspondente ao `{DIAGRAM_TYPE}`.

---

> **Convenções de cor C4Model** — inclua as linhas `classDef` relevantes em todo diagrama flowchart:
>
> | Classe | Elemento | Preenchimento |
> |---|---|---|
> | `person` | Atores humanos / usuários | `#08427B` (azul escuro) |
> | `system` | Sistemas de software internos | `#1168BD` (azul) |
> | `external` | Sistemas externos / terceiros | `#999999` (cinza) |
> | `container` | Apps, serviços, filas dentro de um sistema | `#438DD5` (azul médio) |
> | `database` | Bancos de dados / armazenamento | `#438DD5` (azul médio) |
> | `component` | Componentes dentro de um contêiner | `#85BBF0` (azul claro, texto escuro) |
> | `step` | Etapas de processo | `#438DD5` (azul médio) |
> | `decision` | Nós de decisão / ramificação | `#85BBF0` (azul claro, texto escuro) |
> | `terminal` | Nós de início / fim | `#1168BD` (azul) |

---

## c4-context

````markdown
---
title: "C4 N1 Contexto do Sistema — {WORK_ITEM_TITLE}"
type: artifact
subtype: diagram
diagram_type: c4-context
hierarchy_level: Strategic
generated: YYYY-MM-DD
language: {LANGUAGE}
---

# C4 Nível 1: Contexto do Sistema — {WORK_ITEM_TITLE}

## Diagrama

```mermaid
flowchart TB
    classDef person   fill:#08427B,color:#ffffff,stroke:#052E56
    classDef system   fill:#1168BD,color:#ffffff,stroke:#0B4884
    classDef external fill:#999999,color:#ffffff,stroke:#6B6B6B

    P1(["Nome do Ator<br/>[Pessoa]<br/>Descrição do wiki"]):::person
    S1["Nome do Sistema<br/>[Sistema de Software]<br/>Descrição do wiki"]:::system
    E1["Sistema Externo<br/>[Sistema Externo]<br/>Descrição do wiki"]:::external

    P1 -->|"Usa"| S1
    S1 -->|"Chama — protocolo se informado"| E1
```

## Fontes

- [[overview]]
- [[sources/...]]
- [[concepts/...]]
- [[entities/...]]
````

## c4-container

````markdown
---
title: "C4 N2 Contêiner — {WORK_ITEM_TITLE}"
type: artifact
subtype: diagram
diagram_type: c4-container
hierarchy_level: Strategic
generated: YYYY-MM-DD
language: {LANGUAGE}
---

# C4 Nível 2: Contêiner — {WORK_ITEM_TITLE}

## Diagrama

```mermaid
flowchart TB
    classDef person    fill:#08427B,color:#ffffff,stroke:#052E56
    classDef container fill:#438DD5,color:#ffffff,stroke:#2E6295
    classDef database  fill:#438DD5,color:#ffffff,stroke:#2E6295
    classDef external  fill:#999999,color:#ffffff,stroke:#6B6B6B

    P1(["Nome do Ator<br/>[Pessoa]"]):::person
    E1["Sistema Externo<br/>[Sistema Externo]"]:::external

    subgraph boundary["Nome do Sistema"]
        C1["Nome do Contêiner<br/>[Tecnologia]<br/>Descrição"]:::container
        DB1[("Nome do Banco<br/>[Tecnologia]<br/>Armazena o quê")]:::database
    end

    style boundary fill:none,stroke:#444444,stroke-dasharray:5 5,color:#444444

    P1  -->|"Usa — HTTPS"| C1
    C1  -->|"Lê/Escreve — SQL"| DB1
    C1  -->|"Chama — REST"| E1
```

## Fontes

- [[overview]]
- [[sources/...]]
- [[concepts/...]]
- [[entities/...]]
````

## c4-component

````markdown
---
title: "C4 N3 Componente — {WORK_ITEM_TITLE}"
type: artifact
subtype: diagram
diagram_type: c4-component
hierarchy_level: Product
generated: YYYY-MM-DD
language: {LANGUAGE}
---

# C4 Nível 3: Componente — {WORK_ITEM_TITLE}

## Diagrama

```mermaid
flowchart TB
    classDef component fill:#85BBF0,color:#000000,stroke:#5D82A8
    classDef container fill:#438DD5,color:#ffffff,stroke:#2E6295
    classDef external  fill:#999999,color:#ffffff,stroke:#6B6B6B

    E1["Contêiner Externo<br/>[Tecnologia]"]:::container

    subgraph boundary["Nome do Contêiner"]
        COMP1["Nome do Componente<br/>[Tecnologia]<br/>Responsabilidade"]:::component
        COMP2["Nome do Componente<br/>[Tecnologia]<br/>Responsabilidade"]:::component
    end

    style boundary fill:none,stroke:#444444,stroke-dasharray:5 5,color:#444444

    E1 -->|"Chama"| COMP1
    COMP1 -->|"Usa"| COMP2
```

## Fontes

- [[overview]]
- [[sources/...]]
- [[concepts/...]]
- [[entities/...]]
````

## process-flow

````markdown
---
title: "Fluxo de Processo — {WORK_ITEM_TITLE}"
type: artifact
subtype: diagram
diagram_type: process-flow
hierarchy_level: Product
generated: YYYY-MM-DD
language: {LANGUAGE}
---

# Fluxo de Processo: {WORK_ITEM_TITLE}

## Diagrama

```mermaid
flowchart TD
    classDef terminal  fill:#1168BD,color:#ffffff,stroke:#0B4884
    classDef step      fill:#438DD5,color:#ffffff,stroke:#2E6295
    classDef decision  fill:#85BBF0,color:#000000,stroke:#5D82A8

    START([Início]):::terminal --> STEP1[Nome da etapa]:::step
    STEP1 --> DEC1{Decisão?}:::decision
    DEC1 -->|Sim| STEP2[Próxima etapa]:::step
    DEC1 -->|Não| STEP3[Etapa alternativa]:::step
    STEP2 --> END([Fim]):::terminal
    STEP3 --> END
```

## Fontes

- [[overview]]
- [[sources/...]]
- [[concepts/...]]
- [[entities/...]]
````

## data-flow

````markdown
---
title: "Fluxo de Dados — {WORK_ITEM_TITLE}"
type: artifact
subtype: diagram
diagram_type: data-flow
hierarchy_level: Product
generated: YYYY-MM-DD
language: {LANGUAGE}
---

# Fluxo de Dados: {WORK_ITEM_TITLE}

## Diagrama

```mermaid
flowchart LR
    classDef external  fill:#999999,color:#ffffff,stroke:#6B6B6B
    classDef step      fill:#438DD5,color:#ffffff,stroke:#2E6295
    classDef database  fill:#438DD5,color:#ffffff,stroke:#2E6295

    SRC(["Origem<br/>[Sistema Externo]"]):::external
    PROC["Processo / Transformação"]:::step
    DEST[("Destino<br/>[Banco de Dados]")]:::database

    SRC  -->|"Elemento de dados"| PROC
    PROC -->|"Dados transformados"| DEST
```

## Fontes

- [[overview]]
- [[sources/...]]
- [[concepts/...]]
- [[entities/...]]
````

## sequence

````markdown
---
title: "Diagrama de Sequência — {WORK_ITEM_TITLE}"
type: artifact
subtype: diagram
diagram_type: sequence
hierarchy_level: Tactical
generated: YYYY-MM-DD
language: {LANGUAGE}
---

# Diagrama de Sequência: {WORK_ITEM_TITLE}

## Diagrama

```mermaid
sequenceDiagram
  actor User
  participant ServiceA
  participant ServiceB
  User->>ServiceA: Request (data)
  ServiceA->>ServiceB: Call (payload)
  ServiceB-->>ServiceA: Response
  ServiceA-->>User: Response
```

## Fontes

- [[overview]]
- [[sources/...]]
- [[concepts/...]]
- [[entities/...]]
````

## state

````markdown
---
title: "Diagrama de Estado — {WORK_ITEM_TITLE}"
type: artifact
subtype: diagram
diagram_type: state
hierarchy_level: Tactical
generated: YYYY-MM-DD
language: {LANGUAGE}
---

# Diagrama de Estado: {WORK_ITEM_TITLE}

## Diagrama

```mermaid
stateDiagram-v2
  [*] --> NomeEstado
  NomeEstado --> OutroEstado : evento / condição
  OutroEstado --> [*] : condição terminal
```

## Fontes

- [[overview]]
- [[sources/...]]
- [[concepts/...]]
- [[entities/...]]
````
