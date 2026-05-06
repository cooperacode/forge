---
title: "Feature List — Portal de Autoatendimento"
type: artifact
subtype: feature-list
work_item_type: Epic
hierarchy_level: Product
generated: 2026-05-05
sources_read: 6
total_features: 7
---

# Feature List: Portal de Autoatendimento

## Summary

A partir da wiki do Epic "Portal de Autoatendimento" (6 páginas: 2 fontes, 3 conceitos, 4 entidades), foram identificadas 7 features que compõem o escopo de digitalização do onboarding. As prioridades de MVP foram derivadas de [[sources/pesquisa-jornada-cliente]], que ranqueia as etapas por frequência de abandono. 2 features ficaram sem cobertura suficiente na wiki para classificação de prioridade e foram marcadas como Unclassified.

## Features

| ID | Feature | Descrição | Beneficiário | Prioridade | Dependências | Fonte |
|----|---------|-----------|--------------|------------|-------------|-------|
| F-001 | Cadastro simplificado de cliente | Formulário único com validação de CPF/CNPJ em tempo real, sem necessidade de login prévio | Cliente PF e PJ | MVP | — | [[sources/pesquisa-jornada-cliente]] |
| F-002 | Upload de documentos | Envio de documentos obrigatórios (RG, CNH, contrato social) com feedback imediato sobre formato e tamanho | Cliente PF e PJ | MVP | F-001 | [[sources/pesquisa-jornada-cliente]] |
| F-003 | Acompanhamento de status do onboarding | Portal onde o cliente consulta em qual etapa está sua solicitação e quais pendências existem | Cliente PF e PJ | MVP | F-001, F-002 | [[sources/pesquisa-jornada-cliente]] |
| F-004 | Notificações por e-mail e SMS | Envio automático de notificações nas mudanças de status da solicitação | Cliente PF e PJ | MVP | F-001 | [[concepts/notificacoes]] |
| F-005 | Painel de análise para agente de CS | Fila de solicitações para revisão, com ações de aprovação e rejeição de documentos | Agente de CS | MVP | F-002 | [[sources/pesquisa-jornada-cliente]] |
| F-006 | Reenvio de documentos rejeitados | Fluxo para o cliente enviar uma nova versão de documento após rejeição, sem reabrir toda a solicitação | Cliente PF e PJ | Post-MVP | F-002, F-005 | [[concepts/fluxo-rejeicao]] |
| F-007 | Onboarding PJ com múltiplos sócios | Suporte a solicitações onde cada sócio envia seus próprios documentos individualmente | Cliente PJ | Unclassified | F-001, F-002 | [[entities/cliente-pj]] |

## Out of Scope

| Feature | Motivo de exclusão | Fonte |
|---------|-------------------|-------|
| Integração com CRM legado | Adiada para fase 2; arquitetura de integração não definida | [[sources/benchmarking-setor]] |
| Assinatura eletrônica de contrato | Fora do escopo do onboarding MVP; requer fornecedor externo de certificação | [[sources/requisitos-compliance]] |
| App mobile nativo | Canal definido como web responsivo para o MVP | [[sources/pesquisa-jornada-cliente]] |

## Gaps

> [!gap] F-007 (Onboarding PJ múltiplos sócios): a wiki menciona o caso de uso mas não detalha o modelo de dados nem o fluxo de aprovação. Confirmar se entra no MVP antes de detalhar.

> [!gap] Não há cobertura na wiki sobre autenticação do cliente no portal (login social, OTP, senha). Este requisito transversal precisa ser definido antes de implementar F-001.

## Dependency Map

F-002 depende de → F-001
F-003 depende de → F-001, F-002
F-004 depende de → F-001
F-005 depende de → F-002
F-006 depende de → F-002, F-005
F-007 depende de → F-001, F-002

## Open Questions

- [ ] F-007 entra no MVP ou Post-MVP? Confirmar com VP de Produto.
- [ ] Qual mecanismo de autenticação será usado no portal? (sem cobertura na wiki)
- [ ] F-005 deve incluir SLA de análise (ex.: alerta se solicitação ficar mais de 24h sem revisão)?

## Sources

- [[overview]]
- [[sources/pesquisa-jornada-cliente]]
- [[sources/requisitos-compliance]]
- [[sources/benchmarking-setor]]
- [[concepts/notificacoes]]
- [[concepts/fluxo-rejeicao]]
- [[entities/cliente-pj]]
