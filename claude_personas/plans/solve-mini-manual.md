# Product Spec: Solve Page Mini-Manual

## Problem

The solve page has ~20 interactions but only documents 4 in the Controls modal (Tab, Enter,
Space, Arrows). Users don't discover double-click, Escape, backspace cascading, check vs.
reveal vs. hint distinctions, or how auto-save works. Mobile users especially struggle — no
physical keyboard means no accidental discovery of shortcuts.

## Solution

Replace the existing `#controls-modal` (4-line keyboard legend) with a richer mini-manual
dialog. Same trigger (gear icon button), same modal pattern, more content.

---

## Content Structure

Organize by **task**, not by input method. Users think "how do I check my work?" not
"what does the Check button do?"

### Section 1: Navigation

| Action | How |
|--------|-----|
| Move between cells | Arrow keys or click a cell |
| Switch direction (across/down) | Press **Space** or click the current cell again |
| Jump to next word | Press **Tab** |
| Jump to next empty cell | Press **Enter** |
| Jump to a specific clue | Click the clue text |
| Deselect cell | Press **Escape** or click outside the grid |

### Section 2: Entering Letters

| Action | How |
|--------|-----|
| Type a letter | Select a cell, then type — cursor auto-advances |
| Delete a letter | **Backspace** — if cell is empty, moves back and deletes |
| Filled word | Clue text gets crossed off when every cell in the word has a letter |

### Section 3: Checking Your Work

| Action | What it does |
|--------|-------------|
| Check Cell | Verifies the selected cell — correct cells flash gold, wrong cells get marked |
| Check Word | Verifies every cell in the selected word |
| Check Puzzle | Verifies every cell in the entire grid |
| Check Completion | Checks if the puzzle is 100% correct — triggers the win screen if so |

*All check actions are in the "Check" dropdown menu in the toolbar.*

### Section 4: Getting Help

| Action | What it does |
|--------|-------------|
| Reveal Letter | Shows the correct letter for the selected cell (marked with a black tab) |
| Hint Word | Reveals one random cell in the selected word (prefers empty cells) |

*Revealed cells are marked so you know which ones you didn't solve yourself.*

### Section 5: Saving

| Action | How |
|--------|-----|
| Manual save | Click the save icon in the toolbar |
| Auto-save | Your progress saves automatically every 5 seconds when you make changes |
| Save status | The timestamp below the toolbar shows when your last save happened |

*If you're not logged in, your progress won't be saved when you leave the page.*

### Section 6: Comments

| Action | How |
|--------|-----|
| Post a comment | Type in the comment box, press **Enter** (or tap **Send** on mobile) |
| Reply to a comment | Click "Reply" on any comment |
| Expand/collapse replies | Click the reply count button |

### Section 7: Team Solving (conditional — only show if team solve)

| Action | How |
|--------|-----|
| See who's online | Colored squares in the toolbar show active teammates |
| Real-time updates | Teammates' letters appear as they type (with a colored flash) |
| Highlight a clue | Click a clue — teammates see a dashed outline on those cells |
| Team chat | Click the chat bar at the bottom to expand; type and press Enter |

---

## UI Design

### Modal Structure

```
+------------------------------------------+
|  How to Solve                        [X]  |
|------------------------------------------|
|                                          |
|  Navigation                              |
|  +------------------------------------+  |
|  | Move between cells    Arrow keys   |  |
|  | Switch direction      Space        |  |
|  | Next word             Tab          |  |
|  | Next empty cell       Enter        |  |
|  | Jump to clue          Click clue   |  |
|  | Deselect              Escape       |  |
|  +------------------------------------+  |
|                                          |
|  Entering Letters                        |
|  +------------------------------------+  |
|  | ...                                |  |
|  +------------------------------------+  |
|                                          |
|  (more sections...)                      |
|                                          |
+------------------------------------------+
```

### Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Trigger | Same gear button (`#controls-button`) | Users already know where Controls is; don't add a new button to a full toolbar |
| Title | "How to Solve" | Task-oriented, not "Controls" or "Help" |
| Format | `<dialog>` modal (existing pattern) | Matches win-modal and team-explanation patterns |
| Sections | Collapsible or scrollable | Content is longer than the old 4-line modal; phone screens need scroll |
| Close | X button + click-outside + Escape | Standard modal behavior (already handled by `<dialog>`) |
| Team section | Conditionally rendered | Only include Section 7 if `@team` is truthy |
| Layout | Two-column table per section (action / how) | Scannable, compact; same pattern as old Controls modal but richer |
| Mobile | Full-width modal, scrollable body | `max-height: 80vh; overflow-y: auto` |
| Typography | Section headings in `--font-heading` (Playfair), table text in `--font-body` (Lora) | Matches editorial aesthetic |

### Keyboard Rendering

Use `<kbd>` elements for key names (Space, Tab, Enter, Escape, Arrow keys). Style with:
```scss
kbd {
  display: inline-block;
  padding: 2px 6px;
  font-family: var(--font-mono);
  font-size: var(--text-xs);
  background: var(--color-surface-alt);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
}
```

This gives keys a "keycap" look — common in documentation, fits the editorial aesthetic.

---

## Files Touched

| File | Change |
|------|--------|
| `show.html.haml` | Replace `#controls-modal` content (~line 80-95) with expanded mini-manual |
| `crossword.scss.erb` | Add `kbd` styling, modal section styles, scrollable body |
| No JS changes | Same `showModal()` trigger, same close behavior |

## What NOT to Include

- Admin-only features (fake win, reveal puzzle, clear, flash cascade) — confusing for normal users
- Implementation details (auto-save interval, LWW conflict resolution)
- CSS class names or technical jargon
- The timer — it's self-explanatory (visible, ticking)

## Acceptance Criteria

1. Clicking the gear icon opens the expanded mini-manual (not the old 4-line legend)
2. All 6 (or 7) sections render with correct content
3. Team section only appears on team solve pages
4. Modal scrolls on small screens without overflowing viewport
5. `<kbd>` elements render with keycap styling
6. Close via X, Escape, and click-outside all work
7. No regression: old Controls shortcut info is still present (just expanded)
