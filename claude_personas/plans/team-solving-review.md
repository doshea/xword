# Team Solving UX — Review

**Reviewer:** Planner · **Date:** 2026-03-04
**Scope:** Create/join flow, real-time conflicts, chat, disconnect recovery, invite UX

## Files Reviewed

- `app/views/crosswords/partials/_team.html.haml` — team modal + chat widget
- `app/views/crosswords/partials/_team_chat_form.html.haml` — chat form partial
- `app/views/solutions/send_team_chat.turbo_stream.erb` — chat form reset
- `app/assets/javascripts/crosswords/team_funcs.js.erb` — ActionCable client (328 lines)
- `app/assets/javascripts/controllers/invite_controller.js` — friend invite Stimulus controller
- `app/controllers/solutions_controller.rb` — 6 team broadcast actions
- `app/controllers/crosswords_controller.rb` — `create_team` + `team` actions
- `app/controllers/puzzle_invites_controller.rb` — notification invite
- `app/channels/teams_channel.rb` — ActionCable channel
- `app/channels/application_cable/connection.rb` — WebSocket auth
- `app/models/solution.rb` — team key generation, accessible_by?
- `app/models/solution_partnering.rb` — join record
- `app/assets/stylesheets/crossword.scss.erb` — team CSS (lines 240–580, 1033)
- `spec/controllers/solutions_controller_spec.rb` — 247 lines of team specs
- `spec/requests/solutions_spec.rb` — 525 lines covering team auth + multi-user
- `spec/requests/crosswords_spec.rb` — team join/create specs

## What's Good

- **LWW conflict resolution** is solid: `server_time` (monotonic ms clock) + Infinity sentinel
  for own edits prevents echo clobber. Client-side timestamp gating drops stale messages correctly.
- **Redis failure resilience**: `team_broadcast` rescues `Redis::BaseConnectionError`, gracefully
  degrades chat (Turbo Stream error notice), other actions return 200 silently.
- **XSS protection**: chat text uses jQuery `.text()` (safe setter), not `.html()`. Display names
  also use `.text()`. The `escapeHtml` utility in invite_controller.js is correct.
- **Authorization is comprehensive**: `ensure_team_member` (via `accessible_by?`) on all 6 team
  actions, `ensure_logged_in` filter, outsider 403 rejection — all well-tested.
- **Test coverage is excellent**: controller + request specs cover every team action, Redis failures,
  multi-user interleaved edits, authorization, create/join flows. ~60+ team-specific examples.
- **Turbo navigation cleanup**: `turbo:before-visit` handler calls `leave_team`, consumer
  disconnect prevents duplicate subscriptions. Well-handled.

---

## Findings

### 1. SHOULD-FIX: `leave_team` on `unload` uses `$.ajax` — unreliable

**Lines:** `team_funcs.js.erb:309-310`

Modern browsers cancel async XHR during `unload`. The `$.ajax` POST to `leave_team` will be
killed before it reaches the server when the user closes a tab or hard-refreshes.

The `turbo:before-visit` path (line 314) works fine — the page is still alive during Turbo
navigation. But tab close / browser close / F5 is the most common departure, and it's broken.

**Impact:** Teammates see "ghost" roster entries that never fade out. Cosmetic but confusing.

**Fix:**
```javascript
// Replace $.ajax leave_team for unload with sendBeacon
leave_team_beacon: function() {
  var data = new FormData();
  data.append('solver_id', team_app.solver_id);
  data.append('authenticity_token', document.querySelector('meta[name="csrf-token"]').content);
  navigator.sendBeacon('/solutions/' + solve_app.solution_id + '/leave_team', data);
}
```
Use `leave_team_beacon` for `pagehide`/`beforeunload` (not `unload`, which is deprecated).
Keep the existing `$.ajax` version for `turbo:before-visit` (synchronous context, needs CSRF).

Also consider: switch `unload` → `pagehide` with `{ persisted: false }` check, per MDN guidance.

---

### 2. SHOULD-FIX: No unique constraint on `SolutionPartnering(solution_id, user_id)`

**File:** `app/controllers/crosswords_controller.rb:72`, `db/schema.rb:132-138`

`SolutionPartnering.find_or_create_by(solution_id:, user_id:)` has a classic TOCTOU race:
two simultaneous requests (e.g., opening team link in two tabs) can both see "not found" and
both insert. There's no DB unique index and no model uniqueness validation.

**Impact:** Duplicate partnership rows. Not catastrophic but wastes space and could confuse
queries that count partnerships.

**Fix:**
1. Add migration: `add_index :solution_partnerings, [:solution_id, :user_id], unique: true`
2. Add model validation: `validates :user_id, uniqueness: { scope: :solution_id }`
3. Rescue `ActiveRecord::RecordNotUnique` in the controller (or just let `find_or_create_by`
   handle it naturally with the index — Rails 7+ retries on uniqueness conflict).

---

### 3. SHOULD-FIX: Dead Foundation tooltip in `welcome_teammate`

**Lines:** `team_funcs.js.erb:156-158`

```javascript
teammate.addClass('teammate-box has-tip')
  .css('background', 'rgb(' + data.red + ', ' + data.green + ', ' + data.blue + ')')
  .attr('data-tooltip', true)
  .attr('title', data.display_name)
  .attr('solver_id', data.solver_id);
```

Foundation was fully removed. `has-tip` and `data-tooltip` are dead. The app's tooltip system
uses `data-xw-tooltip`. Teammates currently have NO visible name on hover.

**Fix:**
```javascript
teammate.addClass('teammate-box')
  .css('background', 'rgb(' + data.red + ', ' + data.green + ', ' + data.blue + ')')
  .attr('data-xw-tooltip', data.display_name)
  .attr('data-solver-id', data.solver_id);
```

