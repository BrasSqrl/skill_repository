#!/usr/bin/env bash

# Bootstrap a repository with agent skills, optional subagents, and repository instructions.
#
# Examples:
#   ./scripts/bootstrap-agent-repo.sh --project-path /work/app --harness claude-code --bundle starter
#   ./scripts/bootstrap-agent-repo.sh --project-path /work/app --harness opencode --bundle starter --include-agents
#   ./scripts/bootstrap-agent-repo.sh --project-path /work/app --harness codex --bundle starter --include-agents --dry-run

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_PATH=""
HARNESS="codex"
BUNDLE="starter"
SCOPE="auto"
TARGET_PATH=""
AGENT_TARGET_PATH=""
INCLUDE_AGENTS=0
AGENTS_ARG=""
AGENT_BUNDLE=""
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
  --agent-target-path PATH  Override the resolved native agent target path.
  --include-agents          Install or write subagent guidance for the selected harness.
  --agents LIST             Comma-separated agent names. Requires --include-agents.
  --agent-bundle NAME       Agent bundle id. Requires --include-agents.
  --dry-run                 Print planned actions without writing files.
  --force                   Overwrite installed skills, agents, and AGENTS.md where applicable.
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

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

split_csv() {
  local input="$1"
  local raw item
  IFS=',' read -r -a raw <<< "$input"
  for item in "${raw[@]}"; do
    item="$(trim "$item")"
    [[ -n "$item" ]] && printf '%s\n' "$item"
  done
}

bundle_skills() {
  local bundle_file="$REPO_ROOT/catalog/bundles/$1.txt"
  [[ -f "$bundle_file" ]] || fail "Bundle not found: $1"
  sed -e 's/[[:space:]]*$//' "$bundle_file" | grep -Ev '^[[:space:]]*(#|$)'
}

bundle_agents() {
  local bundle_file="$REPO_ROOT/catalog/agent-bundles/$1.txt"
  [[ -f "$bundle_file" ]] || fail "Agent bundle not found: $1"
  sed -e 's/[[:space:]]*$//' "$bundle_file" | grep -Ev '^[[:space:]]*(#|$)'
}

default_agent_bundle() {
  case "$1" in
    starter) printf 'starter-review' ;;
    backend) printf 'backend-review' ;;
    frontend) printf 'frontend-review' ;;
    quality) printf 'testing-review' ;;
    security) printf 'security-review' ;;
    delivery) printf 'delivery-review' ;;
    agent-orchestration|all-software-dev) printf 'all-agents' ;;
    *) printf 'starter-review' ;;
  esac
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

