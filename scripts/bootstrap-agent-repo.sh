#!/usr/bin/env bash

# Bootstrap a repository with agent skills and repository instructions.
#
# Examples:
#   ./scripts/bootstrap-agent-repo.sh --project-path /work/app --harness claude-code --bundle starter
#   ./scripts/bootstrap-agent-repo.sh --project-path /work/app --harness codex --scope global --bundle starter --dry-run
#   ./scripts/bootstrap-agent-repo.sh --project-path /work/app --harness opencode --scope custom --target-path /tmp/skills --bundle quality

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_PATH=""
HARNESS="codex"
BUNDLE="starter"
SCOPE="auto"
TARGET_PATH=""
DRY_RUN=0
FORCE=0

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/bootstrap-agent-repo.sh --project-path PATH [options]

Options:
  --project-path PATH       Target repository root to bootstrap.
  --harness NAME            codex, claude-code, or opencode. Default: codex.
  --bundle NAME             Bundle id from catalog/bundles.tsv. Default: starter.
  --scope NAME              auto, global, project, or custom. Default: auto.
  --target-path PATH        Override the resolved skills target path.
  --dry-run                 Print planned actions without writing files.
  --force                   Overwrite installed skills and AGENTS.md where applicable.
  -h, --help                Show this help.
USAGE
}

fail() {
  echo "[ERROR] $1" >&2
  exit 1
}

info() {
  echo "[INFO] $1"
}

ok() {
  echo "[OK] $1"
}

bundle_skills() {
  local bundle_file="$REPO_ROOT/catalog/bundles/$1.txt"
  [[ -f "$bundle_file" ]] || fail "Bundle not found: $1"
  sed -e 's/[[:space:]]*$//' "$bundle_file" | grep -Ev '^[[:space:]]*(#|$)'
}

resolve_scope() {
  if [[ -n "$TARGET_PATH" ]]; then
    printf 'custom'
    return
  fi

  if [[ "$SCOPE" != "auto" ]]; then
    printf '%s' "$SCOPE"
    return
  fi

  if [[ "$HARNESS" == "codex" ]]; then
    printf 'global'
  else
    printf 'project'
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-path)
      [[ $# -ge 2 ]] || fail "--project-path requires a value"
      PROJECT_PATH="$2"
      shift 2
      ;;
    --harness)
      [[ $# -ge 2 ]] || fail "--harness requires a value"
      HARNESS="$2"
      shift 2
      ;;
    --bundle)
      [[ $# -ge 2 ]] || fail "--bundle requires a value"
      BUNDLE="$2"
      shift 2
      ;;
    --scope)
      [[ $# -ge 2 ]] || fail "--scope requires a value"
      SCOPE="$2"
      shift 2
      ;;
    --target-path)
      [[ $# -ge 2 ]] || fail "--target-path requires a value"
      TARGET_PATH="$2"
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

[[ -n "$PROJECT_PATH" ]] || { usage; fail "--project-path is required"; }
case "$HARNESS" in
  codex|claude-code|opencode) ;;
  *) fail "Unsupported harness: $HARNESS" ;;
esac
case "$SCOPE" in
  auto|global|project|custom) ;;
  *) fail "Unsupported scope: $SCOPE" ;;
esac

PROJECT_PATH="$(cd "$PROJECT_PATH" 2>/dev/null && pwd)" || fail "Project path not found: $PROJECT_PATH"
INSTALLER="$REPO_ROOT/scripts/install-skills.sh"
TEMPLATE="$REPO_ROOT/templates/project-AGENTS.md"
AGENTS_PATH="$PROJECT_PATH/AGENTS.md"
RECORD_DIR="$PROJECT_PATH/docs/agents"
RECORD_PATH="$RECORD_DIR/installed-skills.md"
EFFECTIVE_SCOPE="$(resolve_scope)"

[[ -f "$INSTALLER" ]] || fail "Installer script not found: $INSTALLER"
[[ -f "$TEMPLATE" ]] || fail "Project AGENTS.md template not found: $TEMPLATE"
mapfile -t BUNDLE_SKILLS < <(bundle_skills "$BUNDLE")

info "Project: $PROJECT_PATH"
info "Harness: $HARNESS"
info "Bundle: $BUNDLE"
info "Scope: $EFFECTIVE_SCOPE"
[[ -n "$TARGET_PATH" ]] && info "Target override: $TARGET_PATH"

installer_args=(--harness "$HARNESS" --scope "$EFFECTIVE_SCOPE" --project-path "$PROJECT_PATH" --bundle "$BUNDLE")
[[ -n "$TARGET_PATH" ]] && installer_args+=(--target-path "$TARGET_PATH")
[[ "$DRY_RUN" -eq 1 ]] && installer_args+=(--dry-run)
[[ "$FORCE" -eq 1 ]] && installer_args+=(--force)

"$INSTALLER" "${installer_args[@]}"
install_exit=$?
[[ "$install_exit" -eq 0 ]] || fail "Skill installation failed with exit code $install_exit"

if [[ "$DRY_RUN" -eq 1 ]]; then
  info "Dry run: would inspect $AGENTS_PATH"
  if [[ -f "$AGENTS_PATH" ]]; then
    if [[ "$FORCE" -eq 1 ]]; then
      info "Dry run: would replace existing AGENTS.md from template."
    else
      info "Dry run: would preserve existing AGENTS.md."
    fi
  else
    info "Dry run: would copy templates/project-AGENTS.md to AGENTS.md."
  fi
  info "Dry run: would write $RECORD_PATH"
  ok "Bootstrap dry run completed."
  exit 0
fi

if [[ -f "$AGENTS_PATH" ]]; then
  if [[ "$FORCE" -eq 1 ]]; then
    cp "$TEMPLATE" "$AGENTS_PATH"
    info "Replaced existing AGENTS.md because --force was provided."
  else
    info "Preserved existing AGENTS.md. Use --force to replace it from the template."
  fi
else
  cp "$TEMPLATE" "$AGENTS_PATH"
  ok "Created AGENTS.md from template."
fi

mkdir -p "$RECORD_DIR"
timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
{
  echo "# Installed Agent Skills"
  echo
  echo "Generated by \`scripts/bootstrap-agent-repo.sh\`."
  echo
  echo "- Harness: \`$HARNESS\`"
  echo "- Bundle: \`$BUNDLE\`"
  echo "- Scope: \`$EFFECTIVE_SCOPE\`"
  echo "- Installed at: \`$timestamp\`"
  echo
  echo "## Skills"
  echo
  for skill in "${BUNDLE_SKILLS[@]}"; do
    echo "- \`$skill\`"
  done
  echo
  echo "## Validation Notes"
  echo
  echo "- Validate the target repository after installing skills."
  echo "- Keep project-specific edits in the target repo's \`AGENTS.md\`; keep reusable workflow logic in installed skills."
  echo "- Re-run the installer with \`--dry-run\` before overwriting installed skills."
} > "$RECORD_PATH"

ok "Wrote installed skill record: $RECORD_PATH"
ok "Bootstrap completed."
