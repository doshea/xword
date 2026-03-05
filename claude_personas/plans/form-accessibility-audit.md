# P2-2: Form Accessibility Audit

**Status:** Reviewed
**Type:** Accessibility fixes
**Scope:** ~12 view files, 0 migrations
**Risk:** Low — all changes are attribute additions or element type swaps; no logic changes

---

## Executive Summary

17 a11y issues found across 12 files. The biggest theme: `text_area_tag` / `text_field_tag` calls
with `id: nil` and no `aria-label`, making inputs invisible to screen readers. Secondary theme:
`<a href="#">` used for action buttons (save, toggle, close) instead of `<button>`.

**False alarm from meta-plan:** "Secondary pages missing `<main>` landmark" — not true.
All pages inherit `%main#body` from `application.html.haml` line 23. No action needed.

---

## Findings

### must-fix — Unlabeled Form Inputs (7 items)

These inputs have no programmatic label. Screen readers announce them as generic
"edit text" with no context.

#### M1. Comment reply textarea
**File:** `app/views/comments/partials/_comment.html.haml:27`
```haml
= text_area_tag('content', nil, id: nil, class: 'reply-content xw-textarea xw-textarea--compact', autocomplete: 'off')
```
**Fix:** Add `aria: {label: 'Write a reply'}` to the options hash.

#### M2. Main comment textarea (solve page)
**File:** `app/views/crosswords/show.html.haml:148`
```haml
= text_area_tag('content', nil, id: 'add-comment', class: 'xw-textarea xw-textarea--compact', rows: 1, autocomplete: 'off', placeholder: 'Add a comment...')
```
**Fix:** Add `aria: {label: 'Add a comment'}`. Placeholder is not a label substitute.

#### M3. Win modal comment textarea
**File:** `app/views/solutions/partials/_win_modal_contents.html.haml:49`
```haml
= text_area_tag 'content', nil, class: 'xw-textarea', autocomplete: 'off', placeholder: Comment.random_wine_comment
```
**Fix:** Add `aria: {label: 'Comment on the crossword'}`.

#### M4. Team chat input
**File:** `app/views/crosswords/partials/_team_chat_form.html.haml:8`
```haml
= text_field_tag 'chat', nil, id: nil, autocomplete: :off
```
**Fix:** Add `aria: {label: 'Team chat message'}`.

#### M5. Edit page clue textareas (all clues, both directions)
**File:** `app/views/unpublished_crosswords/partials/_clue_column.html.haml:10`
```haml
= text_area_tag nil, clue, rows: 1, autocomplete: 'off'
```
**Fix:** Add `aria: {label: "#{direction.titleize} clue #{clue_number}"}`.
This requires the `direction` and `clue_number` locals already available in the loop.

#### M6. Pattern search input
**File:** `app/views/unpublished_crosswords/edit.html.haml:82`
```haml
= text_field_tag :pattern, nil, id: nil, autocomplete: 'off', placeholder: "e.g. P_TT_RN or SE?RCH"
```
**Fix:** Add `aria: {label: 'Pattern search'}`.

#### M7. Notepad/Ideas input
**File:** `app/views/unpublished_crosswords/edit.html.haml:65`
```haml
= text_field_tag :word, nil, id: 'ideas-input', autocomplete: 'off', placeholder: "Type a word you're considering"
```
**Fix:** Add `aria: {label: 'Add word to notepad'}`. The input has an id but no `<label>` element
points at it.

---

### should-fix — Anchor Tags Used as Buttons (8 items)

`<a href="#">` for actions causes: (1) browser scroll-to-top on failed `preventDefault`,
(2) wrong role announced to screen readers ("link" vs "button"), (3) shows up in link lists
(VoiceOver rotor). All should be `<button type="button">`.

#### S1. Comment reply button
**File:** `app/views/comments/partials/_comment.html.haml:17`
```haml
%a.reply-button.reply
```
**Fix:** Change to `%button.reply-button.reply{type: 'button'}`.
jQuery handler in `solve_funcs.js` binds on `.reply-button.reply` class — no JS changes needed.

#### S2. Reply edit pencil icon
**File:** `app/views/comments/partials/_reply.html.haml:9`
```haml
%a
  = icon('pencil')
```
**Fix:** Change to `%button{type: 'button', aria: {label: 'Edit reply'}}`. This element also
needs an `aria-label` since it's icon-only. **Note:** verify whether this button has any JS
handler wired up — it may be dead/unfinished functionality. If dead, delete it instead.

#### S3. Solve save button
**File:** `app/views/crosswords/show.html.haml:53`
```haml
%a#solve-save.xw-btn.xw-btn--sm.xw-btn--ghost{href: '#', ...}
```
**Fix:** Change to `%button#solve-save.xw-btn.xw-btn--sm.xw-btn--ghost{type: 'button', ...}`.
Remove `href`. jQuery binds on `#solve-save` — no JS changes needed.

#### S4. Solve controls button
**File:** `app/views/crosswords/show.html.haml:56`
```haml
= link_to '#', id: 'controls-button', class: 'xw-btn xw-btn--sm xw-btn--ghost', ...
```
**Fix:** Change to `%button#controls-button.xw-btn.xw-btn--sm.xw-btn--ghost{type: 'button', ...}`.
jQuery binds on `#controls-button` — no JS changes needed.

