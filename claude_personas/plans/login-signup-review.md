# Login / Signup Page Review

**Scope:** `/login` (sessions#new), `/users/new` (users#new), `/welcome` (pages#welcome chalkboard)
**Files reviewed:** sessions_controller.rb, users_controller.rb (create/new), sessions/new.html.haml,
sessions/partials/_form_large.html.haml, users/partials/_form.html.haml, users/new.html.haml,
pages/welcome.html.haml, chalkboard_controller.js, welcome.scss.erb, global.scss.erb (auth layout),
forgot_password.scss, password_errors.turbo_stream.erb, wrong_password.turbo_stream.erb,
users/partials/_errors.html.haml, _alert_boxes.html.haml, account.js, both controller + request specs.

---

## Findings

### 1. Turbo Stream `replace` destroys its own target ID — **must-fix**

Both `password_errors.turbo_stream.erb` and `wrong_password.turbo_stream.erb` use
`turbo_stream.replace "password-errors"` but the replacement content has no `id="password-errors"`
wrapper. After the first error submission, the `#password-errors` div is gone from the DOM —
subsequent error submissions silently fail (Turbo Stream finds no target).

**Affects:** Reset password page AND account page change-password section (same templates).

**Fix:** Wrap replacement content with a div preserving the target id:

```erb
<%# password_errors.turbo_stream.erb %>
<%= turbo_stream.replace "password-errors" do %>
  <div id="password-errors" class="xw-alert xw-alert--error">
    <%= render partial: 'users/partials/errors' %>
    <a class="slide-close" href="#">&times;</a>
  </div>
<% end %>

<%# wrong_password.turbo_stream.erb %>
<%= turbo_stream.replace "password-errors" do %>
  <div id="password-errors" class="xw-alert xw-alert--error">
    <p>Your old password is incorrect. Please try again.</p>
    <a class="slide-close" href="#">&times;</a>
  </div>
<% end %>
```

### 2. Reset password page missing labels — **should-fix** (a11y)

`reset_password.html.haml` uses `password_field_tag` with `placeholder:` but no `<label>`.
Screen readers cannot identify these fields. Placeholders are not labels.

**Fix:** Add `.xw-field` wrappers with labels (matching the account page pattern):

```haml
.xw-field
  %label.xw-label{for: 'new_password'} New Password
  = password_field_tag :new_password, nil, class: 'xw-input', id: 'new_password', autocomplete: 'new-password'
.xw-field
  %label.xw-label{for: 'new_password_confirmation'} Confirm New Password
  = password_field_tag :new_password_confirmation, nil, class: 'xw-input', id: 'new_password_confirmation', autocomplete: 'new-password'
```

### 3. Signup form drops redirect parameter — **should-fix**

Flow: `ensure_logged_in` → `/account_required?redirect=/crosswords/5` → user clicks "Sign up"
→ `/users/new?redirect=/crosswords/5` → signs up → `UsersController#create` → `redirect_to root_path`.

The signup form (`_form.html.haml`) doesn't carry the redirect param. After signup the user
lands at root, not where they were going.

**Fix:**
1. Add `= hidden_field_tag :redirect, params[:redirect]` to `_form.html.haml`
2. In `UsersController#create`, on success: `redirect_to safe_redirect_path(params[:redirect])`
3. Same issue on welcome page chalkboard signup form — but that always goes to root anyway
   (logged-out-only page), so less impactful. Still, add it for consistency.

### 4. `/login` accessible when already logged in — **should-fix**

`SessionsController#new` doesn't check `@current_user`. A logged-in user can visit `/login`
and see login+signup forms. The welcome page correctly redirects: `return redirect_to(root_path) if @current_user.present?`.

**Fix:** Add to `SessionsController#new`:
```ruby
def new
  return redirect_to(root_path) if @current_user.present?
  @user = User.new
end
```

Same for `UsersController#new`:
```ruby
def new
  return redirect_to(root_path) if @current_user.present?
  @user = User.new
end
```

### 5. Title/heading inconsistency on login page — **suggestion**

`sessions/new.html.haml`:
- `- title 'Log In'` → HTML `<title>` says "Log In"
- `row_top_title: 'Sign In'` → visible `<h1>` says "Sign In"

These should match. Recommend: both say "Log In" (matches the button text and URL).

### 6. Reset password page missing `<title>` — **suggestion**

`reset_password.html.haml` doesn't call `- title 'Reset Password'`. The `row_top_title`
sets the visible h1 but the browser tab shows the default app title.

**Fix:** Add `- title 'Reset Password'` at line 1.

### 7. `forgot_password.scss` is dead CSS — **suggestion**

The 8-line file styles `#email-sent` which doesn't exist in any template. Leftover from a
pre-Turbo era.

**Fix:** Delete `forgot_password.scss` and remove the `= stylesheet_link_tag :forgot_password`
from `forgot_password.html.haml`. Also remove from `app/assets/config/manifest.js` if listed.

### 8. Legacy controller specs: duplicate coverage + `should` syntax — **suggestion**

Both `spec/controllers/sessions_controller_spec.rb` and `spec/requests/sessions_spec.rb` cover
the same scenarios. Same for users. The request specs are more thorough and follow current
conventions. The controller specs use `should` syntax which violates the project standard.

**Fix:** Delete `spec/controllers/sessions_controller_spec.rb` and
`spec/controllers/users_controller_spec.rb`. The request specs already cover everything they test
and more (redirect param, deleted user, password bypass, notification prefs, etc.).

Verify before deleting: check that every scenario in the controller spec has a counterpart in
the request spec. Quick check:
- Sessions controller spec: new, create (valid/wrong/unknown/remember_me), destroy → ✅ all in request spec
- Users controller spec: show, new, create, update, account, forgot_password, send_password_reset,
  resetter, change_password → ✅ all covered in request spec except `new` (trivial GET, already
  tested implicitly by signup spec)

---

## What's Good

- **Timing-oracle protection** in `SessionsController#create` — DUMMY_DIGEST prevents username
  enumeration via bcrypt timing. Well done.
- **BCrypt::Errors::InvalidHash rescue** — corrupted password_digest doesn't crash the app.
- **Deleted user login guard** — separate check with clear error message.
- **Open-redirect protection** — `safe_redirect_path` blocks `//` and `://` patterns.
- **Auth token rotation** on logout, password change, and password reset — all three covered.
- **Welcome page chalkboard** — polished, accessible (ARIA regions, sr-only labels, reduced
  motion, mobile fallback), well-structured BEM. Focus management after panel slide is a nice touch.
- **Turbo Stream for password errors** — correct architectural choice, just needs the ID fix.
- **Request spec coverage** — thorough edge case testing (deleted user, password bypass,
  duplicate email/username, notification prefs, friendship cleanup on delete).

---

## Summary

| # | Finding | Severity | Effort |
|---|---------|----------|--------|
| 1 | Turbo Stream replace loses `#password-errors` target | must-fix | S |
| 2 | Reset password fields missing labels | should-fix | S |
| 3 | Signup form drops redirect parameter | should-fix | S |
| 4 | /login accessible when logged in | should-fix | S |
| 5 | Title says "Log In", h1 says "Sign In" | suggestion | XS |
| 6 | Reset password page missing `<title>` | suggestion | XS |
| 7 | `forgot_password.scss` is dead CSS | suggestion | XS |
| 8 | Delete duplicate legacy controller specs | suggestion | S |
