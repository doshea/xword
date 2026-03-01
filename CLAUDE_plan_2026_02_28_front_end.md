# Foundation 5 → Modern CSS Migration Plan

## Context

The site's visual datedness stems primarily from Foundation 5 (released 2013). This plan replaces it with **modern vanilla CSS** (CSS Grid, Flexbox, Custom Properties) and **Stimulus controllers** (already installed via gem but not wired up). No new framework to outdate — just web standards.

The chalkboard welcome page stays. Everything else gets modernized.

**Key constraint**: Sprockets 4.2 pipeline — no webpack/PostCSS/Tailwind. All CSS must be plain SCSS.

---

## Phase 0: Design System Foundation
*Foundation 5 stays fully loaded. Nothing visual changes.*

### New files to create:
1. **`app/assets/stylesheets/_design_tokens.scss`** — CSS custom properties for colors, typography, spacing, shadows, borders, breakpoints, transitions. Single source of truth for the new design.
   - Colors: refined palette (primary `#2b7bb9`, neutrals gray-50 through gray-900, semantic success/warning/danger)
   - Typography: Inter font, modular scale (xs through 3xl)
   - Spacing: 4px-base scale (space-1 through space-16)
   - Shadows: sm/md/lg/xl elevation scale
   - SCSS breakpoint variables: `$bp-sm: 640px`, `$bp-md: 768px`, `$bp-lg: 1024px`

2. **`app/assets/stylesheets/_grid.scss`** — CSS Grid replacement for Foundation's 12-column system
   - `.xw-container` (replaces `.row` as wrapper)
   - `.xw-grid` with `.xw-col-*` / `.xw-sm-*` / `.xw-md-*` / `.xw-lg-*` (replaces `.columns` + `.small-*` + `.medium-*` + `.large-*`)
   - `.xw-col-full` (replaces `.large-12.columns`)
   - Offset classes, flexbox utilities, gap utilities
   - `xw-` prefix prevents collision with Foundation during coexistence

3. **`app/assets/stylesheets/_components.scss`** — buttons, alerts, cards, tooltips, modals, tabs, forms
   - `.xw-btn` with `--primary`, `--secondary`, `--success`, `--danger`, `--warning`, `--ghost`, `--sm`, `--lg` modifiers
   - `.xw-alert` with `--info`, `--success`, `--warning`, `--error` variants (left-border accent style)
   - `.xw-card` with hover elevation
   - `[data-xw-tooltip]` — pure CSS tooltips via `::after` pseudo-element
   - `.xw-modal` — styles for native `<dialog>` elements
   - `.xw-tabs` — horizontal and vertical tab styles

4. **Wire Stimulus into Sprockets**: copy `stimulus.min.js` to vendor/assets/javascripts, add `//= require stimulus.min` and `//= require_tree ./controllers` to `application.js`, create `app/assets/javascripts/controllers/` directory

5. **Delete unused Foundation 6** vendor directories (never loaded)

### Files affected:
- NEW: `_design_tokens.scss`, `_grid.scss`, `_components.scss`
- NEW: `app/assets/javascripts/controllers/` (dir)
- EDIT: `app/assets/javascripts/application.js` (add Stimulus requires)
- DELETE: `vendor/assets/stylesheets/foundation6/`, `vendor/assets/javascripts/foundation6/`

### Verify: `bundle exec rspec` passes, `rails assets:precompile` succeeds, site looks identical

---

## Phase 1: Navigation Bar Replacement
*Highest visual impact, isolated to ~5 files.*

### Changes:
1. **Rewrite `app/views/layouts/partials/_nav.html.haml`** — replace Foundation `top-bar` with semantic flexbox nav (`.xw-nav`). Preserve element IDs (`#top-search`, `#live-results`, `#nav-mail`, `#nav-create`) so existing jQuery handlers keep working.

