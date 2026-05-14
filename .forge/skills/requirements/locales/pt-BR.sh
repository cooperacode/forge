#!/usr/bin/env bash
# Modo restrições
LOCALE_CONSTRAINTS_H2=(
  "## Contexto"
  "## Requisitos Não-Funcionais"
  "## Restrições Arquiteturais"
  "## Obrigações de Conformidade e Regulatórias"
  "## Exclusões"
  "## Questões Abertas"
  "## Fontes"
)
LOCALE_CONSTRAINTS_TABLE_NFR='^\| ID \| Categoria \| Requisito \| Prioridade \| Fonte \|$'
LOCALE_CONSTRAINTS_TABLE_NFR_MSG="Cabeçalho ausente: tabela Requisitos Não-Funcionais"
LOCALE_CONSTRAINTS_TABLE_ARCH='^\| ID \| Restrição \| Justificativa \| Fonte \|$'
LOCALE_CONSTRAINTS_TABLE_ARCH_MSG="Cabeçalho ausente: tabela Restrições Arquiteturais"
LOCALE_CONSTRAINTS_TABLE_COMP='^\| ID \| Obrigação \| Órgão Regulatório / Norma \| Fonte \|$'
LOCALE_CONSTRAINTS_TABLE_COMP_MSG="Cabeçalho ausente: tabela Obrigações de Conformidade e Regulatórias"

# Modo funcional
LOCALE_FUNCTIONAL_H2=(
  "## Contexto"
  "## Requisitos Funcionais"
  "## Requisitos de Integração"
  "## Requisitos de Dados"
  "## Exclusões"
  "## Lacunas"
  "## Questões Abertas"
  "## Fontes"
)
LOCALE_FUNCTIONAL_TABLE_FR='^\| ID \| Título \| Descrição \| Critérios de Aceitação \| Prioridade \| Fonte \|$'
LOCALE_FUNCTIONAL_TABLE_FR_MSG="Cabeçalho ausente: tabela Requisitos Funcionais"
LOCALE_FUNCTIONAL_TABLE_IR='^\| ID \| Sistema Origem \| Sistema Destino \| Interação \| Fonte \|$'
LOCALE_FUNCTIONAL_TABLE_IR_MSG="Cabeçalho ausente: tabela Requisitos de Integração"
LOCALE_FUNCTIONAL_TABLE_DR='^\| ID \| Elemento de Dados \| Formato \| Volume / Frequência \| Fonte \|$'
LOCALE_FUNCTIONAL_TABLE_DR_MSG="Cabeçalho ausente: tabela Requisitos de Dados"
