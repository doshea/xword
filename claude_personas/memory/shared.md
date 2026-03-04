# Shared Project Board

This file is read by all personas (Planner, Builder, Deployer). Use it for cross-persona handoffs.

## Current Focus

### ✅ Complete: Publish Service Extraction + Dead Code Cleanup
**Status:** Builder finished (2026-03-04)

### ✅ Builder complete (2026-03-04): Fix two solve-mode bugs

Two user-reported bugs fixed. **Needs manual visual verification** across breakpoints.
- **Bug 1 (row height jump):** `.letter` absolutely positioned + flex-centered (was in flow, line-height pushed td height)
- **Bug 2 (focus jumps to end):** `in_directional_finished_word()` check — advance one cell when word is full
- 772 specs pass (2 pre-existing flaky: `live_search`, `time_difference_hash`)

---

#### Bug 1: Row height jump when first letter is typed

**Symptom:** Typing the first letter in a row causes the puzzle grid to visibly shift/stretch. Each new row "grows" slightly on first keystroke.

**Root cause:** `.letter` div is the only child of `.cell` in normal document flow. When JS calls `.text(letter)` on an empty `.letter` div, the `line-height: 145%` creates a line box that pushes the `<td>` height. Despite `height: 1.5em; overflow: hidden` on `.cell`, the **table layout algorithm overrides explicit `<td>` heights** when content is taller — `overflow: hidden` doesn't work on table cells the same way it does on block elements.

**File:** `app/assets/stylesheets/crossword.scss.erb` lines 92–95

**Current:**
```scss
.letter {
  line-height: 145%;
  z-index: 1001;
}
```

**Fix:** Absolutely position `.letter` inside the cell (like `.cell-num`, `.flag`, and `.circle` already are). This removes it from flow so content can never affect row height:

```scss
.letter {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  line-height: 1.5em;
  z-index: 1001;
}
```

**Why `line-height: 1.5em`:** The cell is `1.5em × 1.5em`. Setting `line-height` equal to the cell height vertically centers the letter. The old `145%` value was roughly trying to do this but depended on flow height. Now it's explicit.

**Verification:** Visually check across breakpoints — cell sizes vary:
- Phone: `font-size: 1.05em`, `width/height: 1.4em`
- Desktop: `font-size: 1.25em`, `width/height: 1.5em`
- XL: `font-size: 1.5em`

Check that letter is still centered, cell-num still visible in top-left, circles still render, and flags still show correctly. Type letters in a fresh row and confirm no height jump.

---

#### Bug 2: Focus jumps to end of fully-filled word

**Symptom:** When all cells in a word are filled and the user overwrites a letter that is NOT the last or second-to-last cell, focus jumps to the **last cell** in the word instead of advancing one cell.

**Root cause:** `crossword_funcs.js` lines 188–189:
```javascript
if (!cw.selected.is_word_end()) {
  cw.selected.next_empty_cell_in_word().highlight();
}
```

`next_empty_cell_in_word()` (cell_funcs.js line 336) recursively walks forward looking for an empty cell. If the whole word is filled, it finds no empty cell and terminates at `is_word_end()`, returning the **last cell in the word**.

**Files:** `app/assets/javascripts/crosswords/crossword_funcs.js` lines 188–189

**Fix:** When the word is fully filled after placing a letter, just advance one cell instead of searching for an empty one. An existing helper already checks this: `in_directional_finished_word()` (cell_funcs.js line 318).

**Current (lines 188–189):**
```javascript
if (!cw.selected.is_word_end()) {
  cw.selected.next_empty_cell_in_word().highlight();
}
```

**Replace with:**
```javascript
if (!cw.selected.is_word_end()) {
  if (cw.selected.in_directional_finished_word()) {
    cw.selected.next_cell().highlight();
  } else {
    cw.selected.next_empty_cell_in_word().highlight();
  }
}
```

**Why this works:** After `set_letter()` on line 183, the current cell is filled. `in_directional_finished_word()` checks the entire word in the active direction. If all cells are filled → advance one. If any are still empty → use existing skip-to-next-empty behavior (correct for initial solve flow).

**Edge case covered:** At the second-to-last cell of a filled word, `is_word_end()` is false, `in_directional_finished_word()` is true, `next_cell()` returns the last cell → focus moves one cell right. Correct.

**Edge case covered:** At the last cell, `is_word_end()` is true → the outer `if` is false → focus stays. Correct (unchanged).

**Verification:** Test these scenarios:
1. Start solving an empty word — letters should still skip to next empty cell (unchanged)
2. Fill a word completely, then go back and overwrite cell 1 — focus should move to cell 2 (not the last cell)
3. Overwrite the second-to-last cell of a filled word — focus moves to last cell (correct)
4. Type on the last cell of a filled word — focus stays (correct, unchanged)
5. Test in both across and down directions

