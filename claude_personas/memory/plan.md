# Plan: Homepage "Load More" Pagination

## Overview

The homepage shows "Showing 100 of 300 puzzles" with no way to see the rest. Replace the dead-letter info text with a working "Load More" button that uses Turbo Streams to append the next batch of puzzle cards.

## Current State

- **Logged-in:** `PagesController#home` loads first 100 via `.limit(per)` per tab. Count is displayed but no pagination.
- **Anonymous:** Uses `will_paginate` in the controller but never renders `will_paginate` links in the view. Same problem.
- **Dead code:** `CrosswordsController#batch` + `_load_next_button.html.haml` + `batch.turbo_stream.erb` were an attempt at load-more but broke because all remaining IDs were stuffed into the query string (414 URI Too Long). The button partial is never rendered. The `batch` endpoint is never called.

## Design

### Approach: Turbo Stream "Load More" button

1. Each puzzle list `<ul>` gets a unique ID
2. Below the list, a `button_to` form points to `POST /home/load_more` with `scope` + `page` params
3. Turbo intercepts the form POST, server returns Turbo Streams:
   - `append` each new puzzle `<li>` to the `<ul>`
   - `replace` the button with an updated one (next page) — or `remove` it if done
4. No custom JS needed — Turbo handles everything

### Why not Turbo Frames?

Frames **replace** content. We need to **append** items to an existing `<ul>`. Turbo Streams are the right tool.

### Why not will_paginate?

Traditional pagination (page 1, 2, 3...) forces a full page reload and loses the tab state. Load-more preserves scroll position and feels native.

---

## Files to Touch (8 files modified, 2 new, 3 deleted)

### 1. Route

**File: `config/routes.rb`**

Add after the existing page routes:

```ruby
post '/home/load_more' => 'pages#load_more', as: 'home_load_more'
```

Also delete the dead `batch` route:

```ruby
# DELETE this line from crosswords resources:
post :batch
```

### 2. Controller

**File: `app/controllers/pages_controller.rb`** — new `load_more` action

```ruby
# POST /home/load_more
# Returns Turbo Stream: appends next page of puzzle cards, updates load-more button.
def load_more
  page = [params[:page].to_i, 1].max
  per = Crossword.per_page
  scope_name = params[:scope]

  scope = if @current_user
            case scope_name
            when 'unstarted'   then Crossword.new_to_user(@current_user)
            when 'in_progress' then Crossword.all_in_progress(@current_user)
            when 'solved'      then Crossword.all_solved(@current_user)
            else return head :bad_request
            end
          else
            return head :bad_request unless scope_name == 'unstarted'
            Crossword.all
          end

  @total     = scope.count
  @crosswords = scope.order(created_at: :desc).includes(:user)
                     .offset((page - 1) * per).limit(per)
  @list_id   = "#{scope_name.dasherize}-list"
  @scope     = scope_name
  @next_page = page + 1
  @remaining = [@total - (page * per), 0].max
  @has_more  = @remaining > 0
end
```

**Design notes:**
- Anonymous users can only load `unstarted` (all puzzles). The other scopes need a user.
- `scope_name.dasherize` converts `in_progress` → `in-progress` for HTML IDs.
- `offset + limit` is standard SQL pagination. No cursor needed — puzzle ordering is stable (created_at desc).

### 3. Turbo Stream View (new)

**New file: `app/views/pages/load_more.turbo_stream.haml`**

```haml
- @crosswords.each do |cw|
  = turbo_stream.append @list_id do
    %li
      = render partial: 'crosswords/partials/crossword_tab', locals: {cw: cw}
- if @has_more
  = turbo_stream.replace "load-more-#{@scope}" do
    = render partial: 'pages/home/load_more_button', locals: {scope: @scope, page: @next_page, remaining: @remaining}
- else
  = turbo_stream.remove "load-more-#{@scope}"
```

### 4. Load More Button Partial (new, replaces broken `_load_next_button`)

**New file: `app/views/pages/home/_load_more_button.html.haml`**

```haml
- next_batch = [remaining, Crossword.per_page].min
%div{id: "load-more-#{scope}"}
  = button_to "Load next #{next_batch} puzzles", home_load_more_path, params: {scope: scope, page: page}, class: 'xw-btn xw-btn--secondary xw-btn--full', data: {disable_with: 'Loading...'}
  %p.center.smaller #{remaining} more #{remaining == 1 ? 'puzzle' : 'puzzles'} available
```

**Key detail:** The outer `%div{id: "load-more-#{scope}"}` is the Turbo Stream target. `button_to` generates a `<form>` which Turbo intercepts. `data-disable-with` prevents double-clicks.

### 5. Update `_crossword_list.html.haml`

**File: `app/views/pages/home/_crossword_list.html.haml`**

Replace entire file:

```haml
- if collection.any?
  %ul{id: list_id}
    - collection.each do |cw|
      %li
        = render partial: 'crosswords/partials/crossword_tab', locals: {cw: cw}
  - if count > collection.size
    = render partial: 'pages/home/load_more_button', locals: {scope: scope, page: 2, remaining: count - collection.size}
- else
  %p= empty_message
```

