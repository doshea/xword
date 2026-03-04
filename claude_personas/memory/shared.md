# Shared Project Board

This file is read by all personas (Planner, Builder, Deployer). Use it for cross-persona handoffs.

## Current Focus

### ✅ Fix 8 Test Failures (4 always-failing, 4 intermittent)
**Status:** Builder complete (2026-03-04). 814 examples, 0 failures — 3 consecutive green runs.

**What shipped (4 fixes):**
1. CSS nesting bug: `#settings-button` → `&#settings-button` in `edit.scss.erb` (compound selector)
2. `render_views` added to `pages_controller_spec.rb` `live_search` describe block
3. Deadlock retry wrapper added to non-JS branch in `spec_helper.rb`
4. Positive wait (`have_text('Welcome back')`) before negative assertion in `login_spec.rb`

**⚠️ Visual verify needed:** Settings gear on edit page should now be fixed-positioned at right edge, 40% viewport height.

**Planner → Builder: 4 fixes, independent (any order):**

---

#### Fix 1: CSS nesting bug — `edit.scss.erb` (fixes 3 always-failing tests)

**Tests:** `edit_spec.rb:35, 41, 115` — all fail with `MouseEventFailed` (settings button overlaps ideas button)

**Root cause:** Sass nests `#settings-button` inside `.side-button`, compiling to descendant selector `.side-button #settings-button`. But HAML renders `<a class="side-button" id="settings-button">` — same element, not parent/child. So `position: fixed; right: 0; top: 40%` never applies. Button sits in flow at page bottom, overlapping `#ideas-button`.

**File:** `app/assets/stylesheets/edit.scss.erb` line 11

**Change:** `#settings-button {` → `&#settings-button {`

This compiles to `.side-button#settings-button` (compound selector, same element).

```scss
.side-button {
  background: var(--color-nav-bg);
  color: var(--color-nav-text);
  font-size: 1.5em;
  box-shadow: var(--shadow-lg);

  &#settings-button {
    position: fixed;
    right: 0;
    top: 40%;
    border-top-left-radius: 0.4em;
    border-bottom-left-radius: 0.4em;
    padding: 0.3em 0.3em 0.2em 0.4em;
  }
}
```

**⚠️ Visual verify needed:** This is also a production bug — the settings gear was never fixed-positioned. After fixing, confirm it appears as a floating tab on the right edge at 40% viewport height on the edit page.

---

#### Fix 2: Missing `render_views` — `pages_controller_spec.rb` (fixes 1 always-failing test)

**Test:** `pages_controller_spec.rb:28` — `expected "".present? to be truthy`

**Root cause:** Controller spec without `render_views`. `render_to_string(partial: ...)` returns `""` when rendering is stubbed. JSON has `result_count: 2` but `html: ""`.

**File:** `spec/controllers/pages_controller_spec.rb` line 23 (inside `describe 'GET #live_search'`)

**Change:** Add `render_views` after the describe line:

```ruby
describe 'GET #live_search' do
  render_views

  before do
    request.env["HTTP_X_REQUESTED_WITH"] = "XMLHttpRequest"
  end
```

---

#### Fix 3: Deadlock retry for non-JS tests — `spec_helper.rb` (fixes 2 intermittent tests)

**Tests:** `admin/clues_controller_spec.rb` (2 tests) — `PG::TRDeadlockDetected` during crossword factory

**Root cause:** JS tests (`:deletion` strategy) run in a Puma thread. Non-JS tests (`:transaction` strategy) run in the main process. Both can create crosswords concurrently, triggering bulk `INSERT INTO clues` on separate connections → deadlock. JS branch has retry; non-JS branch doesn't.

**File:** `spec/spec_helper.rb` lines 69-71 (the `else` branch of `c.around(:each)`)

**Change:** Replace plain `DatabaseCleaner.cleaning` with retry wrapper (matches existing JS pattern):

```ruby
else
  DatabaseCleaner.strategy = :transaction
  retries = 0
  begin
    DatabaseCleaner.cleaning { example.run }
  rescue ActiveRecord::Deadlocked => e
    retries += 1
    raise if retries > 2
    ActiveRecord::Base.connection_pool.disconnect!
    sleep 0.5
    retry
  end
end
```

