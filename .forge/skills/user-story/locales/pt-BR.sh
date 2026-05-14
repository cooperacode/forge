#!/usr/bin/env bash
LOCALE_H2=(
  "## Contexto de Negócio"
  "## Critérios de Aceitação"
  "## Cenários Gherkin"
  "## Regras de Negócio"
  "## Definição de Pronto"
  "## Dependências e Bloqueios"
  "## Fora de Escopo"
  "## Questões Abertas"
  "## Fontes"
)
LOCALE_TABLE_CRITERIA='^\| # \| Critério \| Fonte \|$'
LOCALE_TABLE_CRITERIA_MSG="Cabeçalho ausente: tabela Critérios de Aceitação"
LOCALE_TABLE_RULES='^\| # \| Regra \| Fonte \|$'
LOCALE_TABLE_RULES_MSG="Cabeçalho ausente: tabela Regras de Negócio"
LOCALE_TABLE_DEPS='^\| Tipo \| Item \| Status \| Fonte \|$'
LOCALE_TABLE_DEPS_MSG="Cabeçalho ausente: tabela Dependências e Bloqueios"
