# Product Spec: Edit Page Mini-Manual

## Problem

The edit page has complex interactions — double-click voids, mirror mode, circle mode, 1-click
mode, pattern search syntax, notepad — but zero in-app documentation. The only hints are switch
labels in Advanced Controls. New puzzle creators have to discover everything by trial and error.

The edit page has no existing Controls modal (unlike solve), so this is net-new UI.

---

## Solution

Add a "How to Edit" modal triggered by a help button in the edit toolbar area. Same `<dialog>`
pattern as the solve mini-manual, but with edit-specific content.

---

## Content Structure

### Section 1: Navigation

| Action | How |
|--------|-----|
| Move between cells | Arrow keys or click a cell |
| Switch direction (across/down) | Press **Space** |
| Jump to next word | Press **Tab** |
| Jump to next empty cell | Press **Enter** |
| Jump to a specific clue | Click the clue text |
| Deselect cell | Press **Escape** or click outside the grid |

*(Same as solve — shared crossword_funcs.js)*

### Section 2: Filling the Grid

| Action | How |
|--------|-----|
| Type a letter | Select a cell, then type — cursor auto-advances |
| Delete a letter | **Backspace** — if cell is empty, moves back and deletes |
| Toggle a void (black square) | **Double-click** a cell |
| Toggle void (fast mode) | Turn on "1-Click voids" in Advanced Controls, then single-click |
| Mirror voids | Turn on "Mirror voids" — toggling a void also toggles its rotational mirror |
| Add a circle | Turn on "Circle Mode" in Advanced Controls, then click cells to toggle circles |

### Section 3: Writing Clues

| Action | How |
|--------|-----|
| Edit a clue | Click a clue in the Across or Down column to focus its text field |
| Clue numbers | Updated automatically when you add or remove voids |
| Saving clues | Clues save with the rest of the puzzle (not individually) |

### Section 4: Finding Words

| Action | How |
|--------|-----|
| Pattern search | Open "Pattern Search" at the bottom. Use `_` for unknown letters (e.g., `P_ZZ_E` finds PUZZLE) |
| Notepad | Open "Notepad" to save potential words. Words are sorted by length. |

### Section 5: Saving & Publishing

| Action | How |
|--------|-----|
| Manual save | Click the save icon in the toolbar |
| Auto-save | Your puzzle saves automatically every 15 seconds when you make changes |
| Title & description | These save immediately when you click away from the field |
| Publish | Click "Publish Puzzle" when your grid is complete. **Published puzzles cannot be edited.** |

### Section 6: Advanced Controls

| Switch | What it does |
|--------|-------------|
| Mirror voids | Void toggles are mirrored rotationally (standard crossword symmetry) |
| 1-Click voids | Single-click toggles voids instead of requiring double-click |
| Circle Mode | Click cells to add/remove circle markers (used for themed puzzles) |

---

## UI Design

### Trigger Button

The edit page toolbar doesn't have a gear/controls button like solve. Add one:

```haml
%button#edit-help-button.xw-btn.xw-btn--sm.xw-btn--ghost{type: 'button', data: {'xw-tooltip': 'How to Edit'}, aria: {label: 'How to edit'}}
  = icon('info')
```

Place after the save button in the edit toolbar. The `info` icon (circle-i) signals "help"
without conflicting with the solve page's gear icon.

**Alternative**: Use `lightbulb` icon — both exist in the icon set. `info` is more conventional
for help. Builder decides.

### Modal Structure

Same as solve mini-manual:
- `<dialog>` element
- Title: "How to Edit"
- Sections with two-column tables
- `<kbd>` keycap styling for keys
- Scrollable body, responsive width
- Close via X / Escape / click-outside

### Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Trigger | `info` icon button in toolbar | Edit page has no existing help trigger; info icon is conventional |
| Title | "How to Edit" | Parallel with solve's "How to Solve" |
| Pattern search syntax | Use `_` not `?` in docs | `_` is the standard crossword convention; code accepts both but `_` is more intuitive |
| Void terminology | "void (black square)" on first mention, "void" after | Users may not know the term "void" |
| Advanced Controls section | Separate from "Filling the Grid" | Switches are a distinct UI area; grouping them together is cleaner |
| No Multi-Letter section | Omit | Multi-Letter mode switch exists but is extremely niche; documenting it adds confusion for 99% of users |

---

## Files Touched

| File | Change |
|------|--------|
| `edit.html.haml` | Add help button to toolbar + `<dialog id="edit-help-modal">` with content |
| `crossword.scss.erb` or `global.scss.erb` | Share `kbd` styles with solve manual; add modal section styles if not shared |
| `edit_funcs.js` | Add click handler: `$('#edit-help-button').on('click', ...)` → `showModal()` |

## Shared CSS with Solve Manual

Both manuals use the same styling:
- `.xw-manual` — modal content wrapper
- `.xw-manual__section` — collapsible/scrollable section
- `.xw-manual__table` — two-column action/how table
- `kbd` — keycap styling

Define once in `global.scss.erb` (both pages use it).

## Acceptance Criteria

1. Info button visible in edit toolbar, opens "How to Edit" modal
2. All 6 sections render with correct content
3. Modal scrolls on small screens
4. `<kbd>` keycap styling matches solve manual
5. Close via X, Escape, click-outside
6. Pattern search section shows `_` syntax (not `?`)
7. Void terminology is clear for non-crossword-constructors
8. No regression to edit page functionality
