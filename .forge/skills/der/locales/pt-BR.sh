#!/usr/bin/env bash
LOCALE_H2=(
  "## Diagrama"
  "## Glossário de Entidades"
  "## Relacionamentos Confirmados"
  "## Relacionamentos Inferidos"
  "## Lacunas"
  "## Questões Abertas"
  "## Fontes"
)
LOCALE_TABLE_ENTITY_GLOSSARY='^\| Entidade \| Descrição \| Atributos documentados \| Fonte \|$'
LOCALE_TABLE_ENTITY_GLOSSARY_MSG="Cabeçalho ausente: tabela Glossário de Entidades"
LOCALE_TABLE_CONFIRMED='^\| Relacionamento \| Cardinalidade \| Rótulo \| Fonte \|$'
LOCALE_TABLE_CONFIRMED_MSG="Cabeçalho ausente: tabela Relacionamentos Confirmados"
LOCALE_TABLE_INFERRED='^\| Relacionamento \| Cardinalidade \| Evidência \| Fonte \|$'
LOCALE_TABLE_INFERRED_MSG="Cabeçalho ausente: tabela Relacionamentos Inferidos"
