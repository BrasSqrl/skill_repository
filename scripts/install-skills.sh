#!/usr/bin/env bash

# Install skill folders and optional subagent definitions into harness targets.
#
# Examples:
#   ./scripts/install-skills.sh --harness codex --bundle starter
#   ./scripts/install-skills.sh --harness claude-code --bundle starter --include-agents
#   ./scripts/install-skills.sh --harness opencode --bundle security --include-agents --agent-bundle security-review
#   ./scripts/install-skills.sh --list-agents

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_PATH="$REPO_ROOT/skills"
AGENT_SOURCE_PATH="$REPO_ROOT/agents"
TARGET_PATH=""
AGENT_TARGET_PATH=""
HARNESS=""
SCOPE="global"
PROJECT_PATH=""
SKILLS_ARG=""
BUNDLE=""
INSTALL_ALL=0
INCLUDE_AGENTS=0
AGENTS_ARG=""
AGENT_BUNDLE=""
DRY_RUN=0
FORCE=0
LIST_BUNDLES=0
LIST_SKILLS=0
LIST_AGENTS=0
LIST_AGENT_BUNDLES=0

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/install-skills.sh --harness codex|claude-code|opencode --bundle NAME [--include-agents] [--dry-run] [--force]
  ./scripts/install-skills.sh --harness codex|claude-code|opencode --all [--include-agents] [--dry-run] [--force]
  ./scripts/install-skills.sh --harness codex|claude-code|opencode --skills skill-a,skill-b [--dry-run] [--force]
  ./scripts/install-skills.sh --harness claude-code|opencode --scope project --project-path PATH --bundle starter --include-agents
  ./scripts/install-skills.sh --target-path PATH --bundle starter [--dry-run] [--force]
  ./scripts/install-skills.sh --list-bundles
  ./scripts/install-skills.sh --list-skills
  ./scripts/install-skills.sh --list-agent-bundles
  ./scripts/install-skills.sh --list-agents

Options:
  --harness NAME          Install target profile: codex, claude-code, or opencode.
  --scope SCOPE           Target scope: global, project, or custom. Defaults to global.
  --project-path PATH     Project root for project scope.
  --target-path PATH      Explicit skills directory. Overrides harness skill defaults.
  --agent-target-path PATH Explicit native agent directory.
  --all                   Install every skill under ./skills.
  --skills LIST           Comma-separated skill names to install.
  --bundle NAME           Install a named skill bundle from ./catalog/bundles.
  --include-agents        Install or report subagent definitions for the selected harness.
  --agents LIST           Comma-separated agent names to install. Requires --include-agents.
  --agent-bundle NAME     Install a named agent bundle. Requires --include-agents.
  --list-bundles          Print available skill bundles.
  --list-skills           Print cataloged skills.
  --list-agent-bundles    Print available agent bundles.
  --list-agents           Print cataloged agents.
  --dry-run               Print planned actions without copying files.
  --force                 Replace existing target skill folders and agent files.
  -h, --help              Show this help.
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

resolve_agent_target_path() {
  local profile_path="$REPO_ROOT/harnesses/$HARNESS.profile"
  local agent_support
  agent_support="$(profile_value "$profile_path" "agent_support")"
  if [[ "$agent_support" != "native" ]]; then
    AGENT_TARGET_PATH=""
    return 0
  fi

  if [[ -n "$AGENT_TARGET_PATH" ]]; then
    return 0
  fi

  case "$SCOPE" in
    global)
      local agent_env agent_suffix agent_default env_value
      agent_env="$(profile_value "$profile_path" "agent_global_env")"
      agent_suffix="$(profile_value "$profile_path" "agent_global_suffix")"
      agent_default="$(profile_value "$profile_path" "agent_global_default")"
      if [[ -n "$agent_env" ]]; then
        env_value="${!agent_env:-}"
        if [[ -n "$env_value" ]]; then
          AGENT_TARGET_PATH="$(join_portable_path "$env_value" "$agent_suffix")"
          return 0
        fi
      fi
      AGENT_TARGET_PATH="$(join_portable_path "$HOME" "$agent_default")"
      ;;
    project)
      local supports_agent agent_project_subpath
      supports_agent="$(profile_value "$profile_path" "supports_agent_project_default")"
      agent_project_subpath="$(profile_value "$profile_path" "agent_project_subpath")"
      [[ "$supports_agent" == "true" ]] || fail "$(profile_value "$profile_path" "label") project scope has no native agent target."
      [[ -n "$PROJECT_PATH" ]] || fail "Agent project scope requires --project-path unless --agent-target-path is provided"
      AGENT_TARGET_PATH="$(join_portable_path "$PROJECT_PATH" "$agent_project_subpath")"
      ;;
    custom)
      fail "Custom scope with --include-agents requires --agent-target-path for native agent harnesses"
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

