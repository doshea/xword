# NYT Puzzles Page Review (`/nytimes`)

**Reviewed:** 2026-03-04
**Files examined:** `pages/nytimes.html.haml`, `calendar_controller.js`, `nyt_view_controller.js`,
`tabs_controller.js`, `_components.scss` (lines 419–1162), `_crossword_tab.html.haml`,
`_topper_stopper.html.haml`, `pages_controller.rb#nytimes`, `spec/requests/pages_spec.rb`

**Production scale:** 705 NYT puzzles (growing daily)

---

## What's Good

- **Clean controller separation**: `nyt-view` (By Day / Calendar toggle) and `tabs` (Mon–Sun)
  use different Stimulus controllers with distinct class names — no conflicts with nesting.
- **Calendar is well-engineered**: month index pre-built from JSON, smart prev/next skips empty
  months, year jump buttons, disabled state on boundary months.
- **N+1 avoided**: `.includes(:user)` on the crossword query covers the `display_name` call in
  `_crossword_tab`. CarrierWave `preview_url` reads from the `preview` column (no extra query).
- **Empty state handled**: Graceful fallback when nytimes user or puzzles don't exist.
- **CSS fully tokenized**: All calendar styles use design tokens. BEM naming is correct.
- **Test coverage**: 8 request specs covering day tabs, calendar data, counts, year groups, min/max.

---

## Findings

### 1. All 705 puzzles loaded at once — **should-fix**

```ruby
all_puzzles = @nytimes_user.crosswords.order(created_at: :desc).includes(:user).to_a
```

Loads every NYT crossword into memory, then:
- Renders all 705 puzzle cards in the "By Day" tab HTML (only active tab visible, but all in DOM)
- Builds a 705-entry JSON hash for the calendar

The JSON for the calendar is lightweight (~30KB) and fine. The real cost is **705 rendered
`_crossword_tab` partials** in the initial HTML payload. This will grow indefinitely (365/year).

**Fix — paginate the day-of-week tabs:**
- Keep the current `.to_a` approach for building `@puzzle_dates` (calendar JSON) — it's cheap
  since it only needs `created_at` and `id`. Better: use `.pluck(:id, :created_at)` and
  build the map from that, then load paginated records separately for the day tabs.
- For the day tabs, implement per-tab pagination with load-more (matching home page pattern).
  Alternative: since the tabs are already grouped by weekday, each tab has ~100 puzzles —
  acceptable for now. **Recommend deferring** to a follow-up if performance isn't noticeably
  degraded at 705 records. Mark as known tech debt.

**Pragmatic recommendation:** Split the query into two:
1. `@puzzle_dates` — built from `.pluck(:id, :created_at)` (avoids loading full AR objects for calendar)
2. Day tabs — keep `.to_a` for now, add `TODO` comment noting pagination needed at ~1500+ puzzles

### 2. No ARIA tab roles — **should-fix**

Neither the view toggle (By Day / Calendar) nor the day-of-week tabs use WAI-ARIA tab roles.
Screen readers see them as links/buttons with no tablist semantics.

**Required attributes:**
- Tab nav container: `role="tablist"`
- Each tab: `role="tab"`, `aria-selected="true|false"`, `aria-controls="panel-id"`
- Each panel: `role="tabpanel"`, `aria-labelledby="tab-id"`

This is a **systemic issue** — `tabs_controller.js` is shared across pages and has no ARIA
support. Fix should:
1. Add static `role` attributes in HAML
2. Update `tabs_controller.js#show()` to toggle `aria-selected`
3. Update `nyt_view_controller.js#show()` to toggle `aria-selected`

**Scope note:** The tabs controller is used on word/clue detail pages, stats, and solve page
too. Any ARIA fix should be applied to the shared controller, not just here.

### 3. Calendar not centered on desktop — **suggestion**

`.xw-calendar` has `max-width: 32rem` but no centering. On a 1440px screen the calendar
hugs the left edge of the panel.

**Fix:** Add `margin: 0 auto` to `.xw-calendar`.

### 4. `nyt_view_controller.js` not IIFE-wrapped — **nitpick**

`calendar_controller.js` is wrapped in an IIFE; `nyt_view_controller.js` is not.
`NytViewController` leaks to global scope. Inconsistent with the project convention noted
in CLAUDE.md (Stimulus controllers wrapped in IIFEs to prevent collisions).

**Fix:** Wrap in IIFE like other controllers.

### 5. Calendar grid gap hardcoded — **nitpick**