---

**Files to touch:**
1. `app/assets/stylesheets/crossword.scss.erb` — lines 92–95 (`.letter` positioning)
2. `app/assets/javascripts/crosswords/crossword_funcs.js` — lines 188–189 (focus logic)

**No new files. No test changes** (JS interactions not covered by rspec). Run `bundle exec rspec` to confirm no regressions.

### Next candidate: `Crossword` default scope removal
**Status:** Not started — needs Planner design (34 call sites, high blast radius)

## Recent Handoffs

### Architect → PM (2026-03-03): Priority assessment & recommendation

**Context:** Fresh architecture review of remaining technical debt from CLAUDE.md.

**Recommendation — Two high-value targets remain:**

1. **`UnpublishedCrosswordsController#publish` → service object extraction**
   - ~40 lines of crossword construction logic in the controller
   - Last major service extraction on the roadmap (NYT import + Solution auth already done)
   - Contained problem, clear boundaries, high payoff if publish ever needs a second entry point
   - **I'm ready to design the interface and migration path on request**

2. **`Crossword` default scope removal (`order(created_at: :desc)`)**
   - Silently affects every query — joins, subqueries, `first`/`last` semantics
   - "When, not if" bug source. Needs a careful migration plan (grep all call sites, add explicit `.order` where needed)
   - Lower urgency but higher blast radius — worth planning before it causes a subtle bug

**Medium-value (do when nearby):**
- `SolutionsController` team broadcast → extract to service/concern
- `published` column: either restore it and re-enable guards, or delete the dead `publish!`/`error_if_published` methods. Current half-state is confusing.

**Question for PM:** Which of these aligns with your current priorities? Is there a new feature on the horizon that should influence sequencing? Happy to start on the publish extraction if nothing else is more urgent.

### PM → Architect (2026-03-03): Priority decision & scope

**Decision: Do the publish extraction first. Bundle dead code cleanup with it.**

**Approved scope (one pass):**
1. Extract `UnpublishedCrosswordsController#publish` (lines 39–93) → `CrosswordPublisher` service
2. Delete `Crossword#publish!` (lines 372–382) — unused, untested, partial duplicate of controller logic
3. Delete `Publishable` concern — 13 scopes, zero call sites anywhere in the codebase. Pure dead code.
4. Controller calls service, existing 7 request specs should pass without changes (behavior-preserving refactor)

**Deprioritized:**
- **Default scope removal** → Next session, separate plan. 34 call sites, needs methodical migration.
- **Team broadcast extraction** → Skip. Private `team_broadcast` method is already clean (6 lines + Redis rescue). Not worth a service.
- **`published` column** → Defer. No feature driving it. The `publish!` deletion above cleans up the confusing half-state.

**Request to Architect:** Please design the `CrosswordPublisher` interface and hand off to Builder. Follow the `NytPuzzleImporter` pattern (initialize with inputs, `#call` method, transaction inside).

### Planner → Builder (2026-03-03): CrosswordPublisher design + scope correction

**⚠️ SCOPE CORRECTION: Publishable concern is NOT dead code.**
The earlier review was wrong. `PagesController#home` (lines 13–18) calls 3 Publishable scopes
(`new_to_user`, `all_in_progress`, `all_solved`), and most other scopes are internal dependencies
of those 3. Only 4 of 15 scopes are truly unused (`standard`, `nonstandard`, `solo`, `teamed`).
**DO NOT delete `Publishable`.**

**Revised scope (3 items):**
1. Extract `UnpublishedCrosswordsController#publish` → `CrosswordPublisher` service
2. Delete `Crossword#publish!` (lines 372–382) — confirmed zero callers
3. Controller calls service; existing 7 request specs pass unchanged

---

#### `CrosswordPublisher` Interface Design

**File:** `app/services/crossword_publisher.rb`

**Pattern:** Follows `NytPuzzleImporter` — class method entry point, transaction inside, returns result or raises.

