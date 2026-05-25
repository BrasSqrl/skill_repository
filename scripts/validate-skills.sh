#!/usr/bin/env bash

# Validate OpenAI-style skill folders and repository metadata.
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

fail_line() {
  echo "[FAIL] $1"
}

warn_line() {
  echo "[WARN] $1"
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
  fail_line "Skills directory not found: $SKILLS_PATH"
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

required_catalog_columns=(
  "name"
  "category"
  "maturity"
  "source"
  "license"
  "harnesses"
  "upstream_repo"
  "upstream_ref"
  "upstream_path"
  "import_mode"
  "description"
)

mapfile -t skill_dirs < <(find "$SKILLS_PATH" -mindepth 1 -maxdepth 1 -type d | sort)

if [[ ${#skill_dirs[@]} -eq 0 ]]; then
  fail_line "No skill folders found under: $SKILLS_PATH"
  exit 1
fi

passed=0
failed=0
warnings=0

echo "[INFO] Validating ${#skill_dirs[@]} skill folder(s) in $SKILLS_PATH"

declare -A catalog_seen
declare -A catalog_source
declare -A catalog_license
declare -A catalog_upstream_repo
declare -A catalog_upstream_ref
declare -A catalog_upstream_path

CATALOG_PATH="$REPO_ROOT/catalog/skills.tsv"
if [[ ! -f "$CATALOG_PATH" ]]; then
  fail_line "Required metadata file not found: $CATALOG_PATH"
  failed=$((failed + 1))
else
  header="$(head -n 1 "$CATALOG_PATH")"
  for column in "${required_catalog_columns[@]}"; do
    if ! printf '%s\n' "$header" | tr '\t' '\n' | grep -Fxq "$column"; then
      fail_line "catalog/skills.tsv: missing required column '$column'"
      failed=$((failed + 1))
    fi
  done

  while IFS=$'\t' read -r name category maturity source license harnesses upstream_repo upstream_ref upstream_path import_mode description extra; do
    [[ "$name" == "name" ]] && continue
    [[ -n "$name" ]] || { fail_line "catalog/skills.tsv: row with empty name"; failed=$((failed + 1)); continue; }

    if [[ -n "${catalog_seen[$name]+x}" ]]; then
      fail_line "catalog/skills.tsv: duplicate skill entry '$name'"
      failed=$((failed + 1))
      continue
    fi

    catalog_seen["$name"]=1
    catalog_source["$name"]="$source"
    catalog_license["$name"]="$license"
    catalog_upstream_repo["$name"]="${upstream_repo:-}"
    catalog_upstream_ref["$name"]="${upstream_ref:-}"
    catalog_upstream_path["$name"]="${upstream_path:-}"

    if [[ ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
      fail_line "catalog/skills.tsv: skill '$name' must use lowercase kebab-case"
      failed=$((failed + 1))
    fi

    for value_name in category maturity source license harnesses import_mode description; do
      case "$value_name" in
        category) value="$category" ;;
        maturity) value="$maturity" ;;
        source) value="$source" ;;
        license) value="$license" ;;
        harnesses) value="$harnesses" ;;
        import_mode) value="$import_mode" ;;
        description) value="$description" ;;
      esac
      if [[ -z "$(trim "$value")" ]]; then
        fail_line "catalog/skills.tsv: '$name' is missing required metadata '$value_name'"
        failed=$((failed + 1))
      fi
    done
  done < "$CATALOG_PATH"
fi

