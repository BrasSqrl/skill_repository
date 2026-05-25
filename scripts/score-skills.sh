#!/usr/bin/env bash

# Score skill quality signals. Scores are advisory; run validate-skills before
# publishing or installing broadly.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_PATH="$REPO_ROOT/skills"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/score-skills.sh [--skills-path PATH]

Options:
  --skills-path PATH   Skills directory to score. Defaults to ./skills.
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

[[ -d "$SKILLS_PATH" ]] || { echo "[ERROR] Skills directory not found: $SKILLS_PATH" >&2; exit 1; }

deprecated_license_placeholder="repo""-tbd"

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

declare -A catalog_seen
declare -A catalog_source
declare -A catalog_license

CATALOG_PATH="$REPO_ROOT/catalog/skills.tsv"
if [[ -f "$CATALOG_PATH" ]]; then
  while IFS=$'\t' read -r name category maturity source license harnesses upstream_repo upstream_ref upstream_path import_mode description extra; do
    [[ "$name" == "name" || -z "$name" ]] && continue
    catalog_seen["$name"]=1
    catalog_source["$name"]="$source"
    catalog_license["$name"]="$license"
  done < "$CATALOG_PATH"
fi

NOTICES_PATH="$REPO_ROOT/THIRD_PARTY_NOTICES.md"
printf '%-38s %5s  %s\n' "Skill" "Score" "Notes"
printf '%-38s %5s  %s\n' "-----" "-----" "-----"

total=0
count=0
below=0

mapfile -t skill_dirs < <(find "$SKILLS_PATH" -mindepth 1 -maxdepth 1 -type d | sort)
for skill_dir in "${skill_dirs[@]}"; do
  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"
  score=0
  notes=()

  if [[ ! -f "$skill_file" ]]; then
    printf '%-38s %5s  %s\n' "$skill_name" "0" "missing SKILL.md"
    count=$((count + 1))
    below=$((below + 1))
    continue
  fi

  first_line="$(sed -n '1p' "$skill_file")"
  closing_line="$(awk 'NR > 1 && $0 ~ /^---[[:space:]]*$/ { print NR; exit }' "$skill_file")"
  if [[ "$first_line" == "---" && -n "$closing_line" ]]; then
    score=$((score + 10))
    frontmatter="$(sed -n "2,$((closing_line - 1))p" "$skill_file")"
    description_line="$(printf '%s\n' "$frontmatter" | grep -E '^description:[[:space:]]*' | head -n 1 || true)"
    description="$(trim "${description_line#description:}")"
    description="${description%\"}"
    description="${description#\"}"

    if [[ -n "$description" ]]; then
      if [[ ${#description} -ge 120 ]]; then
        score=$((score + 12))
      elif [[ ${#description} -ge 80 ]]; then
        score=$((score + 8))
      else
        score=$((score + 4))
        notes+=("short description")
      fi

      if [[ "$description" =~ Use[[:space:]](when|before|for|at) ]]; then
        score=$((score + 8))
      else
        notes+=("weak trigger")
      fi
    else
      notes+=("missing description")
    fi
  else
    notes+=("missing frontmatter")
  fi

  section_score=0
  for section in "${required_sections[@]}"; do
    if grep -Eq "^## ${section}[[:space:]]*$" "$skill_file"; then
      section_score=$((section_score + 3))
    else
      notes+=("missing $section")
    fi
  done
  (( section_score > 25 )) && section_score=25
  score=$((score + section_score))

  if grep -Eq '^## Quality Gates[[:space:]]*$' "$skill_file"; then
    score=$((score + 10))
  else
    notes+=("weak quality gates")
  fi

  if grep -Eq '^## Output Format[[:space:]]*$' "$skill_file"; then
    score=$((score + 10))
  else
    notes+=("weak output format")
  fi

  if [[ -d "$skill_dir/references" ]]; then
    if grep -q 'references/' "$skill_file"; then
      score=$((score + 8))
    else
      notes+=("references not linked")
    fi
  else
    score=$((score + 6))
  fi

  if [[ -n "${catalog_seen[$skill_name]+x}" ]]; then
    score=$((score + 10))
    if [[ "${catalog_source[$skill_name]:-}" == "third-party" ]]; then
      if [[ "${catalog_license[$skill_name]:-}" != "" && "${catalog_license[$skill_name]:-}" != "$deprecated_license_placeholder" && -f "$skill_dir/LICENSE" && -f "$NOTICES_PATH" ]] && grep -Fq "$skill_name" "$NOTICES_PATH"; then
        score=$((score + 7))
      else
        notes+=("third-party traceability gap")
      fi
    else
      score=$((score + 7))
    fi
  else
    notes+=("missing catalog entry")
  fi

  (( score > 100 )) && score=100
  [[ "$score" -lt 80 ]] && below=$((below + 1))
  total=$((total + score))
  count=$((count + 1))
  if [[ ${#notes[@]} -eq 0 ]]; then
    note_text="ok"
  else
    note_text="$(IFS='; '; echo "${notes[*]}")"
  fi
  printf '%-38s %5s  %s\n' "$skill_name" "$score" "$note_text"
done

average="0"
if [[ "$count" -gt 0 ]]; then
  average="$(awk -v total="$total" -v count="$count" 'BEGIN { printf "%.1f", total / count }')"
fi

echo
echo "Skill quality scoring summary:"
echo "  Skills:  $count"
echo "  Average: $average"
echo "  Below 80: $below"
echo
echo "Scores are advisory. Run validate-skills before publishing."

exit 0