```ruby
# Converts an UnpublishedCrossword into a published Crossword.
# Extracted from UnpublishedCrosswordsController#publish.
#
# Usage:
#   crossword = CrosswordPublisher.publish(ucw)
#   # Returns the published Crossword.
#   # Raises CrosswordPublisher::BlankCellsError if any cells are blank.
#   # Raises ActiveRecord::RecordInvalid on save failures (rolls back txn).
#   # Destroys the UCW on success.
class CrosswordPublisher
  class BlankCellsError < StandardError; end

  def self.publish(ucw)
    validate_complete!(ucw)

    Crossword.transaction do
      crossword = create_crossword(ucw)
      apply_letters(crossword, ucw)
      assign_clues(crossword, ucw)
      clean_up_cells(crossword)
      apply_circles(crossword, ucw)
      ucw.destroy!
      crossword
    end
  end

  # --- private helpers (one per pipeline step) ---

  def self.validate_complete!(ucw)
    blank_count = ucw.letters.count { |l| !l.nil? && l.blank? }
    return if blank_count == 0
    raise BlankCellsError,
      "Cannot publish: #{blank_count} #{'cell'.pluralize(blank_count)} still blank."
  end
  private_class_method :validate_complete!

  def self.create_crossword(ucw)
    Crossword.create!(
      title: ucw.title, description: ucw.description,
      rows: ucw.rows, cols: ucw.cols, user: ucw.user
    )
  end
  private_class_method :create_crossword

  def self.apply_letters(crossword, ucw)
    letters_string = ucw.letters.map { |l| l.nil? ? '_' : l }.join
    crossword.set_contents(letters_string)
    crossword.number_cells
  end
  private_class_method :apply_letters

  def self.assign_clues(crossword, ucw)
    crossword.cells.reload.each do |cell|
      idx = cell.index - 1
      if cell.is_across_start && ucw.across_clues[idx].present?
        cell.across_clue.update!(content: ucw.across_clues[idx])
      end
      if cell.is_down_start && ucw.down_clues[idx].present?
        cell.down_clue.update!(content: ucw.down_clues[idx])
      end
    end
  end
  private_class_method :assign_clues

  def self.clean_up_cells(crossword)
    crossword.cells.each { |cell| cell.delete_extraneous_cells! }
    crossword.generate_words_and_link_clues
  end
  private_class_method :clean_up_cells

  def self.apply_circles(crossword, ucw)
    if ucw.circles.present? && ucw.circles.chars.any? { |c| c != ' ' && c != '0' }
      crossword.circles_from_array(ucw.circles.chars.map(&:to_i))
    end
  end
  private_class_method :apply_circles
end
```

**Controller after refactor** (`unpublished_crosswords_controller.rb` lines 39–93 → 8 lines):
```ruby
def publish
  ucw = found_object
  crossword = CrosswordPublisher.publish(ucw)
  redirect_to crossword_path(crossword),
    flash: { success: 'Your puzzle has been published!' }
rescue CrosswordPublisher::BlankCellsError => e
  redirect_to edit_unpublished_crossword_path(ucw), flash: { error: e.message }
rescue StandardError => e
  redirect_to edit_unpublished_crossword_path(found_object),
    flash: { error: "Publishing failed: #{e.message}" }
end
```

**Design decisions:**
- `BlankCellsError` replaces early-return validation. Service raises; controller rescues and maps to redirect. Clean separation.
- All class methods (no instance state) — matches `NytPuzzleImporter.import` pattern.
- 5 private helpers mirror the 5 logical pipeline steps. Names are self-documenting.
- Transaction boundary stays in `publish` — same as original.
- `private_class_method` used instead of `private` block (Ruby convention for class methods).

**Files to touch:**
1. `app/services/crossword_publisher.rb` — **new file**
2. `app/controllers/unpublished_crosswords_controller.rb` — replace lines 39–93
3. `app/models/crossword.rb` — delete `publish!` method (lines 372–382)

**DO NOT touch:**
- `app/models/concerns/publishable.rb` — it's live code
- `spec/requests/unpublished_crosswords_spec.rb` — behavior-preserving refactor, specs should pass as-is

**Acceptance criteria:**
- `bundle exec rspec` — all ~735 examples pass
- `PATCH /unpublished_crosswords/:id/publish` still creates Crossword, destroys UCW, copies letters/clues/circles, rejects blank puzzles
- `Crossword#publish!` no longer exists
- `Publishable` concern is untouched

### PM → Builder (2026-03-03): Delete dead persona files

Consolidated from 10 roles to 3 (Planner, Builder, Deployer). 14 leftover files need deletion:

**Persona files to delete:**
- `claude_personas/architect.md`
- `claude_personas/debugger.md`
- `claude_personas/devops.md`
- `claude_personas/frontend.md`
- `claude_personas/pm.md`
- `claude_personas/reviewer.md`
- `claude_personas/test_writer.md`

**Memory files to delete:**
- `claude_personas/memory/architect.md`
- `claude_personas/memory/debugger.md`
- `claude_personas/memory/devops.md`
- `claude_personas/memory/frontend.md`
- `claude_personas/memory/pm.md`
- `claude_personas/memory/reviewer.md`
- `claude_personas/memory/test_writer.md`

**Keep:** `planner.md`, `builder.md`, `deployer.md`, their memory files, `README.md`, `shell_functions.sh`, `memory/shared.md`

**Acceptance:** `ls claude_personas/` shows only the 3 role files + README + shell_functions. `ls claude_personas/memory/` shows only 4 files (3 roles + shared).

## Open Questions
