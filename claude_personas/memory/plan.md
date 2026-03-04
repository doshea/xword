# Plan: NYT Crosswords Page — Day-of-Week Tabs + Calendar View

## Overview

Rewrite `/nytimes` page from flat list to two views: day-of-week tabs (default) and calendar.
Day-of-week = NYT difficulty (Mon=easy → Sat=hard, Sun=themed). Calendar lets you find a
specific date.

**Confirmed:** `Crossword.created_at` is set to the actual NYT publication date in
`NytPuzzleImporter` (line 62), NOT the import date. So `.wday` correctly maps to difficulty.

---

## File-by-File Implementation

### 1. Controller — `app/controllers/pages_controller.rb`

Replace the `nytimes` action (currently line 148-150):

```ruby
def nytimes
  unless @nytimes_user
    @puzzles_by_wday = {}
    @puzzle_dates = {}
    @total_count = 0
    return
  end

  all_puzzles = @nytimes_user.crosswords.order(created_at: :desc).includes(:user).to_a
  @total_count = all_puzzles.size

  # Day-of-week tabs: group by wday (Ruby: 0=Sun, 1=Mon..6=Sat)
  @puzzles_by_wday = all_puzzles.group_by { |c| c.created_at.wday }

  # Calendar: date string => crossword path (JSON for Stimulus)
  @puzzle_dates = all_puzzles.each_with_object({}) do |c, h|
    h[c.created_at.to_date.iso8601] = crossword_path(c)
  end
  @calendar_min = all_puzzles.last&.created_at&.to_date&.iso8601
  @calendar_max = all_puzzles.first&.created_at&.to_date&.iso8601
end
```

**Why `.to_a` first:** The original plan called `puzzles.size` (triggers COUNT query) then
`.group_by` (triggers SELECT query) — two DB roundtrips. `.to_a` loads once; `.size` on the
array is free.

**Why all ivars set on early return:** The view uses `@puzzles_by_wday`, `@puzzle_dates`,
`@total_count`. If `@nytimes_user` is nil and these aren't set, the view gets nil errors.

**Why `.iso8601` not `.to_s`:** Explicit format for JSON parsing in JS. Same output (`2024-01-15`)
but communicates intent.

---

### 2. View — `app/views/pages/nytimes.html.haml`

Full rewrite. Structure:

```haml
- title 'NYT Crosswords'

= render layout: 'layouts/partials/topper_stopper', locals: {columns_class: 'puzzle-tabs', row_top_title: "#{image_tag 'nyt_white.png', width: 20} New York Times Crosswords".html_safe} do

  - if @total_count == 0
    %p.xw-empty-state No NYT puzzles have been imported yet.
  - else
    /- View toggle (By Day / Calendar) — nyt-view Stimulus controller
    .nyt-view{data: {controller: 'nyt-view'}}
      .xw-view-toggle
        %button.xw-view-btn.xw-view-btn--active{data: {'nyt-view-target': 'btn', action: 'click->nyt-view#show'}, value: 'day'}
          = icon('calendar-days')
          By Day
        %button.xw-view-btn{data: {'nyt-view-target': 'btn', action: 'click->nyt-view#show'}, value: 'calendar'}
          = icon('calendar')
          Calendar

      /- Panel 1: Day-of-week tabs
      .nyt-view-panel.nyt-view-panel--active{data: {'nyt-view-target': 'panel'}}
        .xw-tabs{data: {controller: 'tabs'}}
          .xw-tabs__nav
            - day_order = [[1, 'Mon'], [2, 'Tue'], [3, 'Wed'], [4, 'Thu'], [5, 'Fri'], [6, 'Sat'], [0, 'Sun']]
            - day_order.each_with_index do |(wday, label), i|
              - count = (@puzzles_by_wday[wday] || []).size
              = link_to "#day-panel-#{wday}", class: "xw-tab #{'xw-tab--active' if i == 0}", data: {tabs_target: 'tab', action: 'click->tabs#show'} do
                %span.tab-label
                  %span #{label} (#{count})

          .xw-tab-panels
            - day_order.each_with_index do |(wday, label), i|
              - puzzles = @puzzles_by_wday[wday] || []
              %div{id: "day-panel-#{wday}", class: "xw-tab-panel #{'xw-tab-panel--active' if i == 0}", data: {tabs_target: 'panel'}}
                - if puzzles.empty?
                  %p.xw-empty-state No #{label} puzzles imported.
                - else
                  - puzzles.group_by { |c| c.created_at.year }.each do |year, year_puzzles|
                    %h3.xw-year-header= year
                    %ul
                      - year_puzzles.each do |crossword|
                        %li
                          = render partial: 'crosswords/partials/crossword_tab', locals: {cw: crossword}

      /- Panel 2: Calendar
      .nyt-view-panel{data: {'nyt-view-target': 'panel'}}
        .xw-calendar{data: {controller: 'calendar', 'calendar-puzzles-value': @puzzle_dates.to_json, 'calendar-min-value': @calendar_min, 'calendar-max-value': @calendar_max}}
```

