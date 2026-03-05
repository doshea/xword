# P3-E: Loading State Spinners

## Problem

Three locations show text-only "Loading..." with no visual spinner. The `xw-spinner` CSS class
exists and works (used in edit save, solve save, new puzzle overlay). These 3 locations just
need the spinner markup added.

---

## Location 1: Home Page "Load next X puzzles" Button

**File:** `app/views/pages/home/_load_more_button.html.haml` (line 3)

**Current:**
```haml
= button_to "Load next #{next_batch} puzzles", home_load_more_path, params: {scope: scope, page: page}, class: 'xw-btn xw-btn--secondary xw-btn--full', data: {disable_with: 'Loading...'}
```

**Fix:** Change `disable_with` to include spinner HTML:
```haml
= button_to "Load next #{next_batch} puzzles", home_load_more_path, params: {scope: scope, page: page}, class: 'xw-btn xw-btn--secondary xw-btn--full', data: {disable_with: '<span class="xw-spinner"></span> Loading...'}
```

**How it works:** `button_to` generates a `<button>` element. Turbo's form submission adapter
replaces the button's innerHTML with the `data-disable-with` value. HTML renders correctly
because it's set via innerHTML, not textContent. This is the same mechanism used by all other
`disable_with` buttons in the app — the only difference is we're adding a spinner span.

**Verify:** If HTML appears escaped (literal `<span>` text visible), switch to
`data: { turbo_submits_with: '<span class="xw-spinner"></span> Loading...' }` instead.

---

## Location 2: NYT Lazy Tab Placeholder

**File:** `app/views/pages/nytimes.html.haml` (lines 39-40)

**Current:**
```haml
.xw-loading-placeholder
  %p Loading…
```

**Fix:** Add spinner before text, add minimal styling:
```haml
.xw-loading-placeholder
  %span.xw-spinner
  %p Loading…
```

**CSS needed** — `.xw-loading-placeholder` has NO styles defined anywhere. Add to
`app/assets/stylesheets/global.scss.erb` (near the existing `.xw-spinner` definition, ~line 183):

```scss
.xw-loading-placeholder {
  padding: var(--space-8) var(--space-4);
  text-align: center;
  color: var(--color-text-secondary);

  .xw-spinner {
    display: block;
    margin: 0 auto var(--space-3);
    width: 1.5em;
    height: 1.5em;
  }
}
```

**Existing spec** at `spec/requests/pages_spec.rb:285` asserts `xw-loading-placeholder` class
is present — no spec changes needed.

---

## Location 3: Search Form Submit Button

**File:** `app/views/pages/search.html.haml` (line 42)

**Current:** Uses `loading` Stimulus controller, which swaps button text to "Loading…" and
disables. No spinner.

**Fix option A (recommended):** Update the `LoadingController` to inject a spinner alongside
the text. This benefits ALL forms using the loading controller (currently: search + comment form).

**File:** `app/assets/javascripts/controllers/loading_controller.js`

```javascript
submit() {
  if (!this.hasButtonTarget) return;
  var btn = this.buttonTarget;
  this._originalHTML = btn.innerHTML;
  this._originalValue = btn.value;
  btn.disabled = true;
  // For <input type="submit"> (has value), swap value
  if (btn.tagName === 'INPUT') {
    btn.value = 'Loading\u2026';
  }
  // For <button>, inject spinner into innerHTML
  else {
    btn.innerHTML = '<span class="xw-spinner"></span> Loading\u2026';
  }
}

_restore() {
  if (!this.hasButtonTarget) return;
  var btn = this.buttonTarget;
  btn.disabled = false;
  if (btn.tagName === 'INPUT' && this._originalValue) {
    btn.value = this._originalValue;
  } else if (this._originalHTML) {
    btn.innerHTML = this._originalHTML;
  }
}
```

**Why update the controller:** The search button is `<input type="submit">` (from `submit_tag`),
so the current `.value` swap works. But P3-H will add `<button>` targets to comment forms,
and the current controller silently fails on `<button>` text swap (`.value` on `<button>`
changes the form value, not displayed text). Fixing now prevents that bug.

**Fix option B (minimal):** If touching the controller feels risky, just change the search
button's `disable_with` attribute instead:
```haml
= submit_tag 'Search', class: 'xw-btn xw-btn--success xw-search-hero__submit', data: { loading_target: 'button', disable_with: '<span class="xw-spinner"></span> Searching...' }
```
This gives the search button a spinner via `disable_with` and leaves the loading controller
unchanged. Downside: the loading controller still won't work for `<button>` elements (P3-H).

**Recommendation:** Option A. The controller fix is 10 extra lines and prevents a latent bug.

---

## Files Touched (Summary)

| File | Change |
|------|--------|
| `app/views/pages/home/_load_more_button.html.haml` | Add spinner HTML to `disable_with` |
| `app/views/pages/nytimes.html.haml` | Add `%span.xw-spinner` to placeholder |
| `app/assets/stylesheets/global.scss.erb` | Add `.xw-loading-placeholder` styles (~6 lines) |
| `app/assets/javascripts/controllers/loading_controller.js` | Handle `<button>` vs `<input>` in submit/restore |

## Acceptance Criteria

1. Home load-more button shows spinner + "Loading..." text while loading
2. NYT lazy tabs show centered spinner + "Loading…" text in unloaded panels
3. Search button shows spinner during form submission
4. All existing loading controller usage still works (comment form)
5. `bundle exec rspec` passes

## Deploy Notes

Deploy 3 with P3-C (if not already deployed). No migration needed.
