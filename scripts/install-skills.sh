#!/usr/bin/env bash

# Install skill folders into a harness-specific skills directory.
#
# Examples:
#   ./scripts/install-skills.sh --harness codex --all
#   ./scripts/install-skills.sh --harness claude-code --skills context-engineering,test-driven-development
#   ./scripts/install-skills.sh --harness opencode --all --dry-run
#   ./scripts/install-skills.sh --harness claude-code --scope project --project-path "/path/to/repo" --all
#   ./scripts/install-skills.sh --target-path "/path/to/repo/.agent/skills" --all --force

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_PATH="$REPO_ROOT/skills"
TARGET_PATH=""
HARNESS=""
SCOPE="global"
PROJECT_PATH=""
SKILLS_ARG=""
INSTALL_ALL=0
DRY_RUN=0
FORCE=0

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/install-skills.sh --harness codex|claude-code|opencode --all [--dry-run] [--force]
  ./scripts/install-skills.sh --harness codex|claude-code|opencode --skills skill-a,skill-b [--dry-run] [--force]
  ./scripts/install-skills.sh --harness claude-code|opencode --scope project --project-path PATH --all
  ./scripts/install-skills.sh --target-path PATH --all [--dry-run] [--force]

Options:
  --harness NAME       Install target profile: codex, claude-code, or opencode.
  --scope SCOPE        Target scope: global, project, or custom. Defaults to global.
  --project-path PATH  Project root for project scope.
  --target-path PATH   Explicit skills directory. Overrides harness defaults.
  --all                Install every skill under ./skills.
  --skills LIST        Comma-separated skill names to install.
  --dry-run            Print planned actions without copying files.
  --force              Replace existing target skill folders.
  -h, --help           Show this help.
USAGE
}

fail() {
  echo "[ERROR] $1" >&2
  exit 1
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

global_target_path() {
  case "$1" in
    codex)
      if [[ -n "${CODEX_HOME:-}" ]]; then
        printf '%s/skills' "$CODEX_HOME"
      else
        printf '%s/.codex/skills' "$HOME"
      fi
      ;;
    claude-code)
      printf '%s/.claude/skills' "$HOME"
      ;;
    opencode)
      printf '%s/.config/opencode/skills' "$HOME"
      ;;
    *)
      fail "Unsupported harness: $1"
      ;;
  esac
}

project_target_path() {
  local harness_name="$1"
  local project_path="$2"

  [[ -n "$project_path" ]] || fail "Project scope requires --project-path unless --target-path is provided"

  case "$harness_name" in
    claude-code)
      printf '%s/.claude/skills' "$project_path"
      ;;
    opencode)
      printf '%s/.opencode/skills' "$project_path"
      ;;
    codex)
      fail "Codex project scope has no default target. Use --target-path with the desired skills directory."
      ;;
    *)
      fail "Unsupported harness: $harness_name"
      ;;
  esac
}

resolve_target_path() {
  if [[ -n "$TARGET_PATH" ]]; then
    return 0
  fi

  [[ -n "$HARNESS" ]] || { usage; fail "Specify --target-path or provide --harness codex, claude-code, or opencode"; }
  validate_harness "$HARNESS"
  validate_scope "$SCOPE"

  case "$SCOPE" in
    global)
      TARGET_PATH="$(global_target_path "$HARNESS")"
      ;;
    project)
      TARGET_PATH="$(project_target_path "$HARNESS" "$PROJECT_PATH")"
      ;;
    custom)
      fail "Custom scope requires --target-path"
      ;;
  esac
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

resolve_target_path
[[ -d "$SOURCE_PATH" ]] || fail "Source skills directory not found: $SOURCE_PATH"

if [[ "$INSTALL_ALL" -eq 1 && -n "$SKILLS_ARG" ]]; then
  fail "Use either --all or --skills, not both"
fi

if [[ "$INSTALL_ALL" -eq 0 && -z "$SKILLS_ARG" ]]; then
  usage
  fail "Specify --all or --skills"
fi

selected_skills=()
if [[ "$INSTALL_ALL" -eq 1 ]]; then
  mapfile -t selected_skills < <(find "$SOURCE_PATH" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
else
  IFS=',' read -r -a raw_skills <<< "$SKILLS_ARG"
  for raw_skill in "${raw_skills[@]}"; do
    skill="${raw_skill#"${raw_skill%%[![:space:]]*}"}"
    skill="${skill%"${skill##*[![:space:]]}"}"
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
