#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/validate_common.sh"

FILE="${1:-}"
require_file "$FILE" "Usage: $0 <file.md>"

assert_frontmatter_line "$FILE" '^title:' "Missing frontmatter field: title"
assert_frontmatter_line "$FILE" '^type: artifact$' "Frontmatter must include: type: artifact"
assert_frontmatter_line "$FILE" '^subtype: brief$' "Frontmatter must include: subtype: brief"
assert_frontmatter_line "$FILE" '^work_item_type:' "Missing frontmatter field: work_item_type"
assert_frontmatter_line "$FILE" '^hierarchy_level: Strategic$' "Frontmatter must include: hierarchy_level: Strategic"
assert_frontmatter_line "$FILE" '^generated:' "Missing frontmatter field: generated"
assert_frontmatter_line "$FILE" '^sources_read:' "Missing frontmatter field: sources_read"

LANG_CODE="$(frontmatter_field "$FILE" language)"
LANG_CODE="${LANG_CODE:-en}"
LOCALE_FILE="$SCRIPT_DIR/../locales/${LANG_CODE}.sh"
[[ -f "$LOCALE_FILE" ]] || LOCALE_FILE="$SCRIPT_DIR/../locales/en.sh"
# shellcheck source=/dev/null
source "$LOCALE_FILE"

assert_exact_headings "$FILE" 2 "${LOCALE_H2[@]}"
assert_exact_headings "$FILE" 3 "${LOCALE_H3[@]}"
assert_body_line "$FILE" "$LOCALE_TABLE_GOALS" "$LOCALE_TABLE_GOALS_MSG"
assert_body_line "$FILE" "$LOCALE_TABLE_STAKEHOLDERS" "$LOCALE_TABLE_STAKEHOLDERS_MSG"
assert_body_line "$FILE" "$LOCALE_TABLE_METRICS" "$LOCALE_TABLE_METRICS_MSG"
assert_body_line "$FILE" "$LOCALE_TABLE_TIMELINE" "$LOCALE_TABLE_TIMELINE_MSG"
assert_body_line "$FILE" "$LOCALE_TABLE_RISKS" "$LOCALE_TABLE_RISKS_MSG"

echo "OK: brief structure matches template for $FILE"
