# Claude Code Persona Profiles
# Source this file in your .zshrc:
#   source ~/xword/claude_personas/shell_functions.sh

CLAUDE_PERSONAS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

_claude_persona() {
  local name="$1" bg="$2" fg="$3" file="$4"
  shift 4
  # Remaining args are CLI flags passed to claude
  local prompt_file="${CLAUDE_PERSONAS_DIR}/${file}"

  if [[ ! -f "$prompt_file" ]]; then
    echo "Persona file not found: $prompt_file"
    return 1
  fi

  # Auto-cd into project dir when called from home
  if [[ "$PWD" == "$HOME" ]]; then
    cd ~/xword || return 1
  fi

  echo -ne "\033]0;Claude: ${name}\007"
  printf '\e]1337;SetBadge=%s\a' $(echo -n "$name" | base64)
  printf '\e]10;%s\a' "$fg"
  printf '\e]11;%s\a' "$bg"

  claude "$@" --system-prompt "$(cat "$prompt_file")"

  # Reset on exit
  printf '\e]10;#e0e0e0\a'
  printf '\e]11;#1a1a1a\a'
  printf '\e]1337;SetBadge=%s\a' $(echo -n "" | base64)
  echo -ne "\033]0;\007"
}

# Planner: Opus for deep reasoning, skip permission prompts
claude-plan() {
  _claude_persona "Planner" "#2d1b1b" "#e0e0e0" "planner.md" \
    --dangerously-skip-permissions --model opus
}

# Builder: full access, no permission prompts, Sonnet for speed
claude-build() {
  _claude_persona "Builder" "#2d2b1b" "#e0e0e0" "builder.md" \
    --dangerously-skip-permissions
}

# Deployer: full access, no permission prompts
claude-deploy() {
  _claude_persona "Deployer" "#1b2d1b" "#e0e0e0" "deployer.md" \
    --dangerously-skip-permissions
}