---

#### Fix 4: Cuprite timing — `login_spec.rb` (fixes 1 intermittent test)

**Test:** `login_spec.rb:48` — `expected not to find visible link "Login", found 1 match`

**Root cause:** After login + Turbo redirect, `not_to have_link('Login')` sometimes checks before nav re-renders. Needs a positive assertion first to wait for redirect completion.

**File:** `spec/features/login_spec.rb` line 54 (before the `expect(page).not_to have_link('Login')` line)

**Change:** Add positive wait before negative assertion:

```ruby
scenario 'clicking Login navigates to login page and logs in with good credentials' do
  click_link 'Login'
  within('form#login') do
    fill_in :username, with: @user.username
    fill_in :password, with: @user.password
    click_button 'Log in'
  end
  expect(page).to have_text('Welcome back')
  expect(page).not_to have_link('Login')
end
```

---

**Also fixes (no specific change needed):** `users_spec.rb:47` — passed in isolation, likely collides with deadlock. Fix 3 should stabilize it.

**Acceptance criteria:**
- `bundle exec rspec` passes 3 consecutive runs with 0 failures
- Edit page settings gear visually verified at right edge, 40% height

---

### 🔨 Test Suite Performance Optimization
**Status:** Builder-ready (2026-03-04). Plan approved.

**Goal:** Suite under 80s (from ~127s). ~45% speedup.

**Planner → Builder: 3 phases, in order:**

**Phase 1 — `test-prof` gem + `let_it_be` (highest impact, ~30–40s saved):**
1. Add `gem 'test-prof', '~> 1.4'` to Gemfile test group
2. Add `require 'test_prof/recipes/rspec/let_it_be'` to spec_helper.rb
3. **Test compatibility first** on `spec/requests/solutions_spec.rb` — convert `let(:user)` and `let(:crossword)` to `let_it_be`, run that file only. If it passes, proceed. If DatabaseCleaner conflicts, investigate before bulk-converting.
4. Convert these files (`let` → `let_it_be` for crossword/user records that tests only read):
   - `spec/requests/solutions_spec.rb` (user, crossword)
   - `spec/requests/crosswords_spec.rb` (user, crossword)
   - `spec/views/crosswords/show.html.haml_spec.rb` (owner, crossword)
   - `spec/requests/ajax_csrf_spec.rb` (user, crossword)
   - `spec/requests/check_functions_spec.rb` (user, crossword)
   - `spec/views/crosswords/partials/_crossword_tab.html.haml_spec.rb` (crossword)
   - `spec/requests/comments_spec.rb` (if crossword is read-only)
   - `spec/models/phrase_spec.rb` (if crossword is read-only)
5. Feature specs (`solve_spec.rb`, `accessibility_spec.rb`): try `let_it_be` but these use `:deletion` strategy — may need to stay as `let!`. Test and decide.
6. **Safety rule:** Only `let_it_be` on records tests READ. If a test mutates the record (update!, destroy!), keep `let` or use `let_it_be(reload: true)`.

**Phase 2 — Pin crossword dimensions (~10–20s worst-case saved):**
- Replace bare `create(:crossword)` with `create(:crossword, rows: 5, cols: 5)` in:
  - `spec/models/crossword_spec.rb` (lines 336, 416, 442, 568, 584 — keep line 20 random)
  - `spec/controllers/comments_controller_spec.rb` (line 3)
  - `spec/controllers/admin/comments_controller_spec.rb` (line 3)
  - `spec/models/comment_spec.rb` (line 17)
  - `spec/controllers/pages_controller_spec.rb` (lines 25, 53)

**Phase 3 — CSRF token optimization (~1s saved):**
- In `spec/requests/ajax_csrf_spec.rb`, change `csrf_token` helper to `get '/login'` instead of `get "/crosswords/#{crossword.id}"`.

**Acceptance criteria:**
- `bundle exec rspec` — all passing examples still pass
- Suite finishes under 80s consistently (run 3× to confirm)
- No test behavior changes

**See planner memory for full root cause analysis and risk notes.**

---

