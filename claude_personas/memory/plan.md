# Plan: Loading Feedback Audit & Implementation

## Problem

Users click buttons, links, and puzzle cards with no immediate visual confirmation that
anything is happening. On production (Heroku cold boots, network latency), the gap between
click and response can be seconds. The only global feedback is a 3px green Turbo progress bar
at the top of the viewport — barely visible.

## Design Principles

1. **Instant acknowledgment** — every click/keystroke that triggers a server call should
   produce visible feedback within 1 frame (~16ms)
2. **Consistent vocabulary** — one loading pattern for page navigations, one for in-page
   AJAX calls, one for toolbar actions
3. **Café aesthetic** — use the existing `.xw-spinner` (green accent border-spin), opacity
   dimming, and text replacement that already exist in the design system. No generic spinners.
4. **Progressive enhancement** — Turbo progress bar stays as backup; new feedback layers on top
5. **Respect `prefers-reduced-motion`** — dim/disable without animation
6. **Best practices per interaction type** — see patterns below

## Interaction Feedback Best Practices

Different interactions need different feedback:

| Interaction Type | Best Practice | Why |
|------------------|---------------|-----|
| **Page navigation** (link click) | Dim clicked element + inline spinner | User needs to know *which thing* they clicked is loading |
| **Form submission** (login, signup) | Disable button + swap text ("Logging in…") | Prevents double-submit; button text confirms what's happening |
| **Toolbar action** (save, check) | Button enters "busy" state (dim + spinner icon) | Shows the specific tool is working; restores when done |
| **Destructive action** (delete) | Confirmation dialog is sufficient | Turbo confirm already provides the acknowledgment |
| **Toggle action** (favorite) | Optimistic UI swap | Already implemented — instant toggle, server catches up |
| **Background save** (auto-save) | Status text update only | Don't interrupt flow; passive indicator is correct |
| **Instant client-side action** | No loading needed | Clear puzzle, flash cascade — no server call |

## Current State

### What already works well
| Pattern | Where | Mechanism |
|---------|-------|-----------|
| `data-disable-with` | Password reset, admin forms, Load More, Change Password | Rails disables button + swaps text |
| `loading_controller.js` | Comment form, team chat, search form | Stimulus disables button, shows "Loading…" |
| `invite_controller.js` | Team invite modal | "Sending…" → "Invited ✓" with disabled state |
| Overlay spinner | New Puzzle creation | jQuery fades form, shows spinner + "Generating Puzzle" |
| Turbo progress bar | All Turbo Drive navigations | 3px green bar, 200ms delay |
| Save status text | Solve + Edit pages | `#save-status` / `#save-clock` update passively |
| Favorite toggle | Solve page | Optimistic icon swap via Stimulus |
| Confirm dialogs | Delete solution, Publish puzzle | turbo_confirm blocks until user decides |

### What's missing — prioritized by user impact

**HIGH impact (most common interactions, worst gaps):**

| Area | Element | Interaction | Gap |
|------|---------|-------------|-----|
| **Home/NYT/Search** | Puzzle cards | Click → page nav | No feedback at all — just a delayed progress bar |
| **Solve page** | Save button (💾) | Click → $.ajax PUT | No visual change until "Saved" text appears |
| **Solve page** | Check ▾ dropdown items | Click → $.ajax POST | Dropdown closes, then silence until flash animation |
| **Edit page** | Publish Puzzle | Click confirm → page nav | After confirm dialog, nothing until page loads |
| **Profile** | Add Friend / Accept / Decline | Click → full page reload | Button sits there inert during reload |

**MEDIUM impact:**

| Area | Element | Interaction | Gap |
|------|---------|-------------|-----|
| **Login page** | Log In button | Click → form POST | No disabled state |
| **Signup forms** | Sign Up buttons | Click → form POST | No disabled state |
| **Solve page** | Reveal Letter / Hint Word | Click → $.ajax POST | No disabled state, can double-click |
| **Solve page** | Check Completion | Click → $.ajax POST | No feedback until win modal or error |
| **Solve page** | Create Team link | Click → Turbo POST | Link with no visual change |
| **Account** | Update Account | Submit → form_with PATCH | No disabled state |
| **Notifications** | Accept/Decline in inbox | Click → button_to | No feedback during reload |
| **Solution choice** | Table row click | Click → Turbo.visit | Row click, no hover/active state |

