#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/validate_common.sh"

FILE="${1:-}"
require_file "$FILE" "Usage: $0 <file.md>"

assert_frontmatter_line "$FILE" '^title:' "Missing frontmatter field: title"
assert_frontmatter_line "$FILE" '^type: artifact$' "Frontmatter must include: type: artifact"
assert_frontmatter_line "$FILE" '^subtype: feature-list$' "Frontmatter must include: subtype: feature-list"
assert_frontmatter_line "$FILE" '^work_item_type:' "Missing frontmatter field: work_item_type"
assert_frontmatter_line "$FILE" '^hierarchy_level: Product$' "Frontmatter must include: hierarchy_level: Product"
assert_frontmatter_line "$FILE" '^generated:' "Missing frontmatter field: generated"
assert_frontmatter_line "$FILE" '^sources_read:' "Missing frontmatter field: sources_read"
assert_frontmatter_line "$FILE" '^total_features:' "Missing frontmatter field: total_features"

LANG_CODE="$(frontmatter_field "$FILE" language)"
LANG_CODE="${LANG_CODE:-en}"
LOCALE_FILE="$SCRIPT_DIR/../locales/${LANG_CODE}.sh"
[[ -f "$LOCALE_FILE" ]] || LOCALE_FILE="$SCRIPT_DIR/../locales/en.sh"
# shellcheck source=/dev/null
source "$LOCALE_FILE"

assert_exact_headings "$FILE" 2 "${LOCALE_H2[@]}"
assert_body_line "$FILE" "$LOCALE_TABLE_FEATURES" "$LOCALE_TABLE_FEATURES_MSG"
assert_body_line "$FILE" "$LOCALE_TABLE_OUT_OF_SCOPE" "$LOCALE_TABLE_OUT_OF_SCOPE_MSG"

echo "OK: feature-list structure matches template for $FILE"