#### S5. Edit save button
**File:** `app/views/unpublished_crosswords/edit.html.haml:28`
```haml
%a#edit-save.xw-btn.xw-btn--sm.xw-btn--ghost{href: '#', ...}
```
**Fix:** Same as S3. Change `%a` → `%button{type: 'button'}`, remove `href`.

#### S6. Notepad toggle
**File:** `app/views/unpublished_crosswords/edit.html.haml:57`
```haml
= link_to('#ideas', class: 'bottom-button', id: 'ideas-button', data: { turbo: false }) do
```
**Fix:** Change to `%button.bottom-button#ideas-button{type: 'button'}`. jQuery handler
binds on `.bottom-button` class. Remove `data-turbo: false` (no longer navigating).

#### S7. Pattern search toggle
**File:** `app/views/unpublished_crosswords/edit.html.haml:74`
```haml
= link_to('#pattern_search', class: 'bottom-button', id: 'pattern-search-button', data: { turbo: false }) do
```
**Fix:** Same as S6.

#### S8. Slide-close dismiss buttons (2 instances)
**Files:**
- `app/views/users/reset_password.html.haml:10`
- `app/views/users/partials/_account_form.html.haml:84`
```haml
%a.slide-close{href: "#"} &times;
```
**Fix:** Change both to `%button.slide-close{type: 'button', aria: {label: 'Dismiss error'}} ×`.
jQuery handler in `account.js` binds on `.slide-close` — no JS changes needed.

---

### suggestion — Tab Controls Using Links (2 items)

These work functionally but `role="tab"` semantics are better served by `<button>` elements.
The ARIA tab pattern spec recommends buttons. Lower priority because the existing `role="tab"`
partially compensates.

#### T1. Home page tabs
**File:** `app/views/pages/home.html.haml:14,19,23`
```haml
= link_to '#panel1', role: 'tab', ...
```
**Fix:** Change all three `link_to` calls to `%button` with same attributes (minus href).
Stimulus `tabs#show` binds via `data-action` — no JS changes needed.

#### T2. NYT day-of-week tabs
**File:** `app/views/pages/nytimes.html.haml:25`
```haml
= link_to "#day-panel-#{wday}", role: 'tab', ...
```
**Fix:** Same pattern as T1. Change `link_to` → `%button`. Note: the NYT top-level
view-toggle tabs (lines 13-16) already correctly use `<button>` — only the day tabs need fixing.

---

### CSS Verification Needed

When converting `<a>` → `<button>`, check these CSS selectors for element-type specificity:

1. `.bottom-button` — verify no `a.bottom-button` selectors in CSS
2. `.reply-button` — verify no `a.reply-button` selectors
3. `.slide-close` — verify no `a.slide-close` selectors
4. `.xw-tab` — verify no `a.xw-tab` selectors
5. `#solve-save`, `#edit-save`, `#controls-button` — verify no `a#id` selectors
6. Buttons need `border: none; background: none; cursor: pointer` reset if not already covered
   by `.xw-btn` or existing button resets in the CSS

Check `_components.scss`, `crossword.scss.erb`, `edit.scss`, `account.scss` for any
`a`-specific selectors on these classes.

---

## Not Issues (Verified OK)

| Item | Why it's fine |
|------|---------------|
| `<main>` landmark on secondary pages | All pages inherit `%main#body` from `application.html.haml:23` |
| Edit page title input label | `text_field_tag 'title'` auto-generates `id="title"`, matching `label{for: 'title'}` |
| Admin/solve clue inputs (`_clue.html.haml`) | Read-only display context; these are in the solve-view clue lists, not editable forms |
| Account/auth forms | All properly labeled with `%label.xw-label{for: ...}` |
| Modal close buttons | Already have `aria: {label: 'Close'}` |
| Search input | Already labeled via existing patterns |

---

## Implementation Order

Recommended batch order for the Builder:

1. **Batch 1 — aria-labels** (M1–M7): Pure attribute additions, zero risk. ~15 min.
2. **Batch 2 — anchor→button** (S1–S8): Element swaps. Needs CSS check first. ~30 min.
3. **Batch 3 — tab buttons** (T1–T2): Lower priority, same pattern as batch 2. ~15 min.

**Total estimate:** ~1 hour including CSS verification and manual testing.

**Test impact:** No existing specs should break — these are attribute/element changes that
don't affect behavior. No new specs needed (these are view-layer a11y attributes, not
testable business logic). If view specs assert specific element types, they may need updating
for the `a` → `button` changes.

---

## Files Touched (Summary)

| File | Changes |
|------|---------|
| `comments/partials/_comment.html.haml` | M1 (aria-label), S1 (a→button) |
| `crosswords/show.html.haml` | M2 (aria-label), S3 (a→button), S4 (link_to→button) |
| `solutions/partials/_win_modal_contents.html.haml` | M3 (aria-label) |
| `crosswords/partials/_team_chat_form.html.haml` | M4 (aria-label) |
| `unpublished_crosswords/partials/_clue_column.html.haml` | M5 (aria-label) |
| `unpublished_crosswords/edit.html.haml` | M6, M7 (aria-labels), S5–S7 (a→button) |
| `comments/partials/_reply.html.haml` | S2 (a→button + aria-label, or delete if dead) |
| `users/reset_password.html.haml` | S8 (a→button) |
| `users/partials/_account_form.html.haml` | S8 (a→button) |
| `pages/home.html.haml` | T1 (link_to→button) |
| `pages/nytimes.html.haml` | T2 (link_to→button) |