**Key decisions:**
- `columns_class: 'puzzle-tabs'` preserved — needed for `.puzzle-tabs ul` CSS Grid rule.
- `day_order` array keeps Mon-Sun order (wday 1,2,3,4,5,6,0).
- Year sub-grouping done in the view via `.group_by { |c| c.created_at.year }` — this is
  presentation logic, not business logic.
- Puzzle counts shown in tab labels: `Mon (102)`.
- Empty state per tab in case a day has zero puzzles (unlikely but defensive).

---

### 3. Stimulus — `app/assets/javascripts/controllers/nyt_view_controller.js`

```javascript
// Toggle between "By Day" and "Calendar" views on the NYT page.
// Two button targets, two panel targets. Mirrors tabs_controller pattern
// but uses different class names to avoid conflicts with nested tabs.
class NytViewController extends Stimulus.Controller {
  show(event) {
    event.preventDefault();
    var clickedBtn = event.currentTarget;

    this.btnTargets.forEach(function(btn) {
      btn.classList.toggle('xw-view-btn--active', btn === clickedBtn);
    });

    var panels = this.panelTargets;
    var clickedIndex = this.btnTargets.indexOf(clickedBtn);
    panels.forEach(function(panel, i) {
      panel.classList.toggle('nyt-view-panel--active', i === clickedIndex);
    });
  }
}
NytViewController.targets = ['btn', 'panel'];
window.StimulusApp.register('nyt-view', NytViewController);
```

**Why a separate controller (not reusing tabs_controller):** The tabs controller hardcodes
`xw-tab--active` and `xw-tab-panel--active` class names. The view toggle needs different
classes (`xw-view-btn--active`, `nyt-view-panel--active`) to avoid conflicting with the
nested day-of-week tabs inside panel 1.

**Index-based pairing:** Maps button index to panel index (0→first panel, 1→second panel).
Simpler than href-based ID matching since there are only two states.

---

### 4. Stimulus — `app/assets/javascripts/controllers/calendar_controller.js`