Also fix the corresponding selector in `farewell_teammate` (line 167):
```javascript
// Before
$(".teammate-box[solver_id=" + data.solver_id + "]")
// After
$(".teammate-box[data-solver-id=" + data.solver_id + "]")
```

---

### 4. SHOULD-FIX: Invite friend section has NO CSS

**Files:** `_team.html.haml:25-34`, `invite_controller.js:19-28`

The following classes are referenced in HAML/JS but have zero CSS definitions:
- `.team-modal__invite`
- `.team-modal__invite-heading`
- `.team-modal__invite-body`
- `.team-modal__friends-list`
- `.team-modal__friend-btn`
- `.team-modal__friend-name`
- `.team-modal__friend-username`
- `.team-modal__friend-btn--invited`

The invite section renders as unstyled HTML inside the team modal.

**Fix:** Add styles inside `#team-explanation` in `crossword.scss.erb`. Something like:

```scss
.team-modal__invite {
  margin-top: var(--space-4);
  border-top: 1px solid var(--color-border);
  padding-top: var(--space-4);
}
.team-modal__invite-heading {
  font-family: var(--font-ui);
  font-size: var(--text-base);
  font-weight: var(--weight-semibold);
  display: flex;
  align-items: center;
  gap: var(--space-2);
  margin-bottom: var(--space-3);
}
.team-modal__friends-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
  max-height: 12rem;
  overflow-y: auto;
}
.team-modal__friend-btn {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  padding: var(--space-2) var(--space-3);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  background: var(--color-surface);
  cursor: pointer;
  font-family: var(--font-ui);
  transition: var(--transition-colors);
  &:hover { background: var(--color-surface-alt); }
  &--invited {
    opacity: 0.6;
    cursor: default;
  }
}
.team-modal__friend-name {
  font-weight: var(--weight-semibold);
}
.team-modal__friend-username {
  color: var(--color-text-muted);
  font-size: var(--text-sm);
}
```

---

### 5. SUGGESTION: Anonymous users on team pages get silent AJAX errors

**Context:** `crosswords#team` doesn't require login (by design — share link works). But
`team_funcs.js.erb` immediately calls `roll_call()` (line 302) which POSTs to a `ensure_logged_in`
endpoint. The redirect-to-login response comes back as HTML to a jQuery AJAX call, triggering the
`console.warn` error callback.

Anonymous users also see the chat input and can try to type — the form submits to
`send_team_chat` which requires login, causing a redirect (not a useful error message).

**Impact:** Not catastrophic (errors are swallowed), but the UX is rough for anonymous viewers.

**Fix (client-side guard):**
```javascript
// In team_funcs_ready(), skip participation calls for anonymous users
if (!solve_app.anonymous) {
  team_app.roll_call();
}
```

Optionally hide the chat input for anonymous users (server-side in `_team_chat_form.html.haml`):
```haml
- if @current_user
  = form_with(...)
- else
  %p.xw-text-muted.team-chat__anon-prompt
    = link_to 'Sign in', login_path
    to chat with the team
```

---

### 6. SUGGESTION: `solver_id` attribute is non-standard HTML

**Lines:** `team_funcs.js.erb:160, 167`

`teammate.attr('solver_id', data.solver_id)` creates a non-standard HTML attribute. Per HTML spec,
custom attributes should use the `data-` prefix.

**Fix:** Already described in finding #3 — switch to `data-solver-id`.

---

### 7. NITPICK: Hardcoded chat highlight color

**Line:** `team_funcs.js.erb:215`

```javascript
new_chat.css({'background-color': '#fdf0e4'});
```

Hardcoded hex color instead of a CSS custom property. Should use a design token.

**Fix:** Use a CSS class instead:
```scss
// In crossword.scss.erb
.chat--flash { background-color: var(--color-accent-light); }
```
Then in JS: `new_chat.addClass('chat--flash')` + `setTimeout(() => new_chat.removeClass('chat--flash'), 400)`

---

### 8. NITPICK: `team_app` re-initialization clobbers view-injected values

**Line:** `team_funcs.js.erb:4`

```javascript
window.team_app = { ... display_name: team_app.display_name, solver_id: team_app.solver_id ... }
```

The view sets `team_app = {}` with `display_name` and `solver_id`, then this file overwrites
`window.team_app` and copies those values. This works but is fragile — if the script executes
before the inline script (e.g., async loading), it would throw `ReferenceError: team_app is not defined`.

Currently safe because the view's `<script>` tag runs synchronously before `team_funcs.js`.
Not worth fixing unless the loading order changes.

---

## Summary

| # | Severity | Finding | Effort |
|---|----------|---------|--------|
| 1 | should-fix | `leave_team` on unload uses unreliable `$.ajax` | S |
| 2 | should-fix | No unique constraint on SolutionPartnering | S (migration) |
| 3 | should-fix | Dead Foundation tooltip on teammate boxes | XS |
| 4 | should-fix | Invite friend section has no CSS | M |
| 5 | suggestion | Anonymous users get silent AJAX errors on team pages | S |
| 6 | suggestion | `solver_id` is non-standard HTML attribute | XS |
| 7 | nitpick | Hardcoded chat highlight color | XS |
| 8 | nitpick | `team_app` re-init fragile but currently safe | — |

**Verdict:** 4 should-fix, 2 suggestion, 2 nitpick. No must-fix — the feature is
architecturally solid with good conflict resolution and excellent test coverage.
The biggest wins are #1 (reliable disconnect) and #4 (invite styling).
