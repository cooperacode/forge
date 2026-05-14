#!/usr/bin/env bash
LOCALE_H2=(
  "## Declaração da Feature"
  "## Objetivo"
  "## Personas"
  "## Escopo Funcional"
  "## Regras de Negócio"
  "## Interações com Entidades e Dados"
  "## Critérios de Aceitação da Feature"
  "## Desmembramento em Histórias de Usuário"
  "## Dependências"
  "## Lacunas"
  "## Questões Abertas"
  "## Fontes"
)
LOCALE_H3=("### Em escopo" "### Fora de escopo")
LOCALE_TABLE_PERSONAS='^\| Persona \| Papel \| Interação com esta feature \| Fonte \|$'
LOCALE_TABLE_PERSONAS_MSG="Cabeçalho ausente: tabela Personas"
LOCALE_TABLE_RULES='^\| # \| Regra \| Fonte \|$'
LOCALE_TABLE_RULES_MSG="Cabeçalho ausente: tabela Regras de Negócio"
LOCALE_TABLE_ENTITIES='^\| Entidade \| Operação \| Notas \| Fonte \|$'
LOCALE_TABLE_ENTITIES_MSG="Cabeçalho ausente: tabela Interações com Entidades e Dados"
LOCALE_TABLE_CRITERIA='^\| # \| Critério \| Fonte \|$'
LOCALE_TABLE_CRITERIA_MSG="Cabeçalho ausente: tabela Critérios de Aceitação da Feature"
LOCALE_TABLE_STORIES='^\| ID da História \| História \| Persona \| Prioridade \| Notas INVEST \| Depende De \|$'
LOCALE_TABLE_STORIES_MSG="Cabeçalho ausente: tabela Desmembramento em Histórias de Usuário"
LOCALE_TABLE_DEPS='^\| Tipo \| Item \| Direção \| Fonte \|$'
LOCALE_TABLE_DEPS_MSG="Cabeçalho ausente: tabela Dependências"
