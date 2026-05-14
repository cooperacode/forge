#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/validate_common.sh"

FILE="${1:-}"
require_file "$FILE" "Usage: $0 <adr-file.md>"

assert_frontmatter_line "$FILE" '^title:' "Missing frontmatter field: title"
assert_frontmatter_line "$FILE" '^type: artifact$' "Frontmatter must include: type: artifact"
assert_frontmatter_line "$FILE" '^subtype: adr$' "Frontmatter must include: subtype: adr"
assert_frontmatter_line "$FILE" '^adr_number:' "Missing frontmatter field: adr_number"
assert_frontmatter_line "$FILE" '^status: accepted$' "Frontmatter must include: status: accepted"
assert_frontmatter_line "$FILE" '^work_item_type:' "Missing frontmatter field: work_item_type"
assert_frontmatter_line "$FILE" '^hierarchy_level:' "Missing frontmatter field: hierarchy_level"
assert_frontmatter_line "$FILE" '^generated:' "Missing frontmatter field: generated"

LANG_CODE="$(frontmatter_field "$FILE" language)"
LANG_CODE="${LANG_CODE:-en}"
LOCALE_FILE="$SCRIPT_DIR/../locales/${LANG_CODE}.sh"
[[ -f "$LOCALE_FILE" ]] || LOCALE_FILE="$SCRIPT_DIR/../locales/en.sh"
# shellcheck source=/dev/null
source "$LOCALE_FILE"

assert_exact_headings "$FILE" 2 "${LOCALE_H2[@]}"
assert_exact_headings "$FILE" 3 "${LOCALE_H3[@]}"
assert_body_line "$FILE" "$LOCALE_TABLE_ALTERNATIVES" "$LOCALE_TABLE_ALTERNATIVES_MSG"

echo "OK: ADR structure matches template for $FILE"