**LOW impact (niche or already acceptable):**

| Area | Element | Interaction | Gap |
|------|---------|-------------|-----|
| Edit page | Pattern Search | Enter → form submit | No spinner (fast enough usually) |
| Admin | Generate Preview, Clone, Email | Various | Admin-only, low traffic |

---

## Implementation Plan

### Layer 1: Global Turbo Drive Navigation Feedback (HIGH — biggest bang for buck)

**Problem:** Clicking any `<a>` or puzzle card that triggers Turbo Drive shows only a
barely-visible progress bar after 200ms.

**Solution:** Global listener dims the clicked element and shows an inline spinner.

**JS** (append to `global.js`):

```js
// Clicked-element loading feedback for Turbo Drive navigations
(function() {
  document.addEventListener('turbo:click', function(event) {
    var el = event.target.closest('.xw-puzzle-card, .xw-btn, a');
    if (!el) return;
    el.classList.add('xw-loading');
  });

  // Clean up on page render or failed navigation
  ['turbo:before-render', 'turbo:load'].forEach(function(evt) {
    document.addEventListener(evt, function() {
      document.querySelectorAll('.xw-loading').forEach(function(el) {
        el.classList.remove('xw-loading');
      });
    });
  });
})();
```

**CSS** (in `global.scss.erb`, near existing `.xw-spinner`):

```scss
// Clicked-element loading state — applied during Turbo Drive page navigations
.xw-loading {
  opacity: 0.5;
  pointer-events: none;
  transition: opacity var(--duration-fast) var(--ease-out);
}

// Puzzle cards get a centered spinner overlay
.xw-puzzle-card.xw-loading,
a.xw-loading > .xw-puzzle-card {
  &::after {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    @extend .xw-spinner;
    width: 1.5em;
    height: 1.5em;
  }
}

@media (prefers-reduced-motion: reduce) {
  .xw-loading::after { animation: none; }
}
```