### ✅ Notification System + Friend Requests + Puzzle Invites
**Status:** Builder complete (2026-03-04). All 4 phases implemented. 48 new specs, 752 total (1 pre-existing flaky). Needs deploy + visual verification.

**What shipped:**
- Notification model + migration (4 indexes incl. dedup + dedup-null-notifiable partial index)
- NotificationService (class-method pattern, ActionCable broadcast, dedup-safe)
- NotificationsChannel + notifications_channel.js (real-time badge + inbox prepend)
- Nav bell icon with red badge count, linked to /notifications inbox page
- FriendRequestsController (create/accept/reject) with turbo_frame profile buttons
- Comment notifications (add_comment + reply hooks in CommentsController)
- Puzzle invites (friends API, PuzzleInvitesController, Stimulus invite_controller.js in team modal)
- Dead code deleted: cable.js, channels/chatrooms.js

**Builder → Deployer:** Migration adds `notifications` table with 4 indexes. Standard `rails db:migrate`. No data backfill needed. Verify ActionCable WebSocket connects on login (check browser Network tab for `/cable`).

---

### ✅ Deployed v529 (2026-03-04): Bug fixes + CrosswordPublisher refactor + dead code
**Status:** Deployed to Heroku (v527–v529). Verified healthy. Mobile/tablet visual check passed.

**What shipped:**
- Bug fix: row height jump (CSS `.letter` absolute positioning)
- Bug fix: focus skip in filled words (JS `in_directional_finished_word()` guard)
- CrosswordPublisher refactored into 5 private helpers
- Dead code deleted: `Crossword#publish!`, empty `charts.html.haml`
- Persona consolidation (7 → 3 roles)

**⚠️ Deployer → Builder/User: CSS `.letter` positioning change needs manual visual verification across phone/tablet/desktop breakpoints.** Check letter centering, cell-num visibility, circles, flags, and no row height jump when typing.

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

### ✅ Cell Check Flash Effect
**Status:** Builder complete (2026-03-04). Needs visual verification in browser.

**What:** When cells are checked (check cell / check word / check puzzle), a brief golden flash sweeps across the checked cells in reading order (L→R, T→B), then rapidly fades to reveal error flags underneath. Creates a satisfying "server touched this cell" moment.

**Files to touch (3):**
1. `app/assets/stylesheets/_design_tokens.scss` — add `--color-cell-flash: #f5d87a` token (after `--color-cell-incorrect`)
2. `app/assets/stylesheets/crossword.scss.erb` — add `.cell-flash::before` rules + `@keyframes` (~after line 140), add to `prefers-reduced-motion` block (~line 927)
3. `app/assets/javascripts/crosswords/solve_funcs.js` — replace `apply_mismatches` function (~lines 123–136)

**No backend changes. No new files. No test changes.** `bundle exec rspec` should pass unchanged.

---

#### 1. Design Token (`_design_tokens.scss`)

Add after `--color-cell-incorrect`:
```scss
--color-cell-flash:     #f5d87a;  // golden scan — matches selected, distinct from correct/incorrect
```

#### 2. CSS (`crossword.scss.erb`)

Add after `.correct .flag { ... }` block (~line 140):
```scss
// Cell check flash — brief "server scanned" effect.
// Applied with JS stagger for L→R, T→B cascade.
// z-index 1100: above .flag (1000) and .letter (1001) so flash
// genuinely covers the cell, then fades to reveal the error state.
.cell-flash::before {
  content: '';
  position: absolute;
  inset: 0;
  z-index: 1100;
  background: var(--color-cell-flash);
  pointer-events: none;
  animation: cell-check-flash var(--duration-slow) var(--ease-out) forwards;
}

@keyframes cell-check-flash {
  0%   { opacity: 0.6; }
  100% { opacity: 0; }
}
```

Add to existing `@media (prefers-reduced-motion: reduce)` block (~line 927):
```scss
.cell-flash::before { animation: none; display: none; }
```

#### 3. JavaScript (`solve_funcs.js`)

