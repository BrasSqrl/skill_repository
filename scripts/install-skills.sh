#!/usr/bin/env bash

# Install skill folders into a harness-specific skills directory.
#
# Examples:
#   ./scripts/install-skills.sh --harness codex --bundle starter
#   ./scripts/install-skills.sh --harness claude-code --skills context-engineering,test-driven-development
#   ./scripts/install-skills.sh --harness opencode --all --dry-run
#   ./scripts/install-skills.sh --list-bundles
#   ./scripts/install-skills.sh --list-skills

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_PATH="$REPO_ROOT/skills"
TARGET_PATH=""
HARNESS=""
SCOPE="global"
PROJECT_PATH=""
SKILLS_ARG=""
BUNDLE=""
INSTALL_ALL=0
DRY_RUN=0
FORCE=0
LIST_BUNDLES=0
LIST_SKILLS=0

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/install-skills.sh --harness codex|claude-code|opencode --bundle NAME [--dry-run] [--force]
  ./scripts/install-skills.sh --harness codex|claude-code|opencode --all [--dry-run] [--force]
  ./scripts/install-skills.sh --harness codex|claude-code|opencode --skills skill-a,skill-b [--dry-run] [--force]
  ./scripts/install-skills.sh --harness claude-code|opencode --scope project --project-path PATH --bundle starter
  ./scripts/install-skills.sh --target-path PATH --bundle starter [--dry-run] [--force]
  ./scripts/install-skills.sh --list-bundles
  ./scripts/install-skills.sh --list-skills

Options:
  --harness NAME       Install target profile: codex, claude-code, or opencode.
  --scope SCOPE        Target scope: global, project, or custom. Defaults to global.
  --project-path PATH  Project root for project scope.
  --target-path PATH   Explicit skills directory. Overrides harness defaults.
  --all                Install every skill under ./skills.
  --skills LIST        Comma-separated skill names to install.
  --bundle NAME        Install a named bundle from ./catalog/bundles.
  --list-bundles       Print available bundles.
  --list-skills        Print cataloged skills.
  --dry-run            Print planned actions without copying files.
  --force              Replace existing target skill folders.
  -h, --help           Show this help.
USAGE
}

fail() {
  echo "[ERROR] $1" >&2
  exit 1
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

validate_harness() {
  case "$1" in
    codex|claude-code|opencode) ;;
    *) fail "Unsupported harness: $1" ;;
  esac
}

validate_scope() {
  case "$1" in
    global|project|custom) ;;
    *) fail "Unsupported scope: $1" ;;
  esac
}

profile_value() {
  local profile_path="$1"
  local key="$2"
  local line
  line="$(grep -E "^${key}=" "$profile_path" | head -n 1 || true)"
  printf '%s' "${line#*=}"
}

join_portable_path() {
  local base="$1"
  local relative="$2"
  relative="${relative//\\//}"
  if [[ -z "$relative" ]]; then
    printf '%s' "$base"
  else
    printf '%s/%s' "${base%/}" "${relative#/}"
  fi
}

