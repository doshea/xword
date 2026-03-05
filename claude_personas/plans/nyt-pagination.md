# P2-5: NYT Page Pagination

## Problem

The NYT page loads **all** imported puzzles into memory on every page load (currently ~705, growing by 365/year). Two queries run:

1. **Calendar pluck** — `pluck(:id, :created_at)` — lightweight, returns 2 columns. **Fine as-is.**
2. **Day tabs** — `.includes(:user).to_a` — materializes every AR object, then groups by wday. All 7 tabs worth of puzzle card partials are rendered server-side, even though only 1 tab is visible.

The TODO at `pages_controller.rb:239` says: "Add per-tab pagination when puzzle count exceeds ~1500."

### What actually hurts

| Concern | Severity | Notes |
|---------|----------|-------|
| Partial rendering | **Main cost** | ~705 `_crossword_tab` partial renders. Rails partial rendering is expensive (~0.5ms each = ~350ms). 6 of 7 tabs are invisible. |
| AR object allocation | Moderate | ~705 objects × ~2KB = ~1.4MB. Not terrible, but grows linearly. |
| HTML payload | Moderate | ~705 cards × ~500B = ~350KB before gzip. |
| DB query | Low | Single indexed query on `user_id` + `created_at` order. Fast even at 5000 rows. |

**At current growth rate** (365/year), 1500 puzzles is reached ~2028. But the partial rendering cost is already noticeable today.

## Recommendation: Lazy Tab Loading

**Don't paginate within tabs yet.** Instead, **only render the active tab's puzzles**. Fetch other tabs on demand.

This eliminates 6/7 of partial renders on initial load. Each tab has ~100 puzzles today — manageable without intra-tab pagination. When any single tab reaches ~300 (years away), add load-more inside tabs using the existing home page pattern.

### Why this over alternatives

| Approach | Pros | Cons |
|----------|------|------|
| **Lazy tab loading** ✅ | Cuts initial render by ~85%. Simple. No gem. Preserves year-grouping naturally. | New endpoint. Minor JS change. |
| will_paginate per tab | Familiar pattern | Year-grouping across page boundaries is awkward. Requires page params per tab. URL state complex for 7 tabs. |
| Turbo Frames `loading="lazy"` | Declarative | Doesn't work with CSS `display:none` panels — "lazy" triggers on viewport visibility, not DOM show. |
| Keep all, just optimize partial | No arch change | Doesn't reduce memory/payload. Marginal gains from `render collection:`. |

## Implementation Plan

### Batch 1: Controller split + new route (~20 min)

**Files:** `config/routes.rb`, `app/controllers/pages_controller.rb`

**Route:**
```ruby
get '/nytimes/day/:wday' => 'pages#nytimes_day', as: 'nytimes_day'
```

**Controller changes:**

1. **`nytimes` action** — Replace the `.to_a` with a count-only query + load only the default tab (Monday = wday 1):
```ruby
def nytimes
  unless @nytimes_user
    @puzzles_by_wday = {}
    @puzzle_dates = {}
    @total_count = 0
    return
  end

  # Calendar data (unchanged — already lightweight)
  date_and_ids = @nytimes_user.crosswords.order(created_at: :desc).pluck(:id, :created_at)
  @total_count = date_and_ids.size
  @puzzle_dates = date_and_ids.each_with_object({}) { |(id, ca), h| h[ca.to_date.iso8601] = crossword_path(id) }
  @calendar_min = date_and_ids.last&.dig(1)&.to_date&.iso8601
  @calendar_max = date_and_ids.first&.dig(1)&.to_date&.iso8601

  # Tab counts (1 lightweight query)
  @wday_counts = @nytimes_user.crosswords
    .group("EXTRACT(DOW FROM created_at)::integer")
    .count  # => {0=>100, 1=>101, ...}

  # Default tab puzzles only (Monday = 1)
  @default_wday = 1
  @default_puzzles = nytimes_puzzles_for_wday(@default_wday)
end
```

2. **New `nytimes_day` action** — Returns HTML fragment for one day:
```ruby
def nytimes_day
  wday = params[:wday].to_i
  return head(:bad_request) unless (0..6).include?(wday) && @nytimes_user

  @puzzles = nytimes_puzzles_for_wday(wday)
  render partial: 'pages/nyt_day_content', locals: { puzzles: @puzzles }, layout: false
end
```

3. **Private helper:**
```ruby
def nytimes_puzzles_for_wday(wday)
  @nytimes_user.crosswords
    .where("EXTRACT(DOW FROM created_at)::integer = ?", wday)
    .order(created_at: :desc)
    .includes(:user)
end
```

**Note:** `EXTRACT(DOW FROM created_at)` hits an indexed column (`created_at`) and the table is filtered by `user_id` first (~705 rows). No functional index needed — sequential scan of 705 rows is trivially fast.

### Batch 2: View refactor (~15 min)

