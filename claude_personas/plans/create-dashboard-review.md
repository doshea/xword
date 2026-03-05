# Create Dashboard (`/create/dashboard`) — Review & Plan

**Reviewed:** 2026-03-04
**Files:** `create/dashboard.html.haml`, `create_controller.rb`, `spec/controllers/create_controller_spec.rb`
**Screenshots:** `create-dashboard-current.png`, `create-dashboard-mobile.png`, `create-dashboard-logged-out.png`

---

## What's Good

- Puzzle cards use the shared `.xw-puzzle-card` BEM component — consistent with home/NYT/user-made pages
- `.xw-puzzle-grid` auto-fill grid works well on both desktop and mobile
- "New Puzzle" CTA uses `.xw-btn--success` — correct and prominent
- `crossword_tab` partial handles unpublished→edit vs. published→solve routing correctly
- Page title is set ("Create | Crossword Café")

---

## Findings

### 1. Page heading uses unstyled `%h3` with icon on separate line — **should-fix**

The `%h3` with `icon('pencil')` renders the icon above the text ("Your Puzzles") on its own line. Every other polished page uses either:
- `row_top_title` local in `topper_stopper` for an `%h1` in the dark header bar (NYT, user-made pages)
- A styled heading component with BEM class (home page's `.xw-home__heading`, search's `.xw-search-hero__heading`)

**Current:** Raw `%h3` with no class, browser defaults, pencil icon sitting alone above text.

**Recommendation:** Use `row_top_title: 'Your Puzzles'` in the topper_stopper locals (like user-made page does) to get the dark header bar with h1 treatment. Drop the inline pencil icon — it's redundant with the nav "Create" icon.

---

### 2. Section headings (`%h4`) have no design treatment — **should-fix**

"Unpublished ( 1 )" and "Published ( 4 )" are raw `%h4` elements with:
- No BEM class
- No font token (defaults to `--font-display` from global reset, with browser size)
- Count wrapped in literal parentheses with spaces around them

Every other polished page uses section header patterns:
- Stats page: `font-ui`, `text-sm`, `semibold`, `uppercase`, `tracking-wider`, `text-muted`
- Search page: Same + accent-colored count badge (`.xw-search-card__count`)
- Home page: Tab component with icon + count

**Recommendation:** Create a light section header style for this page. Use the established pattern: DM Sans (font-ui), small, semibold, uppercase, muted color, with a count badge or parenthetical styled as a chip. Apply via BEM class `.xw-create__section-heading` or a reusable `.xw-section-heading` if this pattern is needed elsewhere.

---

### 3. No empty state treatment for "no unpublished puzzles" — **should-fix**

When the user has no unpublished puzzles, the page shows:
```
You're not working on any puzzles right now. Why not start a...
```

This is a plain `%p` with no class. Compare to every other empty state on the site which uses the `.xw-empty-state` component (icon + heading + body + optional CTA). The text also ends awkwardly with "start a..." — feels like a truncated sentence.

**Recommendation:** Replace with the standard `.xw-empty-state` pattern:
```haml
.xw-empty-state
  = icon('file-plus', size: 36, class: 'xw-empty-state__icon')
  %p.xw-empty-state__heading No puzzles in progress
  %p Start creating! Your unpublished puzzles will appear here.
```

The "New Puzzle" button already exists below, so no CTA needed in the empty state.

---

### 4. Logged-out state is minimal and inconsistent — **should-fix**

When logged out, the page renders:
```
Oops! You're not logged in
To create your own crosswords, you'll need to login or make a new account.
```

Issues:
- "Oops!" is informal compared to the rest of the site
- No icon, no `.xw-empty-state` treatment — just a raw `%h2` and `%p`
- Other pages use `ensure_logged_in` → redirect to `account_required_path` (a dedicated page for this)
- The create dashboard is the only page that renders its own inline logged-out message instead of redirecting

**Recommendation — Option A (simple):** Replace inline message with `.xw-empty-state` component:
```haml
.xw-empty-state
  = icon('lock', size: 36, class: 'xw-empty-state__icon')
  %p.xw-empty-state__heading Log in to create puzzles
  %p Create your own crosswords and share them with the community.
  .xw-empty-state__actions
    = link_to 'Log in', login_path, class: 'xw-btn xw-btn--sm'
```

**Recommendation — Option B (consistent):** Add `before_action :ensure_logged_in` to `CreateController` and delete the inline logged-out branch entirely. This is how every other creator/editor page handles it. The `account_required` page already has nice messaging.

**I recommend Option B** — it's simpler, more consistent, and removes a code path. If we want the dashboard visible to logged-out users (discoverability), go with Option A.

---

### 5. No explicit ordering on queries — **should-fix**

