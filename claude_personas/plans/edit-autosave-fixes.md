# Plan: Fix Edit Page Autosave Icon — 3 Issues

## Issues Found

### Issue 1: Edit save button uses wrong style variant
**Solve page:** `xw-btn--ghost` (text-only, transparent bg/border — just the floppy icon)
**Edit page:** `xw-btn--secondary` (outlined with visible border)

The ghost variant is correct — the save button should be a quiet toolbar icon, not an outlined button.

### Issue 2: Double-wide gap between "Saved" span and time-ago span
**Root cause:** The `$('#save-status').text('Saved ')` call puts a trailing space *inside* the span, AND the flex container adds `gap: 0.5em` between the two sibling spans. So the visual space is: trailing space character (~0.2em) + flex gap (0.5em) ≈ double.

Both pages have this same text (`'Saved '`), but the Solve page uses `gap: var(--space-2)` (0.5rem = 8px) while the Edit page uses `gap: 0.5em`. The real visual difference is probably negligible — the trailing space in the text is the actual culprit adding extra width on both pages. But since the user notices it on Edit, we should fix it properly.

**Fix:** Remove trailing space from `'Saved '` text in edit_funcs.js. The flex gap already provides spacing. (Should also fix it in solve_funcs.js for consistency — same pattern, same fix.)

### Issue 3: Save status text is left-justified instead of right-aligned
**Root cause comparison:**

**Solve page layout:**
```
.xw-col-full (flex, justify-content: space-between)
  ├─ h1 (title + creator credit)
  └─ #puzzle-controls (naturally pushed right by space-between)
```

**Edit page layout:**
```
.xw-edit-header (flex, gap: 0.75em, flex-wrap: wrap)
  ├─ label "Title:"
  ├─ .xw-edit-header__title (flex: 1, contains input)
  └─ #puzzle-controls (has margin-left: auto in CSS)
```

The Edit CSS already has `margin-left: auto` on `#puzzle-controls`, which *should* push it right. But `#puzzle-controls` is nested inside `.xw-edit-header` which is `flex-wrap: wrap`. On narrower viewports or when the title input is wide enough, the controls could wrap to a new line and `margin-left: auto` on a wrapped item pushes it right — but if there's remaining flex space on the same line, it should also work.

**Wait** — let me re-check the HAML nesting. The HAML shows:
```haml
.xw-edit-header
  %label...
  .xw-edit-header__title
    = text_field_tag...
    %i#title-status
  #puzzle-controls    ← child of .xw-edit-header
```

And the CSS `.xw-edit-header #puzzle-controls` has `margin-left: auto`. This should work... unless `flex-wrap: wrap` is causing it to wrap onto its own line and then `margin-left: auto` doesn't help because there's no flex sibling on that line pushing from the left.

Actually, re-reading: when a flex item wraps to a new line, `margin-left: auto` pushes it to the right edge of that line. So it should be right-aligned even when wrapped.

**Most likely issue:** The `#puzzle-controls` is indeed on the same line as the title input, but `__title` has `flex: 1` which consumes all remaining space. With `gap: 0.75em` and `margin-left: auto` on `#puzzle-controls`, the controls sit right after the title's flex-grown space. This should work correctly...

Unless the issue is that `.xw-edit-header` is wrapping on some viewport sizes, and when the controls wrap to their own line, they left-align because `margin-left: auto` isn't there or not working. Let me verify:

The CSS selector is `.xw-edit-header #puzzle-controls { margin-left: auto; }` — this is correct.

**Alternative diagnosis:** Could `flex-wrap: wrap` be causing `#puzzle-controls` to start a new line left-aligned? If it wraps, `margin-left: auto` should still push it right. But if the flex container itself doesn't have `width: 100%` or isn't taking full width... Let me check — `.xw-edit-header` is a child of `.xw-col-full` which is a grid column. It should be full width.

This needs a visual check in the browser to confirm what's happening. But the CSS looks correct in theory.

**Possible real cause:** If `flex-wrap: wrap` causes the controls to land on a new line, AND the container has `align-items: center` (which it does), the controls wrap starting from the left. `margin-left: auto` should push them right. If the user sees them hugging the title, they might be on the same line but the visual gap between the title field and controls is small.

Actually, I think the real issue might be simpler: the `.xw-edit-header` has `gap: 0.75em` which is relatively tight. The controls sit right after the `flex: 1` title div, so they're pushed to the far right. Unless the title div isn't actually growing...

**Let me reconsider.** The user says "left justified and hugging the title" — this means the controls are right next to the title, not pushed to the right edge. This would happen if `margin-left: auto` is somehow not taking effect, OR if the parent isn't wide enough.

The `.xw-col-full` in the Solve page's `#credit-area` has `display: flex; justify-content: space-between;` — that's what pushes `#puzzle-controls` to the right on Solve.

