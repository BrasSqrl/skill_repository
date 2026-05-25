#!/usr/bin/env bash

# Validate OpenAI-style skill folders.
#
# Examples:
#   ./scripts/validate-skills.sh
#   ./scripts/validate-skills.sh --skills-path ./skills

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_PATH="$REPO_ROOT/skills"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/validate-skills.sh [--skills-path PATH]

Options:
  --skills-path PATH   Skills directory to validate. Defaults to ./skills.
  -h, --help           Show this help.
USAGE
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skills-path)
      [[ $# -ge 2 ]] || { echo "[ERROR] --skills-path requires a value" >&2; exit 1; }
      SKILLS_PATH="$2"
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

if [[ ! -d "$SKILLS_PATH" ]]; then
  echo "[FAIL] Skills directory not found: $SKILLS_PATH" >&2
  exit 1
fi

required_sections=(
  "Purpose"
  "When to Use"
  "When Not to Use"
  "Required Inputs"
  "Workflow"
  "Quality Gates"
  "Anti-Patterns"
  "Output Format"
  "References"
)

mapfile -t skill_dirs < <(find "$SKILLS_PATH" -mindepth 1 -maxdepth 1 -type d | sort)

if [[ ${#skill_dirs[@]} -eq 0 ]]; then
  echo "[FAIL] No skill folders found under: $SKILLS_PATH" >&2
  exit 1
fi

passed=0
failed=0
warnings=0

echo "[INFO] Validating ${#skill_dirs[@]} skill folder(s) in $SKILLS_PATH"

for skill_dir in "${skill_dirs[@]}"; do
  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"
  skill_failed=0

  if [[ ! "$skill_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "[FAIL] $skill_name: folder name must use lowercase kebab-case"
    skill_failed=1
  fi

  if [[ ! -f "$skill_file" ]]; then
    echo "[FAIL] $skill_name: missing SKILL.md"
    failed=$((failed + 1))
    continue
  fi

  first_line="$(sed -n '1p' "$skill_file")"
  if [[ "$first_line" != "---" ]]; then
    echo "[FAIL] $skill_name: missing YAML frontmatter opening marker"
    failed=$((failed + 1))
    continue
  fi

  closing_line="$(awk 'NR > 1 && $0 ~ /^---[[:space:]]*$/ { print NR; exit }' "$skill_file")"
  if [[ -z "$closing_line" ]]; then
    echo "[FAIL] $skill_name: missing YAML frontmatter closing marker"
    failed=$((failed + 1))
    continue
  fi

  frontmatter="$(sed -n "2,$((closing_line - 1))p" "$skill_file")"
  name_line="$(printf '%s\n' "$frontmatter" | grep -E '^name:[[:space:]]*' | head -n 1 || true)"
  description_line="$(printf '%s\n' "$frontmatter" | grep -E '^description:[[:space:]]*' | head -n 1 || true)"
  name="$(trim "${name_line#name:}")"
  description="$(trim "${description_line#description:}")"
  name="${name%\"}"
  name="${name#\"}"
  description="${description%\"}"
  description="${description#\"}"

  if [[ -z "$name" ]]; then
    echo "[FAIL] $skill_name: frontmatter is missing name"
    skill_failed=1
  elif [[ "$name" != "$skill_name" ]]; then
    echo "[WARN] $skill_name: frontmatter name '$name' does not match folder name"
    warnings=$((warnings + 1))
  fi

  if [[ -z "$description" ]]; then
    echo "[FAIL] $skill_name: frontmatter description is empty or missing"
    skill_failed=1
  else
    if [[ ${#description} -lt 80 ]]; then
      echo "[FAIL] $skill_name: description is too short to be useful; use at least 80 characters"
      skill_failed=1
    fi
    if [[ ! "$description" =~ Use[[:space:]](when|before|for|at) ]]; then
      echo "[FAIL] $skill_name: description must include specific trigger language such as 'Use when', 'Use before', or 'Use for'"
      skill_failed=1
    fi
  fi

  for section in "${required_sections[@]}"; do
    if ! grep -Eq "^## ${section}[[:space:]]*$" "$skill_file"; then
      echo "[FAIL] $skill_name: missing required section '## $section'"
      skill_failed=1
    fi
  done

  while IFS= read -r child_dir; do
    child_name="$(basename "$child_dir")"
    case "$child_name" in
      references|scripts|assets|agents) ;;
      *)
        echo "[FAIL] $skill_name: unexpected resource folder '$child_name'"
        skill_failed=1
        ;;
    esac
  done < <(find "$skill_dir" -mindepth 1 -maxdepth 1 -type d | sort)

  if [[ -d "$skill_dir/references" ]] && ! grep -q 'references/' "$skill_file"; then
    echo "[FAIL] $skill_name: references folder exists but SKILL.md does not link to it"
    skill_failed=1
  fi

  while IFS= read -r reference_path; do
    reference_path="${reference_path%%#*}"
    [[ -n "$reference_path" ]] || continue
    if [[ ! -f "$skill_dir/$reference_path" ]]; then
      echo "[FAIL] $skill_name: missing linked reference '$reference_path'"
      skill_failed=1
    fi
  done < <(grep -Eo 'references/[^`) ]+' "$skill_file" | sort -u || true)

  if [[ "$skill_failed" -eq 1 ]]; then
    failed=$((failed + 1))
  else
    echo "[PASS] $skill_name"
    passed=$((passed + 1))
  fi
done

echo
echo "Validation summary:"
echo "  Passed:   $passed"
echo "  Failed:   $failed"
echo "  Warnings: $warnings"

if [[ "$failed" -gt 0 ]]; then
  exit 1
fi

exit 0