```javascript
// Month-by-month calendar for NYT puzzles. Reads puzzle dates from a JSON
// data attribute, renders a 7-column grid (Mon-Sun), highlights days with puzzles.
class CalendarController extends Stimulus.Controller {
  connect() {
    this.puzzles = JSON.parse(this.puzzlesValue || '{}');
    this.minDate = this.minValue ? new Date(this.minValue + 'T00:00:00') : null;
    this.maxDate = this.maxValue ? new Date(this.maxValue + 'T00:00:00') : null;

    if (this.maxDate) {
      this.currentYear = this.maxDate.getFullYear();
      this.currentMonth = this.maxDate.getMonth();
    } else {
      var now = new Date();
      this.currentYear = now.getFullYear();
      this.currentMonth = now.getMonth();
    }

    this.render();
  }

  prev() {
    this.currentMonth--;
    if (this.currentMonth < 0) {
      this.currentMonth = 11;
      this.currentYear--;
    }
    // Clamp to min
    if (this.minDate && new Date(this.currentYear, this.currentMonth + 1, 0) < this.minDate) {
      return;
    }
    this.render();
  }

  next() {
    this.currentMonth++;
    if (this.currentMonth > 11) {
      this.currentMonth = 0;
      this.currentYear++;
    }
    // Clamp to max
    if (this.maxDate && new Date(this.currentYear, this.currentMonth, 1) > this.maxDate) {
      return;
    }
    this.render();
  }

  render() {
    var year = this.currentYear;
    var month = this.currentMonth;
    var firstDay = new Date(year, month, 1);
    var lastDay = new Date(year, month + 1, 0);
    var daysInMonth = lastDay.getDate();
    // JS getDay(): 0=Sun..6=Sat. Convert to Mon-based: Mon=0..Sun=6
    var startOffset = (firstDay.getDay() + 6) % 7;

    var monthNames = ['January','February','March','April','May','June',
                      'July','August','September','October','November','December'];

    // Nav controls
    var canPrev = !this.minDate || new Date(year, month - 1, 1) >= new Date(this.minDate.getFullYear(), this.minDate.getMonth(), 1);
    var canNext = !this.maxDate || new Date(year, month + 1, 1) <= new Date(this.maxDate.getFullYear(), this.maxDate.getMonth(), 1);

    var html = '';
    html += '<div class="xw-calendar__nav">';
    html += '<button class="xw-btn xw-btn--ghost" data-action="click->calendar#prev"' + (canPrev ? '' : ' disabled') + '>&lsaquo;</button>';
    html += '<h3 class="xw-calendar__title">' + monthNames[month] + ' ' + year + '</h3>';
    html += '<button class="xw-btn xw-btn--ghost" data-action="click->calendar#next"' + (canNext ? '' : ' disabled') + '>&rsaquo;</button>';
    html += '</div>';

    // Day headers (Mon-Sun)
    html += '<div class="xw-calendar__grid">';
    var dayHeaders = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    for (var d = 0; d < 7; d++) {
      html += '<div class="xw-calendar__header">' + dayHeaders[d] + '</div>';
    }

    // Empty cells before first day
    for (var e = 0; e < startOffset; e++) {
      html += '<div class="xw-calendar__cell xw-calendar__cell--empty"></div>';
    }

    // Day cells
    for (var day = 1; day <= daysInMonth; day++) {
      var pad = function(n) { return n < 10 ? '0' + n : '' + n; };
      var dateStr = year + '-' + pad(month + 1) + '-' + pad(day);
      var puzzlePath = this.puzzles[dateStr];

      if (puzzlePath) {
        html += '<a href="' + puzzlePath + '" class="xw-calendar__cell xw-calendar__cell--has-puzzle" title="' + dateStr + '">' + day + '</a>';
      } else {
        html += '<div class="xw-calendar__cell">' + day + '</div>';
      }
    }

    html += '</div>';
    this.element.innerHTML = html;
  }
}
CalendarController.targets = [];
CalendarController.values = { puzzles: String, min: String, max: String };
window.StimulusApp.register('calendar', CalendarController);
```

**IMPORTANT — Stimulus values API:** Check whether this Sprockets-bundled Stimulus version
supports `static values = {}`. The existing controllers only use `targets`, not `values`.
If values aren't supported, fall back to reading data attributes directly:

```javascript
// Fallback if values API not available:
this.puzzles = JSON.parse(this.element.dataset.calendarPuzzlesValue || '{}');
this.minDate = this.element.dataset.calendarMinValue ? new Date(...) : null;
this.maxDate = this.element.dataset.calendarMaxValue ? new Date(...) : null;
```