show_agent_bundles() {
  local file="$REPO_ROOT/catalog/agent-bundles.tsv"
  [[ -f "$file" ]] || fail "Agent bundle catalog not found: $file"
  awk -F '\t' 'NR == 1 { next } { printf "%-24s %-24s %s\n", $1, $2, $4 }' "$file"
}

show_agents() {
  local file="$REPO_ROOT/catalog/agents.tsv"
  [[ -f "$file" ]] || fail "Agent catalog not found: $file"
  awk -F '\t' 'NR == 1 { next } { printf "%-26s %-8s %-16s %-42s %s\n", $1, $3, $6, $5, $7 }' "$file"
}

bundle_skills() {
  local bundle_name="$1"
  [[ "$bundle_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "Invalid bundle name '$bundle_name'. Bundle names must use lowercase kebab-case."
  local bundle_path="$REPO_ROOT/catalog/bundles/$bundle_name.txt"
  [[ -f "$bundle_path" ]] || fail "Bundle not found: $bundle_name"
  grep -Ev '^[[:space:]]*(#|$)' "$bundle_path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

bundle_agents() {
  local bundle_name="$1"
  [[ "$bundle_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "Invalid agent bundle name '$bundle_name'. Agent bundle names must use lowercase kebab-case."
  local bundle_path="$REPO_ROOT/catalog/agent-bundles/$bundle_name.txt"
  [[ -f "$bundle_path" ]] || fail "Agent bundle not found: $bundle_name"
  grep -Ev '^[[:space:]]*(#|$)' "$bundle_path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

default_agent_bundle() {
  local mode="$1"
  local bundle="$2"
  if [[ "$mode" == "bundle" ]]; then
    case "$bundle" in
      starter|backend|frontend|quality) printf 'starter-review' ;;
      security) printf 'security-review' ;;
      delivery) printf 'delivery-review' ;;
      agent-orchestration|all-software-dev) printf 'all-agents' ;;
      *) printf 'starter-review' ;;
    esac
    return
  fi
  printf 'starter-review'
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

agent_frontmatter_value() {
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

agent_body() {
  local file="$1"
  awk '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { in_fm = 0; body = 1; next }
    body { print }
  ' "$file"
}

render_claude_agent() {
  local file="$1"
  local name description tools skills skill body
  name="$(agent_frontmatter_value "$file" "name")"
  description="$(agent_frontmatter_value "$file" "description")"
  tools="$(agent_frontmatter_value "$file" "tools")"
  skills="$(agent_frontmatter_value "$file" "skills")"
  body="$(agent_body "$file")"
  {
    echo "---"
    echo "name: $name"
    echo "description: $description"
    [[ -n "$tools" ]] && echo "tools: $tools"
    if [[ -n "$skills" ]]; then
      echo "skills:"
      while IFS= read -r skill; do
        echo "  - $skill"
      done < <(split_csv "$skills")
    fi
    echo "---"
    echo
    printf '%s\n' "$body"
  }
}

render_opencode_agent() {
  local file="$1"
  local description body
  description="$(agent_frontmatter_value "$file" "description")"
  body="$(agent_body "$file")"
  {
    echo "---"
    echo "description: $description"
    echo "mode: subagent"
    echo "permission:"
    echo "  edit: deny"
    echo "  bash:"
    echo '    "*": ask'
    echo '    "git status*": allow'
    echo '    "git diff*": allow'
    echo '    "git log*": allow'
    echo '    "rg *": allow'
    echo '    "grep *": allow'
    echo '    "ls *": allow'
    echo "---"
    echo
    printf '%s\n' "$body"
  }
}

render_agent() {
  local file="$1"
  local format="$2"
  case "$format" in
    claude-subagent) render_claude_agent "$file" ;;
    opencode-agent) render_opencode_agent "$file" ;;
    *) fail "Unsupported native agent format: $format" ;;
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
    --agent-target-path)
      [[ $# -ge 2 ]] || fail "--agent-target-path requires a value"
      AGENT_TARGET_PATH="$2"
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
    --list-bundles)
      LIST_BUNDLES=1
      shift
      ;;
    --list-skills)
      LIST_SKILLS=1
      shift
      ;;
    --list-agents)
      LIST_AGENTS=1
      shift
      ;;
    --list-agent-bundles)
      LIST_AGENT_BUNDLES=1
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

