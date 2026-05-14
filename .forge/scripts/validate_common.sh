#!/usr/bin/env bash

fail() {
  local message="${1:-Validation failed}"
  local code="${2:-1}"
  echo "$message"
  exit "$code"
}

require_file() {
  local file="${1:-}"
  local usage="${2:-Usage: validate.sh <file.md>}"
  if [[ -z "$file" || ! -f "$file" ]]; then
    fail "$usage" 1
  fi
}

init_frontmatter() {
  local file="$1"

  if [[ "$(sed -n '1p' "$file")" != "---" ]]; then
    fail "Frontmatter must start on line 1" 2
  fi

  FRONTMATTER_END_LINE="$(awk '
    NR == 1 { next }
    $0 == "---" { print NR; found = 1; exit }
    END { if (!found) exit 1 }
  ' "$file")" || fail "Missing closing frontmatter delimiter" 2

  BODY_START_LINE=$((FRONTMATTER_END_LINE + 1))
}

frontmatter_text() {
  local file="$1"
  init_frontmatter "$file"
  sed -n "2,$((FRONTMATTER_END_LINE - 1))p" "$file"
}

frontmatter_field() {
  local file="$1"
  local key="$2"
  frontmatter_text "$file" | sed -n "s/^${key}: //p" | head -n1
}

assert_frontmatter_line() {
  local file="$1"
  local pattern="$2"
  local message="$3"

  if ! frontmatter_text "$file" | rg -q "$pattern"; then
    fail "$message" 3
  fi
}

extract_headings() {
  local file="$1"
  local level="$2"
  local prefix=""

  init_frontmatter "$file"

  case "$level" in
    1) prefix="# " ;;
    2) prefix="## " ;;
    3) prefix="### " ;;
    *) fail "Unsupported heading level: $level" 99 ;;
  esac

  awk -v start="$BODY_START_LINE" -v prefix="$prefix" '
    NR < start { next }
    /^```/ { in_code = !in_code; next }
    !in_code && index($0, prefix) == 1 { print }
  ' "$file"
}

assert_exact_headings() {
  local file="$1"
  local level="$2"
  shift 2
  local expected=("$@")
  local actual=()
  local idx=0

  while IFS= read -r line; do
    actual+=("$line")
  done < <(extract_headings "$file" "$level")

  if [[ "${#actual[@]}" -ne "${#expected[@]}" ]]; then
    {
      echo "Unexpected number of level-$level headings."
      echo "Expected (${#expected[@]}):"
      printf '  %s\n' "${expected[@]}"
      echo "Actual (${#actual[@]}):"
      if [[ "${#actual[@]}" -gt 0 ]]; then
        printf '  %s\n' "${actual[@]}"
      fi
    } >&2
    exit 4
  fi

  for idx in "${!expected[@]}"; do
    if [[ "${actual[$idx]}" != "${expected[$idx]}" ]]; then
      {
        echo "Heading order/content mismatch at level $level."
        echo "Expected: ${expected[$idx]}"
        echo "Actual:   ${actual[$idx]}"
      } >&2
      exit 4
    fi
  done
}

assert_body_line() {
  local file="$1"
  local pattern="$2"
  local message="$3"

  init_frontmatter "$file"

  if ! sed -n "${BODY_START_LINE},\$p" "$file" | rg -q "$pattern"; then
    fail "$message" 5
  fi
}

assert_mermaid_keyword() {
  local file="$1"
  local expected="$2"

  init_frontmatter "$file"

  local actual
  actual="$(awk -v start="$BODY_START_LINE" '
    NR < start { next }
    /^```mermaid$/ { getline; print; exit }
  ' "$file")"

  if [[ -z "$actual" ]]; then
    fail "Missing mermaid code block" 6
  fi

  if [[ "$actual" != "$expected" ]]; then
    fail "Mermaid keyword must be '$expected' (found '$actual')" 6
  fi
}