for skill_dir in "${skill_dirs[@]}"; do
  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"
  skill_failed=0

  if [[ ! "$skill_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    fail_line "$skill_name: folder name must use lowercase kebab-case"
    skill_failed=1
  fi

  if [[ -z "${catalog_seen[$skill_name]+x}" ]]; then
    fail_line "$skill_name: missing catalog entry in catalog/skills.tsv"
    skill_failed=1
  fi

  if [[ ! -f "$skill_file" ]]; then
    fail_line "$skill_name: missing SKILL.md"
    failed=$((failed + 1))
    continue
  fi

  first_line="$(sed -n '1p' "$skill_file")"
  if [[ "$first_line" != "---" ]]; then
    fail_line "$skill_name: missing YAML frontmatter opening marker"
    failed=$((failed + 1))
    continue
  fi

  closing_line="$(awk 'NR > 1 && $0 ~ /^---[[:space:]]*$/ { print NR; exit }' "$skill_file")"
  if [[ -z "$closing_line" ]]; then
    fail_line "$skill_name: missing YAML frontmatter closing marker"
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
    fail_line "$skill_name: frontmatter is missing name"
    skill_failed=1
  elif [[ "$name" != "$skill_name" ]]; then
    warn_line "$skill_name: frontmatter name '$name' does not match folder name"
    warnings=$((warnings + 1))
  fi

  if [[ -z "$description" ]]; then
    fail_line "$skill_name: frontmatter description is empty or missing"
    skill_failed=1
  else
    if [[ ${#description} -lt 80 ]]; then
      fail_line "$skill_name: description is too short to be useful; use at least 80 characters"
      skill_failed=1
    fi
    if [[ ! "$description" =~ Use[[:space:]](when|before|for|at) ]]; then
      fail_line "$skill_name: description must include specific trigger language such as 'Use when', 'Use before', or 'Use for'"
      skill_failed=1
    fi
  fi

  for section in "${required_sections[@]}"; do
    if ! grep -Eq "^## ${section}[[:space:]]*$" "$skill_file"; then
      fail_line "$skill_name: missing required section '## $section'"
      skill_failed=1
    fi
  done

  while IFS= read -r child_dir; do
    child_name="$(basename "$child_dir")"
    case "$child_name" in
      references|scripts|assets|agents) ;;
      *)
        fail_line "$skill_name: unexpected resource folder '$child_name'"
        skill_failed=1
        ;;
    esac
  done < <(find "$skill_dir" -mindepth 1 -maxdepth 1 -type d | sort)

  if [[ -d "$skill_dir/references" ]] && ! grep -q 'references/' "$skill_file"; then
    fail_line "$skill_name: references folder exists but SKILL.md does not link to it"
    skill_failed=1
  fi

  while IFS= read -r reference_path; do
    reference_path="${reference_path%%#*}"
    [[ -n "$reference_path" ]] || continue
    if [[ ! -f "$skill_dir/$reference_path" ]]; then
      fail_line "$skill_name: missing linked reference '$reference_path'"
      skill_failed=1
    fi
  done < <(grep -Eo 'references/[^`) ]+' "$skill_file" | sort -u || true)

  if [[ "${catalog_source[$skill_name]:-}" == "third-party" ]]; then
    if [[ -z "${catalog_license[$skill_name]:-}" || "${catalog_license[$skill_name]:-}" == "repo-tbd" ]]; then
      fail_line "$skill_name: third-party catalog entry must include a concrete license"
      skill_failed=1
    fi
    if [[ ! -f "$skill_dir/LICENSE" ]]; then
      fail_line "$skill_name: third-party skill is missing local LICENSE file"
      skill_failed=1
    fi
    for optional_value in upstream_repo upstream_ref upstream_path; do
      case "$optional_value" in
        upstream_repo) value="${catalog_upstream_repo[$skill_name]:-}" ;;
        upstream_ref) value="${catalog_upstream_ref[$skill_name]:-}" ;;
        upstream_path) value="${catalog_upstream_path[$skill_name]:-}" ;;
      esac
      if [[ -z "$value" || "$value" == "unavailable" ]]; then
        warn_line "$skill_name: optional upstream tracking '$optional_value' is incomplete"
        warnings=$((warnings + 1))
      fi
    done
  fi

  if [[ "$skill_failed" -eq 1 ]]; then
    failed=$((failed + 1))
  else
    echo "[PASS] $skill_name"
    passed=$((passed + 1))
  fi
done

for catalog_name in "${!catalog_seen[@]}"; do
  if [[ ! -d "$SKILLS_PATH/$catalog_name" ]]; then
    fail_line "catalog/skills.tsv: entry '$catalog_name' has no matching skill folder"
    failed=$((failed + 1))
  fi
done

BUNDLE_CATALOG="$REPO_ROOT/catalog/bundles.tsv"
BUNDLE_DIR="$REPO_ROOT/catalog/bundles"
declare -A bundle_seen
if [[ ! -f "$BUNDLE_CATALOG" ]]; then
  fail_line "Required metadata file not found: $BUNDLE_CATALOG"
  failed=$((failed + 1))