write_codex_agent_guidance() {
  local target_dir="$PROJECT_PATH/docs/agents"
  local guide_source="$REPO_ROOT/docs/subagent-orchestration-guide.md"
  local guide_target="$target_dir/subagent-orchestration.md"
  local available_target="$target_dir/available-subagents.md"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    info "Dry run: would write Codex subagent guidance docs under $target_dir"
    return
  fi

  mkdir -p "$target_dir"
  if [[ -f "$guide_target" && "$FORCE" -eq 0 ]]; then
    info "Preserved existing Codex subagent orchestration guide: $guide_target"
  else
    cp "$guide_source" "$guide_target"
    ok "Wrote Codex subagent orchestration guide: $guide_target"
  fi

  if [[ -f "$available_target" && "$FORCE" -eq 0 ]]; then
    info "Preserved existing available subagents doc: $available_target"
    return
  fi

  {
    echo "# Available Subagents"
    echo
    echo "Codex does not have a confirmed native subagent file target in this repository. Use these definitions as portable delegation guidance."
    echo
    echo "## Installed Guidance Set"
    echo
    for agent in "${SELECTED_AGENTS[@]}"; do
      description="$(awk -F '\t' -v name="$agent" 'NR > 1 && $1 == name { print $7; exit }' "$REPO_ROOT/catalog/agents.tsv")"
      if [[ -n "$description" ]]; then
        echo "- \`$agent\`: $description"
      else
        echo "- \`$agent\`"
      fi
    done
    echo
    echo "## Invocation Pattern"
    echo
    echo "Ask the main agent to delegate using the named role, required inputs, forbidden actions, and expected output format from the source agent definition."
  } > "$available_target"
  ok "Wrote available subagents doc: $available_target"
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
    --agent-target-path)
      [[ $# -ge 2 ]] || fail "--agent-target-path requires a value"
      AGENT_TARGET_PATH="$2"
      shift 2
      ;;
    --include-agents)
      INCLUDE_AGENTS=1
      shift
      ;;
    --agents)
      [[ $# -ge 2 ]] || fail "--agents requires a value"
      AGENTS_ARG="$2"
      shift 2
      ;;
    --agent-bundle)
      [[ $# -ge 2 ]] || fail "--agent-bundle requires a value"
      AGENT_BUNDLE="$2"
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
if [[ -n "$AGENTS_ARG" || -n "$AGENT_BUNDLE" ]]; then
  [[ "$INCLUDE_AGENTS" -eq 1 ]] || fail "Agent selectors require --include-agents"
fi

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

SELECTED_AGENT_BUNDLE=""
SELECTED_AGENTS=()
if [[ "$INCLUDE_AGENTS" -eq 1 ]]; then
  if [[ -n "$AGENTS_ARG" && -n "$AGENT_BUNDLE" ]]; then
    fail "Specify only one agent selector: --agents or --agent-bundle"
  fi
  if [[ -n "$AGENT_BUNDLE" ]]; then
    SELECTED_AGENT_BUNDLE="$AGENT_BUNDLE"
    mapfile -t SELECTED_AGENTS < <(bundle_agents "$AGENT_BUNDLE")
  elif [[ -n "$AGENTS_ARG" ]]; then
    mapfile -t SELECTED_AGENTS < <(split_csv "$AGENTS_ARG")
  else
    SELECTED_AGENT_BUNDLE="$(default_agent_bundle "$BUNDLE")"
    mapfile -t SELECTED_AGENTS < <(bundle_agents "$SELECTED_AGENT_BUNDLE")
  fi
fi

info "Project: $PROJECT_PATH"
info "Harness: $HARNESS"
info "Bundle: $BUNDLE"
info "Scope: $EFFECTIVE_SCOPE"
[[ -n "$TARGET_PATH" ]] && info "Target override: $TARGET_PATH"
[[ "$INCLUDE_AGENTS" -eq 1 ]] && info "Include agents: ${SELECTED_AGENTS[*]}"

installer_args=(--harness "$HARNESS" --scope "$EFFECTIVE_SCOPE" --project-path "$PROJECT_PATH" --bundle "$BUNDLE")
[[ -n "$TARGET_PATH" ]] && installer_args+=(--target-path "$TARGET_PATH")
[[ -n "$AGENT_TARGET_PATH" ]] && installer_args+=(--agent-target-path "$AGENT_TARGET_PATH")
if [[ "$INCLUDE_AGENTS" -eq 1 ]]; then
  installer_args+=(--include-agents)
  [[ -n "$AGENT_BUNDLE" ]] && installer_args+=(--agent-bundle "$AGENT_BUNDLE")
  [[ -n "$AGENTS_ARG" ]] && installer_args+=(--agents "$AGENTS_ARG")
fi
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
  if [[ "$INCLUDE_AGENTS" -eq 1 && "$HARNESS" == "codex" ]]; then
    write_codex_agent_guidance
  fi
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
if [[ "$INCLUDE_AGENTS" -eq 1 && "$HARNESS" == "codex" ]]; then
  write_codex_agent_guidance
fi

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
  if [[ "$INCLUDE_AGENTS" -eq 1 ]]; then
    echo
    echo "## Agents"
    echo
    for agent in "${SELECTED_AGENTS[@]}"; do
      echo "- \`$agent\`"
    done
    if [[ -n "$SELECTED_AGENT_BUNDLE" ]]; then
      echo
      echo "- Agent bundle: \`$SELECTED_AGENT_BUNDLE\`"
    fi
  fi
  echo
  echo "## Validation Notes"
  echo
  echo "- Validate the target repository after installing skills."
  echo "- Keep project-specific edits in the target repo's \`AGENTS.md\`; keep reusable workflow logic in installed skills."
  echo "- Re-run the installer with \`--dry-run\` before overwriting installed skills or agents."
} > "$RECORD_PATH"

ok "Wrote installed skill record: $RECORD_PATH"
ok "Bootstrap completed."