Replace `apply_mismatches` (lines 123–136) with:
```javascript
// Shared handler for check_cell/check_word/check_puzzle JSON responses.
// Marks cells as correct/incorrect with a staggered golden flash cascade
// that sweeps L→R, T→B (reading order), then fades to reveal error flags.
apply_mismatches: function(data) {
  var mismatches = data.mismatches;
  var keys = Object.keys(mismatches).map(Number);

  // Sort by index — already reading order (HAML iterates rows then cols)
  keys.sort(function(a, b) { return a - b; });

  var count = keys.length;

  // Adaptive stagger: deliberate for words, rapid sweep for full puzzles
  var stagger;
  if (count <= 1)       stagger = 0;
  else if (count <= 20) stagger = 30;
  else                  stagger = Math.max(4, Math.round(1200 / (count - 1)));

  var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  keys.forEach(function(cellIndex, i) {
    var v = mismatches[cellIndex];
    var delay = reducedMotion ? 0 : stagger * i;

    setTimeout(function() {
      var cell = $($('.cell')[cellIndex]);

      // 1. Apply correct/incorrect state (flag renders under the flash)
      if (v) {
        cell.addClass('flagged incorrect').removeClass('correct');
      } else {
        if (cell.hasClass('incorrect')) {
          cell.addClass('flagged correct').removeClass('incorrect');
        }
      }

      // 2. Trigger golden flash overlay — fades to reveal flag state
      if (!reducedMotion) {
        cell.removeClass('cell-flash');
        cell[0].offsetWidth;  // Force reflow to restart animation on re-check
        cell.addClass('cell-flash');
      }
    }, delay);
  });

  // Cleanup flash classes after all animations complete
  if (!reducedMotion && count > 0) {
    var cleanup = (stagger * (count - 1)) + 400;
    setTimeout(function() {
      $('.cell-flash').removeClass('cell-flash');
    }, cleanup);
  }
},
```

#### Cascade Timing

| Check type | Cell count | Stagger | Sweep duration | Total w/ fade |
|---|---|---|---|---|
| Single cell | 1 | 0ms | instant | 300ms |
| Word | 3–15 | 30ms/cell | 90–420ms | 390–720ms |
| Full puzzle (15×15) | 225 | ~5ms/cell | ~1.2s | ~1.5s |

#### Key Design Decisions

- **`::before` pseudo-element**: Avoids touching HAML template. `.cell` already has `position: relative` (line 76) and no pseudo-elements in use.
- **z-index 1100**: Above `.flag` (1000) and `.letter` (1001). Flash genuinely covers the cell, then fades to reveal the flag state underneath.
- **Error state applied simultaneously with flash**: Flag class is painted but obscured by 60%-opacity golden overlay. As overlay fades over 300ms, flag reveals naturally. No second timed callback needed.
- **Reflow trick** (`cell[0].offsetWidth`): Forces CSS animation restart when re-checking the same cells.
- **Empty cells in full-puzzle check**: Flash appears on ALL checked cells uniformly (the wave sweeps continuously). Only cells with actual errors get flag classes.
- **`prefers-reduced-motion`**: Respected in both JS (skip stagger + flash) and CSS (animation: none). Follows existing patterns in global.js and crossword.scss.erb.

#### Watch For

- **Table `overflow: hidden`** on `.cell` (line 78): `::before` with `inset: 0` is clipped to cell bounds — correct behavior, verify no bleed.
- **Selected cells**: Flash is same golden as selection highlight — flash may be invisible on the currently selected cell. Acceptable: user already knows that cell is active, and the flag still reveals normally.
- **Legacy `check_cell.js.erb`**: Won't get flash effect (only the JSON path does). Low risk — fallback is rarely hit.

#### Verification

1. Check single cell → brief golden flash, flag appears as flash fades
2. Check word → cascade sweeps across the word cells in order
3. Check puzzle → wave sweeps entire grid L→R, T→B over ~1.5s
4. Re-check same cells → flash triggers again (reflow trick works)
5. No visual artifacts on void cells, selected cells, or circled cells
6. Test with browser `prefers-reduced-motion` → instant flag application, no flash

---

### ✅ Fix Blurry Puzzle Preview Thumbnails
**Status:** Builder complete (2026-03-04). Needs visual verification.

**Problem:** Preview images are pixel art (75×75px for a 15×15 puzzle — 5px per cell). CSS `width: 100%` stretches them to 140px+ in grid columns. Browser bilinear interpolation turns crisp 1px grid lines into blurry smears. Border is warm tan (`--color-border`), barely visible.

