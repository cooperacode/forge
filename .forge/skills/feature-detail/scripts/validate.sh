#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/validate_common.sh"

FILE="${1:-}"
require_file "$FILE" "Usage: $0 <file.md>"

assert_frontmatter_line "$FILE" '^title:' "Missing frontmatter field: title"
assert_frontmatter_line "$FILE" '^type: artifact$' "Frontmatter must include: type: artifact"
assert_frontmatter_line "$FILE" '^subtype: feature-detail$' "Frontmatter must include: subtype: feature-detail"
assert_frontmatter_line "$FILE" '^feature_id:' "Missing frontmatter field: feature_id"
assert_frontmatter_line "$FILE" '^work_item_type:' "Missing frontmatter field: work_item_type"
assert_frontmatter_line "$FILE" '^hierarchy_level: Product$' "Frontmatter must include: hierarchy_level: Product"
assert_frontmatter_line "$FILE" '^generated:' "Missing frontmatter field: generated"
assert_frontmatter_line "$FILE" '^sources_read:' "Missing frontmatter field: sources_read"
assert_frontmatter_line "$FILE" '^total_stories:' "Missing frontmatter field: total_stories"

LANG_CODE="$(frontmatter_field "$FILE" language)"
LANG_CODE="${LANG_CODE:-en}"
LOCALE_FILE="$SCRIPT_DIR/../locales/${LANG_CODE}.sh"
[[ -f "$LOCALE_FILE" ]] || LOCALE_FILE="$SCRIPT_DIR/../locales/en.sh"
# shellcheck source=/dev/null
source "$LOCALE_FILE"

assert_exact_headings "$FILE" 2 "${LOCALE_H2[@]}"
assert_exact_headings "$FILE" 3 "${LOCALE_H3[@]}"
assert_body_line "$FILE" "$LOCALE_TABLE_PERSONAS" "$LOCALE_TABLE_PERSONAS_MSG"
assert_body_line "$FILE" "$LOCALE_TABLE_RULES" "$LOCALE_TABLE_RULES_MSG"
assert_body_line "$FILE" "$LOCALE_TABLE_ENTITIES" "$LOCALE_TABLE_ENTITIES_MSG"
assert_body_line "$FILE" "$LOCALE_TABLE_CRITERIA" "$LOCALE_TABLE_CRITERIA_MSG"
assert_body_line "$FILE" "$LOCALE_TABLE_STORIES" "$LOCALE_TABLE_STORIES_MSG"
assert_body_line "$FILE" "$LOCALE_TABLE_DEPS" "$LOCALE_TABLE_DEPS_MSG"

echo "OK: feature-detail structure matches template for $FILE"
