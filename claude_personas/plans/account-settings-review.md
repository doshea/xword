# Review: Account Settings Page

**Page:** `/users/account`
**Files:** `_account_form.html.haml`, `account.scss.erb`, `account.js`,
`users_controller.rb`, `update.turbo_stream.erb`, `password_errors.turbo_stream.erb`,
`wrong_password.turbo_stream.erb`

**Verdict:** Clean rebuild (v557). Well-structured BEM, tokens-only CSS, solid specs.
Most issues are shared with the reset password page (job #10).

---

## Must-Fix (0 — already covered)

The Turbo Stream `#password-errors` replacement bug (target ID destroyed after first
error) is already documented in **job #10** (`forgot-reset-password-review.md`, item #1).
The fix to `password_errors.turbo_stream.erb` and `wrong_password.turbo_stream.erb`
applies to both the account page and reset page since they share the same templates.

**Builder note:** When picking up job #10, the fix automatically resolves the account
page's password error display too. No separate work needed here.

---

## Should-Fix (3)

### 1. Missing `autocomplete` attributes on account form fields

**Severity:** should-fix (password manager + browser autofill UX)

The signup form (`_form.html.haml`) correctly uses `autocomplete: 'username'`,
`autocomplete: 'email'`, `autocomplete: 'new-password'`. The account form has none.

**Fix:** Add to `_account_form.html.haml`:

| Field | `autocomplete` value |
|-------|---------------------|
| `first_name` | `given-name` |
| `last_name` | `family-name` |
| `email` | `email` |
| `username` | `username` |
| `old_password` | `current-password` |
| `new_password` | `new-password` |
| `new_password_confirmation` | `new-password` |

### 2. `slide-close` jQuery handler won't rebind after Turbo Stream replacement

**Severity:** should-fix (close button broken after password error)

`account.js` binds `.slide-close` click handlers once during `turbo:load`. After the
job #10 fix wraps Turbo Stream error content in a container with a new `.slide-close`
button, that button won't have the handler.

**Fix:** Switch to event delegation in `account.js`:

```javascript
// Before:
$('.slide-close').on('click', function(e) { ... });

// After:
$(document).on('click', '.slide-close', function(e) {
  e.preventDefault();
  $(this).parent().slideUp();
});
```

With delegation, the handler works for any `.slide-close` added dynamically. The
`turbo:load` guard is still fine — it just prevents double-binding the delegated handler.

### 3. Dead `#password-success` markup

**Severity:** should-fix (misleading dead code)

Line 88: `#password-success.xw-alert.xw-alert--success.hidden Password updated!`

Nothing ever shows this element — `change_password` redirects on success (which shows
a flash). No JS or Turbo Stream targets it. Same dead element exists on the reset
password page (already flagged in job #10, item #8).

**Fix:** Remove `#password-success` from `_account_form.html.haml` (line 88).

---

## Suggestions (2)

### 4. `token_tag nil` no-ops

Lines 18 and 60 have `= token_tag nil`, which outputs empty string in modern Rails.
`form_with` handles CSRF tokens automatically. Harmless but confusing.

**Fix:** Delete both lines.

### 5. `html: { multipart: false }` is the default

Line 59: `= form_with model: user, html: { multipart: false }` — `false` is already
the default. Minor cleanup.

**Fix:** Change to `= form_with model: user do |f|`

---

## What's Good

- **BEM naming** — clean, consistent `.xw-account-*` hierarchy
- **Tokens-only CSS** — zero hardcoded values, all from `_design_tokens.scss`
- **Security** — `update_user_params` excludes password, auth token rotates on change,
  `download_allowlist` prevents SSRF, `ensure_logged_in` covers all 4 account actions
- **Soft delete** — `anonymize!` preserves community content, cleans up PII + relationships
- **Specs** — 10+ request specs covering update, duplicate rejection, notification prefs,
  delete account, deleted user profile/login, auth token rotation, password bypass prevention
- **Responsive** — mobile stacking for header, photo, form grids all work
- **Turbo Stream profile pic** — `update.turbo_stream.erb` correctly preserves element IDs

---

## Overlap with Other Jobs

| Shared fix | Owned by | Files |
|-----------|----------|-------|
| Turbo Stream `#password-errors` ID destruction | Job #10 | `password_errors.turbo_stream.erb`, `wrong_password.turbo_stream.erb` |
| Dead `#password-success` markup | Job #10 (reset page) + this job (account page) |
| `slide-close` delegation | This job | `account.js` |

**Recommendation:** Bundle items 1–5 above with job #10 as a single Builder pickup.
The Turbo Stream fix, event delegation fix, autocomplete, and dead markup removal are
all interrelated and touch the same files.

---

## Files to Touch

| File | Change |
|------|--------|
| `_account_form.html.haml` | Add autocomplete attrs, remove dead `#password-success`, remove `token_tag nil` ×2, remove `multipart: false` |
| `account.js` | Switch to event delegation for `.slide-close` |

## Order of Operations

1. Add `autocomplete` to all 7 form fields
2. Remove dead `#password-success` div
3. Fix `slide-close` event delegation in `account.js`
4. Clean up `token_tag nil` and `multipart: false`
5. Run `bundle exec rspec`
