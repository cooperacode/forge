---
title: "Quality Attributes & Constraints — Redesenhar o Processo de Onboarding"
type: artifact
subtype: requirements
mode: constraints
work_item_type: Initiative
hierarchy_level: Strategic
generated: 2026-05-05
sources_read: 5
---

# Quality Attributes & Constraints: Redesenhar o Processo de Onboarding

## Context

Este artefato documenta os requisitos não-funcionais, restrições arquiteturais e obrigações de compliance identificadas na wiki para a Iniciativa "Redesenhar o Processo de Onboarding". Todos os Epics e Features filho devem respeitar estas restrições ao definir seus requisitos funcionais. Foram consultadas 5 páginas: 2 fontes, 2 conceitos, 1 entidade.

## Non-Functional Requirements

| ID | Categoria | Requisito | Prioridade | Fonte |
|----|-----------|-----------|------------|-------|
| NFR-001 | Performance | O tempo de resposta do upload de documentos deve ser ≤ 3 segundos para arquivos de até 5 MB em conexão de 10 Mbps | Must | [[sources/pesquisa-jornada-cliente]] |
| NFR-002 | Performance | O portal deve suportar até 500 uploads simultâneos sem degradação perceptível de latência | Should | [[sources/benchmarking-setor]] |
| NFR-003 | Disponibilidade | O portal de onboarding deve ter disponibilidade mínima de 99,5% em horário comercial (8h–20h, segunda a sexta) | Must | [[sources/pesquisa-jornada-cliente]] |
| NFR-004 | Segurança | Documentos enviados devem ser criptografados em trânsito (TLS 1.2+) e em repouso (AES-256) | Must | [[sources/requisitos-compliance]] |
| NFR-005 | Segurança | O acesso ao painel do agente de CS deve exigir autenticação multifator (MFA) | Must | [[sources/requisitos-compliance]] |
| NFR-006 | Usabilidade | O fluxo de upload deve ser concluível em menos de 10 minutos por um cliente que nunca usou o portal | Should | [[sources/pesquisa-jornada-cliente]] |
| NFR-007 | Rastreabilidade | Toda mudança de status de solicitação deve ser registrada com timestamp e identificador do agente responsável | Must | [[sources/requisitos-compliance]] |

## Architectural Constraints

| ID | Restrição | Justificativa | Fonte |
|----|-----------|--------------|-------|
| AC-001 | O portal deve ser uma aplicação web responsiva; não será desenvolvido app mobile nativo no escopo desta iniciativa | Decisão de alocação de budget; canal mobile avaliado em fase 2 | [[sources/pesquisa-jornada-cliente]] |
| AC-002 | A integração com o sistema de KYC deve ser feita via API REST com autenticação OAuth 2.0 | Padrão de integração já adotado pelos demais serviços da plataforma | [[concepts/integracoes]] |
| AC-003 | O armazenamento de documentos não pode ser realizado em servidores fora do território nacional (data residency) | Exigência regulatória de privacidade de dados | [[sources/requisitos-compliance]] |
| AC-004 | A autenticação do cliente no portal deve ser desacoplada do sistema de CRM legado | A integração com CRM foi adiada para fase 2; o portal não pode criar dependência de runtime | [[concepts/integracoes]] |

## Compliance & Regulatory Obligations

| ID | Obrigação | Órgão / Norma | Fonte |
|----|-----------|--------------|-------|
| CO-001 | Documentos de onboarding devem ser retidos por no mínimo 5 anos após encerramento do contrato | LGPD / Bacen | [[sources/requisitos-compliance]] |
| CO-002 | O processo de KYC deve incluir verificação biométrica facial para clientes PF com movimentação prevista acima de R$ 10.000/mês | Resolução Bacen 4.753 | [[sources/requisitos-compliance]] |
| CO-003 | O consentimento do cliente para coleta e processamento de dados pessoais deve ser registrado com timestamp antes de qualquer upload | LGPD Art. 8º | [[sources/requisitos-compliance]] |
| CO-004 | Logs de acesso ao painel do agente de CS devem ser mantidos por 6 meses e disponíveis para auditoria | Política interna de segurança | [[sources/requisitos-compliance]] |

## Exclusions

- Requisitos de acessibilidade WCAG 2.1 AA não são escopo desta iniciativa (avaliados para fase 2).
- Suporte a idiomas além de português brasileiro está fora do escopo.
- Requisitos de performance para uploads acima de 100 MB não são aplicáveis — o limite máximo por arquivo é 10 MB.

## Open Questions

- [ ] O prazo de retenção de 5 anos (CO-001) começa na data de upload ou na data de encerramento do contrato? Confirmar com Jurídico.
- [ ] A verificação biométrica (CO-002) será fornecida pelo mesmo vendor do KYC ou por um serviço separado?
- [ ] NFR-003 (99,5% de disponibilidade) se aplica também ao painel do agente de CS ou apenas ao portal do cliente?

> [!gap] A wiki não especifica requisitos de performance para o processo de validação automática de documentos (OCR/KYC). Levantar SLAs do fornecedor antes de definir NFR-001 para essa etapa.

## Sources

- [[overview]]
- [[sources/pesquisa-jornada-cliente]]
- [[sources/requisitos-compliance]]
- [[sources/benchmarking-setor]]
- [[concepts/integracoes]]
- [[concepts/metricas-sucesso]]