**Builder should test this first** — if `CalendarController.values = {...}` throws, use the
`dataset` fallback pattern instead.

---

### 5. CSS — `app/assets/stylesheets/_components.scss`

Append after line 918 (after `.nyt-watermark` block, before LEGACY OVERRIDES):

```scss
// ---------------------------------------------------------------------------
// NYT VIEW TOGGLE — .xw-view-toggle / .nyt-view-panel
// ---------------------------------------------------------------------------

.xw-view-toggle {
  display: flex;
  gap: var(--space-1);
  margin-bottom: var(--space-4);
}

.xw-view-btn {
  display: inline-flex;
  align-items: center;
  gap: var(--space-1);
  background: none;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: var(--space-1) var(--space-3);
  font-family: var(--font-ui);
  font-size: var(--text-sm);
  font-weight: var(--weight-medium);
  color: var(--color-text-muted);
  cursor: pointer;
  transition: var(--transition-colors);

  &:hover { color: var(--color-text); border-color: var(--color-border-strong); }

  &.xw-view-btn--active {
    color: var(--color-accent);
    border-color: var(--color-accent);
    background-color: var(--color-accent-light);
  }

  svg { width: 1em; height: 1em; }
}

.nyt-view-panel {
  display: none;
  &.nyt-view-panel--active { display: block; }
}


// ---------------------------------------------------------------------------
// CALENDAR — .xw-calendar
// ---------------------------------------------------------------------------

.xw-calendar {
  max-width: 32rem;
}

.xw-calendar__nav {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--space-3);
}

.xw-calendar__title {
  font-family: var(--font-display);
  font-size: var(--text-xl);
  font-weight: var(--weight-semibold);
  color: var(--color-text);
  margin: 0;
}

.xw-calendar__grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 2px;
}

.xw-calendar__header {
  font-family: var(--font-ui);
  font-size: var(--text-xs);
  font-weight: var(--weight-medium);
  color: var(--color-text-muted);
  text-align: center;
  padding: var(--space-1) 0;
  text-transform: uppercase;
  letter-spacing: var(--tracking-wide);
}

.xw-calendar__cell {
  aspect-ratio: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: var(--font-ui);
  font-size: var(--text-sm);
  color: var(--color-text-muted);
  border-radius: var(--radius-sm);

  &--has-puzzle {
    background: var(--color-accent-light);
    color: var(--color-accent);
    font-weight: var(--weight-medium);
    text-decoration: none;
    transition: var(--transition-colors);

    &:hover {
      background: var(--color-accent);
      color: white;
    }
  }

  &--empty {
    // intentionally blank — no number, no background
  }
}


// ---------------------------------------------------------------------------
// YEAR SEPARATOR — within day-of-week tabs
// ---------------------------------------------------------------------------

.xw-year-header {
  font-family: var(--font-display);
  font-size: var(--text-lg);
  color: var(--color-text-secondary);
  border-bottom: 1px solid var(--color-border);
  margin: var(--space-4) 0 var(--space-2);
  padding-bottom: var(--space-1);
}
```

**All tokens verified** — every `var(--*)` reference exists in `_design_tokens.scss`.

---

### 6. Specs — `spec/requests/pages_spec.rb`

Expand the existing `describe 'GET /nytimes'` block (line 172-177):