resolve_target_path() {
  if [[ -n "$TARGET_PATH" ]]; then
    return 0
  fi

  [[ -n "$HARNESS" ]] || { usage; fail "Specify --target-path or provide --harness codex, claude-code, or opencode"; }
  validate_harness "$HARNESS"
  validate_scope "$SCOPE"

  local profile_path="$REPO_ROOT/harnesses/$HARNESS.profile"
  [[ -f "$profile_path" ]] || fail "Harness profile not found: $profile_path"

  local profile_id
  profile_id="$(profile_value "$profile_path" "id")"
  [[ "$profile_id" == "$HARNESS" ]] || fail "Harness profile id '$profile_id' does not match '$HARNESS'"

  case "$SCOPE" in
    global)
      local global_env global_suffix global_default env_value
      global_env="$(profile_value "$profile_path" "global_env")"
      global_suffix="$(profile_value "$profile_path" "global_suffix")"
      global_default="$(profile_value "$profile_path" "global_default")"
      if [[ -n "$global_env" ]]; then
        env_value="${!global_env:-}"
        if [[ -n "$env_value" ]]; then
          TARGET_PATH="$(join_portable_path "$env_value" "$global_suffix")"
          return 0
        fi
      fi
      TARGET_PATH="$(join_portable_path "$HOME" "$global_default")"
      ;;
    project)
      local supports_project project_subpath
      supports_project="$(profile_value "$profile_path" "supports_project_default")"
      project_subpath="$(profile_value "$profile_path" "project_subpath")"
      [[ "$supports_project" == "true" ]] || fail "$(profile_value "$profile_path" "label") project scope has no default target. Use --target-path with the desired skills directory."
      [[ -n "$PROJECT_PATH" ]] || fail "Project scope requires --project-path unless --target-path is provided"
      TARGET_PATH="$(join_portable_path "$PROJECT_PATH" "$project_subpath")"
      ;;
    custom)
      fail "Custom scope requires --target-path"
      ;;
  esac
}

show_bundles() {
  local file="$REPO_ROOT/catalog/bundles.tsv"
  [[ -f "$file" ]] || fail "Bundle catalog not found: $file"
  awk -F '\t' 'NR == 1 { next } { printf "%-24s %-24s %s\n", $1, $2, $4 }' "$file"
}

show_skills() {
  local file="$REPO_ROOT/catalog/skills.tsv"
  [[ -f "$file" ]] || fail "Skill catalog not found: $file"
  awk -F '\t' 'NR == 1 { next } { printf "%-36s %-22s %-8s %-12s %s\n", $1, $2, $3, $4, $11 }' "$file"
}

