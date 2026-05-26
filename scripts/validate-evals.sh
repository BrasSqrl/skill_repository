#!/usr/bin/env bash

# Validate dependency-free evaluation scenarios and catalog metadata.
#
# Examples:
#   ./scripts/validate-evals.sh
#   ./scripts/validate-evals.sh --evals-path ./evals

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EVALS_PATH="$REPO_ROOT/evals"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/validate-evals.sh [--evals-path PATH]

Options:
  --evals-path PATH   Evaluation directory to validate. Defaults to ./evals.
  -h, --help          Show this help.
USAGE
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

fail_line() {
  echo "[FAIL] $1"
}

target_exists() {
  local target_type="$1"
  local target_name="$2"

  case "$target_type" in
    skill) [[ -f "$REPO_ROOT/skills/$target_name/SKILL.md" ]] ;;
    agent) [[ -f "$REPO_ROOT/agents/$target_name.md" ]] ;;
    workflow) [[ -f "$REPO_ROOT/workflows/$target_name.md" ]] ;;
    bundle) [[ -f "$REPO_ROOT/catalog/bundles/$target_name.txt" || -f "$REPO_ROOT/catalog/agent-bundles/$target_name.txt" ]] ;;
    *) return 1 ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --evals-path)
      [[ $# -ge 2 ]] || { echo "[ERROR] --evals-path requires a value" >&2; exit 1; }
      EVALS_PATH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

required_columns=(id target_type target_name capability mode status description)
required_sections=(
  "Objective"
  "Target"
  "Inputs"
  "Setup"
  "Expected Behavior"
  "Pass Criteria"
  "Failure Signals"
  "Artifacts"
  "Review Notes"
)

passed=0
failed=0

if [[ ! -d "$EVALS_PATH" ]]; then
  fail_line "Evals directory not found: $EVALS_PATH"
  exit 1
fi

CATALOG_PATH="$REPO_ROOT/catalog/evals.tsv"
if [[ ! -f "$CATALOG_PATH" ]]; then
  fail_line "Required metadata file not found: $CATALOG_PATH"
  exit 1
fi

header="$(head -n 1 "$CATALOG_PATH")"
for column in "${required_columns[@]}"; do
  if ! printf '%s\n' "$header" | tr '\t' '\n' | grep -Fxq "$column"; then
    fail_line "catalog/evals.tsv: missing required column '$column'"
    failed=$((failed + 1))
  fi
done

declare -A seen
row_count=0

while IFS=$'\t' read -r id target_type target_name capability mode status description extra; do
  [[ "$id" == "id" ]] && continue
  row_count=$((row_count + 1))
  scenario_failed=0

  if [[ -z "$(trim "$id")" ]]; then
    fail_line "catalog/evals.tsv: row with empty id"
    failed=$((failed + 1))
    continue
  fi

  if [[ -n "${seen[$id]+x}" ]]; then
    fail_line "catalog/evals.tsv: duplicate eval id '$id'"
    failed=$((failed + 1))
    continue
  fi
  seen["$id"]=1

  if [[ ! "$id" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    fail_line "$id: eval id must use lowercase kebab-case"
    scenario_failed=1
  fi

  case "$target_type" in
    skill|agent|workflow|bundle) ;;
    *)
      fail_line "$id: target_type must be skill, agent, workflow, or bundle"
      scenario_failed=1
      ;;
  esac

  case "$mode" in
    manual|dry-run|fixture) ;;
    *)
      fail_line "$id: mode must be manual, dry-run, or fixture"
      scenario_failed=1
      ;;
  esac

  case "$status" in
    draft|validated|retired) ;;
    *)
      fail_line "$id: status must be draft, validated, or retired"
      scenario_failed=1
      ;;
  esac

  for value_name in id target_type target_name capability mode status description; do
    case "$value_name" in
      id) value="$id" ;;
      target_type) value="$target_type" ;;
      target_name) value="$target_name" ;;
      capability) value="$capability" ;;
      mode) value="$mode" ;;
      status) value="$status" ;;
      description) value="$description" ;;
    esac
    if [[ -z "$(trim "$value")" ]]; then
      fail_line "$id: missing required metadata '$value_name'"
      scenario_failed=1
    fi
  done

  if ! target_exists "$target_type" "$target_name"; then
    fail_line "$id: target '$target_type:$target_name' does not exist"
    scenario_failed=1
  fi

  scenario_file="$EVALS_PATH/scenarios/$id/scenario.md"
  if [[ ! -f "$scenario_file" ]]; then
    fail_line "$id: missing scenario.md"
    scenario_failed=1
  else
    for section in "${required_sections[@]}"; do
      if ! grep -Eq "^## ${section}[[:space:]]*$" "$scenario_file"; then
        fail_line "$id: missing required section '## $section'"
        scenario_failed=1
      fi
    done
  fi

  if [[ "$scenario_failed" -eq 1 ]]; then
    failed=$((failed + 1))
  else
    echo "[PASS] $id"
    passed=$((passed + 1))
  fi
done < "$CATALOG_PATH"

echo "[INFO] Validated $row_count eval scenario(s)"
echo
echo "Eval validation summary:"
echo "  Passed: $passed"
echo "  Failed: $failed"

if [[ "$failed" -gt 0 ]]; then
  exit 1
fi

exit 0
