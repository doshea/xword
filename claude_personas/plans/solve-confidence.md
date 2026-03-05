# P3-A: Solve Confidence — Plan

**Reviewed by:** Planner, 2026-03-05
**Scope:** `solve_funcs.js`, `crossword.scss.erb` (optional: `edit_funcs.js`)
**Estimated time:** ~30 min build

---

## Problem

Users solving puzzles get zero feedback when network requests fail. The 4 check
actions (`check_cell`, `check_word`, `check_puzzle`, `check_completion`) only
`console.warn()` on error — users click "Check" and nothing visibly happens. Auto-save
retries silently forever with no escalation. A pre-built save-success animation exists
in CSS but was never wired up.

## Audit Summary

| AJAX Call | Current Error Feedback | Severity |
|-----------|----------------------|----------|
| `save_solution` (L149) | `$('#save-status').text('Save failed')` — status text only, easy to miss | suggestion |
| `check_cell` (L266) | `console.warn()` only | **should-fix** |
| `check_word` (L298) | `console.warn()` only | **should-fix** |
| `check_puzzle` (L317) | `console.warn()` only | **should-fix** |
| `check_completion` (L351) | `console.warn()` only | **should-fix** |
| `reveal_cell` (L485) | `cw.flash('Reveal failed.', 'error')` | ✅ already good |
| `hint_word` (L537) | `cw.flash('Hint failed.', 'error')` | ✅ already good |
| `fake_win` (L379) | `cw.flash()` | ✅ already good (admin) |
| `reveal_puzzle` (L417) | `cw.flash()` | ✅ already good (admin) |

**Edit page verdict:** Does NOT need work. All 3 edit AJAX calls already have user-visible
error feedback (icon + fade for title, `cw.flash()` for description and puzzle save). Only
minor gap is `update_description` lacking success feedback — not worth fixing.

---

## Deliverables (3 items)

### 1. AJAX error callbacks → `cw.flash()` — should-fix

Add `cw.flash()` calls to the 4 check error handlers. Keep the `console.warn()` for
debugging. The error message should be action-specific so users know what failed.

**Exact changes in `solve_funcs.js`:**

```javascript
// check_cell (line 266) — replace:
error: function(xhr) { console.warn('check_cell failed:', xhr.status); },
// with:
error: function(xhr) {
  cw.flash('Check failed — please try again.', 'error');
  console.warn('check_cell failed:', xhr.status);
},

// check_word (line 298) — replace:
error: function(xhr) { console.warn('check_word failed:', xhr.status); },
// with:
error: function(xhr) {
  cw.flash('Check failed — please try again.', 'error');
  console.warn('check_word failed:', xhr.status);
},

// check_puzzle (line 317) — replace:
error: function(xhr) { console.warn('check_puzzle failed:', xhr.status); },
// with:
error: function(xhr) {
  cw.flash('Check failed — please try again.', 'error');
  console.warn('check_puzzle failed:', xhr.status);
},

// check_completion (line 351) — replace:
error: function(xhr) { console.warn('check_completion failed:', xhr.status); },
// with:
error: function(xhr) {
  cw.flash('Check failed — please try again.', 'error');
  console.warn('check_completion failed:', xhr.status);
},
```

**Design decision — one message for all 4:** "Check failed — please try again." Users don't
distinguish between check-cell and check-word at the network layer. One consistent message
is less confusing than four variations. Matches the existing pattern (`'Reveal failed.'`,
`'Hint failed.'`).

### 2. Consecutive save failure banner — should-fix

Track consecutive auto-save failures. After 3 in a row, show a persistent warning. Reset
on success. This prevents silent data loss on flaky networks.

**Exact changes in `solve_funcs.js`:**

```javascript
// In solve_app object (near line 14, alongside save_counter):
save_fail_count: 0,

// In save_solution success handler (line 138, inside the counter-match block):
// Add as first line:
solve_app.save_fail_count = 0;

// In save_solution error handler (line 149), replace entire block:
error: function(xhr) {
  $('#save-status').text('Save failed');
  $('#save-clock').empty();
  solve_app.save_fail_count++;
  if (solve_app.save_fail_count >= 3) {
    cw.flash('Unable to save — check your connection.', 'error', 0);
  }
  console.warn('save_solution failed:', xhr.status, xhr.statusText);
},
```