bundle_skills() {
  local bundle_name="$1"
  [[ "$bundle_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "Invalid bundle name '$bundle_name'. Bundle names must use lowercase kebab-case."
  local bundle_path="$REPO_ROOT/catalog/bundles/$bundle_name.txt"
  [[ -f "$bundle_path" ]] || fail "Bundle not found: $bundle_name"
  grep -Ev '^[[:space:]]*(#|$)' "$bundle_path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --harness)
      [[ $# -ge 2 ]] || fail "--harness requires a value"
      HARNESS="$2"
      validate_harness "$HARNESS"
      shift 2
      ;;
    --scope)
      [[ $# -ge 2 ]] || fail "--scope requires a value"
      SCOPE="$2"
      validate_scope "$SCOPE"
      shift 2
      ;;
    --project-path)
      [[ $# -ge 2 ]] || fail "--project-path requires a value"
      PROJECT_PATH="$2"
      shift 2
      ;;
    --target-path|-t)
      [[ $# -ge 2 ]] || fail "--target-path requires a value"
      TARGET_PATH="$2"
      shift 2
      ;;
    --all)
      INSTALL_ALL=1
      shift
      ;;
    --skills)
      [[ $# -ge 2 ]] || fail "--skills requires a value"
      SKILLS_ARG="$2"
      shift 2
      ;;
    --bundle)
      [[ $# -ge 2 ]] || fail "--bundle requires a value"
      BUNDLE="$2"
      shift 2
      ;;
    --list-bundles)
      LIST_BUNDLES=1
      shift
      ;;
    --list-skills)
      LIST_SKILLS=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

if [[ "$LIST_BUNDLES" -eq 1 ]]; then
  show_bundles
  exit 0
fi

if [[ "$LIST_SKILLS" -eq 1 ]]; then
  show_skills
  exit 0
fi

resolve_target_path
[[ -d "$SOURCE_PATH" ]] || fail "Source skills directory not found: $SOURCE_PATH"

selector_count=0
[[ "$INSTALL_ALL" -eq 1 ]] && selector_count=$((selector_count + 1))
[[ -n "$SKILLS_ARG" ]] && selector_count=$((selector_count + 1))
[[ -n "$BUNDLE" ]] && selector_count=$((selector_count + 1))
[[ "$selector_count" -eq 1 ]] || { usage; fail "Specify exactly one selector: --all, --skills, or --bundle"; }

selected_skills=()
if [[ "$INSTALL_ALL" -eq 1 ]]; then
  mapfile -t selected_skills < <(find "$SOURCE_PATH" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
elif [[ -n "$BUNDLE" ]]; then
  mapfile -t selected_skills < <(bundle_skills "$BUNDLE")
else
  IFS=',' read -r -a raw_skills <<< "$SKILLS_ARG"
  for raw_skill in "${raw_skills[@]}"; do
    skill="$(trim "$raw_skill")"
    [[ -n "$skill" ]] && selected_skills+=("$skill")
  done
fi

[[ ${#selected_skills[@]} -gt 0 ]] || fail "No skills selected"

for skill in "${selected_skills[@]}"; do
  [[ "$skill" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "Invalid skill name '$skill'. Skill names must use lowercase kebab-case."
  [[ -d "$SOURCE_PATH/$skill" ]] || fail "Source skill not found: $skill"
  [[ -f "$SOURCE_PATH/$skill/SKILL.md" ]] || fail "Source skill '$skill' is missing SKILL.md"
done

echo "[INFO] Source: $SOURCE_PATH"
if [[ -n "$HARNESS" ]]; then
  echo "[INFO] Harness: $HARNESS"
  echo "[INFO] Scope: $SCOPE"
fi
if [[ -n "$BUNDLE" ]]; then
  echo "[INFO] Bundle: $BUNDLE"
fi
echo "[INFO] Target: $TARGET_PATH"
echo "[INFO] Selected skills: ${selected_skills[*]}"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[INFO] Dry run mode: no files will be copied."
else
  mkdir -p "$TARGET_PATH" || fail "Could not create target directory: $TARGET_PATH"
fi

blocked=()
for skill in "${selected_skills[@]}"; do
  if [[ -e "$TARGET_PATH/$skill" && "$FORCE" -eq 0 ]]; then
    blocked+=("$skill")
  fi
done

if [[ ${#blocked[@]} -gt 0 && "$DRY_RUN" -eq 1 ]]; then
  echo "[INFO] Dry run found existing target skill folder(s) that would be skipped without --force: ${blocked[*]}"
elif [[ ${#blocked[@]} -gt 0 ]]; then
  fail "Target already contains skill folder(s): ${blocked[*]}. Re-run with --force to overwrite."
fi

target_abs=""
if [[ "$DRY_RUN" -eq 0 ]]; then
  target_abs="$(cd "$TARGET_PATH" && pwd -P)" || fail "Could not resolve target directory: $TARGET_PATH"
fi

for skill in "${selected_skills[@]}"; do
  src="$SOURCE_PATH/$skill"
  dest="$TARGET_PATH/$skill"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ -e "$dest" && "$FORCE" -eq 1 ]]; then
      echo "[INFO] Would replace: $dest"
    elif [[ -e "$dest" ]]; then
      echo "[INFO] Would skip existing '$skill' at '$dest'"
      continue
    fi
    echo "[INFO] Would copy '$skill' to '$dest'"
    continue
  fi

  if [[ -e "$dest" && "$FORCE" -eq 1 ]]; then
    dest_parent="$(cd "$(dirname "$dest")" && pwd -P)" || fail "Could not resolve destination parent for: $dest"
    dest_abs="$dest_parent/$(basename "$dest")"
    case "$dest_abs/" in
      "$target_abs"/*) ;;
      *) fail "Refusing to remove path outside target directory: $dest_abs" ;;
    esac

    rm -rf -- "$dest" || fail "Could not remove existing skill: $dest"
    echo "[INFO] Removed existing skill: $dest"
  fi

  cp -R "$src" "$TARGET_PATH/" || fail "Could not copy skill: $skill"
  echo "[OK] Installed $skill"
done

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[OK] Dry run completed successfully."
else
  echo "[OK] Installed ${#selected_skills[@]} skill(s) into $TARGET_PATH"
fi

exit 0