2. **Create `app/assets/stylesheets/_nav.scss`** — sticky dark header, flexbox layout, mobile hamburger with slide-down menu, dropdown menus with shadow/radius, search input that expands on focus.

3. **Create Stimulus controllers:**
   - `controllers/nav_controller.js` — mobile hamburger toggle, click-outside-to-close
   - `controllers/dropdown_controller.js` — generic dropdown open/close (reused in Phase 4 for check button)

4. **Update partials:** `_user_dropdown.html.haml`, `_anonymous.html.haml`, `_admin.html.haml` to use new markup patterns

5. **Update `layouts.scss.erb`** — remove `.top-bar` rules, keep non-nav styles

### Files affected:
- NEW: `_nav.scss`, `nav_controller.js`, `dropdown_controller.js`
- EDIT: `_nav.html.haml`, `_user_dropdown.html.haml`, `_anonymous.html.haml`, `_admin.html.haml`, `layouts.scss.erb`, `application.scss`

### Verify: all nav links work, dropdowns open/close, search submits, hamburger works at mobile widths

---

## Phase 2: Icon Migration (Foundation Icons → Inline SVGs)
*Can run in parallel with Phase 1.*

### Changes:
1. **Create `app/helpers/icon_helper.rb`** — `xw_icon(name, size:, css_class:)` helper that renders inline SVGs from Lucide Icons (MIT, stroke-based, consistent). ~35 icons mapped.

2. **Replace all `%i.fi-*` in ~30 HAML files** with `= xw_icon('name')` calls. Mapping:
   - `fi-pencil` → `pencil`, `fi-star` → `star`, `fi-trash` → `trash-2`, `fi-save` → `save`, `fi-mail` → `mail`, `fi-magnifying-glass` → `search`, `fi-power` → `log-in`/`log-out`, `fi-torso` → `user`, `fi-torsos-all` → `users`, `fi-check` → `check`, `fi-eye` → `eye`, `fi-lightbulb` → `lightbulb`, `fi-widget` → `settings`, `fi-clipboard` → `clipboard-list`, etc.
   - Facebook/GitHub: simple brand SVGs inlined directly (just 2 icons)

3. **Update JS files** that toggle `fi-*` classes:
   - `edit_funcs.js`: replace `fi-check`/`fi-x` class toggling with innerHTML swap
   - `global.js`: replace `.fi-magnifying-glass` selector

4. **Update SCSS files** referencing `fi-*`: `layouts.scss.erb`, `edit.scss.erb`, `welcome.scss.erb`, `search.scss.erb`, `solution_choice.scss.erb`

### Files affected:
- NEW: `icon_helper.rb`
- EDIT: ~30 HAML views, 2 JS files, 5 SCSS files, `_components.scss`

### Verify: visual scan all pages for missing icons, `grep -r 'fi-' app/views/ app/assets/` returns zero

---

## Phase 3: Grid Migration
*Replace all Foundation grid classes in HAML templates.*

### Sub-phases (each is a reviewable commit):

**3a: Layout wrappers** — `_topper_stopper.html.haml`, `_footer.html.haml`
- `.row` → `.xw-container` or `.xw-grid`
- `.large-12.columns` → `.xw-col-full`
- `.large-4.columns` → `.xw-col-12.xw-lg-4`
- Preserve `row-bookend` visual pattern (will be redesigned in Phase 5)

**3b: Solve page** — `crosswords/show.html.haml`, `_solve_crossword.html.haml`
- Create `_solve_layout.scss` with CSS Grid layout:
  - Desktop: `grid-template: "puzzle clues" / auto 1fr`
  - Mobile: single column stack (puzzle → clues → controls)
- Replace `float: left` clue columns with grid areas
- Make crossword cell size viewport-responsive: `min(4vw, 1.5em)`
- Make clue column width flexible instead of fixed 250px

