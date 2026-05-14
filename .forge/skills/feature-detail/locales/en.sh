#!/usr/bin/env bash
LOCALE_H2=(
  "## Feature Statement"
  "## Goal"
  "## Personas"
  "## Functional Scope"
  "## Business Rules"
  "## Entity & Data Interactions"
  "## Feature-Level Acceptance Criteria"
  "## Proposed User Story Breakdown"
  "## Dependencies"
  "## Gaps"
  "## Open Questions"
  "## Sources"
)
LOCALE_H3=("### In scope" "### Out of scope")
LOCALE_TABLE_PERSONAS='^\| Persona \| Role \| Interaction with this feature \| Source \|$'
LOCALE_TABLE_PERSONAS_MSG="Missing Personas table header"
LOCALE_TABLE_RULES='^\| # \| Rule \| Source \|$'
LOCALE_TABLE_RULES_MSG="Missing Business Rules table header"
LOCALE_TABLE_ENTITIES='^\| Entity \| Operation \| Notes \| Source \|$'
LOCALE_TABLE_ENTITIES_MSG="Missing Entity & Data Interactions table header"
LOCALE_TABLE_CRITERIA='^\| # \| Criterion \| Source \|$'
LOCALE_TABLE_CRITERIA_MSG="Missing Feature-Level Acceptance Criteria table header"
LOCALE_TABLE_STORIES='^\| Story ID \| Story \| Persona \| Priority \| INVEST Notes \| Depends On \|$'
LOCALE_TABLE_STORIES_MSG="Missing Proposed User Story Breakdown table header"
LOCALE_TABLE_DEPS='^\| Type \| Item \| Direction \| Source \|$'
LOCALE_TABLE_DEPS_MSG="Missing Dependencies table header"
