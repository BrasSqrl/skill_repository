#!/usr/bin/env bash

# Score canonical subagent quality signals. Scores are advisory; run
# validate-skills before publishing or installing broadly.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_PATH="$REPO_ROOT/agents"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/score-agents.sh [--agents-path PATH]

Options:
  --agents-path PATH   Agents directory to score. Defaults to ./agents.
  -h, --help           Show this help.
USAGE
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

frontmatter_value() {
  local file="$1"
  local key="$2"
  awk -v key="$key" '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { exit }
    in_fm && index($0, key ":") == 1 {
      value = substr($0, length(key) + 2)
      sub(/^[[:space:]]*/, "", value)
      sub(/[[:space:]]*$/, "", value)
      gsub(/^"|"$/, "", value)
      print value
      exit
    }
  ' "$file"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agents-path)
      [[ $# -ge 2 ]] || { echo "[ERROR] --agents-path requires a value" >&2; exit 1; }
      AGENTS_PATH="$2"
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

[[ -d "$AGENTS_PATH" ]] || { echo "[ERROR] Agents directory not found: $AGENTS_PATH" >&2; exit 1; }

required_sections=(
  "Use When"
  "Do Not Use When"
  "Required Inputs"
  "Workflow"
  "Allowed Actions"
  "Forbidden Actions"
  "Output Format"
  "Escalation Rules"
)

declare -A catalog_seen
if [[ -f "$REPO_ROOT/catalog/agents.tsv" ]]; then
  while IFS=$'\t' read -r name label maturity harnesses skills permission description extra; do
    [[ "$name" == "name" || -z "$name" ]] && continue
    catalog_seen["$name"]=1
  done < "$REPO_ROOT/catalog/agents.tsv"
fi

declare -A skill_seen
while IFS= read -r skill_dir; do
  skill_seen["$(basename "$skill_dir")"]=1
done < <(find "$REPO_ROOT/skills" -mindepth 1 -maxdepth 1 -type d | sort)

printf '%-28s %5s  %s\n' "Agent" "Score" "Notes"
printf '%-28s %5s  %s\n' "-----" "-----" "-----"

total=0
count=0
below=0

mapfile -t agent_files < <(find "$AGENTS_PATH" -mindepth 1 -maxdepth 1 -type f -name '*.md' | sort)
for agent_file in "${agent_files[@]}"; do
  agent_name="$(basename "$agent_file" .md)"
  score=0
  notes=()
  first_line="$(sed -n '1p' "$agent_file")"
  closing_line="$(awk 'NR > 1 && $0 ~ /^---[[:space:]]*$/ { print NR; exit }' "$agent_file")"

  if [[ "$first_line" == "---" && -n "$closing_line" ]]; then
    score=$((score + 10))
    name="$(frontmatter_value "$agent_file" "name")"
    description="$(frontmatter_value "$agent_file" "description")"
    permission="$(frontmatter_value "$agent_file" "permission")"
    skills="$(frontmatter_value "$agent_file" "skills")"

    if [[ "$name" == "$agent_name" ]]; then
      score=$((score + 8))
    else
      notes+=("name mismatch")
    fi

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

    case "$permission" in
      read-only|validation-only) score=$((score + 8)) ;;
      *) notes+=("unclear permission") ;;
    esac

    missing_skill=0
    IFS=',' read -r -a skill_list <<< "$skills"
    for skill in "${skill_list[@]}"; do
      skill="$(trim "$skill")"
      [[ -z "$skill" ]] && continue
      if [[ -z "${skill_seen[$skill]+x}" ]]; then
        missing_skill=1
      fi
    done
    if [[ "$missing_skill" -eq 0 && -n "$skills" ]]; then
      score=$((score + 10))
    else
      notes+=("missing referenced skill")
    fi
  else
    notes+=("missing frontmatter")
  fi

  section_score=0
  for section in "${required_sections[@]}"; do
    if grep -Eq "^## ${section}[[:space:]]*$" "$agent_file"; then
      section_score=$((section_score + 3))
    else
      notes+=("missing $section")
    fi
  done
  (( section_score > 24 )) && section_score=24
  score=$((score + section_score))

  if grep -Eq 'Do not edit files|Do not edit' "$agent_file"; then
    score=$((score + 8))
  else
    notes+=("weak forbidden actions")
  fi

  if grep -Eq '^## Output Format[[:space:]]*$' "$agent_file" && grep -q 'Subagent Result' "$agent_file"; then
    score=$((score + 8))
  else
    notes+=("weak output format")
  fi

  if [[ -n "${catalog_seen[$agent_name]+x}" ]]; then
    score=$((score + 12))
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
  printf '%-28s %5s  %s\n' "$agent_name" "$score" "$note_text"
done

average="0"
if [[ "$count" -gt 0 ]]; then
  average="$(awk -v total="$total" -v count="$count" 'BEGIN { printf "%.1f", total / count }')"
fi

echo
echo "Agent quality scoring summary:"
echo "  Agents:  $count"
echo "  Average: $average"
echo "  Below 80: $below"
echo
echo "Scores are advisory. Run validate-skills before publishing."

exit 0
