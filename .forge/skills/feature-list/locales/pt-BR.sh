#!/usr/bin/env bash
LOCALE_H2=(
  "## Resumo"
  "## Features"
  "## Fora de Escopo"
  "## Lacunas"
  "## Mapa de Dependências"
  "## Questões Abertas"
  "## Fontes"
)
LOCALE_TABLE_FEATURES='^\| ID \| Feature \| Descrição \| Beneficiário \| Prioridade \| Dependências \| Fonte \|$'
LOCALE_TABLE_FEATURES_MSG="Cabeçalho ausente: tabela Features"
LOCALE_TABLE_OUT_OF_SCOPE='^\| Feature \| Motivo de exclusão \| Fonte \|$'
LOCALE_TABLE_OUT_OF_SCOPE_MSG="Cabeçalho ausente: tabela Fora de Escopo"