**Key details:**
- `duration: 0` makes the banner persistent (manual dismiss only via × button)
- Counter resets to 0 on any successful save (auto or manual)
- `unsaved_changes` stays true on failure → auto-save retries every 5s (existing behavior, correct)
- The persistent flash will stack if the user doesn't dismiss, but since `cw.flash` prepends
  before `#crossword`, a user who dismisses the first one and keeps getting failures will see
  a new one after 3 more failures. This is acceptable — it means "still can't save."

**Alternative considered:** Show the flash after every failure (not just 3). Rejected because
the 15s AJAX timeout + 5s retry = a flash every 20s, which would be spammy on brief
network hiccups. 3 consecutive failures ≈ 60s+ of downtime, which is worth alarming on.

### 3. Manual save success animation — nitpick (free win)

Wire up the existing `.xw-btn--saved` CSS animation (crossword.scss.erb L1269) to fire
after a successful manual save.

**Exact changes in `solve_funcs.js`:**

```javascript
// In save_solution success handler, after log_save() and update_clock() (around line 141):
// Add inside the try block, after update_clock():
if (e) {
  var $saveBtn = $('#solve-save');
  $saveBtn.addClass('xw-btn--saved');
  $saveBtn.one('animationend', function() { $saveBtn.removeClass('xw-btn--saved'); });
}
```

**Problem:** The `e` variable from the outer `save_solution(e)` function is available in the
success closure, but we need to verify it's still truthy. Since `e` is the click event from
the manual save button, it will be truthy for manual saves and undefined for auto-saves.
This is correct — auto-saves should NOT pulse the button.

**CSS is already done:**
- `.xw-btn--saved` → 0.6s green pulse animation (L1269-1277)
- `prefers-reduced-motion: reduce` disables it (L1281)
- `--color-success` and `--color-success-bg` tokens already exist

**Why `animationend` instead of `setTimeout`:** Respects the actual animation duration.
If the CSS timing changes, the class removal stays in sync. Also, `prefers-reduced-motion`
disables the animation entirely — `animationend` fires immediately, so the class is cleaned
up instantly rather than lingering for 600ms doing nothing.

---

## Edit page — also apply save pulse? (optional, low priority)

The edit page `save_puzzle` (edit_funcs.js L121) has the same pattern: manual save with
spinner → success → restore icon. The `.xw-btn--saved` pulse could be applied to `#edit-save`
too. Same 3-line change. Builder can include this if convenient — it's a bonus, not a
requirement.

---

## Files to Touch

| File | Changes |
|------|---------|
| `app/assets/javascripts/crosswords/solve_funcs.js` | All 3 deliverables |
| `app/assets/javascripts/crosswords/edit_funcs.js` | Optional: save pulse on `#edit-save` |

**No CSS changes needed.** All styles already exist.

## Acceptance Criteria

1. Clicking Check Cell/Word/Puzzle when offline shows "Check failed — please try again." error flash
2. Clicking "Am I done?" when offline shows the same error flash
3. After 3 consecutive auto-save failures, a persistent red banner appears: "Unable to save — check your connection."
4. The banner has a dismiss button (× from `cw.flash`)
5. After a successful save following failures, the failure counter resets (no more banners)
6. Clicking the manual Save button shows a green pulse on success
7. Auto-saves do NOT trigger the green pulse
8. All existing behavior unchanged: spinner on manual save, status text updates, stale-save guard

## Test Approach

These are all JS-only changes with no server-side component. Testing options:
- **Manual testing** with browser DevTools Network throttling (offline mode) is sufficient
  for the 3 deliverables — all are visual feedback changes
- No new Rails specs needed — server responses are unchanged
- If the team adds JS unit tests later, the `save_fail_count` logic is the most testable unit

## Risks

- **Low:** `cw.flash()` inserts DOM elements before `#crossword`. If the grid layout is tight,
  stacked flash banners could push content down. Mitigated by the 3-failure threshold
  (at most 1 persistent banner) and auto-dismiss on success flashes.
- **None:** No server-side changes. No migration. No new dependencies.