**Also add** to `solution_choice.js` (programmatic `Turbo.visit`, doesn't fire `turbo:click`):

```js
// Before Turbo.visit(link):
$(this).parent().addClass('xw-loading');
```

**Covers:** All puzzle card clicks (home, NYT, search, profile, user-made), solution choice
rows, nav links, CTA buttons — essentially every page navigation.

**Files:** `global.js`, `global.scss.erb`, `solution_choice.js`
**Effort:** ~1 hour
**Risk:** Low. Pure additive CSS class. The `::after` spinner on puzzle cards needs the card's
`<a>` wrapper to have `position: relative` — verify it does (via `.xw-puzzle-card` border-radius
or explicitly). Test that spinner doesn't conflict with NYT watermark overlay.

---

### Layer 2: Form Submit Buttons — Consistent `disable_with` (MEDIUM — mechanical, zero risk)

**Problem:** Many form buttons don't disable or change text during submission.

**Solution:** Add `data: { disable_with: '...' }` to all submit buttons that lack it. This
is the Rails/Turbo convention — the button disables itself and swaps its text, then restores
on response. Standard, accessible, and already used in 11 places.

| Form | File | Add |
|------|------|-----|
| Login | `sessions/partials/_form_large.html.haml` | `data: { disable_with: 'Logging in…' }` |
| Welcome login | `pages/welcome.html.haml` | `data: { disable_with: 'Logging in…' }` |
| Welcome signup | `pages/welcome.html.haml` | `data: { disable_with: 'Creating account…' }` |
| Signup | `users/partials/_form.html.haml` | `data: { disable_with: 'Creating account…' }` |
| Update Account (personal) | `users/partials/_account_form.html.haml` | `data: { disable_with: 'Updating…' }` |
| Reset Password (set new) | `users/reset_password.html.haml` | `data: { disable_with: 'Resetting…' }` |
| Publish Puzzle | `unpublished_crosswords/edit.html.haml` | Add `disable_with: 'Publishing…'` to existing `data:` hash |
| Add Friend | `users/partials/_friend_status.html.haml` | `data: { disable_with: 'Sending…' }` |
| Accept Friend | `users/partials/_friend_status.html.haml` | `data: { disable_with: 'Accepting…' }` |
| Decline Friend | `users/partials/_friend_status.html.haml` | `data: { disable_with: 'Declining…' }` |
| Accept (notifications) | `notifications/partials/_notification.html.haml` | `data: { disable_with: 'Accepting…' }` |
| Decline (notifications) | `notifications/partials/_notification.html.haml` | `data: { disable_with: 'Declining…' }` |
| Mark All Read | `notifications/index.html.haml` | `data: { disable_with: 'Marking read…' }` |
| Admin Generate Preview | `admin/crosswords/edit.html.haml` | `data: { disable_with: 'Generating…' }` |
| Admin Clone User | `admin/partials/_user_chooser.html.haml` | `data: { disable_with: 'Cloning…' }` |
| Admin Email Test | `admin/email.html.haml` | `data: { disable_with: 'Sending…' }` |

**Turbo compatibility note:** Turbo 2.x supports `data-turbo-submits-with` as the canonical
attribute. However, Rails `disable_with` also works because Turbo's form submission adapter
handles it. Verify with a quick test — if it doesn't work for `button_to`, switch to
`data: { turbo_submits_with: '...' }`.

**Files:** 12 HAML files
**Effort:** ~45 min
**Risk:** Zero. Same pattern used in 11 other places already.

---

### Layer 3: Solve Page Toolbar Feedback (HIGH — core UX)

**Problem:** Save, Check, Reveal, Hint — the most-used buttons on the most-used page — give
no immediate visual feedback on click.

**Solution:** Add a "busy" state pattern to each AJAX-triggering toolbar action.

**General approach per button:**

```js
// Before $.ajax call:
$btn.addClass('xw-btn--busy').prop('disabled', true);

// In the $.ajax complete callback (fires on success OR error):
$btn.removeClass('xw-btn--busy').prop('disabled', false);
```

**CSS** (in `crossword.scss.erb` or `_components.scss`):

```scss
// Busy state for toolbar buttons during AJAX calls
.xw-btn--busy {
  opacity: 0.5;
  pointer-events: none;
  position: relative;

  // Hide the icon, show a spinner in its place
  > svg { opacity: 0; }

  &::after {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 0.875em;
    height: 0.875em;
    border: 2px solid var(--color-border);
    border-top-color: var(--color-accent);
    border-radius: 50%;
    animation: xw-spin 0.6s linear infinite;
  }
}
```

**Per-function specifics:**

| Function | Button to disable | Notes |
|----------|-------------------|-------|
| `save_solution()` | `#solve-save` | On success: brief green flash (`.xw-btn--saved` keyframe, 600ms). The save status text also updates — both signals together. |
| `check_cell()` | `.check-completion` trigger button | The dropdown item `#check-cell` is inside the dropdown which closes. Apply busy to the **parent trigger button** (the "Check ▾" button) instead. |
| `check_word()` | Same as check_cell | Same parent button |
| `check_puzzle()` | Same | Same parent button |
| `check_completion()` | Same | Already targets parent via selector |
| `reveal_cell()` | `.check-completion` trigger button | Same dropdown, same parent |
| `hint_word()` | `.check-completion` trigger button | Same dropdown, same parent |
| `fake_win()` | Admin button | Admin-only, lower priority |
| `reveal_puzzle()` | Admin button | Admin-only, lower priority |

**Save flash animation:**

```scss
.xw-btn--saved {
  animation: xw-save-pulse 0.6s var(--ease-out);
}

@keyframes xw-save-pulse {
  0%   { box-shadow: 0 0 0 0 var(--color-success); }
  50%  { box-shadow: 0 0 0 4px var(--color-success-bg); }
  100% { box-shadow: none; }
}

@media (prefers-reduced-motion: reduce) {
  .xw-btn--saved { animation: none; }
  .xw-btn--busy::after { animation: none; }
}
```

**Implementation pattern** (example for check_cell):

```js
check_cell: function() {
  var cell = cw.selected_cell;
  if (!cell) return;
  var $trigger = $('#solve-controls .check-completion').first().closest('.xw-dropdown').find('button').first();
  $trigger.addClass('xw-btn--busy').prop('disabled', true);

  $.ajax({
    // ... existing call ...
    complete: function() {
      $trigger.removeClass('xw-btn--busy').prop('disabled', false);
    }
  });
}
```

**Files:** `solve_funcs.js`, `crossword.scss.erb` or `_components.scss`
**Effort:** ~2 hours
**Risk:** Low. The button reference capture needs care — the dropdown `toggle()` closes
the menu on click, but the trigger button element persists in the DOM. Verify that
`$trigger` is the right element after dropdown close.

---

### Layer 4: Edit Page Pattern Search + Publish (LOW)

**Pattern Search:** Wire up existing `loading_controller.js` Stimulus controller to the
pattern search form. Single line change in `edit.html.haml`:

```haml
= form_with(url: match_words_path, method: :post,
  data: { controller: 'loading', action: 'submit->loading#submit' }) do |f|
```

And add `data: { loading_target: 'button' }` to the submit element (or the search icon).

**Files:** `edit.html.haml`
**Effort:** ~10 min

---

## Priority Summary

| Layer | Priority | Effort | Impact |
|-------|----------|--------|--------|
| 1. Global nav feedback | HIGH | ~1 hr | Covers 80% of navigation clicks site-wide |
| 2. Form disable_with | MEDIUM | ~45 min | 12 files, mechanical, zero risk |
| 3. Solve toolbar feedback | HIGH | ~2 hrs | Core solve experience |
| 4. Edit pattern search | LOW | ~10 min | Niche usage |

**Recommended order:** Layer 1 → Layer 2 → Layer 3 → Layer 4

Layer 1 gives the biggest bang for the least code (one global listener covers every page).
Layer 2 is mechanical and zero-risk. Layer 3 is the most code but has the deepest UX impact
on the solve page.

## Infrastructure Already Available

- `.xw-spinner` CSS class (defined in `global.scss.erb` line 157, **currently unused**)
- `@keyframes xw-spin` animation (defined alongside `.xw-spinner`)
- `loading_controller.js` Stimulus controller (wired to 3 forms, ready for more)
- `data-disable-with` Rails/Turbo convention (11 existing examples)
- `turbo:click` / `turbo:before-render` / `turbo:load` events
- `prefers-reduced-motion` checks (global.js line 72 already queries this)
- Design tokens: `--duration-fast`, `--ease-out`, `--color-accent`, `--color-border`

## What NOT to change

- **Auto-save** (solve/edit) — fires silently every 5-15s; adding loading would be distracting
- **Live search** — debounced 300ms, results appear fast; a spinner would flash annoyingly
- **Favorite toggle** — already optimistic (instant icon swap via Stimulus)
- **Edit title save** — already has green ✓ / red ✗ status indicator
- **Delete actions with turbo_confirm** — the confirmation dialog itself is acknowledgment
- **ActionCable broadcasts** — server-push, no user action to acknowledge

## Risks

1. **Turbo `data-disable-with` vs `data-turbo-submits-with`**: Turbo 2.x may prefer the
   `turbo_submits_with` attribute. Test with one button first before bulk-applying.
2. **Puzzle card spinner positioning**: The `<a>` wrapping `.xw-puzzle-card` needs
   `position: relative` for the `::after` spinner. The card itself has `overflow: hidden`
   via `@extend .xw-card` — check that the spinner isn't clipped.
3. **Check dropdown button reference**: After the dropdown closes, ensure the trigger button
   reference is still valid for applying/removing `.xw-btn--busy`.
4. **Multiple rapid clicks**: The `pointer-events: none` in `.xw-btn--busy` and `.xw-loading`
   prevents double-clicks, but verify jQuery `.prop('disabled', true)` also works for
   keyboard activation (Enter/Space on focused button).