**3c: Puzzle cards** — `_crossword_tab.html.haml`
- `.large-3.columns.result-crossword` → `.xw-card.xw-puzzle-card`
- Parent list uses CSS Grid: `grid-template-columns: repeat(auto-fill, minmax(240px, 1fr))`

**3d: Remaining pages** (~40 files) — mechanical `.row`/`.columns` → `.xw-grid`/`.xw-col-*` substitution:
- solution_choice, account form, login page, user profile, edit crossword, new crossword, admin pages, comments, search, password pages, controls modal

### Mapping reference:
```
.row                    → .xw-grid (with columns) or .xw-container (wrapper)
.large-N.columns        → .xw-col-12.xw-lg-N
.medium-N.columns       → .xw-col-12.xw-md-N
.small-N.columns        → .xw-col-N
.large-offset-N         → .xw-lg-offset-N
.end                    → (remove, not needed)
.collapse               → .xw-grid--collapse (gap: 0)
```

### Files affected:
- NEW: `_solve_layout.scss`
- EDIT: ~47 HAML templates, `crossword.scss.erb`, `search.scss.erb`, `global.scss.erb`, `application.scss`

### Verify: test every page at 1280px, 768px, and 375px widths. `grep -r '\.columns' app/views/` returns zero.

---

## Phase 4: JS Component Replacement (Foundation JS → Stimulus)
*Can run in parallel with Phase 3.*

### 4a: Modals → native `<dialog>`
- Replace `.reveal-modal` with `<dialog>` element in 4 templates:
  - `_controls_modal.html.haml`, `_win_modal.haml`, `_team.html.haml`, `edit.html.haml`
- Create `controllers/modal_controller.js` using `showModal()`/`close()`
- Update JS callers: `$('#controls-modal').foundation('reveal', 'open')` → `document.getElementById('controls-modal').showModal()` in `solve_funcs.js` and `edit_funcs.js`
- Update `check_completion.js.erb` (win modal opened from server-rendered JS)

### 4b: Tabs → Stimulus
- Replace `%dl.tabs{"data-tab" => ""}` with `div.xw-tabs{data: { controller: 'tabs' }}` in:
  - `pages/home.html.haml` (3 horizontal tabs)
  - `users/partials/_account_form.html.haml` (4 vertical tabs)
- Create `controllers/tabs_controller.js` — click handler that toggles active classes

### 4c: Tooltips → CSS-only
- Replace `data: {tooltip: true}, title: 'X'` with `data: {'xw-tooltip': 'X'}` in 6 places on solve page + favorites toggle

### 4d: Split dropdown (check button)
- Replace `.f-dropdown` / `data-dropdown-content` on solve page with dropdown controller from Phase 1
- Preserve `#check-cell`, `#check-word`, `#check-puzzle` IDs (used by existing JS handlers)

### 4e: Alert boxes
- Replace `.alert-box` with `.xw-alert` in `_alert_boxes.html.haml` and account page
- Create `controllers/alert_controller.js` for dismiss functionality (replaces `data-alert`)

### Files affected:
- NEW: `modal_controller.js`, `tabs_controller.js`, `alert_controller.js`
- EDIT: 4 modal templates, 2 tab templates, solve page, favorites toggle, alert boxes partial
- EDIT: `solve_funcs.js`, `edit_funcs.js`
- DELETE: `foundation_overrides.scss` (all its rules now handled by new components)

### Verify: open all 4 modals, switch tabs on home + account, hover tooltips, use check dropdown, dismiss a flash alert

---

## Phase 5: Visual Modernization
*Depends on Phases 1-4 being complete.*

