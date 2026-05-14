#!/usr/bin/env bash
LOCALE_H2=(
  "## Resumo Executivo"
  "## Contexto de Negócio"
  "## Objetivos e Metas"
  "## Escopo"
  "## Principais Partes Interessadas"
  "## Métricas de Sucesso"
  "## Cronograma e Marcos"
  "## Riscos e Dependências"
  "## Questões Abertas"
  "## Fontes"
)
LOCALE_H3=("### Em escopo" "### Fora de escopo")
LOCALE_TABLE_GOALS='^\| # \| Objetivo \| Resultado Esperado \|$'
LOCALE_TABLE_GOALS_MSG="Cabeçalho ausente: tabela Objetivos e Metas"
LOCALE_TABLE_STAKEHOLDERS='^\| Parte Interessada \| Papel / Interesse \|$'
LOCALE_TABLE_STAKEHOLDERS_MSG="Cabeçalho ausente: tabela Principais Partes Interessadas"
LOCALE_TABLE_METRICS='^\| Métrica \| Meta \| Fonte \|$'
LOCALE_TABLE_METRICS_MSG="Cabeçalho ausente: tabela Métricas de Sucesso"
LOCALE_TABLE_TIMELINE='^\| Marco \| Data-Alvo \| Notas \|$'
LOCALE_TABLE_TIMELINE_MSG="Cabeçalho ausente: tabela Cronograma e Marcos"
LOCALE_TABLE_RISKS='^\| # \| Risco / Dependência \| Probabilidade \| Impacto \| Mitigação \|$'
LOCALE_TABLE_RISKS_MSG="Cabeçalho ausente: tabela Riscos e Dependências"
