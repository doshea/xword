# Review: New Puzzle Form (`/unpublished_crosswords/new`)

**Reviewer:** Planner · 2026-03-04
**Scope:** Style, UX, a11y, logic
**Files:** `unpublished_crosswords/new.html.haml`, `partials/_new_form.html.haml`,
`new_crossword.scss`, `crosswords/new.js`, `spin.min.js` (vendor),
`unpublished_crosswords_controller.rb` (new/create actions)

---

## Executive Summary

The form itself is well-structured — BEM naming, design tokens throughout, responsive
breakpoints. But there are two significant issues: (1) the preview grid's void-toggle
feature is **completely non-functional** (data is never sent to the server), and (2) the
submit spinner uses a **legacy vendor library** (`spin.min.js`) that should be replaced
with the standard `.xw-spinner` pattern. Several smaller UX and a11y gaps round out
the findings.

---

## Findings

### 1. Preview void toggling is cosmetic — data never submitted
**Severity: must-fix (misleading UX)**

The preview grid lets users click cells to toggle a `void` CSS class, suggesting they
can pre-configure the puzzle's void layout before creation. **This is a lie.** The form
only submits `title`, `rows`, `cols`, and `description`. The void state is never
serialized or sent to the server. `create_params` doesn't permit it. The controller
creates a puzzle with zero void cells regardless.

**Evidence:**
- `_new_form.html.haml` — no hidden fields for void data
- `new.js` — `generate_puzzle_overlay` (the submit handler) does not serialize void state
- `create_params` → `permit(:title, :rows, :cols, :description)` — no void data accepted
- `before_create :populate_arrays` initializes all cells as empty strings (no voids)

**Decision point for user:** Two valid fixes exist:
- **Option A — Wire it up:** Serialize void cell positions as a hidden field, accept in
  `create_params`, apply during `populate_arrays`. ~Medium effort (JS serialization +
  controller + model changes).
- **Option B — Remove the affordance:** Remove the `cursor: pointer` and click handler
  from preview cells. Make the preview purely visual (read-only). ~Trivial effort.

**Recommendation:** Option B. The edit page has full void-toggling capability with
mirror mode, one-click-void, etc. Pre-configuring voids on a blank grid before creation
has marginal value. Remove the misleading interaction, keep the preview as a size
visualizer only.

---

### 2. Replace `spin.min.js` with `.xw-spinner`
**Severity: should-fix (tech debt / consistency)**

The submit overlay uses vendor `spin.min.js` (a full spinner library loaded as a separate
`<script>` tag) to render a canvas-based spinner. The rest of the app uses `.xw-spinner`
(a 12-line pure-CSS rotating border). This is the **only page** that loads `spin.min.js`.

**Current behavior:** On submit, all children of `.spin-target` fade to opacity 0, then
a `Spinner` is created and two headings are injected: "Generating Puzzle" and a joke
process name ("Reticulating splines"). The joke array has a second entry ("barfing") that
is **never shown** — only `clever_processes[0]` is used.

**Replacement approach:**
1. Delete `= javascript_include_tag 'spin.min'` from the view
2. Delete `vendor/assets/javascripts/spin.min.js`
3. Replace `generate_puzzle_overlay` with: fade children, then show a centered
   `.xw-spinner` + "Creating puzzle…" text. Can reuse the existing `.spin-target`
   positioning CSS, just swap the spinner element.
4. Add `data: { disable_with: 'Creating…' }` on the submit button (matches pattern
   from login/signup/account forms) as a belt-and-suspenders guard.

---

### 3. Validation errors lose form state
**Severity: should-fix (UX)**

On save failure, the controller redirects back to `new` with a flash error:
```ruby
redirect_to new_unpublished_crossword_path, flash: {error: 'There was a problem...'}
```

This loses all user input. The standard Rails pattern is to re-render the form:
```ruby
render :new, status: :unprocessable_entity
```

This preserves the `@ucw` object with its errors and previously-entered data. The flash
banner also renders (layout handles it), but field-level errors would be better UX.

**Fix:**
- Change `redirect_to` → `render :new, status: :unprocessable_entity`
- Optionally add error display to the form (Rails `@ucw.errors` messages above the form
  or per-field with `.xw-input--error` / `.xw-field-error` classes which already exist
  in `_components.scss` but are unused here)

---

### 4. Submit button missing `disable_with`
**Severity: should-fix (consistency / double-submit prevention)**

Every other form in the app uses `data: { disable_with: '...' }` on submit buttons:
- Login: `'Logging in…'`
- Signup: `'Creating account…'`
- Account: `'Saving…'`