listed=0
if [[ "$LIST_BUNDLES" -eq 1 ]]; then show_bundles; listed=1; fi
if [[ "$LIST_SKILLS" -eq 1 ]]; then show_skills; listed=1; fi
if [[ "$LIST_AGENT_BUNDLES" -eq 1 ]]; then show_agent_bundles; listed=1; fi
if [[ "$LIST_AGENTS" -eq 1 ]]; then show_agents; listed=1; fi
[[ "$listed" -eq 1 ]] && exit 0

if [[ -n "$AGENTS_ARG" || -n "$AGENT_BUNDLE" ]]; then
  [[ "$INCLUDE_AGENTS" -eq 1 ]] || fail "Agent selectors require --include-agents"
fi

resolve_target_path
[[ -d "$SOURCE_PATH" ]] || fail "Source skills directory not found: $SOURCE_PATH"

selector_count=0
[[ "$INSTALL_ALL" -eq 1 ]] && selector_count=$((selector_count + 1))
[[ -n "$SKILLS_ARG" ]] && selector_count=$((selector_count + 1))
[[ -n "$BUNDLE" ]] && selector_count=$((selector_count + 1))
[[ "$selector_count" -eq 1 ]] || { usage; fail "Specify exactly one selector: --all, --skills, or --bundle"; }

