# Changelog Page — UX & Design Review

## Summary

The changelog works technically but has two broken fundamentals: **the CSS never loads**
(so all 306 lines of timeline/badge/responsive styling are invisible), and **commit messages
stutter** ("Fix Fix...", "Polish Polish..."). Beyond that, raw developer commits leak internal
noise to end users. Fixing these transforms the page from a developer debug log into a
real changelog.

---

## Findings

### 1. CSS not loading — MUST-FIX

**Problem:** `changelog.scss` (306 lines — timeline, colored badges, responsive layout) is
compiled by Sprockets but never linked. Every other page-specific stylesheet uses
`content_for :head` + `stylesheet_link_tag`. Changelog doesn't. The page renders as
unstyled body text.

**Evidence:** Screenshot shows no timeline line, no timeline dots, no colored badges, no
entry separators — just a flat text list.

**Fix:** Add `content_for :head` block to `changelog.html.haml`:
```haml
= content_for :head do
  = stylesheet_link_tag 'changelog'
```

**Files:** `app/views/pages/changelog.html.haml`

---

### 2. Redundant category prefix in messages — MUST-FIX

**Problem:** Every entry stutters: "Fix Fix edit page save button", "Polish Polish
notifications", "Update Update persona memory". The `categorize()` method matches on the
first word of the commit message (e.g., "Fix"), creates a badge showing "Fix", and the view
also shows the full message starting with "Fix".

**Evidence:** Every single entry on page 1 has this double-word pattern.

**Fix:** Strip the matched prefix from the displayed message in the service. After
categorizing, remove the leading keyword:
```ruby
# In fetch_from_github, after categorizing:
clean_message = strip_category_prefix(raw_message, category)

# New private method:
def strip_category_prefix(message, category)
  patterns = {
    fix: /\AFix\s*/i,
    feature: /\AAdd\s*/i,
    improve: /\A(?:Rebuild|Modernize|Refactor|Extract)\s*/i,
    polish: /\A(?:Polish|Pixel-perfect polish:|Visual|Clean)\s*/i,
    update: /\A(?:Update|Show|Move|Reduce|Clarify|Vendor|Rename)\s*/i
  }
  pattern = patterns[category]
  pattern ? message.sub(pattern, '') : message
end
```

The `:update` category needs its own stripping too since it's the `else` fallback — those
messages start with verbs like "Show", "Move", "Reduce" which ARE the useful description.
For `:update`, don't strip — the verb IS the message.

Simpler approach: Only strip when the category keyword literally matches the first word:
```ruby
def strip_category_prefix(message, category)
  keyword_map = {
    fix: /\AFix\b\s*/i,
    feature: /\AAdd\b\s*/i,
    improve: /\A(?:Rebuild|Modernize|Refactor|Extract)\b\s*/i,
    polish: /\A(?:Polish|Pixel-perfect\s+polish:?\s*|Visual|Clean)\b\s*/i
  }
  pattern = keyword_map[category]
  return message unless pattern
  cleaned = message.sub(pattern, '')
  # Capitalize first letter after stripping
  cleaned.sub(/\A\w/) { |c| c.upcase }
end
```

For `:update` (the else fallback), don't strip anything — those messages are already
descriptive verbs.

**Files:** `app/services/github_changelog_service.rb`

---

### 3. Internal/noise commits visible to users — SHOULD-FIX

**Problem:** Commits like these are meaningless to site visitors:
- "Update builder/planner memory and add review plans"
- "Update persona memory files"
- "Update CLAUDE.md: remove stale architecture/risk sections"
- "Add test-run guardrails to Deployer persona"

These are developer housekeeping, not site changes.

**Fix:** Filter out noise commits in the service after fetching. Use a skip-list of patterns:
```ruby
SKIP_PATTERNS = [
  /persona memory/i,
  /planner memory/i,
  /builder memory/i,
  /deployer memory/i,
  /shared\.md/i,
  /CLAUDE\.md/i,
  /memory files/i,
  /\AUpdate memory/i,
  /\AMerge branch/i,
  /\AMerge pull request/i
]

def self.skip_commit?(message)
  SKIP_PATTERNS.any? { |pattern| message.match?(pattern) }
end
```