```ruby
@unpublished = @current_user.try(:unpublished_crosswords)
@published = @current_user.try(:crosswords)
```

Neither query has `.order()`. Per CLAUDE.md, Crossword has no default scope, so order depends on DB insertion order (not guaranteed). The home page and profile page both add explicit ordering.

**Recommendation:** Add `.order(updated_at: :desc)` to both queries so recently-edited puzzles appear first. For unpublished, `updated_at` makes more sense than `created_at` since the user cares about what they last worked on.

---

### 6. Missing `%hr` or visual separator before "New Puzzle" button — **nitpick**

The "New Puzzle" button sits between the unpublished section and the published section with no visual separation. When both sections are populated, the button feels like it belongs to neither. The `%hr` comes after the button (before Published), so the flow is:

```
[Unpublished heading]
[puzzle cards]
[New Puzzle button]  ← floating between sections
───────────────────
[Published heading]
```

**Recommendation:** Move the "New Puzzle" button into the page header area (near the page title) or give it a dedicated row with some margin. Alternatively, place it at the bottom of the unpublished section, before the `%hr`, with `margin-top: var(--space-4)`.

---

### 7. Count spans have IDs but nothing updates them — **nitpick**

`#unpublished-count` and `#published-count` have DOM IDs, suggesting they were intended for dynamic updates (Turbo or AJAX), but nothing on the page uses them. The counts are static server-rendered values.

**Recommendation:** Remove the `#id` attributes unless Turbo Stream updates are planned. Dead IDs clutter the DOM and mislead future developers.

---

### 8. `%hr` separators should use design tokens — **nitpick**

The page uses bare `%hr` tags. On other polished pages, `%hr` is styled in global CSS. This should be fine — just verify the global `hr` rule applies `border-color: var(--color-border)`.

---

### 9. Test spec is controller-only, no request spec — **suggestion**

The test file is at `spec/controllers/create_controller_spec.rb` (legacy style). Per CLAUDE.md, new HTTP specs should be request specs. The spec only tests HTTP 200 for two cases — it doesn't test:
- That puzzle cards render (only tests `have_http_status(:ok)`)
- The empty state for no unpublished puzzles
- Ordering of results

**Recommendation:** Add a request spec (`spec/requests/create_spec.rb`) with cases for:
1. Logged-in with puzzles → renders puzzle cards
2. Logged-in with no puzzles → renders empty state
3. Logged-out → either redirects (if we use `ensure_logged_in`) or renders login CTA

---

### 10. Page doesn't handle deleted user edge case — **nitpick**

`@current_user.try(:unpublished_crosswords)` returns `nil` when not logged in, and `.try(:any?)` on nil returns nil (falsy). This works, but it's a double-`.try()` chain. If we add `ensure_logged_in`, this simplifies to direct `@current_user.crosswords`.

---

## Implementation Plan (for Builder)

### Order of operations:

1. **Controller changes** (logic first):
   - Add `before_action :ensure_logged_in` to `CreateController`
   - Add `.order(updated_at: :desc)` to both queries
   - Remove `.try()` wrappers (no longer needed after auth guard)
   - Delete the logged-out `else` branch from the view

2. **View template rewrite** (`dashboard.html.haml`):
   - Pass `row_top_title: 'Your Puzzles'` to `topper_stopper` (dark header bar)
   - Add BEM classes to section headings: use font-ui/small/uppercase/muted pattern
   - Style count as a badge or clean inline element (remove literal parentheses with spaces)
   - Replace empty unpublished state with `.xw-empty-state` component
   - Reposition "New Puzzle" button (page header area or clearly anchored to unpublished section)
   - Remove dead `#id` attributes from count spans

3. **CSS** (minimal — reuse existing tokens):
   - Section heading style: can be added as `.xw-create__section-heading` in `_components.scss`
     or inline in the haml using existing utility classes
   - Alternatively, create a reusable `.xw-section-heading` if the pattern repeats

4. **Test** (`spec/requests/create_spec.rb`):
   - Logged-in with puzzles → 200, renders cards
   - Logged-in with no puzzles → 200, renders empty state
   - Logged-out → redirects to `account_required_path`

### Files to touch:
- `app/controllers/create_controller.rb`
- `app/views/create/dashboard.html.haml`
- `app/assets/stylesheets/_components.scss` (small addition)
- `spec/requests/create_spec.rb` (new)
- `spec/controllers/create_controller_spec.rb` (update: logged-out case now redirects)

### Risks:
- **Low:** The `ensure_logged_in` change means logged-out users no longer see any create dashboard content. This is consistent with every other creator page. If discoverability for anonymous users is desired, keep the logged-out branch with `.xw-empty-state` treatment instead.
- **Low:** If anything references `#unpublished-count`/`#published-count` in JS, removing IDs would break it. Search confirmed nothing uses these.
