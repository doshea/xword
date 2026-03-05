# Review: User-Made Puzzles Page (#13)

**Scope:** `/user_made` route — `PagesController#user_made`, view template, specs
**Verdict:** Clean and small. 1 should-fix, 2 suggestions, 1 nitpick.

---

## Should-Fix

### 1. Missing page title
**File:** `app/views/pages/user_made.html.haml`

Every other page in `pages/` has `- title '...'` on line 1. User-made is the only one missing it.
Browser tab shows the app default instead of "User-Made Puzzles".

**Fix:** Add `- title 'User-Made Puzzles'` as line 1.

---

## Suggestions

### 2. No puzzle count in heading
The NYT page shows per-day counts; the home page shows per-tab counts. User-made shows no count at all.
Adding a count to the heading (e.g., "User-Made Puzzles (12)") gives users context without code complexity.

**Fix:** In controller, set `@user_puzzle_count = @user_puzzles.size` (or `.count` if lazy-loading).
In template, update the `row_top_title` to include count:
`row_top_title: "User-Made Puzzles#{" (#{@user_puzzles.size})" if @user_puzzles.any?}"`

### 3. Thin test coverage
Only one test exists: "renders even without an nytimes user". Missing coverage for:
- Page renders with puzzles present (including correct ordering)
- Empty state renders when no user-made puzzles exist
- Page title is set
- NYT puzzles are excluded when nytimes user exists

**Fix:** Add 2-3 request specs:
```ruby
describe 'GET /user_made' do
  it 'renders even without an nytimes user' do
    get '/user_made'
    expect(response).to have_http_status(:ok)
  end

  it 'sets the page title' do
    get '/user_made'
    expect(response.body).to include('<title>User-Made Puzzles')
  end

  context 'with an nytimes user' do
    let!(:nyt_user) { create(:user, username: 'nytimes') }
    let!(:nyt_crossword) { create(:crossword, user: nyt_user) }
    let!(:user_crossword) { create(:crossword) }

    it 'excludes NYT puzzles' do
      get '/user_made'
      expect(response.body).to include(user_crossword.title)
      expect(response.body).not_to include(nyt_crossword.title)
    end
  end
end
```

---

## Nitpick

### 4. No pagination (known pattern — not actionable now)
Loads all user-made puzzles with `.order().includes()` — no `.paginate()` or `.limit()`.
The NYT page does the same (705+ puzzles loaded at once, flagged in nyt-calendar-review).
Currently few user-made puzzles exist, so this is not urgent.

**Action:** Note for future. If the community puzzle count grows past ~100, add will_paginate
(gem already in Gemfile) or the "load more" pattern used on the home page.

---

## What's Good

- Clean, minimal template (13 lines)
- Proper `.includes(:user)` prevents N+1
- Explicit `.order(created_at: :desc)` (no default scope reliance)
- Nil-safe `@nytimes_user` guard (graceful fallback to all puzzles)
- Reuses `crossword_tab` partial and `topper_stopper` layout — zero duplication
- Empty state with CTA to create dashboard is user-friendly