```ruby
describe 'GET /nytimes' do
  it 'renders even without an nytimes user' do
    get '/nytimes'
    expect(response).to have_http_status(:ok)
  end

  context 'with nytimes user and puzzles' do
    let!(:nytimes_user) { create(:user, username: 'nytimes') }

    before do
      # Create puzzles on different days of the week
      # Monday puzzle
      create(:crossword, :smaller, user: nytimes_user, created_at: Date.new(2024, 1, 15))
      # Saturday puzzle
      create(:crossword, :smaller, user: nytimes_user, created_at: Date.new(2024, 1, 20))
    end

    it 'renders successfully' do
      get '/nytimes'
      expect(response).to have_http_status(:ok)
    end

    it 'includes day-of-week tab labels' do
      get '/nytimes'
      body = response.body
      expect(body).to include('Mon')
      expect(body).to include('Sat')
      expect(body).to include('Sun')
    end

    it 'includes calendar data attributes' do
      get '/nytimes'
      expect(response.body).to include('calendar-puzzles-value')
      expect(response.body).to include('2024-01-15')
    end

    it 'shows puzzle counts in tabs' do
      get '/nytimes'
      expect(response.body).to include('Mon (1)')
      expect(response.body).to include('Sat (1)')
    end
  end
end
```

---

### 7. Sprockets — No changes needed

`app/assets/config/manifest.js` uses `require_tree ./controllers` which auto-includes
new controller files. Verified.

---

## Review Findings

### Must-Fix (2)

**M1 — Nil ivars on early return (severity: must-fix)**
Original plan: `return @nytimes_puzzles = Crossword.none unless @nytimes_user`. This leaves
`@puzzles_by_wday`, `@puzzle_dates`, `@total_count` as nil. The new view iterates these.
**Fix:** Set all ivars to empty defaults on early return (done in code above).

**M2 — Double DB query (severity: must-fix)**
Original plan: `puzzles.size` triggers `SELECT COUNT(*)`, then `.group_by` triggers `SELECT *`.
Two queries when one suffices. 705 records — not a performance issue, but wasteful.
**Fix:** `.to_a` first, then `.size` on the array (done in code above).

### Should-Fix (2)

**S1 — Stimulus values API may not be available (severity: should-fix)**
Existing controllers use only `targets`, never `values`. The Sprockets-bundled Stimulus
may be an older version without values support. The calendar controller in the plan uses
`CalendarController.values = { puzzles: String, min: String, max: String }`.
**Fix:** Builder should test values API first. If it doesn't work, read from
`this.element.dataset` directly (fallback pattern included in code above).

**S2 — View toggle panel visibility CSS missing from original plan (severity: should-fix)**
The original plan's CSS section defines `.xw-view-toggle` and `.xw-view-btn` but never defines
`.nyt-view-panel { display: none }` / `.nyt-view-panel--active { display: block }`. Without
this, both panels are always visible.
**Fix:** Added to CSS section above.

### Suggestions (3)

**G1 — Tab labels could show difficulty emoji**
Mon ☕ → Sat 🔥 → Sun 🎯 would reinforce the difficulty progression. Optional — might feel
gimmicky. Defer to user preference.

**G2 — URL hash for deep linking**
`/nytimes#saturday` could open directly to that tab. Neither the existing tabs controller
nor the plan supports hash-based initial state. Nice-to-have for sharing. Low priority.

**G3 — "N puzzles total" subtitle**
Showing `@total_count` under the page title gives context. e.g. "705 puzzles".

---

## Order of Operations

1. Controller changes (set up all ivars)
2. CSS (new classes must exist before the view references them)
3. Both Stimulus controllers
4. View (depends on controller data + CSS classes + Stimulus controllers)
5. Specs
6. `bundle exec rspec` — verify all pass
7. Manual verification: `/nytimes` with both views, tab switching, calendar navigation, mobile

---

## Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| 700 puzzle card partials rendered server-side | Low | Same as current page (705 cards). Defer lazy-load to later. |
| Calendar JSON ~28KB | Low | Fine for single page load. |
| 7 tabs on mobile | Low | `.xw-tabs__nav` already has `overflow-x: auto` with hidden scrollbar. |
| Stimulus values API unavailability | Medium | Test first; dataset fallback ready. |
| Nested Stimulus controllers (nyt-view wrapping tabs) | Low | Different controller identifiers, no target conflicts. Verified. |
