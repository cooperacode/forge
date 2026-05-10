#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/validate_common.sh"

FILE="${1:-}"
require_file "$FILE" "Usage: $0 <file.md>"

assert_frontmatter_line "$FILE" '^title:' "Missing frontmatter field: title"
assert_frontmatter_line "$FILE" '^type: artifact$' "Frontmatter must include: type: artifact"
assert_frontmatter_line "$FILE" '^subtype: der$' "Frontmatter must include: subtype: der"
assert_frontmatter_line "$FILE" '^work_item_type:' "Missing frontmatter field: work_item_type"
assert_frontmatter_line "$FILE" '^hierarchy_level: Product$' "Frontmatter must include: hierarchy_level: Product"
assert_frontmatter_line "$FILE" '^generated:' "Missing frontmatter field: generated"
assert_frontmatter_line "$FILE" '^entities_count:' "Missing frontmatter field: entities_count"
assert_frontmatter_line "$FILE" '^relationships_confirmed:' "Missing frontmatter field: relationships_confirmed"
assert_frontmatter_line "$FILE" '^relationships_inferred:' "Missing frontmatter field: relationships_inferred"

assert_exact_headings "$FILE" 2 \
  "## Diagram" \
  "## Entity Glossary" \
  "## Confirmed Relationships" \
  "## Inferred Relationships" \
  "## Gaps" \
  "## Open Questions" \
  "## Sources"

assert_body_line "$FILE" '^```mermaid$' "Missing Mermaid block"
assert_body_line "$FILE" '^erDiagram$' "Mermaid keyword must be erDiagram"
assert_body_line "$FILE" '^\| Entity \| Description \| Attributes documented \| Source \|$' "Missing Entity Glossary table header"
assert_body_line "$FILE" '^\| Relationship \| Cardinality \| Label \| Source \|$' "Missing Confirmed Relationships table header"
assert_body_line "$FILE" '^\| Relationship \| Cardinality \| Evidence \| Source \|$' "Missing Inferred Relationships table header"

echo "OK: DER structure matches template for $FILE"