selected_skills=()
skill_selection_mode="skills"
if [[ "$INSTALL_ALL" -eq 1 ]]; then
  mapfile -t selected_skills < <(find "$SOURCE_PATH" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
  skill_selection_mode="all"
elif [[ -n "$BUNDLE" ]]; then
  mapfile -t selected_skills < <(bundle_skills "$BUNDLE")
  skill_selection_mode="bundle"
else
  mapfile -t selected_skills < <(split_csv "$SKILLS_ARG")
  skill_selection_mode="skills"
fi

[[ ${#selected_skills[@]} -gt 0 ]] || fail "No skills selected"

for skill in "${selected_skills[@]}"; do
  [[ "$skill" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "Invalid skill name '$skill'. Skill names must use lowercase kebab-case."
  [[ -d "$SOURCE_PATH/$skill" ]] || fail "Source skill not found: $skill"
  [[ -f "$SOURCE_PATH/$skill/SKILL.md" ]] || fail "Source skill '$skill' is missing SKILL.md"
done

selected_agents=()
resolved_agent_bundle=""
if [[ "$INCLUDE_AGENTS" -eq 1 ]]; then
  [[ -n "$HARNESS" ]] || fail "--include-agents requires --harness so the agent format can be resolved"
  [[ -d "$AGENT_SOURCE_PATH" ]] || fail "Source agents directory not found: $AGENT_SOURCE_PATH"
  if [[ -n "$AGENTS_ARG" && -n "$AGENT_BUNDLE" ]]; then
    fail "Specify only one agent selector: --agents or --agent-bundle"
  fi

  if [[ -n "$AGENT_BUNDLE" ]]; then
    resolved_agent_bundle="$AGENT_BUNDLE"
    mapfile -t selected_agents < <(bundle_agents "$resolved_agent_bundle")
  elif [[ -n "$AGENTS_ARG" ]]; then
    mapfile -t selected_agents < <(split_csv "$AGENTS_ARG")
  else
    resolved_agent_bundle="$(default_agent_bundle "$skill_selection_mode" "$BUNDLE")"
    mapfile -t selected_agents < <(bundle_agents "$resolved_agent_bundle")
  fi

  for agent in "${selected_agents[@]}"; do
    [[ "$agent" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "Invalid agent name '$agent'. Agent names must use lowercase kebab-case."
    [[ -f "$AGENT_SOURCE_PATH/$agent.md" ]] || fail "Source agent not found: $agent"
  done
fi

echo "[INFO] Source: $SOURCE_PATH"
if [[ -n "$HARNESS" ]]; then
  echo "[INFO] Harness: $HARNESS"
  echo "[INFO] Scope: $SCOPE"
fi
[[ -n "$BUNDLE" ]] && echo "[INFO] Bundle: $BUNDLE"
echo "[INFO] Target: $TARGET_PATH"
echo "[INFO] Selected skills: ${selected_skills[*]}"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[INFO] Dry run mode: no skill files will be copied."
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

if [[ "$INCLUDE_AGENTS" -eq 1 ]]; then
  profile_path="$REPO_ROOT/harnesses/$HARNESS.profile"
  agent_support="$(profile_value "$profile_path" "agent_support")"
  agent_format="$(profile_value "$profile_path" "agent_format")"
  echo "[INFO] Selected agents: ${selected_agents[*]}"
  [[ -n "$resolved_agent_bundle" ]] && echo "[INFO] Agent bundle: $resolved_agent_bundle"

  if [[ "$agent_support" != "native" ]]; then
    echo "[INFO] $(profile_value "$profile_path" "label") has no confirmed native subagent file target. No agent files will be copied; use bootstrap to write portable guidance docs."
  else
    resolve_agent_target_path
    echo "[INFO] Agent target: $AGENT_TARGET_PATH"
    if [[ "$DRY_RUN" -eq 0 ]]; then
      mkdir -p "$AGENT_TARGET_PATH" || fail "Could not create agent target directory: $AGENT_TARGET_PATH"
      agent_target_abs="$(cd "$AGENT_TARGET_PATH" && pwd -P)" || fail "Could not resolve agent target directory: $AGENT_TARGET_PATH"
    else
      agent_target_abs=""
    fi

    blocked_agents=()
    for agent in "${selected_agents[@]}"; do
      if [[ -e "$AGENT_TARGET_PATH/$agent.md" && "$FORCE" -eq 0 ]]; then
        blocked_agents+=("$agent")
      fi
    done

    if [[ ${#blocked_agents[@]} -gt 0 && "$DRY_RUN" -eq 1 ]]; then
      echo "[INFO] Dry run found existing target agent file(s) that would be skipped without --force: ${blocked_agents[*]}"
    elif [[ ${#blocked_agents[@]} -gt 0 ]]; then
      fail "Target already contains agent file(s): ${blocked_agents[*]}. Re-run with --force to overwrite."
    fi

    for agent in "${selected_agents[@]}"; do
      src="$AGENT_SOURCE_PATH/$agent.md"
      dest="$AGENT_TARGET_PATH/$agent.md"

      if [[ "$DRY_RUN" -eq 1 ]]; then
        if [[ -e "$dest" && "$FORCE" -eq 1 ]]; then
          echo "[INFO] Would replace agent: $dest"
        elif [[ -e "$dest" ]]; then
          echo "[INFO] Would skip existing agent '$agent' at '$dest'"
          continue
        fi
        echo "[INFO] Would render agent '$agent' to '$dest'"
        continue
      fi

      if [[ -e "$dest" && "$FORCE" -eq 1 ]]; then
        dest_parent="$(cd "$(dirname "$dest")" && pwd -P)" || fail "Could not resolve agent destination parent for: $dest"
        dest_abs="$dest_parent/$(basename "$dest")"
        case "$dest_abs/" in
          "$agent_target_abs"/*) ;;
          *) fail "Refusing to remove path outside agent target directory: $dest_abs" ;;
        esac
        rm -f -- "$dest" || fail "Could not remove existing agent: $dest"
        echo "[INFO] Removed existing agent: $dest"
      fi

      render_agent "$src" "$agent_format" > "$dest" || fail "Could not render agent: $agent"
      echo "[OK] Installed agent $agent"
    done
  fi
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[OK] Dry run completed successfully."
else
  echo "[OK] Installed ${#selected_skills[@]} skill(s) into $TARGET_PATH"
  if [[ "$INCLUDE_AGENTS" -eq 1 && -n "${AGENT_TARGET_PATH:-}" ]]; then
    echo "[OK] Installed ${#selected_agents[@]} agent(s)."
  fi
fi

exit 0
