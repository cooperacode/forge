---
title: "F-002 · US-002 — Enviar arquivo de documento"
type: artifact
subtype: user-story
feature_id: F-002
story_id: US-002
work_item_type: User Story
hierarchy_level: Tactical
persona: Cliente PF / PJ
generated: 2026-05-05
sources_read: 5
---

# User Story: Enviar arquivo de documento

> Como **cliente** (PF ou PJ),
> eu quero **enviar um arquivo de documento para minha solicitação de onboarding**,
> para que **minha solicitação avance para análise sem precisar enviar nada por e-mail**.

## Business Context

Esta história implementa o comportamento central da Feature F-002 (Upload de Documentos). A etapa de envio de documentos é o maior ponto de abandono no onboarding atual — 38% dos clientes desistem nessa etapa [[sources/pesquisa-jornada-cliente]]. Digitalizar este passo elimina a dependência de e-mail e reduz o tempo de coleta de 3 dias para menos de 30 minutos.

## Acceptance Criteria

| # | Critério | Fonte |
|---|---------|-------|
| AC-1 | O sistema aceita arquivos nos formatos PDF, JPG e PNG com até 10 MB | [[sources/requisitos-compliance]] |
| AC-2 | O sistema rejeita outros formatos ou arquivos acima de 10 MB antes de iniciar o envio ao servidor, exibindo mensagem de erro específica | [[sources/requisitos-compliance]] |
| AC-3 | O progresso do upload é exibido em tempo real (barra de progresso) para arquivos acima de 2 MB | [[sources/pesquisa-jornada-cliente]] |
| AC-4 | Após upload bem-sucedido, o documento aparece na lista com status "aguardando" e timestamp do envio | [[entities/documento]] |
| AC-5 | Se o upload falhar por erro de rede, o sistema exibe mensagem de erro e permite nova tentativa sem perder o arquivo selecionado | [[sources/pesquisa-jornada-cliente]] |

## Gherkin Scenarios

```gherkin
Feature: Enviar arquivo de documento no onboarding

  Scenario: Upload bem-sucedido de arquivo válido
    Given que o cliente está na etapa de envio de documentos da solicitação S-001
    And o cliente selecionou um arquivo PDF de 3 MB do tipo "RG"
    When o cliente confirma o envio
    Then o sistema armazena o arquivo e registra o documento com status "aguardando"
    And o documento aparece na lista com o timestamp do envio

  Scenario: Rejeição de arquivo em formato inválido
    Given que o cliente está na etapa de envio de documentos
    And o cliente selecionou um arquivo no formato DOCX
    When o cliente tenta confirmar o envio
    Then o sistema rejeita o arquivo antes de enviá-lo ao servidor
    And exibe a mensagem "Formato não aceito. Use PDF, JPG ou PNG."

  Scenario: Rejeição de arquivo acima do tamanho máximo
    Given que o cliente está na etapa de envio de documentos
    And o cliente selecionou um arquivo PDF de 15 MB
    When o cliente tenta confirmar o envio
    Then o sistema rejeita o arquivo antes de enviá-lo ao servidor
    And exibe a mensagem "Arquivo muito grande. O limite é 10 MB."

  Scenario: Exibição de progresso para arquivo grande
    Given que o cliente está na etapa de envio de documentos
    And o cliente selecionou um arquivo PDF de 8 MB
    When o cliente confirma o envio
    Then o sistema exibe uma barra de progresso atualizada em tempo real
    And a barra atinge 100% antes de exibir a confirmação de sucesso

  Scenario: Falha de rede durante upload
    Given que o cliente está na etapa de envio de documentos
    And o cliente iniciou o upload de um arquivo PDF de 5 MB
    When a conexão é perdida durante o envio
    Then o sistema exibe a mensagem "Falha no envio. Verifique sua conexão e tente novamente."
    And o arquivo selecionado permanece disponível para nova tentativa
```

## Business Rules

| # | Regra | Fonte |
|---|-------|-------|
| BR-1 | Formatos aceitos: PDF, JPG, PNG. Validação ocorre no cliente (frontend) antes de qualquer requisição ao servidor | [[sources/requisitos-compliance]] |
| BR-2 | Tamanho máximo por arquivo: 10 MB. Validação também ocorre no cliente | [[sources/requisitos-compliance]] |
| BR-3 | Cada arquivo enviado gera um registro `DOCUMENTO` com status inicial "aguardando" | [[entities/documento]] |
| BR-4 | O documento é associado à `SOLICITACAO_ONBOARDING` ativa do cliente | [[entities/solicitacao-onboarding]] |

## Definition of Done

- [ ] Componente de upload implementado com validação de formato e tamanho no frontend
- [ ] Endpoint de upload criado, criptografia em trânsito (TLS 1.2+) ativa (NFR-004)
- [ ] Registro de `DOCUMENTO` criado no banco com status "aguardando" e timestamp
- [ ] Barra de progresso exibida para arquivos > 2 MB
- [ ] Todos os cenários Gherkin passando nos testes automatizados
- [ ] Testado manualmente em Chrome, Firefox e Safari (desktop e mobile responsive)
- [ ] PR revisado e aprovado por ao menos 1 par

## Dependencies & Blockers

| Tipo | Item | Status | Fonte |
|------|------|--------|-------|
| Upstream — Story | US-001 (Ver lista de documentos obrigatórios) | Deve estar concluída — lista determina quais tipos de documento estão disponíveis para upload | [[entities/solicitacao-onboarding]] |
| Upstream — Decisão | Mecanismo de autenticação do cliente no portal | Em aberto — necessário para associar o upload à solicitação correta | [[sources/pesquisa-jornada-cliente]] |
| Downstream — Story | US-003 (Feedback de arquivo inválido) | Esta story entrega o backend; US-003 detalha as mensagens de erro no frontend | — |
| Downstream — Story | US-004 (Retomar upload em outro momento) | Depende do registro de estado criado por esta story | — |

## Out of Scope

- Reenvio de documento após rejeição pelo agente (coberto em F-006)
- Preview do arquivo enviado (adiado para post-MVP)
- Upload em lote (múltiplos arquivos simultâneos)

## Open Questions

- [ ] Existe limite de tentativas de upload por documento? (não coberto na wiki)
- [ ] O nome do arquivo original deve ser preservado no armazenamento ou renomeado por convenção interna?

## Sources

- [[overview]]
- [[sources/pesquisa-jornada-cliente]]
- [[sources/requisitos-compliance]]
- [[entities/documento]]
- [[entities/solicitacao-onboarding]]
- [[entities/cliente-pf]]