The new puzzle form's submit button has no `disable_with`:
```haml
= f.submit 'Create Crossword', class: 'xw-btn xw-btn--success xw-newcw-form__submit'
```

**Fix:** Add `data: { disable_with: 'Creating…' }`. This works alongside the spinner
overlay — the button disables immediately while the overlay fades in.

---

### 5. Preview grid accessibility
**Severity: suggestion (a11y)**

If void toggling is removed (finding #1, Option B), the preview becomes a passive
visualization and needs no interaction a11y. But currently:
- Clickable cells have no `role`, `aria-label`, or keyboard support
- Void state changes are not announced to screen readers
- The grid has no `role="grid"` or `aria-label`

If Option B is chosen, add `aria-hidden="true"` to `#preview-crossword` since it's
decorative. If Option A is chosen, full grid a11y (roles, labels, keyboard nav) would
be needed — another reason to prefer Option B.

---

### 6. Script tags in body instead of head
**Severity: nitpick**

```haml
= javascript_include_tag 'spin.min'
= javascript_include_tag 'crosswords/new', 'data-turbo-track': 'reload'
```

These are outside `content_for :head`, so they render in `<body>`. This works but is
inconsistent with the stylesheet (which correctly uses `content_for :head`). Moving them
into the `content_for :head` block would be cleaner and follow the pattern of other
page-specific JS (e.g., `account.html.haml`).

If `spin.min.js` is removed (finding #2), only one script tag remains to move.

---

### 7. Preview grid hardcoded pixel math
**Severity: nitpick**

`.preview-row { width: 360px }` assumes 30 columns × 12px = 360px. If `MAX_DIMENSION`
ever changes, the grid breaks. Not urgent (MAX_DIMENSION is unlikely to change), but
worth a comment in the CSS or using `calc(#{Crossword::MAX_DIMENSION} * 12px)` via ERB
(would require renaming to `.scss.erb`).

The float-based layout with negative margins (`margin: 1px -2px -2px 1px`) is fragile
but functional. A modern `display: grid` or `flexbox` approach would be cleaner but
this is cosmetic and not worth the effort alone.

---

### 8. Spinner overlay text issues
**Severity: nitpick (moot if spin.js is removed)**

- `clever_processes` array has `['Reticulating splines', 'barfing']` — only index 0 is
  ever used. "barfing" is never shown. The array and rotation logic were never completed.
- "Reticulating splines" is a classic SimCity joke; "barfing" is just odd.
- The overlay injects `<h2>` and `<h6>` directly into the DOM without any BEM class — the
  CSS targets them with `.spin-target > h2` / `.spin-target > h6` (tag selectors, not
  class selectors). This is fine since the overlay is transient, but it's the only place
  in the codebase that uses heading-tag selectors for styling.

---

## What's Good

- **CSS is fully tokenized.** Every color, font, spacing, shadow, and radius uses design
  tokens. No hardcoded values. This is excellent.
- **BEM naming is consistent.** `xw-newcw-card`, `xw-newcw-layout`, `xw-newcw-form` — all
  properly namespaced and structured.
- **Responsive breakpoints work.** Form stacks on tablet, preview shrinks on mobile.
  The two breakpoints (`$bp-lg`, `$bp-sm`) are appropriate.
- **Form uses established patterns.** `.xw-field`, `.xw-label`, `.xw-input`, `.xw-btn`
  classes match every other form in the app.
- **Turbo Drive compatibility is handled.** The `turbo:load` listener with dedup guard
  and immediate-execution fallback is the correct pattern for page-specific jQuery.
- **Preview grid responds to dimension changes.** The `change` handler on rows/cols
  immediately shows/hides cells. Nice feedback.
- **Server-side validation exists.** `Crosswordable` validates rows/cols (4–30, integer)
  and title (3–35 chars, present). The HTML `min`/`max`/`required` attributes match.

---

## Implementation Order (for Builder)

1. **Controller fix** — change `redirect_to` → `render :new` on failure (finding #3)
2. **Add `disable_with`** to submit button (finding #4)
3. **Remove void toggle** from preview (finding #1, Option B) — remove JS click handler,
   remove `cursor: pointer` from `.preview-cell`, add `aria-hidden="true"` to
   `#preview-crossword` (finding #5)
4. **Replace spinner** — delete `spin.min.js`, rewrite overlay with `.xw-spinner`
   (finding #2), move JS include into `content_for :head` (finding #6)
5. **Optional:** Add inline error display with `.xw-input--error` for validation failures

**Estimated scope:** Small — 4 files touched, no model changes, no migrations.
