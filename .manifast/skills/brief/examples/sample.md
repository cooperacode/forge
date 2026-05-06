---
title: "Strategic Brief — Redesenhar o Processo de Onboarding"
type: artifact
subtype: brief
work_item_type: Initiative
hierarchy_level: Strategic
generated: 2026-05-05
sources_read: 7
---

# Strategic Brief: Redesenhar o Processo de Onboarding

## Executive Summary

O processo atual de onboarding de novos clientes apresenta taxa de abandono de 38% na etapa de envio de documentos e tempo médio de ativação de 11 dias úteis, conforme levantado em [[sources/pesquisa-jornada-cliente]]. Esta iniciativa propõe redesenhar o fluxo para reduzir o tempo de ativação para menos de 3 dias e o abandono para abaixo de 10%, por meio da digitalização das etapas manuais e da introdução de um portal de autoatendimento.

## Business Context

O mercado de onboarding digital cresceu 42% em 2025, e concorrentes diretos já oferecem ativação em menos de 24h [[sources/benchmarking-setor]]. A ausência de um fluxo digital completo é apontada pelos clientes como principal motivo de churn nos primeiros 30 dias [[sources/pesquisa-jornada-cliente]]. A iniciativa se insere no tema estratégico de Experiência do Cliente e tem patrocínio direto da VP de Produto.

## Goals & Objectives

| # | Objetivo | Resultado esperado |
|---|----------|--------------------|
| 1 | Digitalizar 100% das etapas de coleta de documentos | Eliminar trocas de e-mail e papel no onboarding [[sources/pesquisa-jornada-cliente]] |
| 2 | Reduzir tempo médio de ativação de 11 para ≤ 3 dias úteis | Aumentar satisfação na primeira semana (NPS D+7) [[concepts/metricas-sucesso]] |
| 3 | Reduzir taxa de abandono de 38% para ≤ 10% | Aumentar receita recorrente mensal nos primeiros 90 dias [[sources/benchmarking-setor]] |

## Scope

### In scope
- Redesenho do fluxo de coleta e validação de documentos
- Portal de autoatendimento para acompanhamento do status de onboarding
- Integração com sistema de validação de identidade (KYC)
- Notificações automáticas por e-mail e SMS nas mudanças de status

### Out of scope
- Migração de clientes já ativos para o novo fluxo
- Mudanças no sistema de cobrança e faturamento
- Integração com sistemas legados de CRM (prevista para fase 2)

## Key Stakeholders

| Stakeholder | Papel / Interesse |
|-------------|------------------|
| VP de Produto | Patrocinadora; define prioridade e aprova escopo |
| Time de Sucesso do Cliente | Principal operador do onboarding atual; valida o fluxo redesenhado |
| Compliance & Jurídico | Aprova requisitos de KYC e armazenamento de documentos [[sources/requisitos-compliance]] |
| Clientes PF e PJ | Beneficiários diretos da melhoria de experiência |

## Success Metrics

| Métrica | Meta | Fonte |
|---------|------|-------|
| Tempo médio de ativação | ≤ 3 dias úteis | [[concepts/metricas-sucesso]] |
| Taxa de abandono no onboarding | ≤ 10% | [[sources/pesquisa-jornada-cliente]] |
| NPS D+7 (primeira semana) | ≥ 45 | [[concepts/metricas-sucesso]] |
| % de etapas digitalizadas | 100% | [[sources/pesquisa-jornada-cliente]] |

## Timeline & Milestones

| Marco | Data-alvo | Notas |
|-------|-----------|-------|
| Discovery concluído | 2026-06-01 | Entrevistas com clientes e mapeamento do fluxo atual |
| MVP do portal lançado | 2026-08-15 | Coleta de documentos e acompanhamento de status |
| Integração KYC ativa | 2026-09-30 | Depende de contrato com fornecedor |
| Rollout completo | 2026-11-01 | Todos os novos clientes no novo fluxo |

## Risks & Dependencies

| # | Risco / Dependência | Probabilidade | Impacto | Mitigação |
|---|---------------------|--------------|---------|-----------|
| 1 | Fornecedor de KYC não homologado a tempo | Média | Alto | Iniciar contratação em paralelo ao discovery [[sources/requisitos-compliance]] |
| 2 | Resistência do time de CS à mudança de processo | Alta | Médio | Envolver CS como co-designers desde o início |
| 3 | Requisitos de compliance mais restritivos que o previsto | Baixa | Alto | Revisar com Jurídico antes de fechar escopo técnico |

## Open Questions

- [ ] Qual o prazo mínimo exigido por compliance para retenção de documentos? [[sources/requisitos-compliance]]
- [ ] O portal precisa suportar PJ com múltiplos sócios na fase MVP?
- [ ] A integração com o CRM legado pode ser totalmente adiada ou há dependências críticas?

> [!gap] A wiki não cobre SLAs internos do time de Compliance para aprovação de documentos. Levantar com a área antes de confirmar o target de 3 dias úteis.

## Sources

- [[overview]]
- [[sources/pesquisa-jornada-cliente]]
- [[sources/benchmarking-setor]]
- [[sources/requisitos-compliance]]
- [[concepts/metricas-sucesso]]
- [[entities/cliente-pf]]
- [[entities/cliente-pj]]
