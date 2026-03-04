# Plan: Admin Test Tools — Reveal Puzzle, Clear Puzzle, Flash Cascade

## Overview

Extend the existing Admin dropdown on the solve page (which currently has "Fake Win") with 3 additional testing tools:

1. **Reveal Puzzle** — Fill all cells with correct letters instantly
2. **Clear Puzzle** — Reset all cells to empty
3. **Flash Cascade** — Trigger the golden check-flash animation across the grid

Only Reveal Puzzle needs a server endpoint (returns the answer key). Clear Puzzle and Flash Cascade are pure client-side.

---

## Architecture

### Tool breakdown

| Tool | Server? | Why | Effect on solution |
|---|---|---|---|
| Reveal Puzzle | Yes — `POST admin_reveal_puzzle` | Correct letters live on the server (`@crossword.letters`), not the client | Auto-save fires within 5s → `check_completion` callback → marks `is_complete = true` |
| Clear Puzzle | No — pure client JS | Only needs to empty DOM text content | Auto-save fires within 5s → saves empty letters to DB |
| Flash Cascade | No — pure client JS | Reuses existing `apply_mismatches` with synthetic data | None — flash is visual only (no flag classes applied) |

### Key decisions

| Decision | Choice | Rationale |
|---|---|---|
| Reveal: set letters via DOM vs. `set_letter()` | Direct DOM (`.text()`) | `set_letter(letter, true)` broadcasts each cell to team (225 ActionCable messages for 15×15). `set_letter(letter, false)` calls `check_finisheds()` per cell (225 calls). Direct DOM + one `check_all_finished()` at end is O(1) broadcast, O(n) crossing-off. |
| Reveal: save immediately vs. let auto-save | Let auto-save | `update_unsaved()` triggers auto-save within 5s. No need for an immediate save call. Admin can also click Save manually. The `before_save :check_completion` callback handles marking the solution complete automatically. |
| Reveal: security | Admin-only endpoint | Returns the answer key (`@crossword.letters`). Must be 403 for non-admin. Same guard pattern as `admin_fake_win`. |
| Clear: also clear flags/crossed-off? | Yes | A clean slate: no letters, no check flags (`flagged`, `incorrect`, `correct`), no crossed-off clues. Admin gets a fresh-solve state. |
| Clear: un-set `is_complete`? | No | `check_completion` callback only sets `is_complete = true`, never reverts it. Clearing and re-saving won't undo completion. For a true reset, admin would delete the solution. This is fine for visual testing purposes. |
| Flash: all cells or only filled? | All non-void cells | The point is to see the visual sweep across the full grid. Empty cells flash too (same as "Check Puzzle" when cells are empty). |
| Flash: flag state changes? | None | All mismatches set to `false` (correct). `apply_mismatches` only adds `correct` class when cell already has `incorrect`. So for clean cells: flash animation only, no flag class changes. |

---

## Files to change (4 modified, 0 new)

### 1. `config/routes.rb` — Add admin_reveal_puzzle route

Add `post :admin_reveal_puzzle` to the crosswords member block (next to `admin_fake_win`):

```ruby
member do
  post :check_cell
  post :check_completion
  post :admin_fake_win
  post :admin_reveal_puzzle
  # ... existing routes
end
```

### 2. `app/controllers/crosswords_controller.rb` — Add admin_reveal_puzzle action

Add after `admin_fake_win` (~line 187). Simple — returns the answer key.

```ruby
# POST /crosswords/:id/admin_reveal_puzzle — Admin-only: return correct letters
def admin_reveal_puzzle
  return head :forbidden unless @current_user&.is_admin

  render json: { letters: @crossword.letters }
end
```

**Note:** This is the most security-sensitive endpoint — it returns the full answer. The admin guard is essential. No solution lookup needed; the answer lives on the crossword.

### 3. `app/views/crosswords/show.html.haml` — Add 3 dropdown items

Extend the existing Admin dropdown (lines 101-103). Add separator + new items:

```haml
      - if is_admin?
        .xw-dropdown{data: {controller: 'dropdown'}}
          %button.xw-btn.xw-btn--sm.xw-btn--ghost{data: {action: 'click->dropdown#toggle'}}
            = icon('tool')
            Admin ▾
          %ul.xw-dropdown-menu{data: {dropdown_target: 'menu'}}
            %li
              %a#admin-fake-win{:href => "#"} Fake Win
            %hr
            %li
              %a#admin-reveal-puzzle{:href => "#"} Reveal Puzzle
            %li
              %a#admin-clear-puzzle{:href => "#"} Clear Puzzle
            %hr
            %li
              %a#admin-flash-cascade{:href => "#"} Flash Cascade
```

