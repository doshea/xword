# Review: Admin Panel (#12)

**Scope:** `AdminController`, `Admin::BaseController`, all 6 resource controllers,
views, CSS, specs. Owner-only — low priority.
**Verdict:** Well-structured. 2 should-fix, 3 suggestions, 3 nitpicks.

---

## Should-Fix

### 1. Bare `.find()` in `clone_user`
**File:** `app/controllers/admin_controller.rb:64`

```ruby
def clone_user
  user = User.find params[:id]  # ← unguarded
  cookies.signed[:auth_token] = user.auth_token
  redirect_to root_path
end
```

All other admin CRUD uses `find_object` (which rescues `RecordNotFound`). `clone_user`
bypasses it. In production Rails renders a 404, but the pattern is inconsistent with the
codebase's established "safe find" convention (see CLAUDE.md: bare `.find()` calls replaced
elsewhere).

**Fix:** Use `find_by` with a guard:
```ruby
def clone_user
  user = User.find_by(id: params[:id])
  unless user
    redirect_to admin_cloning_tank_path, flash: { error: 'User not found.' }
    return
  end
  cookies.signed[:auth_token] = user.auth_token
  redirect_to root_path
end
```

### 2. Dead "Mail To" field in email form
**File:** `app/views/admin/email.html.haml:14-15`

```haml
= label_tag :address, 'Mail To:'
= email_field_tag :address, 'dylan@crossword-cafe.org'
```

The controller (`test_emails`) never reads `params[:address]`. The reset password email
goes to `@current_user`, and the NYT error email goes to whatever `AdminMailer` is configured
for. This field is dead UI — confusing because it implies you can change the recipient.

**Fix:** Remove the field and its label. If the intent is to support arbitrary recipients,
wire `params[:address]` into the mailers — but that's feature work, not a fix.

---

## Suggestions

### 3. Admin page titles inconsistent
Most admin pages have `- title 'Admin | X', true` (the `true` hides it from the page heading).
`wine_comment.haml` and the admin index pages should be checked for consistency.

Actually on review: all CRUD index pages DO have titles (`Admin | Crosswords`, etc.), and all
edit/utility pages have them. Only `wine_comment` is missing. Low impact (easter egg page).

### 4. Clues index uses raw SQL UNION
**File:** `app/controllers/admin/clues_controller.rb`

```ruby
across = Clue.joins(:across_cells).where(cells: {is_across_start: true})
down = Clue.joins(:down_cells).where(cells: {is_down_start: true})
@clues = Clue.from("(#{across.to_sql} UNION DISTINCT #{down.to_sql}) AS clues")
```

This works but loses AR relation capabilities (scoping, further chaining). It's admin-only
and paginated, so performance isn't critical. Consider replacing with `.or()`:
```ruby
@clues = Clue.left_joins(:across_cells, :down_cells)
             .where(cells: { is_across_start: true })
             .or(Clue.left_joins(:across_cells, :down_cells)
                     .where(down_cells_clues: { is_down_start: true }))
             .distinct
```
But the current approach is working and correct. Only refactor if this code is being touched
for other reasons.

### 5. Solutions edit form shows `key` unconditionally
**File:** `app/views/admin/solutions/edit.html.haml`

Check: does the form show the `key` field (which is the team password) in plain text?
If so, consider masking or noting it's sensitive. Since it's admin-only, this is low risk.

---

## Nitpicks

### 6. `wine_comment.haml` — old file extension
**File:** `app/views/admin/wine_comment.haml`

Should be `wine_comment.html.haml` for consistency with every other template. Works because
HAML processes both, but inconsistent.

### 7. `wine_comment` missing page title
No `- title 'Admin | Wine Comment', true`. Browser tab shows app default.

### 8. Empty `manual_nyt` action body
**File:** `app/controllers/admin_controller.rb:41-43`

```ruby
def manual_nyt

end
```

Blank line inside empty method. Minor style inconsistency — other empty actions like `email`
and `cloning_tank` don't have blank lines.

---

## What's Good

- **`Admin::BaseController`** — clean shared CRUD. 6 resource controllers are ~10 lines each.
  Convention-based naming (`controller_name.classify` → resource name) is elegant.
- **Mass assignment protection** — all `resource_params` are strict permit lists. No `permit!`.
- **N+1 prevention** — every index action uses `.includes()` appropriately.
- **Pagination** — all index pages paginate (50 per page via `will_paginate`).
- **Auth** — `before_action :ensure_admin` on both `AdminController` and `Admin::BaseController`.
  No gaps in the auth chain.
- **RecordNotFound handling** — `find_object` in `ApplicationController` rescues gracefully
  with a flash message and redirect. All CRUD flows are protected.
- **Test coverage** — shared CRUD examples test auth + all 4 CRUD actions for each resource.
  Feature spec covers dropdown interaction and pagination. Good ratio of coverage to code.
- **CSS** — fully tokenized (316 lines), BEM naming, responsive. Warm aesthetic matches app.
- **Turbo Stream** — user search in cloning tank uses modern Turbo approach.

---

## Not Flagged (considered, decided OK)

- **Clone user (impersonation) has no audit log:** True, but this is an owner-only tool on a
  small app. Logging would be nice but isn't a bug.
- **Email test sends real emails:** By design — it's a test tool for verifying email delivery.
  The hardcoded address prevents accidental sends to random users.
- **No rate limiting on email sends:** Admin-only, single user. Not worth the complexity.