Apply the filter before building the commits array. This means some pages might have fewer
than 20 entries, which is fine — it's better than padding with noise.

**Important consideration:** The filter happens after the GitHub API returns 20 commits per
page. If several commits on a page are filtered, that page will be shorter. This is acceptable
— the alternative (fetching extra to compensate) adds complexity for minimal gain. The
pagination still works correctly with GitHub's cursor.

**Files:** `app/services/github_changelog_service.rb`

---

### 4. Mis-categorization of non-user-facing commits — SHOULD-FIX

**Problem:** The `categorize()` regex is too broad. "Add request specs" → `:feature` (because
it starts with "Add"). "Add test-run guardrails" → `:feature`. These aren't features.

**Fix:** If noise filtering (item #3) is implemented, most of these get filtered out. For the
remaining edge cases, add test/spec/internal detection before the main categorization:
```ruby
def categorize(message)
  return :update if message.match?(/\b(?:spec|test|rspec)\b/i) && !message.match?(/\bfix\b/i)
  # ... existing patterns
end
```

This ensures "Add request specs for login" → `:update` (not `:feature`), while
"Fix 500 on solve page" still → `:fix` even if specs were part of the commit.

**Files:** `app/services/github_changelog_service.rb`

---

### 5. Mobile layout untested (CSS wasn't loading) — SUGGESTION

**Problem:** The responsive CSS stacks badge → SHA → message on mobile (`order: 1/2/3`).
But message is more important than SHA on small screens. Once CSS loads, verify the mobile
stacking makes sense.

**Recommended mobile order:** badge → message → SHA (put the content first, technical
reference last).

**Fix:** In `changelog.scss` mobile breakpoint:
```scss
.xw-changelog__badge   { order: 1; }
.xw-changelog__message { order: 2; flex-basis: 100%; }
.xw-changelog__sha     { order: 3; }
```

**Files:** `app/assets/stylesheets/changelog.scss`

---

### 6. Pagination "Newer" disabled state is a plain span — SUGGESTION

**Problem:** The disabled "Newer" text on page 1 is a `<span>` styled to look like a disabled
button. Semantically, it should either be a `<button disabled>` or simply omitted. Currently
the accessibility tree just shows loose text "Newer".

**Fix:** Use `<button disabled>` instead of `<span>` for the disabled page link:
```haml
- if @page > 1
  = link_to 'Newer', changelog_path(page: @page - 1), class: 'xw-changelog__page-link'
- else
  %button.xw-changelog__page-link.xw-changelog__page-link--disabled{disabled: true, type: 'button'} Newer
```

**Files:** `app/views/pages/changelog.html.haml`

---

## Implementation Order

1. **Fix CSS loading** (#1) — instant visual upgrade, zero risk
2. **Strip category prefix** (#2) — fixes every single entry's readability
3. **Filter noise commits** (#3) — removes internal clutter
4. **Fix categorization** (#4) — small tweak, improves accuracy
5. **Mobile stacking** (#5) — verify after CSS loads
6. **Disabled pagination** (#6) — accessibility polish

## Files Touched

| File | Changes |
|------|---------|
| `app/views/pages/changelog.html.haml` | Add `stylesheet_link_tag`, fix disabled pagination element |
| `app/services/github_changelog_service.rb` | Strip prefix, filter noise, fix categorization |
| `app/assets/stylesheets/changelog.scss` | Fix mobile stacking order |
| `spec/requests/pages_changelog_spec.rb` | Update specs for stripped prefixes, filtered commits |

## Acceptance Criteria

- [ ] Timeline renders with visible vertical line, dots, colored badges
- [ ] No entry has doubled category word ("Fix Fix...")
- [ ] Internal commits (memory files, CLAUDE.md, merge commits) are filtered out
- [ ] "Add request specs" is categorized as `:update`, not `:feature`
- [ ] Mobile: badge → message → SHA stacking order
- [ ] Disabled pagination buttons are `<button disabled>`, not `<span>`
- [ ] Existing specs pass; new specs cover prefix stripping and filtering