**Grouping:**
- **Fake Win** — experience testing (top, separated)
- **Reveal Puzzle / Clear Puzzle** — puzzle state manipulation (middle group)
- **Flash Cascade** — visual effect testing (bottom, separated)

### 4. `app/assets/javascripts/crosswords/solve_funcs.js` — Add 3 handlers + bindings

**Click bindings** — add after existing `$('#admin-fake-win')` binding (~line 59):

```javascript
$('#admin-fake-win').on('click', solve_app.fake_win);
$('#admin-reveal-puzzle').on('click', solve_app.reveal_puzzle);
$('#admin-clear-puzzle').on('click', solve_app.clear_puzzle);
$('#admin-flash-cascade').on('click', solve_app.flash_cascade);
```

**Handler functions** — add after `fake_win` function (~line 300), before `add_comment_or_reply`:

```javascript
// Admin-only: fill all cells with correct letters.
// Sets letter text directly (not via set_letter) to avoid 225 individual
// team broadcasts and per-cell check_finisheds calls. Batches the
// crossing-off into a single check_all_finished() call at the end.
reveal_puzzle: function(e) {
  e.preventDefault();
  $.ajax({
    dataType: 'json',
    type: 'POST',
    url: "/crosswords/" + solve_app.crossword_id + "/admin_reveal_puzzle",
    success: function(data) {
      var letters = data.letters;
      var $cells = $('.cell');
      $cells.each(function(index) {
        var $cell = $(this);
        if (!$cell.hasClass('void')) {
          $cell.children('.letter').first().text(letters[index]);
        }
      });
      // Clear any check flags from previous checks
      $cells.removeClass('flagged incorrect correct cell-flash');
      // Cross off all clues (all words are now complete)
      solve_app.check_all_finished();
      // Mark as unsaved — auto-save will fire within 5s
      solve_app.update_unsaved();
      cw.flash('Puzzle revealed!', 'success');
    },
    error: function(xhr) {
      if (xhr.status === 403) {
        cw.flash('Admin access required.', 'error');
      } else {
        cw.flash('Reveal failed.', 'error');
        console.warn('admin_reveal_puzzle failed:', xhr.status);
      }
    }
  });
},

// Admin-only: clear all letters and reset visual state.
// Pure client-side — no server endpoint needed.
clear_puzzle: function(e) {
  e.preventDefault();
  // Clear all letters from non-void cells
  $('.cell:not(.void)').each(function() {
    $(this).children('.letter').first().empty();
  });
  // Clear check flags from all cells
  $('.cell').removeClass('flagged incorrect correct cell-flash');
  // Un-cross-off all clues
  $('.crossed-off').removeClass('crossed-off');
  // Mark as unsaved — auto-save will fire within 5s
  solve_app.update_unsaved();
  cw.flash('Puzzle cleared.', 'info');
},

// Admin-only: trigger golden flash cascade across all non-void cells.
// Pure client-side — reuses apply_mismatches with synthetic data.
// All values set to false (correct) so no flag classes are applied —
// only the golden flash animation sweeps the grid.
flash_cascade: function(e) {
  e.preventDefault();
  var mismatches = {};
  $('.cell').each(function(index) {
    if (!$(this).hasClass('void')) {
      mismatches[index] = false;
    }
  });
  solve_app.apply_mismatches({ mismatches: mismatches });
},
```

### 5. Tests — `spec/requests/crosswords_spec.rb`

Add a describe block for `admin_reveal_puzzle`. Clear Puzzle and Flash Cascade are client-side only — no server specs needed.

```ruby
describe 'POST /crosswords/:id/admin_reveal_puzzle' do
  let_it_be(:crossword) { create(:crossword, rows: 5, cols: 5) }

  context 'when admin' do
    let(:admin) { create(:user, :with_test_password, is_admin: true) }
    before { log_in_as(admin) }

    it 'returns the correct letters' do
      post admin_reveal_puzzle_crossword_path(crossword),
           headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['letters']).to eq(crossword.letters)
      expect(json['letters'].length).to eq(crossword.rows * crossword.cols)
    end
  end

  context 'when non-admin' do
    let(:user) { create(:user, :with_test_password) }
    before { log_in_as(user) }

    it 'returns forbidden' do
      post admin_reveal_puzzle_crossword_path(crossword),
           headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:forbidden)
    end
  end

  context 'when not logged in' do
    it 'returns forbidden' do
      post admin_reveal_puzzle_crossword_path(crossword),
           headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:forbidden)
    end
  end
end
```

---

## Execution order

