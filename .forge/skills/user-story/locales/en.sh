#!/usr/bin/env bash
LOCALE_H2=(
  "## Business Context"
  "## Acceptance Criteria"
  "## Gherkin Scenarios"
  "## Business Rules"
  "## Definition of Done"
  "## Dependencies & Blockers"
  "## Out of Scope"
  "## Open Questions"
  "## Sources"
)
LOCALE_TABLE_CRITERIA='^\| # \| Criterion \| Source \|$'
LOCALE_TABLE_CRITERIA_MSG="Missing Acceptance Criteria table header"
LOCALE_TABLE_RULES='^\| # \| Rule \| Source \|$'
LOCALE_TABLE_RULES_MSG="Missing Business Rules table header"
LOCALE_TABLE_DEPS='^\| Type \| Item \| Status \| Source \|$'
LOCALE_TABLE_DEPS_MSG="Missing Dependencies & Blockers table header"
