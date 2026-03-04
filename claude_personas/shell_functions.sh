# Claude Code Persona Profiles
# Source this file in your .zshrc:
#   source ~/xword/claude_personas/shell_functions.sh

CLAUDE_PERSONAS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

_claude_profile() {
  local name="$1" bg="$2" file="$3"
  local prompt_file="${CLAUDE_PERSONAS_DIR}/${file}"

  if [[ ! -f "$prompt_file" ]]; then
    echo "Persona file not found: $prompt_file"
    return 1
  fi

  echo -ne "\033]0;Claude: ${name}\007"
  printf '\e]1337;SetBadge=%s\a' $(echo -n "$name" | base64)
  printf '\e]11;%s\a' "$bg"

  claude --system-prompt "$(cat "$prompt_file")"

  # Reset on exit
  printf '\e]11;#1a1a1a\a'
  printf '\e]1337;SetBadge=%s\a' $(echo -n "" | base64)
  echo -ne "\033]0;\007"
}

claude-pm()        { _claude_profile "PM"         "#1b2d24" "pm.md"; }
claude-review()    { _claude_profile "Reviewer"   "#2d1b1b" "reviewer.md"; }
claude-architect() { _claude_profile "Architect"  "#1b2d2d" "architect.md"; }
claude-debug()     { _claude_profile "Debugger"   "#2d2a1b" "debugger.md"; }
claude-test()      { _claude_profile "Test Writer" "#1b2d1b" "test_writer.md"; }
claude-frontend()  { _claude_profile "Frontend"   "#261b2d" "frontend.md"; }
claude-devops()    { _claude_profile "DevOps"     "#1b1b2d" "devops.md"; }