else
  bundle_header="$(head -n 1 "$BUNDLE_CATALOG")"
  for column in id label purpose recommendation; do
    if ! printf '%s\n' "$bundle_header" | tr '\t' '\n' | grep -Fxq "$column"; then
      fail_line "catalog/bundles.tsv: missing required column '$column'"
      failed=$((failed + 1))
    fi
  done

  while IFS=$'\t' read -r id label purpose recommendation extra; do
    [[ "$id" == "id" ]] && continue
    [[ -n "$id" ]] || { fail_line "catalog/bundles.tsv: row with empty id"; failed=$((failed + 1)); continue; }
    bundle_seen["$id"]=1

    if [[ ! "$id" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
      fail_line "catalog/bundles.tsv: bundle '$id' must use lowercase kebab-case"
      failed=$((failed + 1))
    fi
    for value_name in label purpose recommendation; do
      case "$value_name" in
        label) value="$label" ;;
        purpose) value="$purpose" ;;
        recommendation) value="$recommendation" ;;
      esac
      if [[ -z "$(trim "$value")" ]]; then
        fail_line "catalog/bundles.tsv: '$id' is missing '$value_name'"
        failed=$((failed + 1))
      fi
    done

    bundle_file="$BUNDLE_DIR/$id.txt"
    if [[ ! -f "$bundle_file" ]]; then
      fail_line "catalog/bundles: missing bundle file '$id.txt'"
      failed=$((failed + 1))
      continue
    fi

    declare -A bundle_skill_seen=()
    while IFS= read -r bundle_skill; do
      bundle_skill="$(trim "$bundle_skill")"
      [[ -n "$bundle_skill" && ! "$bundle_skill" =~ ^# ]] || continue
      if [[ -n "${bundle_skill_seen[$bundle_skill]+x}" ]]; then
        warn_line "$id: duplicate bundle skill '$bundle_skill'"
        warnings=$((warnings + 1))
      fi
      bundle_skill_seen["$bundle_skill"]=1
      if [[ -z "${catalog_seen[$bundle_skill]+x}" ]]; then
        fail_line "$id: bundle references unknown skill '$bundle_skill'"
        failed=$((failed + 1))
      fi
    done < "$bundle_file"
  done < "$BUNDLE_CATALOG"
fi

if [[ ! -d "$BUNDLE_DIR" ]]; then
  fail_line "Bundle directory not found: $BUNDLE_DIR"
  failed=$((failed + 1))
else
  while IFS= read -r bundle_file; do
    bundle_file_id="$(basename "$bundle_file" .txt)"
    if [[ -z "${bundle_seen[$bundle_file_id]+x}" ]]; then
      fail_line "catalog/bundles: '$(basename "$bundle_file")' has no matching row in bundles.tsv"
      failed=$((failed + 1))
    fi
  done < <(find "$BUNDLE_DIR" -mindepth 1 -maxdepth 1 -type f -name '*.txt' | sort)
fi

HARNESS_DIR="$REPO_ROOT/harnesses"
required_profile_keys=(id label global_env global_suffix global_default project_subpath supports_project_default skills_format instructions_file)
for profile_name in codex claude-code opencode; do
  profile_path="$HARNESS_DIR/$profile_name.profile"
  if [[ ! -f "$profile_path" ]]; then
    fail_line "Required profile file not found: $profile_path"
    failed=$((failed + 1))
    continue
  fi
  for key in "${required_profile_keys[@]}"; do
    if ! grep -Eq "^${key}=" "$profile_path"; then
      fail_line "harnesses/$profile_name.profile: missing '$key'"
      failed=$((failed + 1))
    fi
  done
  profile_id="$(grep -E '^id=' "$profile_path" | head -n 1 | cut -d= -f2-)"
  if [[ "$profile_id" != "$profile_name" ]]; then
    fail_line "harnesses/$profile_name.profile: id '$profile_id' does not match file name"
    failed=$((failed + 1))
  fi
done

NOTICES_PATH="$REPO_ROOT/THIRD_PARTY_NOTICES.md"
third_party_count=0
for catalog_name in "${!catalog_seen[@]}"; do
  if [[ "${catalog_source[$catalog_name]:-}" == "third-party" ]]; then
    third_party_count=$((third_party_count + 1))
    if [[ -f "$NOTICES_PATH" ]]; then
      if ! grep -Fq "$catalog_name" "$NOTICES_PATH"; then
        fail_line "THIRD_PARTY_NOTICES.md: missing notice entry for third-party skill '$catalog_name'"
        failed=$((failed + 1))
      fi
    fi
  fi
done
if [[ "$third_party_count" -gt 0 && ! -f "$NOTICES_PATH" ]]; then
  fail_line "THIRD_PARTY_NOTICES.md is required when third-party skills exist"
  failed=$((failed + 1))
fi

echo
echo "Validation summary:"
echo "  Passed:   $passed"
echo "  Failed:   $failed"
echo "  Warnings: $warnings"

if [[ "$failed" -gt 0 ]]; then
  exit 1
fi

exit 0