On Edit, `.xw-edit-header` doesn't have `justify-content: space-between`. It relies on `margin-left: auto` on `#puzzle-controls`. These should be equivalent... unless `margin-left: auto` is being overridden.

**Check:** Is there a more general `#puzzle-controls` rule in `crossword.scss.erb` that might interfere? Yes! `crossword.scss.erb` lines 40-52 define `#credit-area #puzzle-controls` — but that's scoped to `#credit-area`. The edit page also loads `crossword.scss.erb` (via `stylesheet_link_tag :crossword` on line 3 of edit.html.haml). So the `#credit-area #puzzle-controls` rule has higher specificity but shouldn't apply since the Edit page has the same `#credit-area` wrapper.

Wait — the Edit page DOES have `#credit-area`:
```haml
%header.xw-container.xw-grid#credit-area
  .xw-col-full
    .xw-edit-header
      ...
      #puzzle-controls
```

So the specificity chain is: `#credit-area .xw-col-full` from crossword.scss.erb applies:
```scss
#credit-area {
  .xw-col-full {
    display: flex;
    flex-wrap: wrap;
    align-items: baseline;
    justify-content: space-between;
    gap: var(--space-2);
  }
}
```

But `.xw-col-full` has only ONE child on the Edit page: `.xw-edit-header`. So `justify-content: space-between` has nothing to push apart — there's only one flex child.

The `.xw-edit-header` flex container then handles the internal layout with its own `display: flex`. And `#puzzle-controls` inside `.xw-edit-header` has `margin-left: auto`.

**This should work.** But if `.xw-edit-header` isn't taking full width of `.xw-col-full`, then `margin-left: auto` can only push within the available space.

Hmm — `.xw-edit-header` is a flex child of `.xw-col-full` and `.xw-col-full` has `display: flex`. By default, flex children stretch in the cross axis but don't necessarily take full width on the main axis. Since `.xw-col-full` is `flex-wrap: wrap`, `.xw-edit-header` gets its natural width unless we tell it to grow.

**THAT'S THE BUG.** `.xw-edit-header` is the sole child of a flex container (`.xw-col-full`), but it doesn't have `flex: 1` or `width: 100%`, so it only takes its content width. `margin-left: auto` on `#puzzle-controls` inside it can only push within the header's natural width, not to the edge of the container.

**Fix:** Add `width: 100%` to `.xw-edit-header` (or target it from `#credit-area .xw-col-full > .xw-edit-header`).

---

## Plan — 3 Changes

### Change 1: Match button style (HAML)
**File:** `app/views/unpublished_crosswords/edit.html.haml` line 28

```haml
# Before:
%a#edit-save.xw-btn.xw-btn--sm.xw-btn--secondary{href: '#', title: 'Quicksave', aria: {label: 'Quicksave'}}

# After:
%a#edit-save.xw-btn.xw-btn--sm.xw-btn--ghost{href: '#', data: {'xw-tooltip': 'Save'}, aria: {label: 'Save'}}
```

Also matches tooltip pattern (uses `data-xw-tooltip` like Solve, not `title`).

### Change 2: Remove trailing space in "Saved" text (JS)
**File:** `app/assets/javascripts/crosswords/edit_funcs.js` line 179

```javascript
// Before:
$('#save-status').text('Saved ');
// After:
$('#save-status').text('Saved');
```

**File:** `app/assets/javascripts/crosswords/solve_funcs.js` line 170

```javascript
// Before:
$('#save-status').text('Saved ');
// After:
$('#save-status').text('Saved');
```

Fix both for consistency. The flex `gap` already provides proper spacing between the two spans.

### Change 3: Make edit header full-width so margin-left: auto works (CSS)
**File:** `app/assets/stylesheets/edit.scss.erb`

Add `width: 100%` to `.xw-edit-header`:

```scss
.xw-edit-header {
  display: flex;
  align-items: center;
  gap: 0.75em;
  flex-wrap: wrap;
  width: 100%;        /* ← new: fill .xw-col-full so margin-left: auto on #puzzle-controls pushes to the right edge */
```

---

## Files Touched

1. `app/views/unpublished_crosswords/edit.html.haml` — line 28 (button class)
2. `app/assets/stylesheets/edit.scss.erb` — line 58-62 (add width: 100%)
3. `app/assets/javascripts/crosswords/edit_funcs.js` — line 179 (remove trailing space)
4. `app/assets/javascripts/crosswords/solve_funcs.js` — line 170 (remove trailing space)

## Risk

**Low.** All changes are cosmetic: CSS class swap, whitespace removal, width addition. No logic or data flow changes. Visual regression risk is minimal — verify both pages look correct after changes.

## Acceptance Criteria

1. Edit save button renders as a ghost button (no visible border, just icon) — matches Solve
2. "Saved" and "moments ago" have a single consistent gap between them (no double space)
3. Save status + clock text are right-aligned in the edit header, not hugging the title