**Files:** `app/views/pages/nytimes.html.haml`, new partial `app/views/pages/_nyt_day_content.html.haml`

1. **Extract day panel content** into `_nyt_day_content.html.haml`:
```haml
- if puzzles.empty?
  .xw-empty-state
    %p No puzzles imported for this day.
- else
  - puzzles.group_by { |c| c.created_at.year }.each do |year, year_puzzles|
    %h3.xw-year-header= year
    %ul
      - year_puzzles.each do |crossword|
        %li
          = render partial: 'crosswords/partials/crossword_tab', locals: {cw: crossword}
```

2. **Update `nytimes.html.haml`** — tab panels use `data-lazy-src` for deferred tabs:
```haml
- day_order.each_with_index do |(wday, label), i|
  - count = @wday_counts[wday] || 0
  %button{...same attributes...}
    %span.tab-label
      %span #{label} (#{count})

.xw-tab-panels
  - day_order.each_with_index do |(wday, label), i|
    - is_default = (wday == @default_wday)
    %div{id: "day-panel-#{wday}", role: 'tabpanel', class: "xw-tab-panel #{'xw-tab-panel--active' if is_default}", data: {tabs_target: 'panel'}.merge(is_default ? {} : {'lazy-src': nytimes_day_path(wday: wday)})}
      - if is_default
        = render partial: 'pages/nyt_day_content', locals: {puzzles: @default_puzzles}
      - else
        .xw-loading-placeholder
          %p Loading…
```

### Batch 3: Stimulus enhancement (~10 min)

**File:** `app/assets/javascripts/controllers/tabs_controller.js`

Add lazy-loading logic to the existing `show()` method:

```javascript
show(event) {
  // ... existing tab toggle logic (unchanged) ...

  // Lazy-load tab content if panel has data-lazy-src
  const activePanel = this.panelTargets.find(p => p.id === panelId);
  if (activePanel && activePanel.dataset.lazySrc && !activePanel.dataset.loaded) {
    fetch(activePanel.dataset.lazySrc, {
      headers: { 'X-Requested-With': 'XMLHttpRequest' }
    })
      .then(r => r.text())
      .then(html => {
        activePanel.innerHTML = html;
        activePanel.dataset.loaded = 'true';
      })
      .catch(() => {
        activePanel.innerHTML = '<p class="xw-empty-state">Failed to load. Please refresh.</p>';
      });
  }
}
```

**Why modify TabsController vs create NytTabsController:** The lazy-src behavior is generic and harmless — if no `data-lazy-src` attribute exists, nothing happens. Other tab instances are unaffected.

### Batch 4: Specs (~10 min)

**File:** `spec/requests/pages_spec.rb`

Update existing specs + add new ones:

1. Existing tab count spec still works (counts rendered in buttons from `@wday_counts`)
2. Existing calendar specs unchanged (pluck logic untouched)
3. **New specs:**
   - `GET /nytimes` only renders puzzle cards for the default tab (Monday)
   - `GET /nytimes` includes `data-lazy-src` attributes on non-default panels
   - `GET /nytimes/day/1` returns puzzle cards for Monday
   - `GET /nytimes/day/6` returns puzzle cards for Saturday
   - `GET /nytimes/day/8` returns 400
   - `GET /nytimes/day/1` without nytimes user returns 400

## Risks

| Risk | Mitigation |
|------|-----------|
| `EXTRACT(DOW FROM created_at)` slow on large tables | Only 705 rows (filtered by user_id first). Index on `(user_id, created_at)` already exists. Would need functional index only at 10K+ rows — never happening for NYT. |
| Existing specs break | Tab counts now come from `@wday_counts` hash instead of `.size` on array. Button text is identical — `Mon (1)` — so specs pass. Calendar logic is completely unchanged. |
| TabsController change affects other pages | Lazy-load is opt-in via `data-lazy-src`. No other page uses this attribute. |
| Broken JS = empty tab forever | Error handler shows "Failed to load" message. `data-loaded` flag prevents re-fetching already loaded tabs. |

## Not in scope

- **Intra-tab pagination** (load-more within a single day's tab) — not needed until any day exceeds ~300 puzzles (~2030)
- **Calendar optimization** — pluck is already lightweight; even at 5000 puzzles, plucking 2 columns is fast
- **Collection rendering** (`render collection:` instead of loop) — marginal gain, can be a follow-up nitpick
- **Caching** — fragment caching the tab content is possible but adds complexity; lazy loading is sufficient

## Acceptance Criteria

- [ ] Initial page load renders puzzle cards for Monday tab only
- [ ] Clicking another day tab fetches and displays its puzzles
- [ ] Tab counts are accurate for all 7 days
- [ ] Calendar panel works exactly as before
- [ ] Clicking a tab that was already loaded doesn't re-fetch
- [ ] No nytimes user → empty state renders (no errors)
- [ ] All existing NYT specs pass
- [ ] New specs cover the lazy endpoint
