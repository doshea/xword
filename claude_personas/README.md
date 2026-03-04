# Claude Code Personas

Three specialized Claude agents differentiated by **actual capabilities**, not just tone.

## Setup

Add to `~/.zshrc`:

```bash
source ~/xword/claude_personas/shell_functions.sh
```

Then `source ~/.zshrc`.

## The Three Personas

| Command | Role | Model | Permissions | Color |
|---------|------|-------|-------------|-------|
| `claude-plan` | Planner | Opus | Read-only (`--permission-mode plan`) | Teal |
| `claude-build` | Builder | Default | Full access, no prompts | Green |
| `claude-deploy` | Deployer | Default | Full access, no prompts | Indigo |

### Planner (`claude-plan`)

**Cannot edit files.** Uses Opus for deep reasoning. Covers architecture, code review,
planning, and test design. Produces plans, reviews, and designs — then hands off to the Builder.

### Builder (`claude-build`)

**Full access, no permission prompts.** Implements features, fixes bugs, writes tests, builds UI.
Checks the shared board for Planner handoffs. Runs `bundle exec rspec` after changes.

### Deployer (`claude-deploy`)

**Full access, no permission prompts.** Handles migrations, deployment, infrastructure, and
post-deploy verification. Always confirms before touching production. States rollback plans.

## Why Three?

The previous 7-persona system differentiated roles only through system prompts — "be an
architect" vs "be a reviewer" produced the same behavior since the model naturally adapts
to the task. These three personas differ in **what they can actually do**:

- The Planner literally cannot edit your code (plan mode)
- The Planner uses Opus for deeper reasoning on architectural decisions
- The Builder skips all permission prompts for fast iteration
- The Deployer has deployment-specific checklists and safety protocols

## Memory

Each persona has:

1. **Private memory** (`memory/<role>.md`) — role-specific notes across sessions
2. **Shared board** (`memory/shared.md`) — cross-persona handoffs

### Workflow

```
Terminal 1 (Planner):  "Review the solutions controller"
  -> Reads code, posts review to shared board:
     "Planner -> Builder: 2 should-fix issues, see planner memory"

Terminal 2 (Builder):  "Check the shared board"
  -> Reads findings, implements fixes, runs tests
  -> Posts to shared board: "Builder -> Deployer: migration added, needs safety review"

Terminal 3 (Deployer): "Check the shared board"
  -> Reviews migration, deploys, verifies
```

## Terminal Features (iTerm2)

- Background color per persona
- Badge watermark with role name
- Tab title ("Claude: Planner", etc.)
- Resets to defaults on exit

## Customizing

- Edit `planner.md`, `builder.md`, `deployer.md` to change persona instructions
- Edit `shell_functions.sh` to change CLI flags, colors, or add personas
- The `_claude_persona` function passes extra args to `claude`, so any CLI flag works