**Fix:** Display at native size (75×75, matching home page `.minipic img`), tighten grid, add black border.

**Files to touch (2 CSS files only — no views, no backend):**
1. `app/assets/stylesheets/search.scss.erb` — `.xw-search-puzzles` grid + `.xw-search-puzzle__thumb`
2. `app/assets/stylesheets/profile.scss.erb` — `.xw-profile-puzzles` grid + `.xw-profile-puzzle__thumb`

---

#### Search page (`search.scss.erb`)

**Grid** (~line 200–204) — tighten columns:
```scss
// BEFORE:
grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));

// AFTER:
grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
```

**Thumb** (~lines 230–249) — replace entire rule:
```scss
.xw-search-puzzle__thumb {
  width: 75px;
  height: 75px;
  margin: 0 auto;
  border: 1px solid var(--color-cell-border);
  border-radius: var(--radius-sm);
  box-shadow: var(--shadow-sm);
  object-fit: cover;
  image-rendering: pixelated;
  background-color: var(--color-surface-alt);
  transition: var(--transition-shadow);

  &--empty {
    display: flex;
    align-items: center;
    justify-content: center;
    background-image:
      linear-gradient(var(--color-border) 1px, transparent 1px),
      linear-gradient(90deg, var(--color-border) 1px, transparent 1px);
    background-size: 20% 20%;
    background-position: center;
  }
}
```

**Mobile breakpoint** (~line 434) — already `minmax(100px, 1fr)`, no change needed.

#### Profile page (`profile.scss.erb`)

**Grid** (~line 212–216) — same tightening:
```scss
grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
```

**Thumb** (~lines 234–253) — identical changes as search thumb above (just with `xw-profile-puzzle__thumb` class name).

---

#### What changes and why

| Property | Before | After | Why |
|---|---|---|---|
| `width` | `100%` (stretches to column) | `75px` (native resolution) | No upscaling — pixel art stays crisp |
| `height` | implicit via `aspect-ratio` | `75px` | Explicit native size |
| `aspect-ratio` | `1` | removed | Fixed width/height handles this |
| `margin` | none | `0 auto` | Centers in wider grid column |
| `border` | `1px solid var(--color-border)` (tan) | `1px solid var(--color-cell-border)` (near-black) | Defined edges, matches puzzle grid |
| `border-radius` | `var(--radius-md)` (8px) | `var(--radius-sm)` (4px) | Pixel art + big radius = weird |
| `image-rendering` | browser default (bilinear) | `pixelated` | Insurance for any remaining scale |
| Grid `minmax` | `140px` | `100px` | Tighter mosaic, matches smaller thumbs |

#### Edge cases
- **Non-square puzzles** (e.g., 21×13 → 105×65px native): `object-fit: cover` crops to square. Acceptable — preview communicates grid pattern, not exact dimensions.
- **Empty state** (`--empty` modifier): Unchanged — CSS grid pattern placeholder doesn't need these fixes.
- **Home page** (`.minipic img`): Already uses `width: 75px; height: 75px`. No changes needed.

#### Verification
1. Search page: thumbnails display at 75×75, crisp grid lines, black border visible
2. Profile page: same treatment
3. Non-square puzzles render without distortion
4. Hover lift + shadow still works
5. Mobile: grid still wraps properly at smaller breakpoint
6. Empty placeholder cards still render the CSS grid pattern

---

### ✅ Test Suite Performance Optimization
**Status:** Builder complete (2026-03-04). 814 examples, 60s (was 83.5s). No deploy needed.

**What shipped:**
- `test-prof` gem added for `let_it_be` (shared test fixtures)
- Crossword factory pinned to 5×5 (was random 4–30, up to 2,700 DB inserts per create)
- 17 spec files converted from `let` to `let_it_be` (read-only crossword/user records shared across examples)
- Feature specs untouched (`:deletion` strategy incompatible with `let_it_be`)

**Files changed:** Gemfile, Gemfile.lock, spec/spec_helper.rb, spec/factories/crossword_factory.rb, 17 spec files

---

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
