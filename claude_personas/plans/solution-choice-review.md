# Solution Choice Page — Review & Plan

**Page:** `/crosswords/:id/solution_choice`
**Files:** `crosswords/solution_choice.html.haml`, `solution_choice.scss.erb`, `solution_choice.js`
**Reviewed:** 2026-03-04

---

## Summary

The solution choice page is **mostly well-built.** The SCSS is fully tokenized, responsive
breakpoints are handled, the table has nice hover/animation details, and the controller logic
has good test coverage. This is a polish pass — no structural rework needed.

**Grade: B+** — Good bones, needs 8 targeted fixes across naming, a11y, UX, and mobile.

---

## Findings

### 1. Non-BEM CSS class names — **should-fix**

Three CSS classes use non-BEM, non-prefixed names: `.metadata`, `.trash-td`, `.not-blue`.
These are scoped only to `solution_choice.scss.erb` and used only in the solution choice
HAML, so no collision risk today — but they violate the project convention.

**Fix:**
- `.metadata` → `.xw-solutions-meta` (BEM block for the left column info)
- `.trash-td` → `.xw-solutions-table__delete` (BEM element of the table)
- `.not-blue` → remove entirely; the `a` tag should use `.xw-solutions-table__delete-link`
  and style `color: inherit` on that class instead

**Files:** `solution_choice.html.haml`, `solution_choice.scss.erb`, `solution_choice.js`
(JS references `.trash-td` in the `td:not(.trash-td)` selector — update to new class name)

---

### 2. Accessibility: missing table caption and icon labels — **should-fix**

- The `<table>` has no `<caption>` — screen readers can't identify the table's purpose.
  Add `%caption.sr-only Your solutions for this crossword`.
- The arrow-left icon (`= icon('arrow-left')`) and trash icon (`= icon('trash-2')`) have no
  accessible labels. The `icon` helper will add `aria-hidden="true"` by default, which is fine
  for decorative icons but these are **functional** — they are the only content of clickable
  elements.
- **Fix:** Add `title:` to the icon calls:
  - `= icon('arrow-left', title: 'Open this solution')`
  - `= icon('trash-2', title: 'Delete solution')`
- The team/user icon (`= icon(solution.team ? 'users' : 'user')`) is purely informational
  within the row context — `aria-hidden` is fine, but add a column header: `%th Type` or
  add `%th %span.sr-only Type`.

---

### 3. Thumbnail sizing on mobile — **should-fix**

The `.xw-thumbnail` class only sets `box-shadow` and `border` — no `max-width` or
`width: 100%`. On mobile (where the left column goes full-width at 12 cols), the preview
image will render at its natural size. If the uploaded preview is large, it'll overflow.

**Fix:** Add `max-width: 100%; height: auto;` to `.xw-thumbnail` (in `global.scss.erb`
since it's a global utility class) or scope it to `.xw-solutions-meta img` in the
solution choice stylesheet.

**Recommendation:** Add to global `.xw-thumbnail` since this issue likely applies elsewhere.

---

### 4. `hr` element rule too broad — **nitpick**

Line 129 of the SCSS: `hr { border: none; border-top: 1px solid var(--color-border); }` is
an unscoped element selector. This will affect ALL `<hr>` tags on the page if any others exist
(e.g., from `topper_stopper`). Should be scoped to `.xw-solutions-meta hr` or use a class.

**Fix:** Scope the `hr` rule under the new `.xw-solutions-meta` block.

---

### 5. Row click excludes trash-td but not collaborators row — **suggestion**

The JS `$("tbody").on("click", "tr td:not(.trash-td)")` will fire on clicks to the
collaborators sub-row (`%tr.xw-solutions-table__members`). That row has no `data-link`,
so clicking navigates to `undefined` (Turbo.visit would receive undefined).

Looking at the code: `if (link)` guards against this — `undefined` is falsy. ✅ No crash.
But the row still has `cursor: pointer` from the tbody `tr` rule.

**Fix:** The SCSS already sets `cursor: default` on `.xw-solutions-table__members` — this is
handled. No change needed. Just confirming.

---

### 6. `xw-loading` applied to row, not link — **suggestion**

The JS adds `xw-loading` to the `$row` (a `<tr>`), not a link element. The global
`.xw-loading` style just does `opacity: 0.5 + pointer-events: none`, which works fine on a
`<tr>`. This is correct behavior.

However, the row doesn't get un-dimmed if the user navigates back (Turbo Drive caches the
page). Turbo's restoration visit restores the original HTML, so the cached version won't have
the class. ✅ No fix needed.

---

### 7. Delete confirmation text too long — **suggestion**

The inline `turbo_confirm` text is verbose (up to ~90 chars). This renders as a browser
`confirm()` dialog, which is fine functionally but looks rough. Not a bug — just noting
it. Consider a custom modal in the future, but browser `confirm()` is acceptable for a
destructive action like this.

**No fix required now.** Just noting for future UX improvement.

---

### 8. `xw-col-12.xw-lg-4` layout — **nitpick**

The left column uses `xw-col-12.xw-lg-4` which means it goes full-width on everything
below 1024px. On tablet (768–1023px), the metadata + thumbnail stack above a full-width
table. This is fine but could benefit from a `xw-md-4` / `xw-md-8` split at tablet size
since the table is narrow enough.

**Recommendation:** Consider `xw-col-12.xw-md-4.xw-lg-4` and `xw-col-12.xw-md-8.xw-lg-8`
for a better tablet layout. Low priority — the stacked layout works.

---

### 9. Arrow icon points left — **suggestion**

`icon('arrow-left')` points ← which is the "back" direction. The arrow is used to mean
"go to this solution" which is conceptually "forward" / "open." The CSS transform on hover
(`scaleX(-1) translateX(-4px)`) flips it right and nudges it — so on hover it points →.
At rest it points ←, which reads as "go back."

**Recommendation:** Use `icon('arrow-right')` or `icon('chevron-right')` at rest. Or keep
the current hover animation but start with a neutral icon (e.g., `icon('external-link')` or
`icon('play')`). This is subjective — noting it as a UX polish item.

---

## Action Plan for Builder

**Priority order (do all in one commit):**

1. **Rename CSS classes to BEM** (finding #1)
   - `.metadata` → `.xw-solutions-meta`
   - `.trash-td` → `.xw-solutions-table__delete`
   - `.not-blue` → `.xw-solutions-table__delete-link`
   - Update HAML, SCSS, and JS selectors

2. **Add table caption + icon a11y labels** (finding #2)
   - Add `%caption.sr-only` to the table
   - Add `title:` param to arrow-left and trash-2 icons
   - Add `%th %span.sr-only Type` for the team/user icon column

3. **Fix thumbnail overflow** (finding #3)
   - Add `max-width: 100%; height: auto;` to global `.xw-thumbnail`

4. **Scope the `hr` rule** (finding #4)
   - Move `hr` styles under `.xw-solutions-meta` block

5. **Optional: tablet breakpoint** (finding #8)
   - Add `xw-md-4` / `xw-md-8` to the columns

6. **Optional: arrow icon direction** (finding #9)
   - Consider `chevron-right` or `arrow-right` instead of `arrow-left`

---

## Test Coverage Assessment

The existing request spec (`spec/requests/crosswords_spec.rb`) covers:
- ✅ No solutions → redirect to crossword
- ✅ One solution → redirect to that solution
- ✅ Multiple solutions → renders page (no redirect)
- ✅ Partnered team solution → included in list
- ✅ Sorting with mixed-progress solutions
- ✅ Anonymous user → redirect

**Good coverage.** No additional specs needed for this review — the changes are CSS/HAML only.
