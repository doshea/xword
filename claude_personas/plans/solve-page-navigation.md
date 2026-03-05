# P3-H: Solve Page Navigation

## Problem

Two navigation gaps on the solve page:
1. **No visible "exit" from the puzzle** — the nav logo links home but mobile users don't discover it
2. **No Send button for comments** — form relies on Enter keypress with a 10px hint; on mobile, users see a textarea and expect Enter = newline

---

## Deliverable 1: Home Button in Toolbar

**Current state**: `#puzzle-controls` contains Save, Favorites, Controls, Delete, Team. No back/home button.

**What to add**: A `arrow-left` ghost button as the **first item** in `#puzzle-controls`, linking to `root_url`.

```haml
-# First item in #puzzle-controls, before save-status
= link_to root_url, class: 'xw-btn xw-btn--sm xw-btn--ghost', data: { 'xw-tooltip': 'Home' }, aria: { label: 'Back to home' } do
  = icon('arrow-left')
```

### Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| `root_url` vs `history.back()` | `root_url` | Predictable. `history.back()` fails for deep links, bookmarks, new tabs. |
| Placement | First in `#puzzle-controls` | Top-left exit is the universal back position (iOS, Android, web) |
| Visibility | All screen sizes | Desktop users benefit too; the logo isn't an obvious exit for everyone |
| Style | `.xw-btn--ghost` with arrow-left icon | Matches existing toolbar buttons. Ghost = unobtrusive. |
| Text label | Icon only (tooltip "Home") | Consistent with Save/Controls/Delete which are icon-only + tooltip |

### Risk

One extra button on a toolbar that already wraps on narrow phones. At current count (Save + Favorites + Controls + Delete + Team = 5), adding one more = 6. With `--space-3` gap on phones (12px), 6 x ~36px buttons = ~264px + gaps = ~324px. A 375px phone has room. **Builder should test on 320px width.**

**Severity**: suggestion — nice UX polish, not critical (logo path exists)

**Files touched**: `show.html.haml` (1 line addition)

---

## Deliverable 2: Mobile Comment Send Button

**Current state**:
- Comment form has NO submit button — only Enter keypress via jQuery (`add_comment_or_reply`, line 599)
- "Enter to send" hint: 10px, opacity 0.7 on focus — barely visible
- The `loading` controller is wired to `#comment-form` but has no `button` target — non-functional
- Reply forms have the same issue

### DOM Changes

**Top-level comment form** (`show.html.haml:147-149`):
```haml
= form_with(url: add_comment_path(@crossword), id: 'comment-form', data: { controller: 'loading', action: 'submit->loading#submit' }) do |f|
  = text_area_tag('content', nil, id: 'add-comment', class: 'xw-textarea xw-textarea--compact', rows: 1, autocomplete: 'off', placeholder: 'Add a comment...', aria: {label: 'Add a comment'})
  %span.xw-comment__hint Enter to send
  %button.xw-btn.xw-btn--sm.xw-comment__send{type: 'submit', data: {loading_target: 'button'}}
    = icon('send', size: 14)
    Send
```

**Reply form** (`_comment.html.haml:25-30`):
```haml
.reply-form__field
  = text_area_tag(...)
  %button.reply-form__close{...}
  %span.xw-comment__hint Enter to send
  %button.xw-btn.xw-btn--sm.xw-comment__send{type: 'submit'}
    = icon('send', size: 14)
    Send
```

### CSS

In `crossword.scss.erb`, in `#comments` block:
```scss
.xw-comment__send {
  margin-top: var(--space-1);
  margin-left: auto;       // right-align
  display: flex;            // visible by default (touch devices)
}

@media (hover: hover) {
  .xw-comment__send {
    display: none;          // hide on devices that support hover
  }
}
```

### Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Visibility toggle | `@media (hover: hover)` | Matches existing pattern for comment action overlays. Targets capability, not screen width. iPad Pro in landscape still shows button. |
| Button style | `.xw-btn.xw-btn--sm` (default = accent green) | Small and compact. Default variant = forest green, stands out as the primary action. |
| Icon | `send` (Feather) | Universal "send message" affordance. 14px to match small button. |
| Position | Below textarea, right-aligned | Standard chat/comment pattern. Doesn't crowd the textarea. |

### Must-Fix: Button Click Must Clear Textarea

The jQuery `add_comment_or_reply` handler (line 599) only runs on `keypress` Enter. Clicking the Send button submits via Turbo natively but **does NOT clear the textarea** or close reply forms.

**Fix**: Extract the post-submit cleanup into a shared function and call it from both paths:

```javascript
// In solve_funcs.js, add new function:
_submit_comment: function($textarea) {
  if ($textarea.val() === '') return false;
  var form = $textarea.closest('form');
  form[0].requestSubmit();
  $textarea.val('');
  // Reply-specific cleanup
  if ($textarea.hasClass('reply-content')) {
    var comment = $textarea.closest('.xw-comment');
    comment.removeClass('xw-comment--replying');
    form.hide('fast');
    form[0].reset();
    var replies = comment.find('.replies');
    var countBtn = comment.find('.xw-comment__reply-count');
    if (replies.is(':hidden')) {
      replies.slideDown('fast');
      countBtn.addClass('xw-comment__reply-count--expanded');
    }
  }
  return true;
},
```

Then wire both paths:
```javascript
// Enter keypress handler (refactored)
add_comment_or_reply: function(e) {
  if (!e.metaKey && e.which === cw.ENTER) {
    e.preventDefault();
    solve_app._submit_comment($(this));
  }
},

// Button click handler (new, in init block)
$('#comments').on('click', '.xw-comment__send', function(e) {
  e.preventDefault();
  var $textarea = $(this).closest('form').find('textarea');
  solve_app._submit_comment($textarea);
});
```

### Bonus Effects

- **Loading controller now works** — Send button provides the missing `data-loading-target="button"`, so it disables during submission. Free win.
- **CSS sibling selector preserved** — `textarea:focus ~ .xw-comment__hint` still works because the hint remains a subsequent sibling of the textarea. The Send button placed after the hint doesn't affect the `~` selector.

---

## Files Touched (Summary)

| File | Changes |
|------|---------|
| `show.html.haml` | Add home button (~line 48), add Send button to comment form (~line 149) |
| `_comment.html.haml` | Add Send button to reply form (~line 30) |
| `solve_funcs.js` | Extract `_submit_comment`, refactor `add_comment_or_reply`, add click handler |
| `crossword.scss.erb` | `.xw-comment__send` styles + `@media (hover: hover)` hide rule |

## Acceptance Criteria

1. Home button visible in toolbar on all screen sizes, links to home
2. Send button visible below comment textarea on touch devices (no hover)
3. Send button hidden on hover-capable devices (desktop with mouse)
4. Clicking Send submits comment, clears textarea, closes reply form (if reply)
5. Loading controller disables Send button during submission
6. Enter-to-submit still works (regression check)
7. Toolbar doesn't overflow on 320px-wide viewport

## Deploy Notes

- Deploy 4 in the meta-plan sequence (after P3-A)
- `solve_funcs.js` has uncommitted P3-A work. P3-H changes are additive and non-conflicting but should be committed separately after P3-A.
