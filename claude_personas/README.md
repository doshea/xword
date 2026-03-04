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
  echo "  claude-pm         Tech lead            (green)   <- runs the show"
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

## The Tech Lead (PM)

`claude-pm` is the tech lead. It plans, implements backend code, and shifts into specialist
mindsets for focused phases. For non-trivial reviews, it writes a handoff and tells you to open
a specialist in another terminal.

Two process tracks:
- **Lightweight** (well-understood tasks): Implement → Test → Commit
- **Full** (ambiguous/high-risk): Discover → Plan → Implement → Test → Review → Deliver → Verify

Each specialist has two modes:
- **Inline** — the PM shifts into their mindset within the same session
- **Separate terminal** — you open `claude-review`, `claude-debug`, etc. for focused, independent work

## Memory

Each persona has two memory sources:

1. **Private memory** (`memory/<role>.md`) — role-specific notes that persist across sessions.
   The Debugger remembers past bugs, the Reviewer tracks recurring issues, etc.

2. **Shared board** (`memory/shared.md`) — a cross-persona project board owned by the PM.
   All personas read it at session start and post handoff notes to it.

This means you can run the PM in one terminal, then open `claude-review` in another, and the
Reviewer will see what the PM left in the shared board (e.g., "Reviewer: check the new service
object, focus on error handling"). When the Reviewer finishes, it posts findings back to the
shared board for the PM to pick up.

### Workflow example

```
Terminal 1 (PM):       "Build a password reset feature"
  → PM plans, implements, writes to shared board:
    "Reviewer: check app/services/password_reset.rb and the new request spec"

Terminal 2 (Reviewer): "Check the shared board for my assignment"
  → Reviewer reads shared board, reviews the code, posts back:
    "Reviewer → PM: 1 must-fix (no rate limiting), 1 suggestion (rename method)"

Terminal 1 (PM):       "Check the shared board for updates"
  → PM reads findings, addresses them, continues to next phase
```

## Customizing

- Edit any `*.md` file in this directory to change a persona's instructions
- Add new personas: create a `.md` file and add a line to `shell_functions.sh`
- Change colors: edit the hex values in `shell_functions.sh`
- Reset background default: change `#1a1a1a` in `_claude_profile()` to match your theme
