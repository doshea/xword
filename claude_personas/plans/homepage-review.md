# Homepage Pixel-Perfect Review — Plan

## Task 1: Fix puzzle count (must-fix)

**File:** `app/models/crossword.rb` line 49
**Change:** `self.per_page = 36` → `self.per_page = 30`

30 divides evenly by 5, 3, 2, and 1 (all column counts except 4, where it leaves 2 — acceptable).
No other files need changes; all references read `Crossword.per_page` dynamically.

**Acceptance:** At 1280px+ viewport, the last row of puzzle cards is full (5 of 5).

## Task 2: Replace legacy utility classes on load-more helper (suggestion)

**File:** `app/views/pages/home/_load_more_button.html.haml` line 4

The "N more puzzles available" text uses `.center.smaller` — global utility classes from
the Foundation era (`global.scss.erb` lines 101-108). They work, but every other homepage
element uses BEM/token classes. Replace with inline token styles or a BEM class.

**Change:** `%p.center.smaller` → `%p{ style: 'text-align: center; font-size: var(--text-sm); color: var(--color-text-muted); margin-top: var(--space-2)' }`

Or better: add a BEM modifier like `.xw-btn-hint` to `_components.scss`. But the inline
approach avoids creating a class for a single usage. Builder's call.

**Acceptance:** Text below load-more button uses design tokens, not legacy utility classes.
