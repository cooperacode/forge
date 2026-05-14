#!/usr/bin/env bash
LOCALE_H2=(
  "## Diagram"
  "## Entity Glossary"
  "## Confirmed Relationships"
  "## Inferred Relationships"
  "## Gaps"
  "## Open Questions"
  "## Sources"
)
LOCALE_TABLE_ENTITY_GLOSSARY='^\| Entity \| Description \| Attributes documented \| Source \|$'
LOCALE_TABLE_ENTITY_GLOSSARY_MSG="Missing Entity Glossary table header"
LOCALE_TABLE_CONFIRMED='^\| Relationship \| Cardinality \| Label \| Source \|$'
LOCALE_TABLE_CONFIRMED_MSG="Missing Confirmed Relationships table header"
LOCALE_TABLE_INFERRED='^\| Relationship \| Cardinality \| Evidence \| Source \|$'
LOCALE_TABLE_INFERRED_MSG="Missing Inferred Relationships table header"
