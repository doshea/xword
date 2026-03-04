# Claude Code Personas

A team of specialized Claude agents, each with their own role, terminal appearance, and persistent memory.

## Setup

Add these lines to your `~/.zshrc`:

```bash
# Claude Code persona profiles
source ~/xword/claude_personas/shell_functions.sh

claude-team() {
  echo ""
  echo "  Claude Persona Roster"
  echo "  ====================="
  echo ""
  echo "  claude-pm         Product manager      (green)   <- runs the show"
  echo ""
  echo "  claude-review     Code reviewer        (red)"
  echo "  claude-architect  Software architect   (teal)"
  echo "  claude-debug      Debugger             (amber)"
  echo "  claude-test       Test writer           (green)"
  echo "  claude-frontend   Frontend specialist  (purple)"
  echo "  claude-devops     DevOps engineer      (indigo)"
  echo ""
}
```

Then reload: `source ~/.zshrc`

## Usage

Type any command to launch Claude with that persona's system prompt:

```bash
claude-review      # Opens Claude as a code reviewer (red background)
claude-pm          # Opens Claude as a PM who orchestrates the other roles
claude-team        # Prints the roster of available personas
```

Each persona gets:
- **Distinct terminal background color** — so you can tell windows apart at a glance
- **iTerm2 badge** — semi-transparent role name watermarked on the terminal
- **Tab title** — shows "Claude: Reviewer", "Claude: PM", etc.
- **Persistent memory** — each role remembers context across sessions via `memory/*.md`

When you exit Claude, the terminal appearance resets to defaults.

## Terminal requirements

The background color and badge features require **iTerm2** (or another terminal that supports
`\e]11;` and `\e]1337;SetBadge`). macOS Terminal.app won't respond to these escape sequences —
the personas still work, you just won't get the visual differentiation.

## The PM

`claude-pm` is the orchestrator. Give it a project and it will:

1. **Discover** — clarify requirements, identify affected code
2. **Plan** — call in the Architect, break work into tasks
3. **Implement** — work through tasks, calling in Frontend/Debugger as needed
4. **Test** — call in the Test Writer, run the suite
5. **Review** — call in the Reviewer for a final audit
6. **Deliver** — call in DevOps if needed, summarize and offer to commit/deploy

## Memory

Each persona has a memory file in `memory/` that it reads at session start and updates at
session end. This gives each role continuity — the Debugger remembers past bugs, the Reviewer
tracks recurring issues, the PM knows what phase a project is in.

## Customizing

- Edit any `*.md` file in this directory to change a persona's instructions
- Add new personas: create a `.md` file and add a line to `shell_functions.sh`
- Change colors: edit the hex values in `shell_functions.sh`
- Reset background default: change `#1a1a1a` in `_claude_profile()` to match your theme