```scss
.xw-calendar__grid {
  gap: 2px;
}
```

Uses literal `2px` instead of a design token. Could use `var(--space-0)` or a named token.

### 6. Calendar `innerHTML` string concatenation — **nitpick**

Calendar builds HTML via string concatenation and sets `this.element.innerHTML`. The data
comes from server-generated `crossword_path(c)` which produces `/crosswords/:id` (safe), but
this pattern doesn't escape output. Risk is effectively zero here (no user input reaches the
template), but worth noting as a code smell.

No action needed — would only matter if puzzle paths ever included user-controlled strings.

---

## Summary Table

| # | Finding | Severity | Action |
|---|---------|----------|--------|
| 1 | 705 puzzles loaded at once | should-fix | Split query: pluck for calendar, keep `.to_a` for tabs with TODO |
| 2 | No ARIA tab roles | should-fix | Add roles to shared tabs controller + nyt-view controller |
| 3 | Calendar not centered | suggestion | Add `margin: 0 auto` |
| 4 | nyt_view_controller not IIFE-wrapped | nitpick | Wrap in IIFE |
| 5 | Calendar grid gap hardcoded | nitpick | Use token |
| 6 | innerHTML string concatenation | nitpick | No action needed |

---

## Build Instructions

### Finding 1: Optimize the query

In `pages_controller.rb#nytimes`:

```ruby
def nytimes
  unless @nytimes_user
    @puzzles_by_wday = {}
    @puzzle_dates = {}
    @total_count = 0
    return
  end

  # Calendar data: lightweight pluck (no AR objects)
  date_and_ids = @nytimes_user.crosswords.order(created_at: :desc).pluck(:id, :created_at)
  @total_count = date_and_ids.size

  @puzzle_dates = date_and_ids.each_with_object({}) do |(id, created_at), h|
    h[created_at.to_date.iso8601] = crossword_path(id)
  end
  @calendar_min = date_and_ids.last&.dig(1)&.to_date&.iso8601
  @calendar_max = date_and_ids.first&.dig(1)&.to_date&.iso8601

  # Day tabs: full objects (needed for partial rendering)
  # TODO: Add per-tab pagination when puzzle count exceeds ~1500
  all_puzzles = @nytimes_user.crosswords.order(created_at: :desc).includes(:user).to_a
  @puzzles_by_wday = all_puzzles.group_by { |c| c.created_at.wday }
end
```

Note: `crossword_path(id)` works because Rails routing accepts an integer ID directly.

### Finding 2: ARIA tab roles

**In `nytimes.html.haml`** — add `role` attributes to the view toggle:
```haml
.xw-view-toggle{role: 'tablist'}
  %button.xw-view-btn.xw-view-btn--active{role: 'tab', 'aria-selected': 'true', ...}
  %button.xw-view-btn{role: 'tab', 'aria-selected': 'false', ...}
```

**In `nytimes.html.haml`** — add `role` attributes to day-of-week tabs:
```haml
.xw-tabs__nav{role: 'tablist'}
  = link_to "#day-panel-#{wday}", role: 'tab', 'aria-selected': (i == 0).to_s, ...
```

Each panel: `role: 'tabpanel'`

**In `tabs_controller.js#show()`** — toggle `aria-selected`:
```js
this.tabTargets.forEach(tab => {
  tab.classList.toggle('xw-tab--active', tab === activeTab);
  tab.setAttribute('aria-selected', tab === activeTab ? 'true' : 'false');
});
```

Same pattern in `nyt_view_controller.js#show()`.

### Finding 3: Center calendar

In `_components.scss`:
```scss
.xw-calendar {
  max-width: 32rem;
  margin: 0 auto;  // ← add
}
```

### Finding 4: IIFE wrap

Wrap `nyt_view_controller.js` in `(function() { ... })();` like `calendar_controller.js`.

### Finding 5: Token gap

```scss
.xw-calendar__grid {
  gap: 1px;  // or define a --space-px token
}
```

(2px gap between cells is fine aesthetically — just use a token or keep literal with a comment.)

---

## Specs

Existing specs are solid. One addition for the query optimization:

```ruby
it 'does not N+1 on day-tab puzzle cards' do
  # This is implicitly tested by the existing specs rendering successfully,
  # but could add a query-count assertion if bullet gem is available
end
```

No new specs needed for ARIA (view specs test semantic HTML, but these are request specs
testing data — ARIA attributes are presentation layer).