Changes:
- Line 2: `list_id` is now required (no conditional `defined?` check)
- Lines 6-7: Replaced "Showing X of Y" text with load_more_button partial
- New required local: `scope`

### 6. Update Tab Partials (pass `list_id` and `scope`)

**File: `app/views/pages/home/_unstarted.html.haml`**

```haml
= render partial: 'pages/home/crossword_list', locals: { collection: @unstarted, count: @unstarted_count, list_id: 'unstarted-list', scope: 'unstarted', empty_message: "You're already working on all of the puzzles we've got!" }
```

Changes: `list_id: 'crossword-tab-list'` → `'unstarted-list'`, added `scope: 'unstarted'`. Remove the comment about batch.

**File: `app/views/pages/home/_in_progress.html.haml`**

```haml
- if @current_user
  = render partial: 'pages/home/crossword_list', locals: { collection: @in_progress, count: @in_progress_count, list_id: 'in-progress-list', scope: 'in_progress', empty_message: "You're not working on any puzzles right now! Why not #{link_to 'start a new one?', '#panel1'}" }
- else
  %p Make an account or log in and you'll be able to track which crosswords you're working on!
```

Changes: added `list_id`, `scope`. Also fixed broken link: `'#panel2'` → `'#panel1'` (the empty-state message linked to itself — should link to the New Puzzles tab).

**File: `app/views/pages/home/_solved_puzzles.html.haml`**

```haml
- if @current_user
  = render partial: 'pages/home/crossword_list', locals: { collection: @solved, count: @solved_count, list_id: 'solved-list', scope: 'solved', empty_message: "You haven't finished any puzzles yet -- go check out the New tab and try one!" }
- else
  %p Make an account or log in and you'll be able to track which crosswords you've finished!
```

Changes: added `list_id`, `scope`.

### 7. Delete Dead Code

- **Delete:** `app/views/pages/home/_load_next_button.html.haml` (broken, never rendered)
- **Delete:** `app/views/crosswords/batch.turbo_stream.erb` (dead — button never rendered)
- **Delete:** `CrosswordsController#batch` action (dead code)
- **Delete:** `post :batch` from `config/routes.rb`

### 8. Specs

**New file: `spec/requests/pages_load_more_spec.rb`**

```ruby
require 'rails_helper'

RSpec.describe 'POST /home/load_more', type: :request do
  let(:user) { create(:user, :with_test_password) }

  describe 'as a logged-in user' do
    before { log_in_as(user) }

    it 'returns turbo stream with puzzle cards for unstarted scope' do
      post home_load_more_path, params: { scope: 'unstarted', page: 1 }
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq Mime[:turbo_stream].to_s
    end

    it 'returns turbo stream for in_progress scope' do
      post home_load_more_path, params: { scope: 'in_progress', page: 1 }
      expect(response).to have_http_status(:ok)
    end

    it 'returns turbo stream for solved scope' do
      post home_load_more_path, params: { scope: 'solved', page: 1 }
      expect(response).to have_http_status(:ok)
    end

    it 'rejects invalid scope' do
      post home_load_more_path, params: { scope: 'bogus', page: 1 }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'as an anonymous user' do
    it 'allows unstarted scope' do
      post home_load_more_path, params: { scope: 'unstarted', page: 1 }
      expect(response).to have_http_status(:ok)
    end

    it 'rejects non-unstarted scopes' do
      post home_load_more_path, params: { scope: 'in_progress', page: 1 }
      expect(response).to have_http_status(:bad_request)
    end
  end
end
```

### 9. Button styling (minor CSS addition)

**File: `app/assets/stylesheets/_components.scss`** — add `.xw-btn--full` utility if it doesn't exist:

```scss
.xw-btn--full {
  width: 100%;
}
```

This makes the load-more button span the full width of the puzzle grid (centered, prominent). If this utility already exists, skip.

---

## Edge Cases

| Case | Handling |
|------|----------|
| Tab has ≤ 100 puzzles | No button rendered (count ≤ collection.size) |
| Last page has < 100 | Button says "Load last N puzzles" then removed |
| Anonymous + non-unstarted scope | 400 Bad Request |
| Page param is 0 or negative | Clamped to 1 via `[params[:page].to_i, 1].max` |
| Double-click | `data-disable-with` grays out button during request |
| Tab switch after loading | Loaded puzzles persist in DOM (Stimulus tabs just toggle visibility) |

## Risk

**Very low.** This replaces dead code with working code:
- No existing behavior changes (the "Showing X of Y" text was purely informational)
- Turbo Streams is proven infrastructure (used by batch.turbo_stream.erb design, notifications, etc.)
- Pure additive: new route, new action, new view, new partial
- Dead code deletion: `batch` was confirmed unreachable (button never rendered)

## Not in Scope

- **NYTimes / User-Made pages:** Also lack pagination, but those are separate pages with different layouts. Can be addressed later with the same pattern.
- **Search pagination:** Different UX (live search vs page-based). Separate concern.
- **Infinite scroll:** User approved "load more" button, not auto-scroll-to-load.