### 5a: Remove textures, update backgrounds
- `global.scss.erb`: `background: url(wood_table.jpg)` → `background-color: var(--color-bg)` (#fafafa)
- `crossword.scss.erb`: `background-image: url(paper.jpeg)` → `background-color: var(--color-surface)` (white)
- Replace black `row-bookend` bars with subtle card containers (`.xw-section` with border-radius and light shadow)

### 5b: Typography
- Add Google Fonts `Inter` to layout `<head>`
- Create `_typography.scss` with base styles for body, h1-h6, links, lists

### 5c: Puzzle cards
- Larger thumbnails (96px), rounded corners, padding, hover lift effect
- Grid layout: `repeat(auto-fill, minmax(240px, 1fr))` for responsive card flow

### 5d: Form styling
- Consistent input/label/fieldset styling using design tokens
- Focus rings with primary color glow

### 5e: Footer
- Light gray background, flexbox columns, cleaner spacing

### 5f: Welcome page (chalkboard)
- Keep chalkboard aesthetic
- Update fonts to Inter, use migrated SVG icons, clean up raw CSS

### Files affected:
- NEW: `_typography.scss`
- EDIT: `global.scss.erb`, `crossword.scss.erb`, `layouts.scss.erb`, `search.scss.erb`, `welcome.scss.erb`, `account.scss.erb`, `profile.scss.erb`, `_components.scss`
- EDIT: `application.html.haml` (add font link), `_footer.html.haml`
- EDIT: button classes in view templates (`.button.tiny.secondary` → `.xw-btn.xw-btn--secondary.xw-btn--sm`)

### Verify: screenshot comparison of all major pages before/after

---

## Phase 6: Foundation 5 Removal
*The final gate. Nothing visual should change.*

### Changes:
1. Remove Foundation requires from `application.scss`: `foundation5/normalize`, `foundation5/foundation.min`, `foundation-icons/foundation-icons`, `foundation_overrides`
2. Remove Foundation JS includes from `application.html.haml`: `foundation5/foundation.min`, `foundation5/modernizr`
3. Remove `$(document).foundation()` init from `_body.html.haml`
4. Remove Foundation Icons `@font-face` from `application.scss`
5. Delete files: `foundation_overrides.scss`, `_buttons.scss`, `_global_mixins.scss`
6. Delete vendor directories: `vendor/assets/stylesheets/foundation5/`, `vendor/assets/stylesheets/foundation-icons/`, `vendor/assets/javascripts/foundation5/`
7. Replace `@include transition()` etc. in remaining SCSS with native CSS properties
8. Add modern normalize (or keep existing `reset.css`)

### Verify:
- `rails assets:precompile` succeeds
- `bundle exec rspec` passes
- `grep -r 'foundation' app/ vendor/` → zero results
- `grep -r 'fi-' app/` → zero results
- `grep -r 'alert-box\|reveal-modal\|top-bar\|data-tab\|data-topbar' app/views/` → zero results
- Network tab: no foundation CSS/JS/font requests
- Expected savings: ~260KB (97KB CSS + 85KB JS + 80KB icon font)

---

## Phase 7: Cleanup
- Delete `_dimensions.scss` (replaced by CSS custom properties)
- Consolidate small SCSS files (`forgot_password.scss`, `site_stats.scss`, `pagination.scss`) into `_components.scss`
- Tighten `config/initializers/assets.rb` precompile globs
- Update CLAUDE.md tech stack documentation
- Performance audit: measure bundle sizes

---

## Dependency Graph
```
Phase 0 (design system + Stimulus wiring)
  ├── Phase 1 (nav)          ─┐
  ├── Phase 2 (icons)         ├── can run in parallel
  ├── Phase 3 (grid)          │
  └── Phase 4 (JS components)─┘
        │
        Phase 5 (visual modernization) ← depends on 1-4
        │
        Phase 6 (Foundation removal) ← depends on 1-5
        │
        Phase 7 (cleanup)
```

## Testing Strategy
- `bundle exec rspec` after every phase (0 failures currently, 15 pending)
- Visual testing at 3 breakpoints: desktop (1280px), tablet (768px), mobile (375px)
- Key pages to check: home (logged in/out), solve page, edit page, solution choice, account, login, search, admin index
- Grep audits after each phase to catch straggling Foundation references
