# Review: Forgot / Reset Password Pages

**Pages:** `/users/forgot_password`, `/users/reset_password/:token`
**Files:** `forgot_password.html.haml`, `reset_password.html.haml`, `forgot_password.scss`,
`account.js`, `password_errors.turbo_stream.erb`, `users_controller.rb`

---

## Must-Fix (1)

### 1. Turbo Stream `password_errors` replacement destroys its own target

**Severity:** must-fix (broken UX on validation failure)

`password_errors.turbo_stream.erb` does `turbo_stream.replace "password-errors"` with a bare
`<ul>` from `_errors.html.haml`. This replaces the `#password-errors` div (which has `.xw-alert`,
`.xw-alert--error`, `.slide-close` button) with an unstyled list that lacks:

1. The `id="password-errors"` — so **subsequent turbo stream replacements silently fail**
2. The `.xw-alert--error` styling
3. The dismiss button

**Impact:** First validation error shows as unstyled bullets. Second error attempt does nothing
(Turbo can't find target). Same bug exists in account page's change-password section.

**Fix:** Wrap the partial output so the replacement preserves the container:

```erb
<%= turbo_stream.replace "password-errors" do %>
  <div id="password-errors" class="xw-alert xw-alert--error">
    <%= render partial: 'users/partials/errors' %>
    <a href="#" class="slide-close">&times;</a>
  </div>
<% end %>
```

Do the same for `wrong_password.turbo_stream.erb` — it has the identical bug.

---

## Should-Fix (4)

### 2. Reset password form has no `<label>` elements

**Severity:** should-fix (WCAG 1.3.1 failure)

Both password fields use only `placeholder` text — no `<label>` tags. Screen readers
announce "password field" with no purpose.

**Fix:** Add labels matching account page pattern:
```haml
.xw-field
  %label.xw-label{for: 'new_password'} New Password
  = password_field_tag :new_password, nil, class: 'xw-input', id: 'new_password', ...
.xw-field
  %label.xw-label{for: 'new_password_confirmation'} Confirm New Password
  = password_field_tag :new_password_confirmation, nil, class: 'xw-input', id: 'new_password_confirmation', ...
```

### 3. Missing `autocomplete` and `required` on reset password fields

**Severity:** should-fix (password manager UX + form validation)

Both fields should have:
- `autocomplete: 'new-password'` (helps password managers)
- `required: true` (prevents empty submission)
- `maxlength: User::MAX_PASSWORD_LENGTH` (matches account page)

### 4. Forgot password form missing `autocomplete` attributes

**Severity:** should-fix

- Username field: add `autocomplete: 'username'`
- Email field: add `autocomplete: 'email'`

### 5. Reset password page missing `<title>`

**Severity:** should-fix

`forgot_password.html.haml` sets `- title 'Retrieve Password'` but `reset_password.html.haml`
has no title helper. Browser tab shows the default app name.

**Fix:** Add `- title 'Reset Password'` at top of file.

---

## Suggestions (4)

### 6. Inconsistent page structure between forgot and reset

The forgot page puts `<h1>` inside the body with an empty topper bar; the reset page uses
`row_top_title` in the green topper. Both should use `row_top_title` for consistency.

The forgot page also wraps content in `#password-reset-form` — a bare div with no styling
and no max-width constraint. The form stretches full-width on wide screens.

**Fix:** Match reset page's pattern — use `row_top_title: 'Retrieve Password'` and
`custom_columns: true`, then use `.xw-col-12.xw-lg-center-6` to constrain width.

### 7. `forgot_password.scss` is dead CSS

The entire file (7 lines) styles `#email-sent` which is not referenced in any template.
Likely vestigial from a pre-Turbo/Foundation implementation.

**Fix:** Delete `forgot_password.scss`. Remove `= stylesheet_link_tag :forgot_password` from
the template. (Sprockets `link_directory` auto-links all stylesheets but per-page link tags
are explicit — just remove the link tag.)

### 8. `#password-success` element on reset page is dead markup

The controller redirects on success (`redirect_to account_users_path`), so the success alert
element is never made visible. Same for the `password-success` element if there's no turbo
stream targeting it.

**Fix:** Remove the `#password-success` div from `reset_password.html.haml`. (Keep it on the
account page where `change_password` may use it — verify.)

Actually, I see `change_password` also redirects on success. So `#password-success` is dead on
account page too. Remove from both.

### 9. Vestigial `password_reset_token` / `password_reset_sent_at` DB columns

Rails 8.1 signed tokens (`user.password_reset_token`) derive from password salt — no DB storage.
Both columns are unused in application code. Low-priority migration to remove them.

**Not part of this job** — flag for backend audit (job #16).

---

## Test Coverage

Existing specs are solid:
- Request specs cover: forgot page renders, send_password_reset (known + unknown user),
  reset_password with valid/invalid token
- Controller specs cover: resetter with valid/invalid token, mismatched passwords
- Auth token rotation covered

**Missing:** No spec for the turbo stream error rendering (the must-fix bug). After the fix,
add a spec that verifies turbo_stream response includes the error container with correct ID.

---

## Files to Touch

| File | Change |
|------|--------|
| `password_errors.turbo_stream.erb` | Wrap in container with ID + classes (must-fix) |
| `wrong_password.turbo_stream.erb` | Same wrap fix |
| `reset_password.html.haml` | Add title, labels, autocomplete, required, remove dead markup |
| `forgot_password.html.haml` | Use row_top_title, add autocomplete, constrain width |
| `forgot_password.scss` | Delete file |
| `spec/requests/users_spec.rb` or `spec/controllers/users_controller_spec.rb` | Add turbo stream error rendering spec |

## Order of Operations

1. Fix turbo stream templates (must-fix) — both files
2. Add title + labels + autocomplete to reset page
3. Add autocomplete to forgot page
4. Restructure forgot page layout (row_top_title + column constraint)
5. Delete dead CSS + dead markup
6. Add/update specs
7. Run `bundle exec rspec`
