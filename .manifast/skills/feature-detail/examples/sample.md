---
title: "Feature Detail — F-002: Upload de Documentos"
type: artifact
subtype: feature-detail
feature_id: F-002
work_item_type: Epic
hierarchy_level: Product
generated: 2026-05-05
sources_read: 6
total_stories: 4
---

# Feature Detail: F-002 — Upload de Documentos

## Feature Statement

O cliente deve conseguir enviar os documentos exigidos para abertura da conta diretamente pelo portal, com feedback imediato sobre a validade de cada arquivo, sem precisar entrar em contato com o time de CS.

## Goal

Eliminar a etapa manual de envio de documentos por e-mail, reduzindo o tempo de coleta de 3 dias para menos de 30 minutos [[sources/pesquisa-jornada-cliente]].

## Personas

| Persona | Papel | Interação com esta feature | Fonte |
|---------|-------|---------------------------|-------|
| Cliente PF | Pessoa física abrindo conta | Envia RG ou CNH e comprovante de endereço | [[entities/cliente-pf]] |
| Cliente PJ | Representante legal de empresa | Envia CNPJ, contrato social e documentos dos sócios | [[entities/cliente-pj]] |
| Agente de CS | Analista de Sucesso do Cliente | Recebe notificação quando upload é concluído; não interage com o upload em si | [[entities/agente-cs]] |

## Functional Scope

### In scope
- Upload de arquivos nos formatos PDF, JPG e PNG
- Validação de tamanho (máx. 10 MB por arquivo) e formato em tempo real
- Listagem dos documentos obrigatórios por tipo de cliente (PF ou PJ)
- Confirmação visual de cada documento enviado com sucesso
- Persistência do estado (cliente pode fechar e retomar o upload)

### Out of scope
- Reenvio de documentos após rejeição pelo agente (coberto em F-006)
- Assinatura eletrônica de documentos
- Upload por app mobile nativo (fase 2)

## Business Rules

| # | Regra | Fonte |
|---|-------|-------|
| BR-1 | Formatos aceitos: PDF, JPG, PNG. Arquivos em outros formatos devem ser rejeitados antes do envio ao servidor | [[sources/requisitos-compliance]] |
| BR-2 | Tamanho máximo por arquivo: 10 MB. Exceder deve mostrar mensagem de erro com orientação de compressão | [[sources/requisitos-compliance]] |
| BR-3 | Documentos obrigatórios para PF: RG ou CNH + comprovante de endereço com menos de 90 dias | [[sources/requisitos-compliance]] |
| BR-4 | Documentos obrigatórios para PJ: CNPJ + contrato social + documentos pessoais de todos os sócios com > 25% de participação | [[sources/requisitos-compliance]] |
| BR-5 | O cliente só pode avançar para a etapa de revisão após enviar todos os documentos obrigatórios | [[sources/pesquisa-jornada-cliente]] |

## Entity & Data Interactions

| Entidade | Operação | Notas | Fonte |
|----------|----------|-------|-------|
| DOCUMENTO | CREATE | Um registro por arquivo enviado; armazenar tipo, URL e timestamp | [[entities/documento]] |
| SOLICITACAO_ONBOARDING | READ / UPDATE | Consultar lista de documentos obrigatórios; atualizar status quando todos os docs forem enviados | [[entities/solicitacao-onboarding]] |
| CLIENTE | READ | Verificar tipo (PF/PJ) para determinar lista de documentos exigidos | [[entities/cliente-pf]], [[entities/cliente-pj]] |
| CANAL_NOTIFICACAO | READ | Disparar notificação de upload concluído (via F-004) | [[concepts/notificacoes]] |

## Feature-Level Acceptance Criteria

| # | Critério | Fonte |
|---|---------|-------|
| FAC-1 | O sistema rejeita arquivos fora dos formatos permitidos antes do envio, exibindo mensagem de erro específica | [[sources/requisitos-compliance]] |
| FAC-2 | O cliente consegue retomar o upload em uma sessão diferente sem perder os documentos já enviados | [[sources/pesquisa-jornada-cliente]] |
| FAC-3 | O progresso de upload (% concluído) é exibido em tempo real para arquivos acima de 2 MB | [[sources/pesquisa-jornada-cliente]] |
| FAC-4 | Ao enviar o último documento obrigatório, o status da solicitação muda automaticamente para "em_analise" | [[entities/solicitacao-onboarding]] |

## Proposed User Story Breakdown

| Story ID | História | Persona | Prioridade | INVEST Notes | Depende de |
|----------|---------|---------|------------|-------------|-----------|
| US-001 | Como cliente, quero ver a lista de documentos que preciso enviar, para saber o que preparar antes de começar o upload | Cliente PF / PJ | Alta | OK — pequena, testável, independente | — |
| US-002 | Como cliente, quero enviar um arquivo de documento, para que ele seja registrado na minha solicitação | Cliente PF / PJ | Alta | OK — comportamento central, testável via AC | US-001 |
| US-003 | Como cliente, quero receber feedback imediato se meu arquivo for inválido, para corrigir sem precisar chamar o CS | Cliente PF / PJ | Alta | OK — testável; validação no frontend, não depende de backend | US-002 |
| US-004 | Como cliente, quero retomar o upload em outro momento sem perder o progresso, para não precisar reenviar tudo | Cliente PF / PJ | Média | Estimable concern: depende de decisão sobre persistência de sessão — confirmar abordagem técnica | US-002 |

## Dependencies

| Tipo | Item | Direção | Fonte |
|------|------|---------|-------|
| Feature anterior | F-001 (Cadastro de Cliente) | upstream — o cadastro cria a solicitação que esta feature popula | [[entities/solicitacao-onboarding]] |
| Feature posterior | F-005 (Painel do Agente de CS) | downstream — esta feature entrega documentos que F-005 analisa | [[sources/pesquisa-jornada-cliente]] |
| Feature posterior | F-006 (Reenvio de Documentos) | downstream — reenvio só ocorre após análise iniciada por esta feature | [[concepts/fluxo-rejeicao]] |

## Gaps

> [!gap] Mecanismo de autenticação não definido na wiki: não é possível especificar como o sistema identifica o cliente na retomada da sessão (US-004) sem essa decisão. Bloqueia estimativa de US-004.

> [!gap] Armazenamento de documentos: a wiki não especifica onde os arquivos serão armazenados (S3, GCS, storage interno) nem política de retenção. Necessário para definir o atributo `url_armazenamento` em DOCUMENTO.

## Open Questions

- [ ] Existe limite de tentativas de upload por documento? (ex.: máx. 5 envios por tipo antes de bloquear)
- [ ] O agente de CS é notificado por upload individual ou apenas quando todos os documentos forem enviados?
- [ ] Como tratar documentos bilingues ou com OCR necessário (clientes estrangeiros)?

## Sources

- [[overview]]
- [[sources/pesquisa-jornada-cliente]]
- [[sources/requisitos-compliance]]
- [[concepts/notificacoes]]
- [[concepts/fluxo-rejeicao]]
- [[entities/cliente-pf]]
- [[entities/cliente-pj]]
- [[entities/documento]]
- [[entities/solicitacao-onboarding]]
- [[entities/agente-cs]]