| # | Step | Files | Risk |
|---|---|---|---|
| 1 | Add route | `routes.rb` | None — additive |
| 2 | Add controller action | `crosswords_controller.rb` | Low — 5-line action with admin guard |
| 3 | Add HAML dropdown items | `show.html.haml` | None — inside existing `- if is_admin?` block |
| 4 | Add JS handlers + bindings | `solve_funcs.js` | Low — 3 new functions, 3 no-op bindings for non-admins |
| 5 | Add tests | `crosswords_spec.rb` | None |

All steps are purely additive. No existing behavior is modified.

---

## Interaction with existing features

### Reveal Puzzle → then Check Completion
After Reveal, all cells contain correct letters. Auto-save fires → `check_completion` callback marks `is_complete = true`. Clicking "Check → Completion" will then show the real win modal (not the admin Fake Win). This provides a way to test the **genuine** win pathway.

### Reveal Puzzle → then Check Puzzle
After Reveal, "Check → Entire Puzzle" will show the golden flash cascade with all cells correct — no error flags. Useful for seeing the flash on a fully-correct grid.

### Clear Puzzle → then Reveal Puzzle
Admin can cycle between empty and filled states without leaving the page. Useful for testing different puzzle states.

### Flash Cascade → on empty grid
Flash sweeps across all cells even when empty. The mismatches are all `false` (correct), so no flags. Pure visual effect.

### Flash Cascade → on grid with existing errors
If admin has previously run "Check Puzzle" and cells have `incorrect` flags, Flash Cascade will re-flash all cells. The `false` mismatch value will flip any `incorrect` cells to `correct` (since `apply_mismatches` adds `correct` class when cell has `incorrect`). This is a minor side effect but acceptable — admin is testing visuals.

**Note on that last point:** If this side effect is undesirable, the Flash Cascade could strip `incorrect`/`correct`/`flagged` classes before running. But since it's an admin tool, the simpler approach (reuse `apply_mismatches` as-is) is better. The admin can run "Clear Puzzle" to reset flag state.

---

## Risks & mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| Reveal endpoint leaks answer key | Critical if no guard | `return head :forbidden unless @current_user&.is_admin` — same pattern as `admin_fake_win`. Tested with non-admin and anonymous specs. |
| Reveal floods team channel | None | Letters set via direct DOM `.text()`, not `set_letter(letter, true)`. No team broadcasting. |
| Reveal causes 225 `check_finisheds` calls | None | Avoided by using `.text()` instead of `set_letter()`. Single `check_all_finished()` call at end. |
| Clear doesn't un-mark `is_complete` | Low | By design — `check_completion` callback only sets `true`, never reverts. Admin can delete solution for true reset. Documented in architecture decisions above. |
| Flash Cascade flips error flags to correct | Low | Side effect of reusing `apply_mismatches`. Admin tool — acceptable. Can run Clear Puzzle to reset. |
| No-op bindings for non-admin | None | `$('#admin-reveal-puzzle')` matches nothing when element isn't rendered. jQuery silently ignores. |

---

## What stays the same

- **Fake Win** — unchanged, still first item in dropdown
- **Check dropdown** — unchanged, works normally
- **Non-admin experience** — completely unchanged (dropdown not rendered)
- **Existing admin_fake_win specs** — no modifications
- **`apply_mismatches` function** — reused as-is (not modified)
- **`check_all_finished` function** — reused as-is (not modified)
- **Solution model** — no changes

---

## Acceptance criteria

1. Admin dropdown shows 4 items: Fake Win, Reveal Puzzle, Clear Puzzle, Flash Cascade
2. Reveal Puzzle fills all cells with correct letters and crosses off all clues
3. Clear Puzzle empties all cells, removes check flags, un-crosses-off clues
4. Flash Cascade triggers golden sweep across all non-void cells
5. Non-admin POST to `/admin_reveal_puzzle` returns 403
6. Reveal + auto-save correctly triggers `is_complete` via `check_completion` callback
7. `bundle exec rspec` passes with new specs

---

## Future: Set Timer (deferred)

**What:** Modify `solution.created_at` to simulate different solve durations for timer display testing.

**Why deferred:** Higher risk (modifying timestamps with `update_column`), needs UI for duration selection (sub-menu or prompt), and the admin can already test timer display by combining Fake Win with their actual solution time. The ROI is lower than the other 3 tools.

**If built later:** `POST /crosswords/:id/admin_set_timer` with `duration` param in minutes. Controller uses `solution.update_column(:created_at, solution.updated_at - duration.minutes)` to skip callbacks. Dropdown items could be presets: "1 min", "30 min", "2 hours", "3 days".
